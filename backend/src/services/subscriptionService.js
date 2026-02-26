const Subscription = require('../models/Subscription');

const addDays = (date, days) => {
  const next = new Date(date);
  next.setDate(next.getDate() + days);
  return next;
};

class SubscriptionService {
  async createSubscription({
    userId,
    plan_id,
    billing_cycle,
    payment_provider = 'mock',
    payment_token = null,
  }) {
    if (!['weekly', 'monthly'].includes(String(billing_cycle))) {
      throw new Error('billing_cycle must be weekly or monthly');
    }

    const now = new Date();
    const next_billing_date = billing_cycle === 'weekly'
      ? addDays(now, 7)
      : addDays(now, 30);

    const subscription = await Subscription.create({
      user_id: userId,
      plan_id,
      status: 'active',
      billing_cycle,
      next_billing_date,
      payment_provider,
      payment_token,
    });

    return subscription;
  }

  async getUserSubscriptions(userId) {
    return Subscription.find({ user_id: userId }).sort({ created_at: -1 });
  }
}

module.exports = {
  SubscriptionService,
};
