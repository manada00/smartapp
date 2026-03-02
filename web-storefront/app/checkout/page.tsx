'use client';

import { useMemo, useState } from 'react';
import { apiRequest } from '@/lib/api';
import { storage } from '@/lib/storage';
import type { CartItem } from '@/lib/types';

type OrderResponse = {
  data: {
    _id: string;
  };
  payment?: {
    payment_url?: string;
  };
};

type VerifyResponse = {
  data: {
    accessToken: string;
    refreshToken: string;
  };
};

export default function CheckoutPage() {
  const [name, setName] = useState('');
  const [address, setAddress] = useState('');
  const [phone, setPhone] = useState('');
  const [otp, setOtp] = useState('');
  const [otpSent, setOtpSent] = useState(false);
  const [authLoading, setAuthLoading] = useState(false);
  const [isAuthenticated, setIsAuthenticated] = useState(() => Boolean(storage.getAccessToken()));
  const [step, setStep] = useState<'details' | 'payment'>('details');
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState('');
  const items = storage.getCart<CartItem>();

  const subtotal = useMemo(
    () => items.reduce((sum, item) => sum + item.price * item.quantity, 0),
    [items],
  );

  async function sendOtp() {
    setAuthLoading(true);
    setError('');
    try {
      await apiRequest('/auth/send-otp', { method: 'POST', body: { phone } });
      setOtpSent(true);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to send OTP');
    } finally {
      setAuthLoading(false);
    }
  }

  async function verifyOtp() {
    setAuthLoading(true);
    setError('');
    try {
      const response = await apiRequest<VerifyResponse>('/auth/verify-otp', {
        method: 'POST',
        body: { phone, otp },
      });
      storage.setTokens(response.data.accessToken, response.data.refreshToken);
      setIsAuthenticated(true);
      if (name.trim()) {
        await apiRequest('/user/profile', { method: 'PUT', body: { name: name.trim() } });
      }
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to verify OTP');
    } finally {
      setAuthLoading(false);
    }
  }

  function continueToPayment() {
    if (!name.trim() || !address.trim() || phone.trim().length !== 10) {
      setError('Please complete name, address, and 10-digit phone first.');
      return;
    }
    if (!isAuthenticated) {
      setError('Please verify OTP first to continue.');
      return;
    }
    setError('');
    setStep('payment');
  }

  async function placeOrder() {
    setSubmitting(true);
    setError('');
    try {
      const origin = window.location.origin.replace(/\/$/, '');
      const response = await apiRequest<OrderResponse>('/orders/create', {
        method: 'POST',
        body: {
          items: items.map((item) => ({
            food: item.id,
            quantity: item.quantity,
            unitPrice: item.price,
            totalPrice: item.price * item.quantity,
            name: item.name,
            price: item.price,
          })),
          subtotal,
          delivery_fee: 25,
          currency: 'EGP',
          payment_method: 'card',
          payment_provider: 'kashier',
          delivery_address: {
            streetName: address,
            landmark: `${name} | ${phone}`,
          },
          redirect_urls: {
            success: `${origin}/payment-success`,
            failure: `${origin}/payment-failed`,
          },
        },
      });

      if (!response?.payment?.payment_url) {
        throw new Error('Unable to start payment session. Please try again.');
      }

      window.location.href = response.payment.payment_url;
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Checkout failed');
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <section className="section">
      <h1>Checkout</h1>
      <div className="card">
        <p className="muted">Step 1: user details + login verification. Step 2: payment method. Step 3: confirmation.</p>

        {step === 'details' ? (
          <div className="grid">
            <input placeholder="Full name" value={name} onChange={(e) => setName(e.target.value)} />
            <input placeholder="Delivery address" value={address} onChange={(e) => setAddress(e.target.value)} />
            <input placeholder="Egypt phone number (10 digits)" value={phone} onChange={(e) => setPhone(e.target.value)} />

            {!isAuthenticated ? (
              <>
                {!otpSent ? (
                  <button className="btn secondary" onClick={sendOtp} disabled={authLoading || phone.length !== 10}>
                    {authLoading ? 'Sending OTP...' : 'Send OTP'}
                  </button>
                ) : (
                  <>
                    <input placeholder="Enter OTP" value={otp} onChange={(e) => setOtp(e.target.value)} />
                    <button className="btn secondary" onClick={verifyOtp} disabled={authLoading || otp.length !== 6}>
                      {authLoading ? 'Verifying...' : 'Verify OTP'}
                    </button>
                  </>
                )}
              </>
            ) : <p className="muted">Logged in and verified.</p>}

            <strong>Subtotal: {subtotal} EGP</strong>
            <strong>Delivery: 25 EGP</strong>
            <strong>Total: {subtotal + 25} EGP</strong>
            <button className="btn" onClick={continueToPayment} disabled={items.length === 0}>Continue to Payment</button>
          </div>
        ) : (
          <div className="grid">
            <h3 style={{ margin: 0 }}>Pay with Card (Kashier)</h3>
            <p className="muted" style={{ margin: 0 }}>
              You will be securely redirected to Kashier hosted checkout to complete payment.
            </p>

            <strong>Total: {subtotal + 25} EGP</strong>
            <div className="toolbar">
              <button className="btn secondary" onClick={() => setStep('details')}>Back</button>
              <button className="btn" onClick={placeOrder} disabled={submitting || items.length === 0}>
                {submitting ? 'Redirecting...' : 'Pay'}
              </button>
            </div>
          </div>
        )}

        {error ? <p style={{ color: '#b42318' }}>{error}</p> : null}
      </div>
    </section>
  );
}
