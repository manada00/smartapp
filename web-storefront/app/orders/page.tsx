'use client';

import { useEffect, useState } from 'react';
import { apiRequest } from '@/lib/api';

type Order = {
  _id: string;
  status: string;
  paymentStatus?: string;
  total: number;
  createdAt: string;
};

export default function OrdersPage() {
  const [orders, setOrders] = useState<Order[]>([]);
  const [error, setError] = useState('');

  useEffect(() => {
    async function loadOrders() {
      try {
        const response = await apiRequest<{ data: Order[] }>('/orders');
        setOrders(response.data || []);
      } catch (e) {
        setError(e instanceof Error ? e.message : 'Failed to load orders');
      }
    }
    loadOrders();
  }, []);

  return (
    <section className="section">
      <h1>Orders</h1>
      {error ? <p style={{ color: '#b42318' }}>{error}</p> : null}
      <div className="card">
        <div className="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Order</th>
                <th>Status</th>
                <th>Payment</th>
                <th>Total</th>
                <th>Date</th>
              </tr>
            </thead>
            <tbody>
              {orders.map((order) => (
                <tr key={order._id}>
                  <td>{order._id}</td>
                  <td>{order.status}</td>
                  <td>{order.paymentStatus || '-'}</td>
                  <td>{order.total} EGP</td>
                  <td>{new Date(order.createdAt).toLocaleString()}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </section>
  );
}
