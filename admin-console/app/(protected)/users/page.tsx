import { cookies } from 'next/headers';
import { Button, Card } from '@/components/ui/primitives';
import { hasPermission, type AdminRole } from '@/lib/rbac';
import { fetchAdmin } from '@/lib/backend';

export default async function UsersPage() {
  const role = ((await cookies()).get('smartapp_role')?.value || 'SUPPORT_ADMIN') as AdminRole;
  const canManage = hasPermission(role, 'users.manage');
  const usersRes = await fetchAdmin('/api/v1/admin/users');
  const users = usersRes?.data || [];

  return (
    <Card>
      <h3>User Management</h3>
      <div className="table-wrap">
        <table>
          <thead><tr><th>User</th><th>Total Spend</th><th>Plan</th><th>Retention</th><th>Last Activity</th><th>Actions</th></tr></thead>
          <tbody>
            {users.map((u: { id: string; name?: string; email?: string; totalSpend: number; totalOrders: number; points: number; lastActivity: string }) => (
              <tr key={u.id}>
                <td>{u.name || u.email || 'Unnamed user'}</td>
                <td>${Number(u.totalSpend || 0).toFixed(2)}</td>
                <td>{u.totalOrders > 10 ? 'Premium' : 'Basic'}</td>
                <td>{u.points > 500 ? 'Healthy' : 'At Risk'}</td>
                <td>{new Date(u.lastActivity).toLocaleString()}</td>
                <td>
                  <div style={{ display: 'flex', gap: 6 }}>
                    <Button variant="ghost" disabled={!canManage}>Order History</Button>
                    <Button variant="ghost" disabled={!canManage}>Reset Password</Button>
                    <Button variant="ghost" disabled={!canManage}>Issue Credit</Button>
                    <Button variant="danger" disabled={!canManage}>Block</Button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </Card>
  );
}
