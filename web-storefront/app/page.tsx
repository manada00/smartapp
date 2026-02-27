import Link from 'next/link';

export default function HomePage() {

  return (
    <>
      <section className="hero">
        <h1>How would you like to order today?</h1>
        <p>Choose your path and switch anytime.</p>
        <div className="entry-grid">
          <Link href="/meals" className="entry-card">
            <h3>I know what I want</h3>
            <p className="muted">Go to full menu browsing with categories, search, filters, and Drinks & Sweets.</p>
          </Link>
          <Link href="/guided" className="entry-card">
            <h3>Help me choose</h3>
            <p className="muted">Use mood cards for SmartScore-based recommendations.</p>
          </Link>
        </div>
      </section>
    </>
  );
}
