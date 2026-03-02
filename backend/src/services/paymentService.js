const crypto = require('crypto');
const Order = require('../models/Order');
const Subscription = require('../models/Subscription');

const createReference = (prefix) => `${prefix}_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`;
const KASHIER_DEFAULT_BASE_URL = 'https://test-api.kashier.io';
const KASHIER_SESSIONS_PATH = '/v3/payment/sessions';
const KASHIER_HOST_REWRITES = {
  'test-checkout.kashier.io': 'test-api.kashier.io',
  'checkout.kashier.io': 'test-api.kashier.io',
  'payments.kashier.io': 'test-api.kashier.io',
};

const normalizeKashierBaseUrl = (value) => {
  const candidate = String(value || '').trim();
  const withProtocol = candidate
    ? (/^https?:\/\//i.test(candidate) ? candidate : `https://${candidate}`)
    : KASHIER_DEFAULT_BASE_URL;

  try {
    const parsed = new URL(withProtocol);
    const rewrittenHost = KASHIER_HOST_REWRITES[parsed.hostname.toLowerCase()];
    if (rewrittenHost) {
      parsed.hostname = rewrittenHost;
    }

    parsed.pathname = parsed.pathname.replace(/\/+$/, '');
    return `${parsed.origin}${parsed.pathname}`;
  } catch (_error) {
    return KASHIER_DEFAULT_BASE_URL;
  }
};

const normalizeAmountForHash = (value) => {
  const amount = Number(value || 0);
  if (!Number.isFinite(amount)) return '0.00';
  return amount.toFixed(2);
};

const addDays = (date, days) => {
  const next = new Date(date);
  next.setDate(next.getDate() + days);
  return next;
};

class PaymentService {
  constructor({ provider = 'kashier' } = {}) {
    const pickEnv = (...keys) => keys
      .map((key) => process.env[key])
      .find((value) => String(value || '').trim().length > 0) || '';

    this.provider = provider;
    this.merchantId = pickEnv(
      'KASHIER_MERCHANT_ID',
      'KASHIER_MERCHANT',
      'KASHIER_MID',
      'KASHIER_ACCOUNT_ID',
      'MERCHANT_ID',
      'Merchant_ID',
      'KASHIER_MERCHANTID',
    );
    this.apiKey = pickEnv(
      'KASHIER_API_KEY',
      'KASHIER_DEFAULT_TEST_KEY',
      'KASHIER_TEST_API_KEY',
      'KASHIER_PUBLIC_KEY',
      'DEFAULT_TEST_KEY',
      'DEFAULT-TEST-KEY',
      'default-test-key',
      'PAYMENT_API_KEY',
      'PAYMENT_API_KEYS',
      'Payment_API_Key',
      'Payment API Keys',
    );
    this.secret = pickEnv(
      'KASHIER_SECRET',
      'KASHIER_SECRET_KEY',
      'KASHIER_WEBHOOK_SECRET',
      'SECRET_KEY',
      'SECRET_KEYS',
      'Secret Keys',
    );
    if (!this.merchantId && this.secret.includes('$')) {
      this.merchantId = this.secret.split('$')[0].trim();
    }
    this.baseUrl = normalizeKashierBaseUrl(pickEnv('KASHIER_BASE_URL'));
    this.mode = String(pickEnv('KASHIER_MODE') || 'test').trim().toLowerCase() === 'live'
      ? 'live'
      : 'test';
    this.webhookUrl = process.env.KASHIER_WEBHOOK_URL || '';
    this.storefrontBaseUrl = (
      process.env.WEB_STOREFRONT_URL
      || process.env.FRONTEND_BASE_URL
      || process.env.WEBSITE_BASE_URL
      || ''
    ).replace(/\/$/, '');
    this.successRedirectUrl = process.env.KASHIER_SUCCESS_REDIRECT_URL
      || (this.storefrontBaseUrl ? `${this.storefrontBaseUrl}/payment-success` : '');
    this.failureRedirectUrl = process.env.KASHIER_FAILURE_REDIRECT_URL
      || (this.storefrontBaseUrl ? `${this.storefrontBaseUrl}/payment-failed` : '');
  }

  async createOneTimePayment(order, options = {}) {
    const redirectUrls = {
      success: options.redirectUrls?.success || this.successRedirectUrl,
      failure: options.redirectUrls?.failure || this.failureRedirectUrl,
    };

    const orderId = String(order._id);
    const amount = Number(order.total || 0);
    const amountString = normalizeAmountForHash(amount);
    const currency = order.currency || 'EGP';
    const customer = this._buildCustomerPayload({
      id: options.customer?.id || order.user_id || order.user,
      email: options.customer?.email || order.userEmail,
    });
    const metaData = encodeURIComponent(JSON.stringify({
      type: 'one_time',
      order_id: String(order._id),
    }));
    const expireAt = new Date(Date.now() + (30 * 60 * 1000)).toISOString();

    const payload = {
      expireAt,
      maxFailureAttempts: 3,
      paymentType: 'credit',
      merchantId: this.merchantId,
      mode: this.mode,
      amount: amountString,
      currency,
      orderId,
      customer,
      description: `SmartApp one-time order ${orderId}`,
      merchantRedirect: redirectUrls.success,
      failureRedirect: true,
      display: 'en',
      type: 'external',
      allowedMethods: 'card',
      ...(this.webhookUrl ? { serverWebhook: this.webhookUrl } : {}),
      metaData,
      interactionSource: 'ECOMMERCE',
    };

    const response = await this._createKashierPaymentSession(payload);

    return {
      success: true,
      provider: this.provider,
      payment_reference: orderId,
      payment_url: response.payment_url,
      status: 'pending',
      message: 'Kashier one-time payment session created',
    };
  }

  async createSubscriptionPayment(subscription, options = {}) {
    const orderId = String(subscription._id);
    const amount = Number(subscription.initial_amount || 0);
    const amountString = normalizeAmountForHash(amount);
    const currency = subscription.currency || 'EGP';
    const customer = this._buildCustomerPayload({
      id: options.customer?.id || subscription.user_id,
      email: options.customer?.email,
    });
    const metaData = encodeURIComponent(JSON.stringify({
      type: 'subscription',
      subscription_id: String(subscription._id),
      billing_cycle: subscription.billing_cycle,
    }));
    const expireAt = new Date(Date.now() + (30 * 60 * 1000)).toISOString();

    const payload = {
      expireAt,
      maxFailureAttempts: 3,
      paymentType: 'credit',
      merchantId: this.merchantId,
      mode: this.mode,
      amount: amountString,
      currency,
      orderId,
      customer,
      description: `SmartApp subscription ${orderId}`,
      merchantRedirect: this.successRedirectUrl,
      failureRedirect: true,
      display: 'en',
      type: 'external',
      allowedMethods: 'card',
      ...(this.webhookUrl ? { serverWebhook: this.webhookUrl } : {}),
      metaData,
      interactionSource: 'ECOMMERCE',
    };

    const response = await this._createKashierPaymentSession(payload);

    return {
      success: true,
      provider: this.provider,
      payment_reference: orderId,
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
      normalizedPayload.orderId
      || normalizedPayload.order_id
      || normalizedPayload.merchantOrderId
      || normalizedPayload.merchant_reference
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

  async _createKashierPaymentSession(payload) {
    if (!(process && process.versions && process.versions.node)) {
      throw new Error('Kashier payment session creation must run in Node.js server runtime');
    }

    if (!this.baseUrl || !this.merchantId || !this.apiKey || !this.secret) {
      const missing = [];
      if (!this.merchantId) missing.push('KASHIER_MERCHANT_ID');
      if (!this.apiKey) missing.push('KASHIER_API_KEY');
      if (!this.secret) missing.push('KASHIER_SECRET');
      if (!this.baseUrl) missing.push('KASHIER_BASE_URL');
      throw new Error(`Kashier configuration is missing: ${missing.join(', ')}`);
    }

    const requestPaymentSession = async (endpoint) => {
      const authorizationHeader = String(this.secret || '').trim();

      const response = await fetch(endpoint, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'api-key': this.apiKey,
          Authorization: authorizationHeader,
        },
        body: JSON.stringify(payload),
      });

      return response;
    };

    const baseCandidate = this.baseUrl.replace(/\/$/, '');
    const fallbackBaseCandidate = normalizeKashierBaseUrl(KASHIER_DEFAULT_BASE_URL).replace(/\/$/, '');
    const endpointCandidates = Array.from(new Set([
      `${baseCandidate}${KASHIER_SESSIONS_PATH}`,
      `${fallbackBaseCandidate}${KASHIER_SESSIONS_PATH}`,
    ]));

    let response;
    const attempts = [];

    for (const candidate of endpointCandidates) {
      try {
        const current = await requestPaymentSession(candidate);
        attempts.push(`${candidate} => ${current.status}`);

        if (current.status !== 404) {
          response = current;
          break;
        }
      } catch (error) {
        attempts.push(`${candidate} => network_error:${error.message}`);
      }
    }

    if (!response) {
      throw new Error(`Unable to reach Kashier session endpoint. Attempts: ${attempts.join(' | ')}`);
    }

    const rawBody = await response.text().catch(() => '');
    const body = (() => {
      try {
        return rawBody ? JSON.parse(rawBody) : {};
      } catch (_error) {
        return {};
      }
    })();

    if (!response.ok) {
      const providerMessage = body?.message
        || body?.error
        || body?.errors?.[0]?.message
        || rawBody.slice(0, 220)
        || '';
      throw new Error(`Failed to create Kashier payment session (${response.status})${providerMessage ? `: ${providerMessage}` : ''}`);
    }

    const paymentUrl = body.sessionUrl
      || body.session_url
      || body.data?.sessionUrl
      || body.data?.session_url
      || body.result?.sessionUrl
      || body.result?.session_url
      || body.url
      || body.redirect_url
      || body.checkout_url
      || body.paymentLink
      || body.data?.payment_url
      || body.data?.url
      || body.data?.redirect_url
      || body.data?.checkout_url
      || body.data?.paymentLink
      || body.nextAction?.url
      || null;

    if (!paymentUrl) {
      throw new Error('Kashier session created but no sessionUrl/checkout URL was returned');
    }

    return {
      payment_url: paymentUrl,
      raw: body,
    };
  }

  _buildCustomerPayload(input = {}) {
    const email = String(input.email || '').trim() || 'customer@smartapp.app';
    const reference = String(input.id || '').trim() || createReference('customer');

    return {
      reference,
      email,
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
