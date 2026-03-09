const express = require('express');
const { body, validationResult } = require('express-validator');
const User = require('../models/User');
const Address = require('../models/Address');
const AkedlyAuthSession = require('../models/AkedlyAuthSession');
const { generateTokens } = require('../middleware/auth');

const router = express.Router();

router.post(
  '/',
  [
    body('phoneNumber').isString().notEmpty().withMessage('phoneNumber is required'),
    body('firstName').isString().notEmpty().withMessage('firstName is required'),
    body('lastName').isString().notEmpty().withMessage('lastName is required'),
  ],
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ success: false, errors: errors.array() });
      }

      const phoneNumber = String(req.body.phoneNumber || '').trim();
      const firstName = String(req.body.firstName || '').trim();
      const lastName = String(req.body.lastName || '').trim();
      const email = req.body.email ? String(req.body.email).trim().toLowerCase() : undefined;
      const attemptId = String(req.body.attemptId || '').trim();
      const transactionId = String(req.body.transactionId || '').trim();

      if (!attemptId && !transactionId) {
        return res.status(400).json({
          success: false,
          message: 'OTP verification reference is required',
        });
      }

      const sessionQuery = attemptId ? { attemptId } : { transactionId };
      const session = await AkedlyAuthSession.findOne(sessionQuery).sort({ updatedAt: -1 });

      if (!session || (session.status !== 'verified' && session.status !== 'success')) {
        return res.status(403).json({
          success: false,
          message: 'Phone number is not verified',
        });
      }

      if (session.expiresAt && new Date(session.expiresAt).getTime() < Date.now()) {
        return res.status(403).json({
          success: false,
          message: 'OTP session expired. Please verify again',
        });
      }

      const verifiedPhone = String(session.phoneNumber || session.phone || '').trim();
      if (!verifiedPhone || verifiedPhone !== phoneNumber) {
        return res.status(403).json({
          success: false,
          message: 'Verified phone does not match request',
        });
      }

      let user = await User.findOne({
        $or: [{ phone: phoneNumber }, { phoneNumber }],
      });
      const isNewUser = !user;

      if (!user) {
        user = await User.create({
          phone: phoneNumber,
          phoneNumber,
          name: `${firstName} ${lastName}`.trim(),
          email,
          socialProvider: 'phone',
          phoneVerified: true,
          referralCode: `SF${Math.random().toString(36).substring(2, 8).toUpperCase()}`,
          akedlyAttemptId: session.attemptId,
          akedlyTransactionId: session.transactionId,
          isOnboardingComplete: true,
        });

        const rawAddress = req.body.deliveryAddress;
        if (rawAddress && typeof rawAddress === 'object') {
          const governorate = String(rawAddress.governorate || '').trim();
          const area = String(rawAddress.area || '').trim();
          const streetName = String(rawAddress.streetName || '').trim();
          const buildingNumber = String(rawAddress.buildingNumber || '').trim();
          const landmark = String(rawAddress.landmark || '').trim();

          if (governorate && area && streetName && buildingNumber && landmark) {
            await Address.create({
              user: user._id,
              label: String(rawAddress.label || 'home').toLowerCase(),
              governorate,
              area,
              streetName,
              buildingNumber,
              floor: rawAddress.floor ? String(rawAddress.floor) : undefined,
              apartmentNumber: rawAddress.apartmentNumber ? String(rawAddress.apartmentNumber) : undefined,
              landmark,
              deliveryInstructions: rawAddress.deliveryInstructions
                ? String(rawAddress.deliveryInstructions)
                : undefined,
              location: {
                type: 'Point',
                coordinates: [
                  Number(rawAddress.longitude || 0),
                  Number(rawAddress.latitude || 0),
                ],
              },
              isDefault: true,
            });
          }
        }
      }

      if (user.isBlocked) {
        return res.status(403).json({
          success: false,
          message: 'User account is blocked',
        });
      }

      const tokens = generateTokens(user._id);
      user.refreshTokens.push(tokens.refreshToken);
      user.phoneVerified = true;
      await user.save();

      session.status = 'success';
      session.user = user._id;
      session.accessToken = tokens.accessToken;
      session.refreshToken = tokens.refreshToken;
      session.isNewUser = isNewUser;
      await session.save();

      return res.status(201).json({
        success: true,
        data: {
          user: {
            id: user._id,
            phone: user.phone,
            phoneNumber: user.phoneNumber,
            name: user.name,
            email: user.email,
            isOnboardingComplete: user.isOnboardingComplete,
          },
          isNewUser,
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken,
        },
      });
    } catch (error) {
      return res.status(500).json({
        success: false,
        message: error.message,
      });
    }
  },
);

module.exports = router;
