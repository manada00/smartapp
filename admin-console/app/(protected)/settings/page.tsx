import { cookies } from 'next/headers';
import { Button, Card } from '@/components/ui/primitives';
import { hasPermission, type AdminRole } from '@/lib/rbac';

export default async function SettingsPage() {
  const role = ((await cookies()).get('smartapp_role')?.value || 'SUPPORT_ADMIN') as AdminRole;
  const canManage = hasPermission(role, 'settings.manage');

  return (
    <Card>
      <h3>App Configuration Settings</h3>
      <div className="grid" style={{ gridTemplateColumns: '1fr 1fr' }}>
        <label>Delivery Fee<input defaultValue="25" disabled={!canManage} /></label>
        <label>Tax Percentage<input defaultValue="14" disabled={!canManage} /></label>
        <label>Payment Gateway Key<input type="password" value="••••••••••••" readOnly /></label>
        <label>Promo Codes<input placeholder="WELCOME20" disabled={!canManage} /></label>
        <label>Discount Rules<input placeholder="Buy 2 get 1" disabled={!canManage} /></label>
        <label>Referral Program<input placeholder="Enabled" disabled={!canManage} /></label>
      </div>
      <div className="toolbar" style={{ marginTop: 12 }}>
        <Button disabled={!canManage}>Notification Settings</Button>
        <Button variant="danger" disabled={!canManage}>Maintenance Mode Toggle</Button>
        <Button variant="primary" disabled={!canManage}>Save Changes</Button>
      </div>
    </Card>
  );
}
