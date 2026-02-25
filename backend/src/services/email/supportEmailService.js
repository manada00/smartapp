const { Resend } = require('resend');

const getResendClient = () => {
  const apiKey = process.env.RESEND_API_KEY;
  if (!apiKey) return null;
  return new Resend(apiKey);
};

const sendSupportReplyEmail = async ({ to, subject, message }) => {
  if (!to) {
    return { success: false, error: 'Recipient email is required' };
  }

  const resend = getResendClient();
  if (!resend) {
    return { success: false, error: 'Email provider is not configured' };
  }

  try {
    const response = await resend.emails.send({
      from: process.env.EMAIL_FROM || 'SmartApp Support <support@smartapp.com>',
      to,
      subject,
      html: `<div style="font-family:Arial,sans-serif;line-height:1.6"><p>${String(message).replace(/\n/g, '<br/>')}</p></div>`,
    });

    return {
      success: true,
      providerMessageId: response?.data?.id || null,
    };
  } catch (error) {
    return { success: false, error: error.message };
  }
};

module.exports = { sendSupportReplyEmail };
