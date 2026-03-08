const crypto = require('crypto');

const generateAkedlySignature = ({
  apiKey,
  publicKey,
  secret,
  timestamp,
  phoneNumber,
}) => {
  const message = JSON.stringify({
    apiKey,
    publicKey,
    timestamp,
    phoneNumber,
  });

  return crypto
    .createHmac('sha256', String(secret || '').trim())
    .update(message)
    .digest('hex');
};

const normalizePhoneNumber = (value) => {
  const raw = String(value || '').trim();
  if (!raw) {
    throw new Error('phoneNumber is required');
  }

  const cleaned = raw
    .replace(/[\s\-().]/g, '')
    .replace(/(?!^)\+/g, '')
    .trim();

  if (!cleaned.startsWith('+')) {
    throw new Error('Phone number must include country code\nExample: +201234567890');
  }

  const normalized = `+${cleaned.slice(1).replace(/\D/g, '')}`;
  if (!/^\+\d{8,15}$/.test(normalized)) {
    throw new Error('Invalid phone number format');
  }

  return normalized;
};

const getSafeTimestamp = () => Date.now();

module.exports = {
  generateAkedlySignature,
  normalizePhoneNumber,
  getSafeTimestamp,
};
