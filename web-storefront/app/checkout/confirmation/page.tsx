import Link from 'next/link';

export default function CheckoutConfirmationPage({
  searchParams,
}: {
  searchParams: {
    orderId?: string;
    paymentStatus?: string;
    orderStatus?: string;
    paymentMethod?: string;
    message?: string;
    referenceCode?: string;
    fakeIban?: string;
  };
}) {
  return (
    <section className="section">
      <h1>Order Confirmation</h1>
      <div className="card">
        <p><strong>Order ID:</strong> {searchParams.orderId || '-'}</p>
        <p><strong>Order Status:</strong> {searchParams.orderStatus || '-'}</p>
        <p><strong>Payment Method:</strong> {searchParams.paymentMethod || '-'}</p>
        <p><strong>Payment Status:</strong> {searchParams.paymentStatus || '-'}</p>
        <p className="muted">{searchParams.message || 'Your order has been received.'}</p>
        {searchParams.referenceCode ? <p><strong>Reference Code:</strong> {searchParams.referenceCode}</p> : null}
        {searchParams.fakeIban ? <p><strong>InstaPay IBAN:</strong> {searchParams.fakeIban}</p> : null}
        <div className="toolbar">
          <Link href="/orders" className="btn">View Orders</Link>
          <Link href="/meals" className="btn secondary">Back to Meals</Link>
        </div>
      </div>
    </section>
  );
}
