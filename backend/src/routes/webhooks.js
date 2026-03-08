const express = require('express');
const { PaymentService } = require('../services/paymentService');
const AkedlyAuthSession = require('../models/AkedlyAuthSession');
const { logSystemEvent } = require('../services/system/systemLogger');

const router = express.Router();
const paymentService = new PaymentService();
const AKEDLY_SESSION_TTL_MS = 15 * 60 * 1000;

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
    await logSystemEvent({
      level: 'error',
      service: 'webhook',
      message: `Kashier webhook failed: ${error.message}`,
      stackTrace: error,
    });
    return res.status(500).json({
      success: false,
      message: 'Webhook processing failed',
    });
  }
};

router.post('/kashier', handleKashierWebhook);
router.post('/payment', handleKashierWebhook);

router.post('/akedly', async (req, res) => {
  const payload = req.body;
  if (!payload || typeof payload !== 'object') {
    return res.status(200).json({ received: true });
  }

  const {
    status,
    widgetAttempt = {},
    transaction = {},
    publicMetadata = {},
    privateMetadata = {},
    error = {},
  } = payload;

  const normalizedStatus = String(status || '').toLowerCase();
  const attemptId = String(widgetAttempt.attemptId || widgetAttempt.attempt_id || '').trim();

  console.log('[Akedly Webhook]', {
    status: normalizedStatus || 'unknown',
    attemptId: attemptId || 'unknown',
  });

  try {
    if (normalizedStatus === 'success' || normalizedStatus === 'verified') {
      const transactionId = String(transaction.transactionID || transaction.transactionId || '').trim();
      const phoneNumber = String(
        transaction.verificationAddress?.phoneNumber
        || transaction.verificationAddress?.phone
        || '',
      ).trim();

      if (attemptId) {
        await AkedlyAuthSession.findOneAndUpdate(
          { attemptId },
          {
            $set: {
              attemptId,
              transactionId: transactionId || undefined,
              phone: phoneNumber || undefined,
              status: 'verified',
              verifiedAt: new Date(),
              metadata: {
                publicMetadata,
                privateMetadata,
              },
              payload,
              expiresAt: new Date(Date.now() + AKEDLY_SESSION_TTL_MS),
            },
          },
          { upsert: true, new: true, setDefaultsOnInsert: true },
        );
      }
    } else {
      if (error && Object.keys(error).length > 0) {
        console.warn('[Akedly Webhook Error]', {
          code: error.code,
          message: error.message,
          attemptId: attemptId || 'unknown',
        });
      }

      if (attemptId) {
        await AkedlyAuthSession.findOneAndUpdate(
          { attemptId },
          {
            $set: {
              status: normalizedStatus === 'failed' ? 'failed' : 'pending',
              payload,
              metadata: {
                publicMetadata,
                privateMetadata,
              },
              expiresAt: new Date(Date.now() + AKEDLY_SESSION_TTL_MS),
            },
          },
          { upsert: true, new: true, setDefaultsOnInsert: true },
        );
      }
    }
  } catch (webhookError) {
    console.error('[Akedly Webhook Processing Error]', webhookError);
    await logSystemEvent({
      level: 'error',
      service: 'webhook',
      message: `Akedly webhook failed: ${webhookError.message}`,
      stackTrace: webhookError,
    });
  }

  return res.status(200).json({ received: true });
});

module.exports = router;
