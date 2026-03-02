const express = require('express');
const { PaymentService } = require('../services/paymentService');
const User = require('../models/User');
const AkedlyAuthSession = require('../models/AkedlyAuthSession');
const { generateTokens } = require('../middleware/auth');
const { normalizeEgyptPhoneToE164 } = require('../utils/phone');

const router = express.Router();
const paymentService = new PaymentService();
const AKEDLY_SESSION_TTL_MS = 15 * 60 * 1000;

const createReferralCode = () => `SF${Math.random().toString(36).substring(2, 8).toUpperCase()}`;

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

router.post('/akedly', async (req, res) => {
  const payload = req.body || {};

  const status = String(
    payload.status
    || payload.eventStatus
    || payload.event_status
    || '',
  ).toLowerCase();

  const attemptId = String(
    payload.attemptId
    || payload.attempt_id
    || payload.attempt?.id
    || '',
  ).trim();

  const transactionId = String(
    payload.transactionId
    || payload.transaction_id
    || payload.transaction?.id
    || payload.id
    || '',
  ).trim();

  const upsertSession = async (updates) => {
    const filters = [];
    if (attemptId) filters.push({ attemptId });
    if (transactionId) filters.push({ transactionId });

    const payload = {
      ...(attemptId ? { attemptId } : {}),
      ...(transactionId ? { transactionId } : {}),
      ...updates,
      expiresAt: new Date(Date.now() + AKEDLY_SESSION_TTL_MS),
    };

    if (filters.length === 0) {
      await AkedlyAuthSession.create(payload);
      return;
    }

    await AkedlyAuthSession.findOneAndUpdate(
      { $or: filters },
      { $set: payload },
      { upsert: true, new: true, setDefaultsOnInsert: true },
    );
  };

  try {
    if (status === 'success') {
      const normalizedPhone = normalizeEgyptPhoneToE164(
        payload.phoneNumber
          || payload.phone
          || payload.customer?.phone
          || payload.user?.phone
          || '',
      );

      let user = await User.findOne({ phone: normalizedPhone });
      const isNewUser = !user;

      if (!user) {
        user = await User.create({
          phone: normalizedPhone,
          socialProvider: 'phone',
          phoneVerified: true,
          referralCode: createReferralCode(),
          akedlyAttemptId: attemptId || undefined,
          akedlyTransactionId: transactionId || undefined,
        });
      }

      if (user.isBlocked) {
        await upsertSession({
          phone: normalizedPhone,
          status: 'failed',
          payload: {
            ...payload,
            reason: 'USER_BLOCKED',
          },
        });
        return res.status(200).json({ success: true });
      }

      user.phoneVerified = true;
      if (attemptId) user.akedlyAttemptId = attemptId;
      if (transactionId) user.akedlyTransactionId = transactionId;

      const tokens = generateTokens(user._id);
      user.refreshTokens = [...(user.refreshTokens || []), tokens.refreshToken].slice(-10);
      await user.save();

      await upsertSession({
        phone: normalizedPhone,
        status: 'success',
        user: user._id,
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        isNewUser,
        payload,
      });
    } else {
      if (status === 'failed') {
        console.warn(`Akedly OTP failed for attempt ${attemptId || 'unknown'} and transaction ${transactionId || 'unknown'}`);
      }

      await upsertSession({
        status: status === 'failed' ? 'failed' : 'pending',
        payload,
      });
    }
  } catch (error) {
    console.error(`Akedly webhook processing error: ${error.message}`);
  }

  return res.status(200).json({ success: true });
});

module.exports = router;
