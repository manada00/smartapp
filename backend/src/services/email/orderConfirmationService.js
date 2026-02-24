const { Resend } = require('resend');
const { buildOrderConfirmationEmail } = require('./orderConfirmationTemplate');

const getResendClient = () => {
  const apiKey = process.env.RESEND_API_KEY;
  if (!apiKey) return null;
  return new Resend(apiKey);
};

const sendOrderConfirmationEmail = async ({ order, user }) => {
  const recipientEmail = order.userEmail || user?.email;

  if (!recipientEmail) {
    return {
      success: false,
      status: 'email_failed',
      error: 'Recipient email not found',
    };
  }

  const resend = getResendClient();
  if (!resend) {
    return {
      success: false,
      status: 'email_failed',
      error: 'Email provider is not configured',
    };
  }

  const trackBase = process.env.TRACK_ORDER_URL || 'https://smartapp.com/orders';
  const trackOrderUrl = `${trackBase}/${order._id}`;
  const emailPayload = buildOrderConfirmationEmail({ order, user, trackOrderUrl });

  try {
    const response = await resend.emails.send({
      from: process.env.EMAIL_FROM || 'SmartApp <orders@smartapp.com>',
      to: recipientEmail,
      subject: emailPayload.subject,
      html: emailPayload.html,
    });

    return {
      success: true,
      status: 'email_sent',
      providerMessageId: response?.data?.id || null,
      sentAt: new Date(),
      error: null,
    };
  } catch (error) {
    return {
      success: false,
      status: 'email_failed',
      error: error.message,
    };
  }
};

module.exports = {
  sendOrderConfirmationEmail,
};
