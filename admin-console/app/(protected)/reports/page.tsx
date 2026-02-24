import { Card, Button } from '@/components/ui/primitives';

const reportCards = [
  'Daily sales',
  'Monthly revenue',
  'Category performance',
  'Top 10 items',
  'Low-performing items',
  'Customer retention',
  'Repeat purchase rate',
  'Average order value',
];

export default function ReportsPage() {
  return (
    <div className="grid">
      <Card>
        <h3>Reports & Analytics</h3>
        <div className="toolbar">
          <input type="date" />
          <input type="date" />
          <Button>Export CSV</Button>
          <Button>Export PDF</Button>
        </div>
      </Card>
      <div className="grid" style={{ gridTemplateColumns: 'repeat(4, minmax(0, 1fr))' }}>
        {reportCards.map((item) => (
          <Card key={item}>
            <h3>{item}</h3>
            <p className="muted">KPI widgets + trend deltas sourced from Supabase views/materialized reports.</p>
          </Card>
        ))}
      </div>
    </div>
  );
}
