'use client';

import Link from 'next/link';
import { useState } from 'react';
import { apiRequest } from '@/lib/api';
import { storage } from '@/lib/storage';

type VerifyResponse = {
  data: {
    accessToken: string;
    refreshToken: string;
  };
};

export default function LoginPage() {
  const [phone, setPhone] = useState('');
  const [otp, setOtp] = useState('');
  const [sent, setSent] = useState(false);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  async function sendOtp() {
    setLoading(true);
    setError('');
    try {
      await apiRequest('/auth/send-otp', { method: 'POST', body: { phone } });
      setSent(true);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to send OTP');
    } finally {
      setLoading(false);
    }
  }

  async function verifyOtp() {
    setLoading(true);
    setError('');
    try {
      const response = await apiRequest<VerifyResponse>('/auth/verify-otp', {
        method: 'POST',
        body: { phone, otp },
      });
      storage.setTokens(response.data.accessToken, response.data.refreshToken);
      window.location.href = '/meals';
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to verify OTP');
    } finally {
      setLoading(false);
    }
  }

  return (
    <section className="login-page">
      <div className="login-overlay" />
      <div className="login-card">
        <h1>Welcome Back</h1>
        <p className="muted">Your smart choices start here</p>
        <div className="login-form">
          <input placeholder="Egypt phone number (10 digits)" value={phone} onChange={(e) => setPhone(e.target.value)} />
          {sent ? <input placeholder="OTP" value={otp} onChange={(e) => setOtp(e.target.value)} /> : null}
          {error ? <p className="login-error">{error}</p> : null}
          {!sent ? (
            <button className="btn login-btn" onClick={sendOtp} disabled={loading || phone.length !== 10}>
              {loading ? 'Sending...' : 'Send OTP'}
            </button>
          ) : (
            <button className="btn login-btn" onClick={verifyOtp} disabled={loading || otp.length !== 6}>
              {loading ? 'Verifying...' : 'Verify & Login'}
            </button>
          )}
        </div>
        <p className="muted">New user? <Link href="/signup">Create account</Link></p>
      </div>
    </section>
  );
}
