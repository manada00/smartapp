'use client';

import Link from 'next/link';
import { useMemo, useState } from 'react';
import { storage } from '@/lib/storage';
import type { CartItem } from '@/lib/types';

export default function CartPage() {
  const [items, setItems] = useState<CartItem[]>(() => storage.getCart<CartItem>());

  const total = useMemo(
    () => items.reduce((sum, item) => sum + item.price * item.quantity, 0),
    [items],
  );

  function updateQuantity(id: string, delta: number) {
    const next = items
      .map((item) => (item.id === id ? { ...item, quantity: Math.max(0, item.quantity + delta) } : item))
      .filter((item) => item.quantity > 0);
    setItems(next);
    storage.setCart(next);
  }

  return (
    <section className="section">
      <h1>Cart</h1>
      <div className="card">
        {items.length === 0 ? <p className="muted">Your cart is empty.</p> : null}
        {items.map((item) => (
          <div className="toolbar" key={item.id}>
            <strong>{item.name}</strong>
            <span className="muted">{item.price} EGP</span>
            <button className="btn secondary" onClick={() => updateQuantity(item.id, -1)}>-</button>
            <span>{item.quantity}</span>
            <button className="btn secondary" onClick={() => updateQuantity(item.id, 1)}>+</button>
          </div>
        ))}
        <h3>Total: {total} EGP</h3>
        <Link href="/checkout" className="btn">Proceed to Checkout</Link>
      </div>
    </section>
  );
}
