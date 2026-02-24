'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { Card, Button } from '@/components/ui/primitives';

export default function LoginPage() {
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  async function onSubmit(formData: FormData) {
    setLoading(true);
    setError('');
    const res = await fetch('/api/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: formData.get('email'),
        password: formData.get('password'),
      }),
    });

    if (!res.ok) {
      const data = await res.json();
      setError(data.message || 'Invalid credentials');
      setLoading(false);
      return;
    }

    router.replace('/dashboard');
  }

  return (
    <div className="login">
      <Card className="login-card">
        <h2 style={{ marginTop: 0 }}>smartApp Admin Login</h2>
        <p className="muted">Secure access with role-based permissions.</p>
        <form
          action={onSubmit}
          className="grid"
          style={{ marginTop: 14 }}
        >
          <input type="email" name="email" placeholder="Email" required />
          <input type="password" name="password" placeholder="Password" required minLength={8} />
          {error ? <p style={{ color: '#b42318', margin: 0 }}>{error}</p> : null}
          <Button type="submit" variant="primary" disabled={loading}>{loading ? 'Signing in...' : 'Sign in'}</Button>
        </form>
      </Card>
    </div>
  );
}
