import { cookies } from 'next/headers';
import { Card } from '@/components/ui/primitives';
import { hasPermission, type AdminRole } from '@/lib/rbac';
import { fetchAdmin } from '@/lib/backend';
import { UsersView } from '@/components/users/users-view';

export default async function UsersPage() {
  const role = ((await cookies()).get('smartapp_role')?.value || 'SUPPORT_ADMIN') as AdminRole;
  const canManage = hasPermission(role, 'users.manage');
  const canCreateAdmin = role === 'SUPER_ADMIN';
  const usersRes = await fetchAdmin('/api/v1/admin/users');
  const users = usersRes?.data || [];

  return (
    <Card>
      <h3>User Management</h3>
      <UsersView initialUsers={users} canManage={canManage} canCreateAdmin={canCreateAdmin} />
    </Card>
  );
}
