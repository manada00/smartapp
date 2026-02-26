const crypto = require('crypto');
const Order = require('../models/Order');
const Subscription = require('../models/Subscription');

const createReference = (prefix) => `${prefix}_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`;

const addDays = (date, days) => {
  const next = new Date(date);
  next.setDate(next.getDate() + days);
  return next;
};

class PaymentService {
  constructor({ provider = 'kashier' } = {}) {
    this.provider = provider;
    this.merchantId = process.env.KASHIER_MERCHANT_ID || '';
    this.apiKey = process.env.KASHIER_API_KEY || '';
    this.secret = process.env.KASHIER_SECRET || '';
    this.baseUrl = process.env.KASHIER_BASE_URL || '';
    this.webhookUrl = process.env.KASHIER_WEBHOOK_URL || '';
    this.successRedirectUrl = process.env.KASHIER_SUCCESS_REDIRECT_URL || '';
    this.failureRedirectUrl = process.env.KASHIER_FAILURE_REDIRECT_URL || '';
  }

  async createOneTimePayment(order) {
    const merchantReference = String(order._id);

    const payload = {
      merchantId: this.merchantId,
      amount: Number(order.total || 0),
      currency: order.currency || 'EGP',
      merchantReference,
      description: `SmartApp one-time order ${merchantReference}`,
      redirectUrls: {
        success: this.successRedirectUrl,
        failure: this.failureRedirectUrl,
      },
      webhookUrl: this.webhookUrl,
      metadata: {
        type: 'one_time',
        order_id: String(order._id),
      },
    };

    const response = await this._createKashierPaymentLink(payload);

    return {
      success: true,
      provider: this.provider,
      payment_reference: merchantReference,
      payment_url: response.payment_url,
      status: 'pending',
      message: 'Kashier one-time payment session created',
    };
  }

  async createSubscriptionPayment(subscription) {
    const merchantReference = String(subscription._id);

    const payload = {
      merchantId: this.merchantId,
      amount: Number(subscription.initial_amount || 0),
      currency: subscription.currency || 'EGP',
      merchantReference,
      description: `SmartApp subscription ${merchantReference}`,
      redirectUrls: {
        success: this.successRedirectUrl,
        failure: this.failureRedirectUrl,
      },
      webhookUrl: this.webhookUrl,
      metadata: {
        type: 'subscription',
        subscription_id: String(subscription._id),
        billing_cycle: subscription.billing_cycle,
      },
    };

    const response = await this._createKashierPaymentLink(payload);

    return {
      success: true,
      provider: this.provider,
      payment_reference: merchantReference,
      payment_url: response.payment_url,
      status: 'pending',
      message: 'Kashier subscription initial payment session created',
    };
  }

  async verifyWebhook(payload, signature) {
    const normalizedPayload = payload || {};
    const expected = crypto
      .createHmac('sha256', this.secret)
      .update(JSON.stringify(normalizedPayload))
      .digest('hex');

    const sanitizedSignature = String(signature || '').replace(/^sha256=/i, '').trim();
    const isValid = Boolean(this.secret)
      && Boolean(sanitizedSignature)
      && sanitizedSignature.length === expected.length
      && crypto.timingSafeEqual(Buffer.from(sanitizedSignature), Buffer.from(expected));

    if (!isValid) {
      return { isValid: false };
    }

    const payment_status = String(
      normalizedPayload.payment_status
      || normalizedPayload.status
      || normalizedPayload.paymentStatus
      || '',
    ).toLowerCase();

    const merchant_reference = String(
      normalizedPayload.merchant_reference
      || normalizedPayload.merchantReference
      || normalizedPayload.reference
      || '',
    );

    const transaction_id = String(
      normalizedPayload.transaction_id
      || normalizedPayload.transactionId
      || normalizedPayload.id
      || '',
    );

    const amount = Number(
      normalizedPayload.amount
      || normalizedPayload.total
      || 0,
    );

    const hasOrderId = /^[0-9a-fA-F]{24}$/.test(merchant_reference);

    return {
      isValid,
      payment_status,
      merchant_reference,
      amount,
      transaction_id,
      payment_provider: 'kashier',
      target_type: normalizedPayload.target_type
        || (normalizedPayload.metadata?.type === 'subscription' ? 'subscription' : 'order'),
      order_id: normalizedPayload.order_id || (hasOrderId ? merchant_reference : undefined),
      subscription_id: normalizedPayload.subscription_id || normalizedPayload.metadata?.subscription_id,
      payload: normalizedPayload,
    };
  }

