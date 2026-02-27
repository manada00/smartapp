'use client';

import { useEffect, useState } from 'react';
import { useParams } from 'next/navigation';
import { apiRequest } from '@/lib/api';

type OrderDetails = {
  _id: string;
  status: string;
  paymentStatus?: string;
  total: number;
  timeline?: Array<{ status: string; message: string; timestamp: string }>;
};

export default function OrderDetailPage() {
  const params = useParams<{ id: string }>();
  const [order, setOrder] = useState<OrderDetails | null>(null);

  useEffect(() => {
    async function load() {
      const response = await apiRequest<{ data: OrderDetails }>(`/orders/${params.id}`);
      setOrder(response.data);
    }
    if (params.id) load();
  }, [params.id]);

  if (!order) return <p className="muted">Loading order...</p>;

  return (
    <section className="section">
      <h1>Order {order._id}</h1>
      <div className="card">
        <p>Status: <strong>{order.status}</strong></p>
        <p>Payment: <strong>{order.paymentStatus || '-'}</strong></p>
        <p>Total: <strong>{order.total} EGP</strong></p>
      </div>
    </section>
  );
}
