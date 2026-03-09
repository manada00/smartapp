const express = require('express');
const axios = require('axios');
const { body, validationResult } = require('express-validator');
const { OAuth2Client } = require('google-auth-library');
const User = require('../models/User');
const AkedlyAuthSession = require('../models/AkedlyAuthSession');
const { generateTokens, protect } = require('../middleware/auth');
const { otpStartIpLimiter, otpStartPhoneLimiter } = require('../middleware/otpRateLimiter');
const { verifyFirebaseIdToken } = require('../config/firebase_admin');
const { normalizeEgyptPhoneToE164 } = require('../utils/phone');
const {
  generateAkedlySignature,
  normalizePhoneNumber,
} = require('../utils/akedly');

const router = express.Router();
const googleOAuthClient = new OAuth2Client();
const devOtpBypassEnabled = String(process.env.OTP_BYPASS_ENABLED || '').toLowerCase() === 'true';
const devOtpBypassCode = String(process.env.OTP_BYPASS_CODE || '123456');
const AKEDLY_CREATE_ATTEMPT_URL = `${String(process.env.AKEDLY_API_URL || 'https://api.akedly.io').replace(/\/$/, '')}/api/v1/widget-sdk/create-attempt`;
const AKEDLY_SESSION_TTL_MS = 15 * 60 * 1000;
const AKEDLY_ERROR_MAP = {
  INVALID_SIGNATURE: { statusCode: 400, message: 'Signature error' },
  SIGNATURE_EXPIRED: { statusCode: 400, message: 'Request expired' },
  INVALID_API_KEY: { statusCode: 401, message: 'Invalid API key' },
  INVALID_PUBLIC_KEY: { statusCode: 400, message: 'Widget misconfigured' },
  WIDGET_INACTIVE: { statusCode: 503, message: 'Widget disabled' },
  RATE_LIMIT_PHONENUMBER_ATTEMPTS: { statusCode: 429, message: 'Too many attempts' },
  CIRCUIT_BREAKER_OPEN: { statusCode: 503, message: 'Service temporarily unavailable' },
};

const createReferralCode = () => `SF${Math.random().toString(36).substring(2, 8).toUpperCase()}`;

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

router.post('/otp/start', [
  otpStartIpLimiter,
  otpStartPhoneLimiter,
  body('phoneNumber').isString().notEmpty().withMessage('phoneNumber is required'),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ success: false, errors: errors.array() });
    }

    const apiKey = String(process.env.AKEDLY_API_KEY || '').trim();
    const publicKey = String(process.env.AKEDLY_PUBLIC_KEY || '').trim();
    const secret = String(process.env.AKEDLY_SECRET || '').trim();

    if (!apiKey || !publicKey || !secret) {
      const missing = [];
      if (!apiKey) missing.push('AKEDLY_API_KEY');
      if (!publicKey) missing.push('AKEDLY_PUBLIC_KEY');
      if (!secret) missing.push('AKEDLY_SECRET');

      return res.status(500).json({
        success: false,
        message: `Akedly configuration is missing: ${missing.join(', ')}`,
      });
    }

    let phoneNumber;
    try {
      phoneNumber = normalizePhoneNumber(req.body.phoneNumber);
    } catch (error) {
      return res.status(400).json({
        success: false,
        message: error.message || 'Invalid phoneNumber format',
      });
    }

    const timestamp = Date.now();
    const signature = generateAkedlySignature({
      apiKey,
      publicKey,
      secret,
      timestamp,
      phoneNumber,
    });

    const requestBody = {
      apiKey,
      publicKey,
      signature,
      timestamp,
      verificationAddress: {
        phoneNumber,
      },
      digits: 6,
    };

    console.log('[Akedly OTP Start Request Body]', requestBody);

    let providerBody;
    let statusCode = 502;

    for (let attempt = 0; attempt < 2; attempt += 1) {
      try {
        const providerResponse = await axios.post(AKEDLY_CREATE_ATTEMPT_URL, requestBody, {
          timeout: 10000,
        });
        providerBody = providerResponse.data || {};
        statusCode = providerResponse.status;
        break;
      } catch (error) {
        const timedOut = error?.code === 'ECONNABORTED' || /timeout/i.test(String(error?.message || ''));
        if (timedOut && attempt === 0) {
          continue;
        }

        statusCode = error?.response?.status || 502;
        providerBody = error?.response?.data || {};
        if (!providerBody || Object.keys(providerBody).length === 0) {
          providerBody = { error: { code: timedOut ? 'REQUEST_TIMEOUT' : 'AKEDLY_START_FAILED' } };
        }
        break;
      }
    }

    if (statusCode >= 400 || providerBody.success === false) {
      console.error('[Akedly OTP Start Error]', {
        statusCode,
        code: providerBody?.code || providerBody?.errorCode || providerBody?.error?.code,
        message: providerBody?.message || providerBody?.error?.message,
        response: providerBody,
      });

      const providerCode = String(
        providerBody.code
        || providerBody.errorCode
        || providerBody.error?.code
        || '',
      ).toUpperCase();

      const mappedError = AKEDLY_ERROR_MAP[providerCode];
      if (mappedError) {
        return res.status(mappedError.statusCode).json({
          success: false,
          code: providerCode,
          message: mappedError.message,
        });
      }

      return res.status(502).json({
        success: false,
        code: providerCode || 'AKEDLY_START_FAILED',
        message: 'Unable to start OTP verification',
      });
    }

    const iframeUrl = String(
      providerBody.iframeUrl
      || providerBody.iframe_url
      || providerBody.widgetUrl
      || providerBody.data?.iframeUrl
      || providerBody.data?.iframe_url
      || providerBody.data?.widgetUrl
      || '',
    ).trim();

    const attemptId = String(
      providerBody.attemptId
      || providerBody.attempt_id
      || providerBody.widgetAttempt?.attemptId
      || providerBody.widgetAttempt?.attempt_id
      || providerBody.data?.attemptId
      || providerBody.data?.attempt_id
      || providerBody.id
      || '',
    ).trim();

    const expiresAtRaw = providerBody.expiresAt
      || providerBody.expires_at
      || providerBody.data?.expiresAt
      || providerBody.data?.expires_at;
    const expiresAt = expiresAtRaw ? new Date(expiresAtRaw) : new Date(Date.now() + AKEDLY_SESSION_TTL_MS);

    if (!iframeUrl || !attemptId) {
      return res.status(502).json({
        success: false,
        code: 'AKEDLY_INVALID_RESPONSE',
        message: 'Akedly did not return iframeUrl and attemptId',
      });
    }

    await AkedlyAuthSession.findOneAndUpdate(
      { attemptId },
      {
        $set: {
          attemptId,
          phone: phoneNumber,
          status: 'pending',
          metadata: {
            userId: req.body.userId ? String(req.body.userId).trim() : undefined,
            email: req.body.email ? String(req.body.email).trim() : undefined,
          },
          payload: providerBody,
          expiresAt,
        },
      },
      { upsert: true, new: true, setDefaultsOnInsert: true },
    );

    return res.json({
      success: true,
      iframeUrl,
      attemptId,
      expiresAt,
    });
  } catch (error) {
    console.error('[Akedly OTP Start Unexpected Error]', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to start OTP verification',
    });
  }
});

