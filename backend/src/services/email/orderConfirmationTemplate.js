const formatCurrency = (value) => `EGP ${Number(value || 0).toFixed(2)}`;

const buildItemsRows = (items = []) => items
  .map((item) => `
    <tr>
      <td style="padding:10px 0;border-bottom:1px solid #f1f1f1;color:#111827;">${item.foodName || 'Item'}</td>
      <td style="padding:10px 0;border-bottom:1px solid #f1f1f1;color:#6b7280;text-align:center;">${item.quantity || 1}</td>
      <td style="padding:10px 0;border-bottom:1px solid #f1f1f1;color:#111827;text-align:right;">${formatCurrency(item.totalPrice)}</td>
    </tr>
  `)
  .join('');

const buildOrderConfirmationEmail = ({ order, user, trackOrderUrl }) => {
  const orderDate = new Date(order.createdAt || Date.now()).toLocaleString();

  return {
    subject: `Your SmartApp Order Confirmation – Order #${order.orderNumber || order._id}`,
    html: `
      <div style="margin:0;padding:0;background:#f7f7fb;font-family:Inter,Arial,sans-serif;color:#111827;">
        <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="padding:24px 0;">
          <tr>
            <td align="center">
              <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="max-width:640px;background:#ffffff;border-radius:16px;overflow:hidden;">
                <tr>
                  <td style="padding:24px 28px;background:linear-gradient(135deg,#7C3AED,#A855F7);color:#ffffff;">
                    <div style="font-size:24px;font-weight:700;">SmartApp</div>
                    <div style="margin-top:4px;font-size:14px;opacity:0.9;">Order Confirmation</div>
                  </td>
                </tr>
                <tr>
                  <td style="padding:24px 28px;">
                    <h2 style="margin:0 0 10px;font-size:22px;">Thanks, ${user?.name || 'Valued Customer'}.</h2>
                    <p style="margin:0 0 20px;color:#4b5563;font-size:14px;">Your order has been received successfully.</p>

                    <div style="padding:16px;border:1px solid #ececff;border-radius:12px;background:#fafaff;margin-bottom:20px;">
                      <div style="display:flex;justify-content:space-between;gap:10px;font-size:14px;margin-bottom:8px;"><span>Order Number</span><strong>${order.orderNumber || order._id}</strong></div>
                      <div style="display:flex;justify-content:space-between;gap:10px;font-size:14px;margin-bottom:8px;"><span>Order Date</span><strong>${orderDate}</strong></div>
                      <div style="display:flex;justify-content:space-between;gap:10px;font-size:14px;margin-bottom:8px;"><span>Payment Method</span><strong>${order.paymentMethod}</strong></div>
                      <div style="display:flex;justify-content:space-between;gap:10px;font-size:14px;margin-bottom:8px;"><span>Payment Status</span><strong>${order.paymentStatus}</strong></div>
                      <div style="display:flex;justify-content:space-between;gap:10px;font-size:14px;"><span>Order Status</span><strong>${order.status}</strong></div>
                    </div>

                    <h3 style="margin:0 0 8px;font-size:16px;">Order Summary</h3>
                    <table width="100%" cellspacing="0" cellpadding="0" style="font-size:14px;margin-bottom:12px;">
                      <thead>
                        <tr>
                          <th align="left" style="padding:8px 0;color:#6b7280;border-bottom:1px solid #e5e7eb;">Item</th>
                          <th align="center" style="padding:8px 0;color:#6b7280;border-bottom:1px solid #e5e7eb;">Qty</th>
                          <th align="right" style="padding:8px 0;color:#6b7280;border-bottom:1px solid #e5e7eb;">Price</th>
                        </tr>
                      </thead>
                      <tbody>
                        ${buildItemsRows(order.items)}
                      </tbody>
                    </table>

                    <div style="font-size:14px;margin-bottom:20px;">
                      <div style="display:flex;justify-content:space-between;margin-bottom:4px;"><span style="color:#6b7280;">Subtotal</span><strong>${formatCurrency(order.subtotal)}</strong></div>
                      <div style="display:flex;justify-content:space-between;margin-bottom:4px;"><span style="color:#6b7280;">Delivery Fee</span><strong>${formatCurrency(order.deliveryFee)}</strong></div>
                      <div style="display:flex;justify-content:space-between;margin-bottom:4px;"><span style="color:#6b7280;">Total Amount</span><strong>${formatCurrency(order.total)}</strong></div>
                      <div style="display:flex;justify-content:space-between;"><span style="color:#6b7280;">Estimated Delivery</span><strong>${order.estimatedMinutes || 35} mins</strong></div>
                    </div>

                    <a href="${trackOrderUrl}" style="display:inline-block;background:#7C3AED;color:#ffffff;text-decoration:none;padding:12px 18px;border-radius:10px;font-weight:600;">Track Your Order</a>
                  </td>
                </tr>
                <tr>
                  <td style="padding:16px 28px;background:#f9fafb;color:#6b7280;font-size:12px;">
                    Need help? Contact support at <a href="mailto:support@smartapp.com" style="color:#7C3AED;">support@smartapp.com</a>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
        </table>
      </div>
    `,
  };
};

module.exports = {
  buildOrderConfirmationEmail,
};
