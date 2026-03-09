'use client';

import { useMemo, useState } from 'react';
import { useSearchParams } from 'next/navigation';
import { apiRequest } from '@/lib/api';
import { storage } from '@/lib/storage';

type CreateUserResponse = {
  data?: {
    accessToken?: string;
    refreshToken?: string;
  };
};

export default function SignupPage() {
  const searchParams = useSearchParams();
  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [email, setEmail] = useState('');
  const [deliveryAddress, setDeliveryAddress] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const phoneNumber = useMemo(() => searchParams.get('phoneNumber') || '', [searchParams]);
  const attemptId = useMemo(() => searchParams.get('attemptId') || '', [searchParams]);
  const transactionId = useMemo(() => searchParams.get('transactionId') || '', [searchParams]);

  const canSubmit =
    firstName.trim().length > 0
    && lastName.trim().length > 0
    && phoneNumber.length > 0
    && attemptId.length > 0;

  async function createAccount() {
    if (!canSubmit) return;

    setLoading(true);
    setError('');

    try {
      const response = await apiRequest<CreateUserResponse>('/users', {
        method: 'POST',
        token: null,
        body: {
          phoneNumber,
          firstName: firstName.trim(),
          lastName: lastName.trim(),
          email: email.trim() || undefined,
          attemptId,
          transactionId: transactionId || undefined,
          deliveryAddress: deliveryAddress.trim()
            ? {
                governorate: 'Cairo',
                area: 'Cairo',
                streetName: deliveryAddress.trim(),
                buildingNumber: 'N/A',
                landmark: 'N/A',
                label: 'home',
              }
            : undefined,
        },
      });

      if (!response.data?.accessToken || !response.data?.refreshToken) {
        throw new Error('Invalid account creation response');
      }

      storage.setTokens(response.data.accessToken, response.data.refreshToken);
      window.location.replace('/meals');
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Unable to create account');
    } finally {
      setLoading(false);
    }
  }

  if (!phoneNumber || !attemptId) {
    return (
      <section className="section">
        <div className="card">
          <h1>Create account</h1>
          <p className="muted">Missing OTP verification context. Please start from login.</p>
          <a className="btn" href="/login">Back to login</a>
        </div>
      </section>
    );
  }

  return (
    <section className="section">
      <div className="card" style={{ maxWidth: 520, margin: '0 auto' }}>
        <h1>Create your account</h1>
        <p className="muted">Verified phone: {phoneNumber}</p>
        <div className="login-form">
          <input
            placeholder="First name"
            value={firstName}
            onChange={(e) => setFirstName(e.target.value)}
          />
          <input
            placeholder="Last name"
            value={lastName}
            onChange={(e) => setLastName(e.target.value)}
          />
          <input
            placeholder="Email (optional)"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
          />
          <input
            placeholder="Delivery address (optional)"
            value={deliveryAddress}
            onChange={(e) => setDeliveryAddress(e.target.value)}
          />
          {error ? <p className="login-error">{error}</p> : null}
          <button className="btn login-btn" onClick={createAccount} disabled={loading || !canSubmit}>
            {loading ? 'Creating...' : 'Create My Account'}
          </button>
        </div>
      </div>
    </section>
  );
}
