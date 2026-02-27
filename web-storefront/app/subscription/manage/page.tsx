import Link from 'next/link';

export default function ManageSubscriptionPage() {
  return (
    <section className="section">
      <h1>Manage Subscription</h1>
      <div className="card">
        <p>Subscription lifecycle is powered by the same backend and payment system.</p>
        <Link href="/subscriptions" className="btn">Back to Plans</Link>
      </div>
    </section>
  );
}
