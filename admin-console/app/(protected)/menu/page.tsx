import { cookies } from 'next/headers';
import { Card } from '@/components/ui/primitives';
import { MenuItemsView } from '@/components/menu/menu-items-view';
import { hasPermission, type AdminRole } from '@/lib/rbac';
import { fetchAdmin } from '@/lib/backend';

export default async function MenuPage() {
  const role = ((await cookies()).get('smartapp_role')?.value || 'SUPPORT_ADMIN') as AdminRole;
  const canManage = hasPermission(role, 'menu.manage');
  const menuRes = await fetchAdmin('/api/v1/admin/menu');
  const categoriesRes = await fetchAdmin('/api/v1/admin/menu/categories');
  const items = menuRes?.data || [];
  const categories = categoriesRes?.data || [];

  return (
    <Card>
      <h3>Menu & Item Management</h3>
      <MenuItemsView initialItems={items} categories={categories} canManage={canManage} />
    </Card>
  );
}
