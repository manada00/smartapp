const Order = require('../models/Order');

const ORDER_TRANSITIONS = {
  pending: ['paid', 'cancelled'],
  paid: ['delivered'],
  cancelled: [],
  delivered: [],
};

const ALLOWED_PAYMENT_METHODS = ['cod', 'card', 'mobile_wallet', 'fawry', 'instapay', 'wallet'];

const createReference = (prefix) => `${prefix}_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`;

const canTransition = (from, to) => {
  const allowed = ORDER_TRANSITIONS[from] || [];
  return allowed.includes(to);
};

class OrderService {
  async createOneTimeOrder({
    userId,
    items = [],
    subtotal = 0,
    delivery_fee = 0,
    currency = 'EGP',
    payment_method = 'card',
    payment_provider = 'mock',
  }) {
    const normalizedPaymentMethod = ALLOWED_PAYMENT_METHODS.includes(String(payment_method))
      ? String(payment_method)
      : 'card';

    const normalizedItems = items.map((item) => ({
      product_id: item.product_id || item.food || null,
      name: String(item.name || item.foodName || 'Item'),
      quantity: Number(item.quantity || 1),
      price: Number(item.price || item.unitPrice || 0),
      food: item.product_id || item.food || null,
      foodName: String(item.name || item.foodName || 'Item'),
      unitPrice: Number(item.price || item.unitPrice || 0),
      totalPrice: Number(item.totalPrice || (Number(item.quantity || 1) * Number(item.price || item.unitPrice || 0))),
    }));

    const computedSubtotal = Number(subtotal) || normalizedItems.reduce((sum, item) => sum + Number(item.totalPrice || 0), 0);
    const computedDeliveryFee = Number(delivery_fee || 0);
    const total = computedSubtotal + computedDeliveryFee;

    const order = await Order.create({
      user: userId,
      user_id: userId,
      items: normalizedItems,
      subtotal: computedSubtotal,
      deliveryFee: computedDeliveryFee,
      delivery_fee: computedDeliveryFee,
      total,
      currency,
      paymentMethod: normalizedPaymentMethod,
      order_type: 'one_time',
      status: 'pending',
      payment_status: 'pending',
      paymentStatus: 'pending',
      payment_provider,
      payment_reference: createReference('order'),
      paymentReferenceCode: undefined,
      timeline: [{
        status: 'pending',
        message: 'Order created and awaiting payment',
        timestamp: new Date(),
      }],
    });

    return order;
  }

  async transitionOrderState({ order, nextStatus, reason }) {
    if (!canTransition(order.status, nextStatus)) {
      throw new Error(`Invalid order status transition: ${order.status} -> ${nextStatus}`);
    }

    order.status = nextStatus;
    if (nextStatus === 'paid') {
      order.payment_status = 'paid';
      order.paymentStatus = 'paid';
      order.paymentTimestamp = new Date();
    }

    if (nextStatus === 'cancelled' && order.payment_status === 'pending') {
      order.payment_status = 'failed';
      order.paymentStatus = 'failed';
    }

    order.timeline = order.timeline || [];
    order.timeline.push({
      status: nextStatus,
      message: reason || `Order moved to ${nextStatus}`,
      timestamp: new Date(),
    });

    await order.save();
    return order;
  }
}

module.exports = {
  OrderService,
  ORDER_TRANSITIONS,
};
