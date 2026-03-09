'use client';

import { useEffect, useState } from 'react';
import { apiRequest } from '@/lib/api';
import { storage } from '@/lib/storage';

type SessionResponse = {
  pending?: boolean;
  failed?: boolean;
  message?: string;
  data?: {
    accessToken: string;
    refreshToken: string;
    isNewUser?: boolean;
    phoneNumber?: string;
    attemptId?: string;
    transactionId?: string;
  };
};

const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

export default function AuthCallbackPage() {
  const [message, setMessage] = useState('Finalizing your login...');

  useEffect(() => {
    let cancelled = false;

    const run = async () => {
      const query = new URLSearchParams(window.location.search);
      const status = (query.get('status') || '').toLowerCase();
      const attemptId = query.get('attemptId') || '';
      const transactionId = query.get('transactionId') || '';

      if (status !== 'success') {
        window.location.replace('/login');
        return;
      }

      if (!attemptId && !transactionId) {
        setMessage('Missing verification reference. Redirecting to login...');
        await sleep(1200);
        window.location.replace('/login');
        return;
      }

      const startedAt = Date.now();
      const timeoutMs = 30_000;

      while (!cancelled && Date.now() - startedAt < timeoutMs) {
        const params = new URLSearchParams();
        if (attemptId) params.set('attemptId', attemptId);
        if (transactionId) params.set('transactionId', transactionId);

        try {
          const session = await apiRequest<SessionResponse>(`/auth/otp/session?${params.toString()}`, {
            method: 'GET',
            token: null,
          });

          if (session.pending) {
            setMessage('Verifying OTP result...');
            await sleep(2000);
            continue;
          }

          if (session.failed) {
            setMessage(session.message || 'Verification failed. Redirecting to login...');
            await sleep(1200);
            window.location.replace('/login');
            return;
          }

          if (session.data?.accessToken && session.data?.refreshToken) {
            storage.setTokens(session.data.accessToken, session.data.refreshToken);
            window.location.replace('/meals');
            return;
          }

          if (session.data?.isNewUser) {
            const signupParams = new URLSearchParams();
            if (session.data.phoneNumber) signupParams.set('phoneNumber', session.data.phoneNumber);
            if (session.data.attemptId || attemptId) {
              signupParams.set('attemptId', session.data.attemptId || attemptId);
            }
            if (session.data.transactionId || transactionId) {
              signupParams.set('transactionId', session.data.transactionId || transactionId);
            }
            window.location.replace(`/signup?${signupParams.toString()}`);
            return;
          }
        } catch (error) {
          const errorText = error instanceof Error ? error.message : 'Unable to complete login';
          setMessage(errorText);
          await sleep(1200);
          window.location.replace('/login');
          return;
        }

        await sleep(2000);
      }

      if (!cancelled) {
        setMessage('Verification timed out. Redirecting to login...');
        await sleep(1200);
        window.location.replace('/login');
      }
    };

    void run();

    return () => {
      cancelled = true;
    };
  }, []);

  return (
    <section className="payment-result-section">
      <div className="payment-result-card">
        <h1>Signing you in</h1>
        <p className="payment-result-message">{message}</p>
      </div>
    </section>
  );
}
