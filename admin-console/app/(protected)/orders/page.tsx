import { cookies } from 'next/headers';
import { Card } from '@/components/ui/primitives';
import { type AdminRole } from '@/lib/rbac';
import { OrdersView } from '@/components/orders/orders-view';
import { fetchAdmin } from '@/lib/backend';

export default async function OrdersPage() {
  const role = ((await cookies()).get('smartapp_role')?.value || 'SUPPORT_ADMIN') as AdminRole;
  const ordersRes = await fetchAdmin('/api/v1/admin/orders?limit=50');
  const initialOrders = ordersRes?.data || [];

  return (
    <Card>
      <h3>Orders Management</h3>
      <OrdersView role={role} initialOrders={initialOrders} />
    </Card>
  );
}
