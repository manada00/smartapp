import { cookies } from 'next/headers';
import { Button, Card } from '@/components/ui/primitives';
import { hasPermission, type AdminRole } from '@/lib/rbac';

export default async function CategoriesPage() {
  const role = ((await cookies()).get('smartapp_role')?.value || 'SUPPORT_ADMIN') as AdminRole;
  const canManage = hasPermission(role, 'menu.manage');

  return (
    <div className="grid" style={{ gridTemplateColumns: '1fr 1fr' }}>
      <Card>
        <h3>Category & Subcategory Management</h3>
        <div className="toolbar">
          <Button disabled={!canManage}>Create Category</Button>
          <Button disabled={!canManage}>Edit Subcategories</Button>
          <Button disabled={!canManage}>Assign Functional Tags</Button>
        </div>
        <p className="muted">Example structure: Bowls → Protein Bowls / Low Carb / Sleep Friendly.</p>
      </Card>

      <Card>
        <h3>Recommendation Weight Controls</h3>
        <label>Energy score: 4<input type="range" min={1} max={5} defaultValue={4} disabled={!canManage} /></label>
        <label>Sleep score: 1<input type="range" min={1} max={5} defaultValue={1} disabled={!canManage} /></label>
        <label>Satiety score: 3<input type="range" min={1} max={5} defaultValue={3} disabled={!canManage} /></label>
        <p className="muted">Weights feed the recommendation engine ranking query.</p>
      </Card>
    </div>
  );
}
