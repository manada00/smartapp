import { Badge, Button, Card } from '@/components/ui/primitives';
import { tickets } from '@/lib/mock-data';

export default function SupportPage() {
  return (
    <Card>
      <h3>Support & Tickets</h3>
      <div className="table-wrap">
        <table>
          <thead><tr><th>ID</th><th>Subject</th><th>Status</th><th>Priority</th><th>Assignee</th><th>Actions</th></tr></thead>
          <tbody>
            {tickets.map((t) => (
              <tr key={t.id}>
                <td>{t.id}</td>
                <td>{t.subject}</td>
                <td><Badge tone={t.status === 'Resolved' ? 'success' : t.status === 'Pending' ? 'warning' : 'neutral'}>{t.status}</Badge></td>
                <td><Badge tone={t.priority === 'High' ? 'danger' : t.priority === 'Medium' ? 'warning' : 'neutral'}>{t.priority}</Badge></td>
                <td>{t.assignee}</td>
                <td>
                  <div style={{ display: 'flex', gap: 6 }}>
                    <Button variant="ghost">Reply</Button>
                    <Button variant="ghost">Assign</Button>
                    <Button>Resolve</Button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      <p className="muted">Thread timeline and conversation history are ready for Supabase realtime channel per ticket.</p>
    </Card>
  );
}
