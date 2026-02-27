'use client';

import { useState } from 'react';
import { apiRequest } from '@/lib/api';

const plans = [
  { id: 'high-protein-weekly', title: 'High Protein', description: 'Performance-focused weekly meals.' },
  { id: 'keto-monthly', title: 'Keto', description: 'Low-carb premium keto rotation.' },
  { id: 'weight-loss-monthly', title: 'Weight Loss', description: 'Calorie-aware meals for steady progress.' },
];

export default function SubscriptionsPage() {
  const [loadingPlan, setLoadingPlan] = useState('');
  const [error, setError] = useState('');

  async function subscribe(planId: string) {
    setError('');
    setLoadingPlan(planId);
    try {
      const response = await apiRequest<{ payment?: { payment_url?: string } }>('/subscriptions/create', {
        method: 'POST',
        body: {
          plan_id: planId,
          billing_cycle: 'monthly',
          payment_provider: 'kashier',
        },
      });
      if (response?.payment?.payment_url) {
        window.location.href = response.payment.payment_url;
      }
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Unable to subscribe');
    } finally {
      setLoadingPlan('');
    }
  }

  return (
    <section className="section">
      <h1>Subscriptions</h1>
      <p className="muted">Managed by the same backend and admin console.</p>
      {error ? <p style={{ color: '#b42318' }}>{error}</p> : null}
      <div className="grid cols-3">
        {plans.map((plan) => (
          <div key={plan.id} className="card">
            <h3>{plan.title}</h3>
            <p className="muted">{plan.description}</p>
            <button className="btn" onClick={() => subscribe(plan.id)} disabled={loadingPlan === plan.id}>
              {loadingPlan === plan.id ? 'Starting...' : 'Choose Plan'}
            </button>
          </div>
        ))}
      </div>
    </section>
  );
}
