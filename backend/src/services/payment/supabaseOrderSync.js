const { getSupabaseClient } = require('../../config/supabase');

const PAYMENT_METHOD_MAP = {
  cod: 'cash_on_delivery',
  card: 'card',
  instapay: 'instapay',
};

const extractId = (value) => {
  if (!value) return '';
  if (typeof value === 'string') return value;
  if (value._id) return String(value._id);
  if (value.id) return String(value.id);
  return String(value);
};

const syncOrderPaymentToSupabase = async (order) => {
  const client = getSupabaseClient();
  if (!client) return;

  const userId = extractId(order.user);

  const payload = {
    order_id: String(order._id),
    user_id: userId,
    user_email: order.userEmail || null,
    order_items: order.items || [],
    total_amount: Number(order.total || 0),
    payment_method: PAYMENT_METHOD_MAP[order.paymentMethod] || order.paymentMethod,
    payment_status: order.paymentStatus,
    transaction_id: order.transactionId || null,
    payment_timestamp: order.paymentTimestamp || null,
    order_status: order.status,
    created_at: order.createdAt || new Date(),
    email_sent: Boolean(order.emailSent),
    email_sent_at: order.emailSentAt || null,
    email_delivery_status: order.emailDeliveryStatus || 'email_pending',
  };

  const { error } = await client.from('orders').upsert(payload, { onConflict: 'order_id' });
  if (error) {
    throw new Error(`Supabase sync failed: ${error.message}`);
  }
};

module.exports = {
  syncOrderPaymentToSupabase,
};
