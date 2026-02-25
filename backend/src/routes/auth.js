const express = require('express');
const { body, validationResult } = require('express-validator');
const { OAuth2Client } = require('google-auth-library');
const User = require('../models/User');
const { generateTokens, protect } = require('../middleware/auth');
const { verifyFirebaseIdToken } = require('../config/firebase_admin');

const router = express.Router();
const googleOAuthClient = new OAuth2Client();

const getGoogleAudiences = () => {
  const fromEnv = (process.env.GOOGLE_CLIENT_IDS || '')
    .split(',')
    .map((id) => id.trim())
    .filter(Boolean);

  return fromEnv;
};

const verifyGoogleIdToken = async (idToken) => {
  const audiences = getGoogleAudiences();
  const ticket = await googleOAuthClient.verifyIdToken({
    idToken,
    audience: audiences.length > 0 ? audiences : undefined,
  });
  const payload = ticket.getPayload();

  if (!payload?.sub) {
    throw new Error('Invalid Google ID token');
  }

  return {
    uid: payload.sub,
    email: payload.email,
    name: payload.name,
    picture: payload.picture,
    phone_number: payload.phone_number,
  };
};

// Store OTPs temporarily (use Redis in production)
const otpStore = new Map();

// Send OTP
router.post('/send-otp', [
  body('phone').matches(/^(10|11|12|15)\d{8}$/).withMessage('Invalid Egyptian phone number'),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ success: false, errors: errors.array() });
    }

    const { phone } = req.body;
    
    // Generate OTP (fixed in development for easier testing)
    const otp = process.env.NODE_ENV === 'development'
      ? '123456'
      : Math.floor(100000 + Math.random() * 900000).toString();
    
    // Store OTP with expiry (5 minutes)
    otpStore.set(phone, {
      otp,
      expiresAt: Date.now() + 5 * 60 * 1000,
    });

    // TODO: Send OTP via Twilio
    console.log(`OTP for ${phone}: ${otp}`);

    res.json({
      success: true,
      message: 'OTP sent successfully',
      ...(process.env.NODE_ENV === 'development' ? { debugOtp: otp } : {}),
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// Verify OTP
router.post('/verify-otp', [
  body('phone').matches(/^(10|11|12|15)\d{8}$/).withMessage('Invalid phone number'),
  body('otp').isLength({ min: 6, max: 6 }).withMessage('OTP must be 6 digits'),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ success: false, errors: errors.array() });
    }

    const { phone, otp } = req.body;
    
    // Verify OTP
    const storedOtp = otpStore.get(phone);
    
    if (!storedOtp || storedOtp.otp !== otp || storedOtp.expiresAt < Date.now()) {
      return res.status(400).json({
        success: false,
        message: 'Invalid or expired OTP',
      });
    }

    // Clear OTP
    otpStore.delete(phone);

    // Find or create user
    let user = await User.findOne({ phone: `+20${phone}` });
    const isNewUser = !user;

    if (!user) {
      user = await User.create({
        phone: `+20${phone}`,
        socialProvider: 'phone',
        referralCode: `SF${Math.random().toString(36).substring(2, 8).toUpperCase()}`,
      });
    }

    if (user.isBlocked) {
      return res.status(403).json({
        success: false,
        message: 'User account is blocked',
      });
    }

    // Generate tokens
    const tokens = generateTokens(user._id);

    // Store refresh token
    user.refreshTokens.push(tokens.refreshToken);
    await user.save();

    res.json({
      success: true,
      message: 'Verification successful',
      data: {
        user: {
          id: user._id,
          phone: user.phone,
          name: user.name,
          isOnboardingComplete: user.isOnboardingComplete,
        },
        isNewUser,
        ...tokens,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// Social login (Google/Apple)
router.post('/social', [
  body('provider')
    .isIn(['google', 'apple'])
    .withMessage('Unsupported social provider'),
  body('idToken').notEmpty().withMessage('idToken is required'),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ success: false, errors: errors.array() });
    }

    const { provider, idToken } = req.body;

    let decodedToken;
    let isFirebaseToken = false;

    try {
      decodedToken = await verifyFirebaseIdToken(idToken);
      isFirebaseToken = true;
    } catch (error) {
      if (provider === 'google') {
        decodedToken = await verifyGoogleIdToken(idToken);
      } else {
        throw error;
      }
    }

    if (isFirebaseToken) {
      const firebaseProvider = decodedToken.firebase?.sign_in_provider;
      const providerMap = {
        google: 'google.com',
        apple: 'apple.com',
      };

      if (providerMap[provider] !== firebaseProvider) {
        return res.status(400).json({
          success: false,
          message: `Token provider mismatch. Expected ${provider}.`,
        });
      }
    }

    let user = await User.findOne({ firebaseUid: decodedToken.uid });

    if (!user && decodedToken.email) {
      user = await User.findOne({ email: decodedToken.email });
    }

    const isNewUser = !user;

    if (!user) {
      user = await User.create({
        firebaseUid: decodedToken.uid,
        socialProvider: provider,
        email: decodedToken.email,
        name: decodedToken.name,
        profileImage: decodedToken.picture,
        phone: decodedToken.phone_number,
        referralCode: `SF${Math.random().toString(36).substring(2, 8).toUpperCase()}`,
      });
    } else {
      user.firebaseUid = user.firebaseUid || decodedToken.uid;
      user.socialProvider = provider;
      user.email = user.email || decodedToken.email;
      user.name = user.name || decodedToken.name;
      user.profileImage = user.profileImage || decodedToken.picture;
    }

    if (user.isBlocked) {
      return res.status(403).json({
        success: false,
        message: 'User account is blocked',
      });
    }

    const tokens = generateTokens(user._id);
    user.refreshTokens.push(tokens.refreshToken);
    await user.save();

    res.json({
      success: true,
      message: 'Social login successful',
      data: {
        user: {
          id: user._id,
          phone: user.phone,
          name: user.name,
          email: user.email,
          profileImage: user.profileImage,
          isOnboardingComplete: user.isOnboardingComplete,
        },
        isNewUser,
        ...tokens,
      },
    });
  } catch (error) {
    res.status(401).json({
      success: false,
      message: error.message || 'Social login failed',
    });
  }
});

// Refresh token
router.post('/refresh', async (req, res) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(400).json({
        success: false,
        message: 'Refresh token required',
      });
    }

    const decoded = require('jsonwebtoken').verify(refreshToken, process.env.JWT_SECRET);
    const user = await User.findById(decoded.id);

    if (!user || !user.refreshTokens.includes(refreshToken)) {
      return res.status(401).json({
        success: false,
        message: 'Invalid refresh token',
      });
    }

    if (user.isBlocked) {
      return res.status(403).json({
        success: false,
        message: 'User account is blocked',
      });
    }

    // Remove old refresh token
    user.refreshTokens = user.refreshTokens.filter(t => t !== refreshToken);

    // Generate new tokens
    const tokens = generateTokens(user._id);
    user.refreshTokens.push(tokens.refreshToken);
    await user.save();

    res.json({
      success: true,
      ...tokens,
    });
  } catch (error) {
    res.status(401).json({
      success: false,
      message: 'Invalid refresh token',
    });
  }
});

// Logout
router.post('/logout', protect, async (req, res) => {
  try {
    const { refreshToken } = req.body;
    
    if (refreshToken) {
      req.user.refreshTokens = req.user.refreshTokens.filter(t => t !== refreshToken);
      await req.user.save();
    }

    res.json({
      success: true,
      message: 'Logged out successfully',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

module.exports = router;