  async handleSuccessfulPayment(data) {
    const {
      target_type = 'order',
      payment_reference,
      order_id,
      subscription_id,
    } = data;

    if (target_type === 'order') {
      const order = await this._findOrder({ order_id, payment_reference });
      if (!order) {
        return { success: false, message: 'Order not found' };
      }

      if (order.payment_webhook_processed_at) {
        return { success: true, ignored: true, message: 'Duplicate webhook ignored', data: order };
      }

      if (order.payment_status !== 'paid') {
        order.payment_status = 'paid';
      }
      order.paymentStatus = order.payment_status;

      if (order.status === 'pending') {
        order.status = 'paid';
      }

      if (data.transaction_id) {
        order.transactionId = data.transaction_id;
      }

      if (!order.payment_reference && payment_reference) {
        order.payment_reference = payment_reference;
      }
      order.paymentReferenceCode = order.payment_reference;
      order.payment_provider = data.payment_provider || order.payment_provider || this.provider;
      order.payment_webhook_processed_at = new Date();
      await order.save();

      return { success: true, ignored: false, data: order };
    }

    const subscription = await this._findSubscription({ subscription_id, payment_reference });
    if (!subscription) {
      return { success: false, message: 'Subscription not found' };
    }

    if (subscription.last_payment_date && payment_reference && subscription.payment_reference === payment_reference) {
      return { success: true, ignored: true, message: 'Duplicate webhook ignored', data: subscription };
    }

    const now = new Date();
    subscription.status = 'active';
    subscription.last_payment_date = now;
    subscription.payment_provider = data.payment_provider || subscription.payment_provider || this.provider;
    if (payment_reference) {
      subscription.payment_reference = payment_reference;
    }
    subscription.next_billing_date = subscription.billing_cycle === 'weekly'
      ? addDays(now, 7)
      : addDays(now, 30);
    await subscription.save();

    const generatedOrder = await Order.create({
      user: subscription.user_id,
      user_id: subscription.user_id,
      items: data.items || [],
      subtotal: Number(data.subtotal || 0),
      deliveryFee: Number(data.delivery_fee || 0),
      delivery_fee: Number(data.delivery_fee || 0),
      total: Number(data.total || 0),
      currency: data.currency || 'EGP',
      paymentMethod: data.payment_method || 'card',
      order_type: 'subscription',
      status: 'paid',
      payment_status: 'paid',
      paymentStatus: 'paid',
      transactionId: data.transaction_id || undefined,
      payment_provider: subscription.payment_provider,
      payment_reference: payment_reference || createReference('subpay'),
      paymentReferenceCode: payment_reference || undefined,
      timeline: [{
        status: 'paid',
        message: 'Generated from subscription recurring billing',
        timestamp: now,
      }],
    });

    return { success: true, ignored: false, data: { subscription, order: generatedOrder } };
  }

  async handleFailedPayment(data) {
    const {
      target_type = 'order',
      payment_reference,
      order_id,
      subscription_id,
    } = data;

    if (target_type === 'order') {
      const order = await this._findOrder({ order_id, payment_reference });
      if (!order) {
        return { success: false, message: 'Order not found' };
      }

      if (order.payment_webhook_processed_at) {
        return { success: true, ignored: true, message: 'Duplicate webhook ignored', data: order };
      }

      order.payment_status = 'failed';
      order.paymentStatus = 'failed';
      if (order.status === 'pending') {
        order.status = 'cancelled';
      }
      if (data.transaction_id) {
        order.transactionId = data.transaction_id;
      }
      if (!order.payment_reference && payment_reference) {
        order.payment_reference = payment_reference;
      }
      order.payment_provider = data.payment_provider || order.payment_provider || this.provider;
      order.payment_webhook_processed_at = new Date();
      await order.save();

      return { success: true, ignored: false, data: order };
    }

    const subscription = await this._findSubscription({ subscription_id, payment_reference });
    if (!subscription) {
      return { success: false, message: 'Subscription not found' };
    }

    subscription.status = 'paused';
    subscription.payment_provider = data.payment_provider || subscription.payment_provider || this.provider;
    if (payment_reference) {
      subscription.payment_reference = payment_reference;
    }
    await subscription.save();

    return { success: true, ignored: false, data: subscription };
  }

  async _createKashierPaymentLink(payload) {
    if (!this.baseUrl || !this.merchantId || !this.apiKey) {
      throw new Error('Kashier configuration is missing');
    }

    const endpoint = `${this.baseUrl.replace(/\/$/, '')}/payments/link`;
    const response = await fetch(endpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': this.apiKey,
      },
      body: JSON.stringify(payload),
    });

    const body = await response.json().catch(() => ({}));
    if (!response.ok) {
      throw new Error('Failed to create Kashier payment link');
    }

    return {
      payment_url: body.payment_url || body.url || body.data?.payment_url || body.data?.url || null,
      raw: body,
    };
  }

  async _findOrder({ order_id, payment_reference }) {
    if (order_id) {
      return Order.findById(order_id);
    }

    if (payment_reference) {
      return Order.findOne({ payment_reference });
    }

    return null;
  }

  async _findSubscription({ subscription_id, payment_reference }) {
    if (subscription_id) {
      return Subscription.findById(subscription_id);
    }

    if (payment_reference) {
      return Subscription.findOne({ payment_reference });
    }

    return null;
  }
}

module.exports = {
  PaymentService,
};
