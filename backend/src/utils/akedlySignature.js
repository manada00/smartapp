const crypto = require('crypto');

const buildAkedlySignaturePayload = ({
  apiKey,
  publicKey,
  timestamp,
  phoneNumber,
}) => ({
  apiKey: String(apiKey || '').trim(),
  publicKey: String(publicKey || '').trim(),
  timestamp: Number(timestamp),
  phoneNumber: String(phoneNumber || '').trim(),
});

const generateAkedlySignature = (payload, secret) => {
  const signingPayload = buildAkedlySignaturePayload(payload);
  const signingBody = JSON.stringify(signingPayload);

  return crypto
    .createHmac('sha256', String(secret || '').trim())
    .update(signingBody)
    .digest('hex');
};

module.exports = {
  buildAkedlySignaturePayload,
  generateAkedlySignature,
};
