import Link from 'next/link';

export default function SignupPage() {
  return (
    <section className="section">
      <h1>Sign up</h1>
      <div className="card">
        <p>Account creation uses the same phone OTP flow and backend as mobile.</p>
        <Link href="/login" className="btn">Continue with Phone OTP</Link>
      </div>
    </section>
  );
}
