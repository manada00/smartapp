'use client';

import { useCallback, useEffect, useMemo, useState } from 'react';
import { Badge, Button } from '@/components/ui/primitives';
import { hasPermission, type AdminRole } from '@/lib/rbac';

type AdminOrder = {
  _id: string;
  orderNumber?: string;
  status: string;
  paymentMethod: string;
  paymentStatus: string;
  transactionId?: string;
  paymentTimestamp?: string;
  emailDeliveryStatus?: string;
  emailSent?: boolean;
  emailSentAt?: string;
  total: number;
  createdAt: string;
  user?: { name?: string };
  timeline?: { status: string }[];
};

export function OrdersView({ role, initialOrders }: { role: AdminRole; initialOrders: AdminOrder[] }) {
  const [orderList, setOrderList] = useState<AdminOrder[]>(initialOrders);
  const [search, setSearch] = useState('');
  const [status, setStatus] = useState('all');
  const [paymentMethod, setPaymentMethod] = useState('all');
  const [paymentStatus, setPaymentStatus] = useState('all');
  const [emailStatus, setEmailStatus] = useState('all');
  const canRefund = hasPermission(role, 'orders.refund');
  const canDelete = hasPermission(role, 'orders.delete');
  const canOverridePaymentStatus = hasPermission(role, 'orders.overridePaymentStatus');
  const canResendConfirmationEmail = hasPermission(role, 'orders.resendConfirmationEmail');

  const query = useMemo(() => {
    const params = new URLSearchParams();
    if (search) params.set('search', search);
    if (status !== 'all') params.set('status', status);
    if (paymentMethod !== 'all') params.set('paymentMethod', paymentMethod);
    if (paymentStatus !== 'all') params.set('paymentStatus', paymentStatus);
    if (emailStatus !== 'all') params.set('emailStatus', emailStatus);
    params.set('limit', '50');
    return params.toString();
  }, [search, status, paymentMethod, paymentStatus, emailStatus]);

  const fetchOrders = useCallback(async () => {
    const res = await fetch(`/api/admin/orders?${query}`, { cache: 'no-store' });
    if (!res.ok) return;
    const body = await res.json();
    setOrderList(body.data || []);
  }, [query]);

  async function updateStatus(id: string, nextStatus: string) {
    const res = await fetch(`/api/admin/orders/${id}/status`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ status: nextStatus }),
    });

    if (res.ok) fetchOrders();
  }

  async function refundOrder(id: string) {
    if (!window.confirm('Confirm order refund?')) return;
    const res = await fetch(`/api/admin/orders/${id}/refund`, { method: 'POST' });
    if (res.ok) fetchOrders();
  }

  async function overridePaymentStatus(id: string, nextPaymentStatus: string) {
    const res = await fetch(`/api/admin/orders/${id}/payment-status`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ paymentStatus: nextPaymentStatus }),
    });

    if (res.ok) fetchOrders();
  }

  async function deleteOrder(id: string) {
    if (!window.confirm('Delete this order permanently?')) return;
    const res = await fetch(`/api/admin/orders/${id}`, { method: 'DELETE' });
    if (res.ok) fetchOrders();
  }

  async function resendConfirmationEmail(id: string) {
    const res = await fetch(`/api/admin/orders/${id}/resend-confirmation-email`, { method: 'POST' });
    if (res.ok) fetchOrders();
  }

  function exportCsv() {
    const rows = [
      ['Order Number', 'Customer', 'Status', 'Payment', 'Total', 'Created At'],
      ...orderList.map((o) => [
        o.orderNumber || o._id,
        o.user?.name || 'Guest',
        o.status,
        o.paymentMethod,
        String(o.total || 0),
        new Date(o.createdAt).toISOString(),
      ]),
    ];

    const csv = rows.map((row) => row.map((cell) => `"${String(cell).replaceAll('"', '""')}"`).join(',')).join('\n');
    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'orders.csv';
    a.click();
    URL.revokeObjectURL(url);
  }

  useEffect(() => {
    void fetchOrders();
    const interval = window.setInterval(() => {
      void fetchOrders();
    }, 10000);

    return () => {
      window.clearInterval(interval);
    };
  }, [fetchOrders]);

  function statusTone(s: string): 'success' | 'neutral' | 'warning' {
    if (s === 'delivered') return 'success';
    if (s === 'cancelled') return 'warning';
    return 'neutral';
  }

  function nextStatus(s: string) {
    const flow = ['pending', 'confirmed', 'preparing', 'out_for_delivery', 'delivered'];
    const current = flow.indexOf(s);
    return flow[current + 1] || s;
  }

  function displayStatus(s: string) {
    return s.replaceAll('_', ' ');
  }

  function timelineText(order: AdminOrder) {
    return (order.timeline || []).map((t) => t.status.replaceAll('_', ' ')).join(' → ');
  }

  function customerName(order: AdminOrder) {
    return order.user?.name || 'Guest';
  }

  function orderId(order: AdminOrder) {
    return order.orderNumber || order._id;
  }

  function totalValue(order: AdminOrder) {
    return `$${Number(order.total || 0).toFixed(2)}`;
  }

  function paymentLabel(order: AdminOrder) {
    return order.paymentMethod;
  }

  function paymentStatusLabel(order: AdminOrder) {
    return order.paymentStatus.replaceAll('_', ' ');
  }

  function paymentTone(statusValue: string): 'success' | 'neutral' | 'warning' {
    if (statusValue === 'paid') return 'success';
    if (statusValue === 'failed') return 'warning';
    return 'neutral';
  }

  function createdAtLabel(order: AdminOrder) {
    return new Date(order.createdAt).toLocaleString();
  }

  function emailSentAtLabel(order: AdminOrder) {
    return order.emailSentAt ? new Date(order.emailSentAt).toLocaleString() : '—';
  }

  function emailStatusLabel(order: AdminOrder) {
    return (order.emailDeliveryStatus || 'email_pending').replaceAll('_', ' ');
  }

  function emailTone(value?: string): 'success' | 'neutral' | 'warning' {
    if (value === 'email_sent') return 'success';
    if (value === 'email_failed') return 'warning';
    return 'neutral';
  }

  function rowKey(order: AdminOrder) {
    return order._id;
  }

  function canAdvanceStatus(order: AdminOrder) {
    return !['cancelled', 'delivered'].includes(order.status);
  }

  const todayOrdersCount = useMemo(() => {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    return orderList.filter((order) => new Date(order.createdAt) >= today).length;
  }, [orderList]);

  const methodSummary = useMemo(() => {
    return orderList.reduce<Record<string, number>>((acc, order) => {
      acc[order.paymentMethod] = (acc[order.paymentMethod] || 0) + 1;
      return acc;
    }, {});
  }, [orderList]);

  const statusSummary = useMemo(() => {
    return orderList.reduce<Record<string, number>>((acc, order) => {
      acc[order.paymentStatus] = (acc[order.paymentStatus] || 0) + 1;
      return acc;
    }, {});
  }, [orderList]);

  function onStatusAdvance(order: AdminOrder) {
    const target = nextStatus(order.status);
    if (target !== order.status) {
      void updateStatus(order._id, target);
    }
  }

  return (
    <>
      <div className="grid" style={{ gridTemplateColumns: 'repeat(4, minmax(0, 1fr))', marginBottom: 12, gap: 8 }}>
        <Badge tone="neutral">Total orders today: {todayOrdersCount}</Badge>
        <Badge tone="neutral">By method: {Object.entries(methodSummary).map(([m, c]) => `${m} ${c}`).join(' • ') || 'N/A'}</Badge>
        <Badge tone="success">Paid: {statusSummary.paid || 0}</Badge>
        <Badge tone="warning">Pending/Failed: {(statusSummary.pending || 0) + (statusSummary.failed || 0) + (statusSummary.awaiting_transfer || 0)}</Badge>
      </div>

      <div className="toolbar">
        <input placeholder="Search by order ID" value={search} onChange={(e) => setSearch(e.target.value)} />
        <input type="date" />
        <select value={status} onChange={(e) => setStatus(e.target.value)}>
          <option value="all">All statuses</option>
          <option value="pending">Pending</option>
          <option value="confirmed">Confirmed</option>
          <option value="preparing">Preparing</option>
          <option value="out_for_delivery">Out for delivery</option>
          <option value="delivered">Completed</option>
          <option value="cancelled">Cancelled</option>
        </select>
        <select value={paymentMethod} onChange={(e) => setPaymentMethod(e.target.value)}>
          <option value="all">All payment types</option>
          <option value="card">Card</option>
          <option value="instapay">InstaPay</option>
          <option value="cod">Cash on Delivery</option>
        </select>
        <select value={paymentStatus} onChange={(e) => setPaymentStatus(e.target.value)}>
          <option value="all">All payment status</option>
          <option value="paid">Paid</option>
          <option value="pending">Pending</option>
          <option value="failed">Failed</option>
          <option value="awaiting_transfer">Awaiting transfer</option>
        </select>
        <select value={emailStatus} onChange={(e) => setEmailStatus(e.target.value)}>
          <option value="all">All email status</option>
          <option value="email_sent">Email sent</option>
          <option value="email_pending">Email pending</option>
          <option value="email_failed">Email failed</option>
        </select>
        <Button onClick={exportCsv}>Export CSV</Button>
      </div>

      <div className="table-wrap">
        <table>
          <thead>
            <tr>
              <th>ID</th><th>Customer</th><th>Status</th><th>Payment Method</th><th>Payment Status</th><th>Email</th><th>Email Sent At</th><th>Transaction ID</th><th>Total</th><th>Timeline</th><th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {orderList.map((order) => (
              <tr key={rowKey(order)}>
                <td>{orderId(order)}</td>
                <td>{customerName(order)}</td>
                <td><Badge tone={statusTone(order.status)}>{displayStatus(order.status)}</Badge></td>
                <td>{paymentLabel(order)}</td>
                <td><Badge tone={paymentTone(order.paymentStatus)}>{paymentStatusLabel(order)}</Badge></td>
                <td><Badge tone={emailTone(order.emailDeliveryStatus)}>{emailStatusLabel(order)}</Badge></td>
                <td>{emailSentAtLabel(order)}</td>
                <td>{order.transactionId || '—'}</td>
                <td>{totalValue(order)}</td>
                <td className="muted">{timelineText(order) || createdAtLabel(order)}</td>
                <td style={{ display: 'flex', gap: 6 }}>
                  {canAdvanceStatus(order) ? <Button variant="ghost" onClick={() => onStatusAdvance(order)}>Advance Status</Button> : null}
                  {canOverridePaymentStatus ? (
                    <select
                      value={order.paymentStatus}
                      onChange={(e) => {
                        const nextStatus = e.target.value;
                        if (nextStatus !== order.paymentStatus) {
                          void overridePaymentStatus(order._id, nextStatus);
                        }
                      }}
                    >
                      <option value="pending">pending</option>
                      <option value="paid">paid</option>
                      <option value="failed">failed</option>
                      <option value="awaiting_transfer">awaiting_transfer</option>
                      <option value="refunded">refunded</option>
                    </select>
                  ) : null}
                  <Button variant="ghost">Print</Button>
                  {canResendConfirmationEmail ? (
                    <Button variant="ghost" onClick={() => resendConfirmationEmail(order._id)}>Resend Email</Button>
                  ) : null}
                  {canRefund ? <Button onClick={() => refundOrder(order._id)}>Refund</Button> : null}
                  {canDelete ? <Button variant="danger" onClick={() => deleteOrder(order._id)}>Delete</Button> : null}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      <div className="pager">
        <Button variant="ghost">Prev</Button>
        <Button variant="ghost">1</Button>
        <Button variant="ghost">2</Button>
        <Button variant="ghost">Next</Button>
      </div>
      <p className="muted">Connected to shared backend orders API with auto-refresh polling every 10s.</p>
    </>
  );
}
