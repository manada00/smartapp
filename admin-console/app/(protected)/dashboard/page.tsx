import { Card, Badge } from '@/components/ui/primitives';
import { fetchAdmin } from '@/lib/backend';

export default async function DashboardPage() {
  const overviewRes = await fetchAdmin('/api/v1/admin/overview');
  const ordersRes = await fetchAdmin('/api/v1/admin/orders?limit=5');
  const menuRes = await fetchAdmin('/api/v1/admin/menu');

  const overview = overviewRes?.data;
  const recentOrders = ordersRes?.data || [];
  const meals = (menuRes?.data || []).slice(0, 5);
  const kpis = [
    { title: 'Total Orders Today', value: String(overview?.totalOrdersToday ?? 0) },
    { title: 'Revenue Today', value: `$${Number(overview?.revenueToday ?? 0).toFixed(2)}` },
    { title: 'Active Users', value: String(overview?.activeUsers ?? 0) },
    { title: 'Pending Orders', value: String(overview?.pendingOrders ?? 0) },
    { title: 'Failed Payments', value: String(overview?.failedPayments ?? 0) },
    { title: 'Low Stock Items', value: String(overview?.lowStockItems ?? 0) },
  ];
  const byMethod = (overview?.ordersByPaymentMethod || []) as { _id: string; count: number }[];
  const byPaymentStatus = (overview?.paymentStatusSummary || []) as { _id: string; count: number }[];

  return (
    <div className="grid">
      <div className="grid kpis">
        {kpis.map((kpi) => (
          <Card key={kpi.title}>
            <p className="muted" style={{ marginTop: 0 }}>{kpi.title}</p>
            <h2 style={{ margin: '2px 0 6px' }}>{kpi.value}</h2>
            <Badge tone="neutral">Live</Badge>
          </Card>
        ))}
      </div>

      <div className="grid" style={{ gridTemplateColumns: '2fr 1fr' }}>
        <Card>
          <h3>Sales trend (Daily / Weekly / Monthly)</h3>
          <div style={{ height: 220, border: '1px dashed var(--border)', borderRadius: 12, padding: 12 }}>
            <p className="muted">Connected to backend; chart layer can consume aggregated admin metrics.</p>
          </div>
        </Card>
        <Card>
          <h3>Orders by category</h3>
          <div style={{ height: 220, border: '1px dashed var(--border)', borderRadius: 12, padding: 12 }}>
            {byMethod.length === 0 ? (
              <p className="muted">No payment method data yet.</p>
            ) : (
              byMethod.map((entry) => (
                <p key={entry._id} className="muted" style={{ marginBottom: 8 }}>
                  {entry._id}: {entry.count}
                </p>
              ))
            )}
          </div>
        </Card>
      </div>

      <Card>
        <h3>Paid vs Pending vs Failed</h3>
        <div style={{ display: 'flex', gap: 12, flexWrap: 'wrap' }}>
          {byPaymentStatus.length === 0 ? (
            <p className="muted">No payment status data yet.</p>
          ) : (
            byPaymentStatus.map((entry) => (
              <Badge key={entry._id} tone={entry._id === 'paid' ? 'success' : entry._id === 'failed' ? 'warning' : 'neutral'}>
                {entry._id}: {entry.count}
              </Badge>
            ))
          )}
        </div>
      </Card>

      <div className="grid" style={{ gridTemplateColumns: '1fr 1fr' }}>
        <Card>
          <h3>Most ordered meals</h3>
          {meals.map((m: { _id: string; name: string; category?: { name?: string } }) => (
            <div key={m._id} style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 10 }}>
              <span>{m.name}</span>
              <Badge tone="neutral">{m.category?.name || 'Uncategorized'}</Badge>
            </div>
          ))}
        </Card>
        <Card>
          <h3>Recent activity feed</h3>
          {recentOrders.map((o: { _id: string; orderNumber?: string; user?: { name?: string }; status: string }) => (
            <div key={o._id} style={{ marginBottom: 10 }}>
              <strong>{o.orderNumber || o._id}</strong> · {o.user?.name || 'Guest'} · <span className="muted">{o.status}</span>
            </div>
          ))}
        </Card>
      </div>
    </div>
  );
}
