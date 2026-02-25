import { cookies } from 'next/headers';
import { Card } from '@/components/ui/primitives';
import { fetchAdmin } from '@/lib/backend';
import { hasPermission, type AdminRole } from '@/lib/rbac';
import { SupportView } from '@/components/support/support-view';

export default async function SupportPage() {
  const role = ((await cookies()).get('smartapp_role')?.value || 'SUPPORT_ADMIN') as AdminRole;
  const canManage = hasPermission(role, 'support.manage') || hasPermission(role, 'settings.manage');

  const [ticketsRes, configRes] = await Promise.all([
    fetchAdmin('/api/v1/admin/support/tickets'),
    fetchAdmin('/api/v1/admin/app-config/support'),
  ]);

  const tickets = ticketsRes?.data || [];
  const config = configRes?.data || {
    phone: '01552785430',
    email: 'support@smartfood.app',
    whatsapp: '01552785430',
  };

  return (
    <Card>
      <h3>Support & Tickets</h3>
      <SupportView initialTickets={tickets} initialConfig={config} canManage={canManage} />
    </Card>
  );
}
