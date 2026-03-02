'use client';

import Link from 'next/link';
import { useEffect, useState } from 'react';
import { apiRequest } from '@/lib/api';
import { storage } from '@/lib/storage';

type PaymentStatusResponse = {
  data: {
    paymentStatus: string;
    webhookConfirmed: boolean;
  };
};

export default function PaymentSuccessPage() {
  const [orderId, setOrderId] = useState('');
  const [loading, setLoading] = useState(true);
  const [confirmed, setConfirmed] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    if (typeof window === 'undefined') return;
    const id = new URLSearchParams(window.location.search).get('orderId') || '';
    setOrderId(id);
  }, []);

  useEffect(() => {
    let cancelled = false;
    let intervalId: ReturnType<typeof setInterval> | undefined;

    const checkStatus = async () => {
      if (!orderId) {
        if (!cancelled) {
          setLoading(false);
          setError('Missing order reference in redirect URL.');
        }
        return;
      }

      try {
        const response = await apiRequest<PaymentStatusResponse>(`/orders/${orderId}/payment-status`);
        const paid = response?.data?.paymentStatus === 'paid' && response?.data?.webhookConfirmed;

        if (cancelled) return;

        setConfirmed(paid);
        setLoading(!paid);

        if (paid) {
          storage.setCart([]);
          if (intervalId) {
            clearInterval(intervalId);
          }
        }
      } catch (e) {
        if (cancelled) return;
        setLoading(false);
        setError(e instanceof Error ? e.message : 'Unable to verify payment status.');
      }
    };

    void checkStatus();
    intervalId = setInterval(() => {
      void checkStatus();
    }, 3000);

    const timeoutId = setTimeout(() => {
      if (!cancelled) {
        setLoading(false);
      }
      if (intervalId) {
        clearInterval(intervalId);
      }
    }, 30000);

    return () => {
      cancelled = true;
      if (intervalId) clearInterval(intervalId);
      clearTimeout(timeoutId);
    };
  }, [orderId]);

  return (
    <section className="payment-result-section payment-result-success">
      <div className="payment-result-card">
        <span className="pill">Payment update</span>
        <h1>{confirmed ? 'Payment Confirmed' : 'Payment Verification'}</h1>
        <p className="payment-result-message">
          {confirmed ? 'Your order is confirmed.' : 'We are verifying your payment with Kashier webhook.'}
        </p>
        {loading ? <p className="muted">Please wait a few seconds...</p> : null}
        {!loading && !confirmed ? <p className="muted">Payment is not confirmed yet. Check your orders shortly.</p> : null}
        {error ? <p style={{ color: '#b42318', margin: 0 }}>{error}</p> : null}
        <div className="toolbar payment-result-actions">
          <Link href="/orders" className="btn">View Orders</Link>
          <Link href="/" className="btn secondary">Return to Home</Link>
        </div>
      </div>
    </section>
  );
}
