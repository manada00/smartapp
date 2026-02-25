import { cookies } from 'next/headers';
import { Card } from '@/components/ui/primitives';
import { fetchAdmin } from '@/lib/backend';
import { hasPermission, type AdminRole } from '@/lib/rbac';
import { HomeContentView } from '@/components/settings/home-content-view';

const DEFAULT_MOODS = [
  { type: 'need_energy', title: '', subtitle: '', emoji: '⚡', isVisible: true, sortOrder: 0 },
  { type: 'very_hungry', title: '', subtitle: '', emoji: '🍽️', isVisible: true, sortOrder: 1 },
  { type: 'something_light', title: '', subtitle: '', emoji: '🥗', isVisible: true, sortOrder: 2 },
  { type: 'trained_today', title: '', subtitle: '', emoji: '💪', isVisible: true, sortOrder: 3 },
  { type: 'stressed', title: '', subtitle: '', emoji: '🫶', isVisible: true, sortOrder: 4 },
  { type: 'bloated', title: '', subtitle: '', emoji: '🌿', isVisible: true, sortOrder: 5 },
  { type: 'help_sleep', title: '', subtitle: '', emoji: '🌙', isVisible: true, sortOrder: 6 },
  { type: 'kid_needs_meal', title: '', subtitle: '', emoji: '🧒', isVisible: true, sortOrder: 7 },
  { type: 'fasting_tomorrow', title: '', subtitle: '', emoji: '✨', isVisible: true, sortOrder: 8 },
  { type: 'browse_all', title: '', subtitle: '', emoji: '🧭', isVisible: true, sortOrder: 9 },
];

export default async function SettingsPage() {
  const role = ((await cookies()).get('smartapp_role')?.value || 'SUPPORT_ADMIN') as AdminRole;
  const canManage = hasPermission(role, 'settings.manage') || hasPermission(role, 'menu.manage');

  const [configRes, menuRes] = await Promise.all([
    fetchAdmin('/api/v1/admin/app-config/home'),
    fetchAdmin('/api/v1/admin/menu?limit=200'),
  ]);

  const config = configRes?.data || {};
  const menuItems = (menuRes?.data || []).map((item: { _id: string; name: string }) => ({
    _id: String(item._id || ''),
    name: String(item.name || 'Unnamed'),
  }));

  const initialConfig = {
    homeHero: {
      title: String(config.homeHero?.title || ''),
      subtitle: String(config.homeHero?.subtitle || ''),
    },
    announcement: {
      enabled: Boolean(config.announcement?.enabled),
      message: String(config.announcement?.message || ''),
    },
    promotions: Array.isArray(config.promotions)
      ? config.promotions.map((item: { title?: string; message?: string; imageUrl?: string; ctaText?: string; isActive?: boolean }) => ({
        title: String(item.title || ''),
        message: String(item.message || ''),
        imageUrl: String(item.imageUrl || ''),
        ctaText: String(item.ctaText || ''),
        isActive: Boolean(item.isActive),
      }))
      : [],
    moods: Array.isArray(config.moods)
      ? config.moods.map((item: { type?: string; title?: string; subtitle?: string; emoji?: string; isVisible?: boolean; sortOrder?: number }) => ({
        type: String(item.type || ''),
        title: String(item.title || ''),
        subtitle: String(item.subtitle || ''),
        emoji: String(item.emoji || ''),
        isVisible: item.isVisible !== false,
        sortOrder: Number(item.sortOrder || 0),
      }))
      : DEFAULT_MOODS,
    popularFoodIds: Array.isArray(config.popularFoodIds)
      ? config.popularFoodIds.map((id: unknown) => String(id)).filter(Boolean)
      : [],
  };

  return (
    <Card>
      <h3>Home App Content Controls</h3>
      <HomeContentView initialConfig={initialConfig} menuItems={menuItems} canManage={canManage} />
    </Card>
  );
}
