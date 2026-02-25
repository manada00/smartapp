'use client';

import { useState } from 'react';
import { Badge, Button, Card } from '@/components/ui/primitives';

type ReportData = {
  range: string;
  from: string;
  to: string;
  totalSales: number;
  totalOrders: number;
  returnedOrders: number;
  casesOrMessagesSent: number;
  repeatPurchaseRate: number;
  topItems: Array<{ itemId: string; name: string; quantity: number; revenue: number }>;
  lowPerformanceItems: Array<{ itemId: string; name: string; quantity: number; revenue: number }>;
  salesByPeriod: Array<{ label: string; orders: number; sales: number }>;
};

export function ReportsView({ initialData }: { initialData: ReportData }) {
  const [range, setRange] = useState(initialData.range || 'daily');
  const [data, setData] = useState<ReportData>(initialData);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function generate() {
    setLoading(true);
    setError(null);
    const res = await fetch(`/api/admin/reports?range=${range}`);
    const body = await res.json().catch(() => null);
    setLoading(false);

    if (!res.ok || !body?.success) {
      setError(body?.message || 'Failed to generate report');
      return;
    }

    setData(body.data as ReportData);
  }

  return (
    <div className="grid">
      <Card>
        <h3>Reports & Analytics</h3>
        <div className="toolbar">
          <select value={range} onChange={(e) => setRange(e.target.value)}>
            <option value="daily">Daily</option>
            <option value="weekly">Weekly</option>
            <option value="monthly">Monthly</option>
          </select>
          <Button onClick={() => void generate()}>{loading ? 'Generating...' : 'Generate Report'}</Button>
        </div>
        {error ? <p className="muted" style={{ color: '#b42318' }}>{error}</p> : null}
        <p className="muted">Window: {new Date(data.from).toLocaleString()} - {new Date(data.to).toLocaleString()}</p>
      </Card>

      <div className="grid" style={{ gridTemplateColumns: 'repeat(6, minmax(0, 1fr))' }}>
        <Card><h3>Total Sales</h3><p>${Number(data.totalSales || 0).toFixed(2)}</p></Card>
        <Card><h3>Total Orders</h3><p>{data.totalOrders}</p></Card>
        <Card><h3>Returned Orders</h3><p>{data.returnedOrders}</p></Card>
        <Card><h3>Cases/Messages</h3><p>{data.casesOrMessagesSent}</p></Card>
        <Card><h3>Repeat Purchase Rate</h3><p>{Number(data.repeatPurchaseRate || 0).toFixed(2)}%</p></Card>
        <Card><h3>Period</h3><Badge tone="neutral">{data.range}</Badge></Card>
      </div>

      <div className="grid" style={{ gridTemplateColumns: '1fr 1fr' }}>
        <Card>
          <h3>Top 10 Items</h3>
          <div style={{ display: 'grid', gap: 8 }}>
            {data.topItems.map((item) => (
              <div key={`${item.itemId}-top`} style={{ display: 'flex', justifyContent: 'space-between' }}>
                <span>{item.name}</span>
                <span>{item.quantity} sold · ${Number(item.revenue || 0).toFixed(2)}</span>
              </div>
            ))}
          </div>
        </Card>

        <Card>
          <h3>Low Performance Items</h3>
          <div style={{ display: 'grid', gap: 8 }}>
            {data.lowPerformanceItems.map((item) => (
              <div key={`${item.itemId}-low`} style={{ display: 'flex', justifyContent: 'space-between' }}>
                <span>{item.name}</span>
                <span>{item.quantity} sold · ${Number(item.revenue || 0).toFixed(2)}</span>
              </div>
            ))}
          </div>
        </Card>
      </div>

      <Card>
        <h3>Sales Trend</h3>
        <div style={{ display: 'grid', gap: 8 }}>
          {data.salesByPeriod.map((point) => (
            <div key={point.label} style={{ display: 'flex', justifyContent: 'space-between' }}>
              <span>{point.label}</span>
              <span>{point.orders} orders · ${Number(point.sales || 0).toFixed(2)}</span>
            </div>
          ))}
        </div>
      </Card>
    </div>
  );
}
