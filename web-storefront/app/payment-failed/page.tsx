'use client';

import Link from 'next/link';
import { useEffect, useState } from 'react';
import { useSearchParams } from 'next/navigation';
import { apiRequest } from '@/lib/api';

type PaymentStatusResponse = {
  data: {
    paymentStatus: string;
    webhookConfirmed: boolean;
  };
};

export default function PaymentFailedPage() {
  const searchParams = useSearchParams();
  const orderId = searchParams.get('orderId');
  const [loading, setLoading] = useState(true);
  const [isPaid, setIsPaid] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    let cancelled = false;

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
        if (cancelled) return;

        const paid = response?.data?.paymentStatus === 'paid' && response?.data?.webhookConfirmed;
        setIsPaid(paid);
      } catch (e) {
        if (cancelled) return;
        setError(e instanceof Error ? e.message : 'Unable to verify payment status.');
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
      }
    };

    void checkStatus();

    return () => {
      cancelled = true;
    };
  }, [orderId]);

  return (
    <section className="payment-result-section payment-result-failed">
      <div className="payment-result-card">
        <span className="pill">Payment update</span>
        <h1>{isPaid ? 'Payment Confirmed' : 'Payment Failed'}</h1>
        <p className="payment-result-message">
          {isPaid ? 'Kashier webhook confirmed your payment.' : 'Payment is not confirmed. Please try again.'}
        </p>
        {loading ? <p className="muted">Checking payment status...</p> : null}
        {!loading && !isPaid ? <p className="muted">No worries, your order remains unpaid until webhook confirmation.</p> : null}
        {error ? <p style={{ color: '#b42318', margin: 0 }}>{error}</p> : null}
        <div className="toolbar payment-result-actions">
          <Link href={isPaid ? '/orders' : '/checkout'} className="btn">{isPaid ? 'View Orders' : 'Retry Order'}</Link>
          <Link href="/cart" className="btn secondary">Back to Cart</Link>
        </div>
      </div>
    </section>
  );
}
