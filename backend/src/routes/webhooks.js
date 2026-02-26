const express = require('express');
const { PaymentService } = require('../services/paymentService');

const router = express.Router();
const paymentService = new PaymentService();

const handleKashierWebhook = async (req, res) => {
  try {
    const payload = req.body || {};
    const signature = req.headers['x-kashier-signature']
      || req.headers['x-payment-signature']
      || req.headers['x-signature']
      || null;

    const verified = await paymentService.verifyWebhook(payload, signature);
    if (!verified.isValid) {
      console.warn('Kashier webhook rejected: invalid signature');
      return res.status(400).json({
        success: false,
        message: 'Invalid webhook signature',
      });
    }

    const eventStatus = String(verified.payment_status || payload.event_status || payload.status || '').toLowerCase();

    let result;
    if (eventStatus === 'success' || eventStatus === 'paid') {
      result = await paymentService.handleSuccessfulPayment(verified);
    } else {
      result = await paymentService.handleFailedPayment(verified);
    }

    return res.status(200).json({
      success: true,
      data: result,
    });
  } catch (error) {
    console.error(`Kashier webhook handling failed: ${error.message}`);
    return res.status(500).json({
      success: false,
      message: 'Webhook processing failed',
    });
  }
};

router.post('/kashier', handleKashierWebhook);
router.post('/payment', handleKashierWebhook);

module.exports = router;