router.get('/otp/test-config', (req, res) => {
  res.json({
    akedly: {
      apiKeyLoaded: Boolean(process.env.AKEDLY_API_KEY),
      publicKeyLoaded: Boolean(process.env.AKEDLY_PUBLIC_KEY),
      secretLoaded: Boolean(process.env.AKEDLY_SECRET),
    },
  });
});

router.get('/otp/session', async (req, res) => {
  try {
    const attemptId = String(req.query.attemptId || '').trim();
    if (!attemptId) {
      return res.status(400).json({
        success: false,
        message: 'attemptId is required',
      });
    }

    const session = await AkedlyAuthSession.findOne({ attemptId }).sort({ updatedAt: -1 });

    if (!session) {
      return res.json({
        success: true,
        status: 'pending',
      });
    }

    if (session.status === 'verified' || session.status === 'success') {
      return res.json({
        success: true,
        status: 'verified',
        data: {
          attemptId: session.attemptId,
          transactionId: session.transactionId,
          phoneNumber: session.phone,
          verifiedAt: session.verifiedAt,
        },
      });
    }

    return res.json({
      success: true,
      status: 'pending',
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Unable to fetch OTP session',
    });
  }
});

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
    const otp = (process.env.NODE_ENV === 'development' || devOtpBypassEnabled)
      ? devOtpBypassCode
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
      ...((process.env.NODE_ENV === 'development' || devOtpBypassEnabled) ? { debugOtp: otp } : {}),
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
    
    const bypassMatch = devOtpBypassEnabled && otp === devOtpBypassCode;

    if (!bypassMatch && (!storedOtp || storedOtp.otp !== otp || storedOtp.expiresAt < Date.now())) {
      return res.status(400).json({
        success: false,
        message: 'Invalid or expired OTP',
      });
    }

    // Clear OTP
    if (storedOtp) {
      otpStore.delete(phone);
    }

    // Find or create user
    let user = await User.findOne({ phone: `+20${phone}` });
    const isNewUser = !user;

    if (!user) {
      user = await User.create({
        phone: `+20${phone}`,
        socialProvider: 'phone',
        referralCode: createReferralCode(),
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
        referralCode: createReferralCode(),
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
