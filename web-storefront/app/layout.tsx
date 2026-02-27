import './globals.css';
import type { Metadata } from 'next';
import Link from 'next/link';
import type { ReactNode } from 'react';

export const metadata: Metadata = {
  title: 'SmartApp Web',
  description: 'SmartApp premium food ordering platform',
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <body>
        <header className="top-nav">
          <div className="container nav-inner">
            <Link href="/" className="brand">SmartApp</Link>
            <nav className="nav-links">
              <Link href="/meals">Meals</Link>
              <Link href="/guided">Help Me Choose</Link>
              <Link href="/subscriptions">Subscriptions</Link>
              <Link href="/orders">Orders</Link>
              <Link href="/cart">Cart</Link>
              <Link href="/login">Login</Link>
            </nav>
          </div>
        </header>
        <main className="container">{children}</main>
      </body>
    </html>
  );
}
