import { cookies } from 'next/headers';
import { Card } from '@/components/ui/primitives';
import { hasPermission, type AdminRole } from '@/lib/rbac';
import { fetchAdmin } from '@/lib/backend';
import { CategoriesView } from '@/components/menu/categories-view';

export default async function CategoriesPage() {
  const role = ((await cookies()).get('smartapp_role')?.value || 'SUPPORT_ADMIN') as AdminRole;
  const canManage = hasPermission(role, 'menu.manage');
  const categoriesRes = await fetchAdmin('/api/v1/admin/menu/categories?includeInactive=true');
  const categories = categoriesRes?.data || [];

  return (
    <Card>
      <h3>Category Management</h3>
      <CategoriesView initialCategories={categories} canManage={canManage} />
    </Card>
  );
}
