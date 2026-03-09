const rateLimit = require('express-rate-limit');
const { logSystemEvent } = require('../services/system/systemLogger');

const WINDOW_MS = 60 * 60 * 1000;

const sanitizePhoneKey = (value) => String(value || '')
  .trim()
  .replace(/[\s\-().]/g, '')
  .toLowerCase();

const handleBlockedAttempt = async ({ req, res, limitName, max }) => {
  await logSystemEvent({
    level: 'warning',
    service: 'otp_rate_limiter',
    message: `${limitName} limit exceeded for OTP start (max ${max}/hour)`,
    requestPath: req.originalUrl,
  });

  return res.status(429).json({
    success: false,
    code: 'OTP_RATE_LIMIT_EXCEEDED',
    message: 'Too many OTP attempts. Please try again later.',
  });
};

const otpStartIpLimiter = rateLimit({
  windowMs: WINDOW_MS,
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
  keyGenerator: (req) => `otp:start:ip:${req.ip}`,
  handler: (req, res) => {
    void handleBlockedAttempt({ req, res, limitName: 'ip', max: 10 });
  },
});

const otpStartPhoneLimiter = rateLimit({
  windowMs: WINDOW_MS,
  max: 3,
  standardHeaders: true,
  legacyHeaders: false,
  keyGenerator: (req) => {
    const phoneKey = sanitizePhoneKey(req.body?.phoneNumber);
    return `otp:start:phone:${phoneKey || 'unknown'}`;
  },
  handler: (req, res) => {
    void handleBlockedAttempt({ req, res, limitName: 'phone', max: 3 });
  },
});

module.exports = {
  otpStartIpLimiter,
  otpStartPhoneLimiter,
};
