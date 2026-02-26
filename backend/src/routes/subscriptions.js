const express = require('express');
const { protect } = require('../middleware/auth');
const { SubscriptionService } = require('../services/subscriptionService');
const { PaymentService } = require('../services/paymentService');

const router = express.Router();
const subscriptionService = new SubscriptionService();
const paymentService = new PaymentService();

router.post('/create', protect, async (req, res) => {
  try {
    const {
      plan_id,
      billing_cycle,
      payment_provider,
      payment_token,
    } = req.body;

    const subscription = await subscriptionService.createSubscription({
      userId: req.user._id,
      plan_id,
      billing_cycle,
      payment_provider,
      payment_token,
    });

    const paymentSession = await paymentService.createSubscriptionPayment(subscription);
    if (paymentSession?.payment_reference) {
      subscription.payment_reference = paymentSession.payment_reference;
      await subscription.save();
    }

    return res.status(201).json({
      success: true,
      data: subscription,
      payment: paymentSession,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

router.get('/user/:id', protect, async (req, res) => {
  try {
    if (String(req.user._id) !== String(req.params.id)) {
      return res.status(403).json({
        success: false,
        message: 'Access denied',
      });
    }

    const subscriptions = await subscriptionService.getUserSubscriptions(req.params.id);

    return res.json({
      success: true,
      data: subscriptions,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

module.exports = router;
