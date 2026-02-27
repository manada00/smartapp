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
    <section className="section cart-luxury-page">
      <div className="cart-luxury-hero">
        <h1>Your Cart</h1>
        <p className="muted">A refined final step before your premium healthy order.</p>
      </div>

      <div className="cart-luxury-grid">
        <div className="card cart-items-card">
          {items.length === 0 ? <p className="muted">Your cart is empty.</p> : null}
          {items.map((item) => (
            <div className="cart-item-row" key={item.id}>
              <div>
                <strong>{item.name}</strong>
                <p className="muted cart-item-price">{item.price} EGP</p>
              </div>
              <div className="cart-qty-controls">
                <button className="btn secondary qty-btn" onClick={() => updateQuantity(item.id, -1)}>-</button>
                <span className="qty-value">{item.quantity}</span>
                <button className="btn secondary qty-btn" onClick={() => updateQuantity(item.id, 1)}>+</button>
              </div>
            </div>
          ))}
        </div>

        <aside className="card cart-summary-card">
          <h3>Order Summary</h3>
          <div className="summary-row">
            <span className="muted">Subtotal</span>
            <strong>{total} EGP</strong>
          </div>
          <div className="summary-row">
            <span className="muted">Delivery</span>
            <strong>Calculated at checkout</strong>
          </div>
          <div className="summary-row total-row">
            <span>Total</span>
            <strong>{total} EGP</strong>
          </div>
          <Link href="/checkout" className="btn cart-checkout-btn">Proceed to Checkout</Link>
        </aside>
      </div>
    </section>
  );
}
