'use client';

import Link from 'next/link';
import { storage } from '@/lib/storage';

export default function AccountPage() {
  function logout() {
    storage.clearTokens();
    window.location.href = '/';
  }

  return (
    <section className="section">
      <h1>Account</h1>
      <div className="card">
        <p className="muted">Single SmartApp account across web and mobile.</p>
        <div className="toolbar">
          <Link href="/orders" className="btn secondary">View Orders</Link>
          <Link href="/subscriptions" className="btn secondary">Manage Subscriptions</Link>
          <button className="btn" onClick={logout}>Logout</button>
        </div>
      </div>
    </section>
  );
}
