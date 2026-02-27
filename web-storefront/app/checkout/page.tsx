'use client';

import { useMemo, useState } from 'react';
import { apiRequest } from '@/lib/api';
import { storage } from '@/lib/storage';
import type { CartItem } from '@/lib/types';

type OrderResponse = {
  data: {
    _id: string;
    paymentStatus?: string;
    paymentMethod?: string;
    status?: string;
  };
  payment?: {
    status?: string;
    message?: string;
    referenceCode?: string;
    fakeIban?: string;
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
  const [paymentMethod, setPaymentMethod] = useState<'cod' | 'card' | 'instapay'>('cod');
  const [cardNumber, setCardNumber] = useState('4111111111111111');
  const [cardExpiry, setCardExpiry] = useState('12/30');
  const [cardCvv, setCardCvv] = useState('123');
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
      const response = await apiRequest<OrderResponse>('/orders', {
        method: 'POST',
        body: {
          items: items.map((item) => ({
            food: item.id,
            quantity: item.quantity,
            unitPrice: item.price,
            totalPrice: item.price * item.quantity,
          })),
          deliveryAddress: {
            streetName: address,
            landmark: `${name} | ${phone}`,
          },
          paymentMethod: paymentMethod,
          ...(paymentMethod === 'card' ? {
            cardDetails: {
              number: cardNumber,
              expiry: cardExpiry,
              cvv: cardCvv,
            },
          } : {}),
        },
      });

      storage.setCart<CartItem>([]);
      const query = new URLSearchParams({
        orderId: response?.data?._id || '',
        paymentStatus: response?.payment?.status || response?.data?.paymentStatus || '',
        orderStatus: response?.data?.status || '',
        paymentMethod: response?.data?.paymentMethod || paymentMethod,
        message: response?.payment?.message || 'Order placed successfully.',
        referenceCode: response?.payment?.referenceCode || '',
        fakeIban: response?.payment?.fakeIban || '',
      });
      window.location.href = `/checkout/confirmation?${query.toString()}`;
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
            <h3 style={{ margin: 0 }}>Choose Payment Method</h3>
            <label className="payment-option"><input type="radio" name="payment" checked={paymentMethod === 'cod'} onChange={() => setPaymentMethod('cod')} /> Cash on Delivery</label>
            <label className="payment-option"><input type="radio" name="payment" checked={paymentMethod === 'card'} onChange={() => setPaymentMethod('card')} /> Card (Visa/Mastercard/Meeza)</label>
            <label className="payment-option"><input type="radio" name="payment" checked={paymentMethod === 'instapay'} onChange={() => setPaymentMethod('instapay')} /> InstaPay</label>

            {paymentMethod === 'card' ? (
              <>
                <input placeholder="Card number" value={cardNumber} onChange={(e) => setCardNumber(e.target.value)} />
                <input placeholder="Expiry MM/YY" value={cardExpiry} onChange={(e) => setCardExpiry(e.target.value)} />
                <input placeholder="CVV" value={cardCvv} onChange={(e) => setCardCvv(e.target.value)} />
              </>
            ) : null}

            <strong>Total: {subtotal + 25} EGP</strong>
            <div className="toolbar">
              <button className="btn secondary" onClick={() => setStep('details')}>Back</button>
              <button className="btn" onClick={placeOrder} disabled={submitting || items.length === 0}>
                {submitting ? 'Processing...' : 'Confirm Order'}
              </button>
            </div>
          </div>
        )}

        {error ? <p style={{ color: '#b42318' }}>{error}</p> : null}
      </div>
    </section>
  );
}
