import { Badge, Card } from '@/components/ui/primitives';

const systems = [
  { name: 'Server Health', status: 'Healthy' },
  { name: 'Failed API Calls', status: '12 in last hour' },
  { name: 'Payment Errors', status: '3 unresolved' },
  { name: 'Database Status', status: 'Operational' },
];

export default function MonitoringPage() {
  return (
    <div className="grid" style={{ gridTemplateColumns: '1fr 1fr' }}>
      <Card>
        <h3>System Monitoring</h3>
        {systems.map((s) => (
          <div key={s.name} style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 10 }}>
            <span>{s.name}</span>
            <Badge tone={s.status.includes('Healthy') || s.status.includes('Operational') ? 'success' : 'warning'}>{s.status}</Badge>
          </div>
        ))}
      </Card>
      <Card>
        <h3>Realtime Logs Panel</h3>
        <pre style={{ margin: 0, padding: 12, borderRadius: 12, background: 'rgba(16,18,22,.92)', color: '#d8f9e8', minHeight: 220 }}>
{`[10:22:31] GET /orders 200 34ms
[10:22:45] POST /refund 201 81ms
[10:23:02] webhook/payment-failed 500 20ms`}
        </pre>
      </Card>
    </div>
  );
}
