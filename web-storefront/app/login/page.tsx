'use client';

import { useState } from 'react';
import { apiRequest } from '@/lib/api';
import { AkedlyWidgetModal } from '@/components/auth/akedly-widget-modal';

type StartOtpResponse = {
  iframeUrl: string;
  attemptId: string;
};

export default function LoginPage() {
  const [phone, setPhone] = useState('');
  const [iframeUrl, setIframeUrl] = useState('');
  const [attemptId, setAttemptId] = useState('');
  const [widgetOpen, setWidgetOpen] = useState(false);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  async function startOtpLogin() {
    setLoading(true);
    setError('');
    try {
      const digitsOnly = phone.replace(/\D/g, '');
      const normalizedPhone = digitsOnly.startsWith('20')
        ? `+${digitsOnly}`
        : `+20${digitsOnly}`;

      const response = await apiRequest<StartOtpResponse>('/auth/otp/start', {
        method: 'POST',
        body: { phoneNumber: normalizedPhone },
      });

      setIframeUrl(response.iframeUrl);
      setAttemptId(response.attemptId);
      setWidgetOpen(true);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to send OTP');
    } finally {
      setLoading(false);
    }
  }

  const canStart = phone.replace(/\D/g, '').length >= 10;

  return (
    <section className="login-page">
      <div className="login-overlay" />
      <div className="login-card">
        <h1>Welcome to SmartApp</h1>
        <p className="muted">Order healthy meals tailored to your mood</p>
        <div className="login-form">
          <input
            placeholder="Egypt phone number (10 digits)"
            value={phone}
            onChange={(e) => setPhone(e.target.value)}
          />
          {error ? <p className="login-error">{error}</p> : null}
          <button className="btn login-btn" onClick={startOtpLogin} disabled={loading || !canStart}>
            {loading ? 'Starting...' : 'Continue'}
          </button>
        </div>
        <p className="muted">Don&apos;t have an account? Continue to create one.</p>
      </div>
      <AkedlyWidgetModal
        open={widgetOpen}
        iframeUrl={iframeUrl}
        onClose={() => setWidgetOpen(false)}
        onResult={(result) => {
          const params = new URLSearchParams();
          params.set('status', result.status);
          if (result.attemptId || attemptId) {
            params.set('attemptId', result.attemptId || attemptId);
          }
          if (result.transactionId) {
            params.set('transactionId', result.transactionId);
          }
          window.location.href = `/auth/callback?${params.toString()}`;
        }}
      />
    </section>
  );
}
