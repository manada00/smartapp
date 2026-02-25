'use client';

import { useMemo, useState } from 'react';
import { Button } from '@/components/ui/primitives';

type MenuItem = {
  _id: string;
  name: string;
};

type Mood = {
  type: string;
  title: string;
  subtitle: string;
  emoji: string;
  isVisible: boolean;
  sortOrder: number;
};

type Promotion = {
  title: string;
  message: string;
  imageUrl: string;
  ctaText: string;
  isActive: boolean;
};

type Config = {
  homeHero: { title: string; subtitle: string };
  announcement: { enabled: boolean; message: string };
  promotions: Promotion[];
  moods: Mood[];
  popularFoodIds: string[];
};

const DEFAULT_PROMOTION: Promotion = {
  title: '',
  message: '',
  imageUrl: '',
  ctaText: '',
  isActive: false,
};

const MOOD_LIBRARY: Array<{ type: string; label: string; emoji: string }> = [
  { type: 'need_energy', label: 'Need energy', emoji: '⚡' },
  { type: 'very_hungry', label: 'Very hungry', emoji: '🍽️' },
  { type: 'something_light', label: 'Something light', emoji: '🥗' },
  { type: 'trained_today', label: 'Trained today', emoji: '💪' },
  { type: 'stressed', label: 'Stressed', emoji: '🫶' },
  { type: 'bloated', label: 'Bloated', emoji: '🌿' },
  { type: 'help_sleep', label: 'Help sleep', emoji: '🌙' },
  { type: 'kid_needs_meal', label: 'Kid needs meal', emoji: '🧒' },
  { type: 'fasting_tomorrow', label: 'Fasting tomorrow', emoji: '✨' },
  { type: 'browse_all', label: 'Browse all', emoji: '🧭' },
];

export function HomeContentView({
  initialConfig,
  menuItems,
  canManage,
}: {
  initialConfig: Config;
  menuItems: MenuItem[];
  canManage: boolean;
}) {
  const [config, setConfig] = useState<Config>({
    ...initialConfig,
    promotions: initialConfig.promotions.length > 0 ? initialConfig.promotions : [DEFAULT_PROMOTION],
  });
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [search, setSearch] = useState('');

  const filteredMenuItems = useMemo(() => {
    const q = search.trim().toLowerCase();
    if (!q) return menuItems;
    return menuItems.filter((item) => item.name.toLowerCase().includes(q));
  }, [menuItems, search]);

  const availableMoodTypes = useMemo(
    () => MOOD_LIBRARY.filter((entry) => !config.moods.some((mood) => mood.type === entry.type)),
    [config.moods],
  );

  function resetMessages() {
    setError(null);
    setSuccess(null);
  }

  function togglePopular(foodId: string) {
    setConfig((prev) => {
      const has = prev.popularFoodIds.includes(foodId);
      return {
        ...prev,
        popularFoodIds: has
          ? prev.popularFoodIds.filter((id) => id !== foodId)
          : [...prev.popularFoodIds, foodId],
      };
    });
  }

  function removeMood(type: string) {
    setConfig((prev) => ({
      ...prev,
      moods: prev.moods
        .filter((mood) => mood.type !== type)
        .map((mood, index) => ({ ...mood, sortOrder: index })),
    }));
  }

  function addMood(type: string) {
    const preset = MOOD_LIBRARY.find((item) => item.type === type);
    if (!preset) return;

    setConfig((prev) => ({
      ...prev,
      moods: [
        ...prev.moods,
        {
          type: preset.type,
          title: '',
          subtitle: '',
          emoji: preset.emoji,
          isVisible: true,
          sortOrder: prev.moods.length,
        },
      ],
    }));
  }

  async function save() {
    setSaving(true);
    resetMessages();

    const res = await fetch('/api/admin/app-config/home', {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(config),
    });
    const body = await res.json().catch(() => null);

    if (!res.ok || !body?.success) {
      setError(body?.message || 'Failed to save home configuration');
      setSaving(false);
      return;
    }

    setConfig(body.data as Config);
    setSuccess('Home content updated successfully.');
    setSaving(false);
  }

  return (
    <div className="grid" style={{ gap: 12 }}>
      <div className="card">
        <h4 style={{ marginTop: 0 }}>Popular Right Now Items</h4>
        <input
          placeholder="Search menu item..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          disabled={!canManage}
          style={{ marginBottom: 10 }}
        />
        <div style={{ maxHeight: 220, overflow: 'auto', border: '1px solid var(--border)', borderRadius: 10, padding: 10 }}>
          {filteredMenuItems.map((item) => (
            <label key={item._id} style={{ display: 'flex', gap: 8, marginBottom: 8, alignItems: 'center' }}>
              <input
                type="checkbox"
                checked={config.popularFoodIds.includes(item._id)}
                onChange={() => togglePopular(item._id)}
                disabled={!canManage}
              />
              {item.name}
            </label>
          ))}
        </div>
      </div>

      <div className="card">
        <h4 style={{ marginTop: 0 }}>Home Hero Message</h4>
        <label>
          Title
          <input
            value={config.homeHero.title}
            disabled={!canManage}
            onChange={(e) => setConfig((s) => ({ ...s, homeHero: { ...s.homeHero, title: e.target.value } }))}
          />
        </label>
        <label>
          Subtitle
          <textarea
            rows={2}
            value={config.homeHero.subtitle}
            disabled={!canManage}
            onChange={(e) => setConfig((s) => ({ ...s, homeHero: { ...s.homeHero, subtitle: e.target.value } }))}
          />
        </label>
      </div>

      <div className="card">
        <h4 style={{ marginTop: 0 }}>Announcement / Message to Users</h4>
        <label style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <input
            type="checkbox"
            checked={config.announcement.enabled}
            disabled={!canManage}
            onChange={(e) => setConfig((s) => ({
              ...s,
              announcement: { ...s.announcement, enabled: e.target.checked },
            }))}
          />
          Enable announcement
        </label>
        <label>
          Message
          <textarea
            rows={2}
            value={config.announcement.message}
            disabled={!canManage}
            onChange={(e) => setConfig((s) => ({
              ...s,
              announcement: { ...s.announcement, message: e.target.value },
            }))}
          />
        </label>
      </div>

      <div className="card">
        <h4 style={{ marginTop: 0 }}>Promotions</h4>
        {config.promotions.map((promo, idx) => (
          <div key={idx} style={{ border: '1px solid var(--border)', borderRadius: 10, padding: 10, marginBottom: 10 }}>
            <label style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
              <input
                type="checkbox"
                checked={promo.isActive}
                disabled={!canManage}
                onChange={(e) => setConfig((s) => ({
                  ...s,
                  promotions: s.promotions.map((item, i) => i === idx ? { ...item, isActive: e.target.checked } : item),
                }))}
              />
              Active
            </label>
            <label>Title
              <input
                value={promo.title}
                disabled={!canManage}
                onChange={(e) => setConfig((s) => ({
                  ...s,
                  promotions: s.promotions.map((item, i) => i === idx ? { ...item, title: e.target.value } : item),
                }))}
              />
            </label>
            <label>Message
              <textarea
                rows={2}
                value={promo.message}
                disabled={!canManage}
                onChange={(e) => setConfig((s) => ({
                  ...s,
                  promotions: s.promotions.map((item, i) => i === idx ? { ...item, message: e.target.value } : item),
                }))}
              />
            </label>
            <label>Image URL
              <input
                value={promo.imageUrl}
                disabled={!canManage}
                onChange={(e) => setConfig((s) => ({
                  ...s,
                  promotions: s.promotions.map((item, i) => i === idx ? { ...item, imageUrl: e.target.value } : item),
                }))}
              />
            </label>
            <label>CTA Text
              <input
                value={promo.ctaText}
                disabled={!canManage}
                onChange={(e) => setConfig((s) => ({
                  ...s,
                  promotions: s.promotions.map((item, i) => i === idx ? { ...item, ctaText: e.target.value } : item),
                }))}
              />
            </label>
          </div>
        ))}
        <Button
          variant="ghost"
          disabled={!canManage}
          onClick={() => setConfig((s) => ({ ...s, promotions: [...s.promotions, DEFAULT_PROMOTION] }))}
        >
          Add Promotion
        </Button>
      </div>

      <div className="card">
        <h4 style={{ marginTop: 0 }}>Moods (Home Feeling Cards)</h4>
        {availableMoodTypes.length > 0 ? (
          <div style={{ display: 'flex', gap: 8, marginBottom: 10, flexWrap: 'wrap' }}>
            {availableMoodTypes.map((entry) => (
              <Button
                key={entry.type}
                variant="ghost"
                disabled={!canManage}
                onClick={() => addMood(entry.type)}
              >
                Add {entry.label}
              </Button>
            ))}
          </div>
        ) : null}
        {config.moods
          .slice()
          .sort((a, b) => a.sortOrder - b.sortOrder)
          .map((mood) => (
            <div key={mood.type} style={{ border: '1px solid var(--border)', borderRadius: 10, padding: 10, marginBottom: 10 }}>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 8 }}>
                <strong>{MOOD_LIBRARY.find((entry) => entry.type === mood.type)?.label || mood.type}</strong>
                <Button variant="danger" disabled={!canManage} onClick={() => removeMood(mood.type)}>Delete</Button>
              </div>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 90px 90px', gap: 8 }}>
              <input
                value={mood.title}
                placeholder={`${mood.type} title`}
                disabled={!canManage}
                onChange={(e) => setConfig((s) => ({
                  ...s,
                  moods: s.moods.map((item) => item.type === mood.type ? { ...item, title: e.target.value } : item),
                }))}
              />
              <input
                value={mood.subtitle}
                placeholder="Subtitle"
                disabled={!canManage}
                onChange={(e) => setConfig((s) => ({
                  ...s,
                  moods: s.moods.map((item) => item.type === mood.type ? { ...item, subtitle: e.target.value } : item),
                }))}
              />
              <input
                value={mood.emoji}
                placeholder="Emoji"
                disabled={!canManage}
                onChange={(e) => setConfig((s) => ({
                  ...s,
                  moods: s.moods.map((item) => item.type === mood.type ? { ...item, emoji: e.target.value } : item),
                }))}
              />
              <label style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                <input
                  type="checkbox"
                  checked={mood.isVisible}
                  disabled={!canManage}
                  onChange={(e) => setConfig((s) => ({
                    ...s,
                    moods: s.moods.map((item) => item.type === mood.type ? { ...item, isVisible: e.target.checked } : item),
                  }))}
                />
                Show
              </label>
              </div>
            </div>
          ))}
      </div>

      {error ? <p className="muted" style={{ color: '#b42318' }}>{error}</p> : null}
      {success ? <p className="muted" style={{ color: '#027a48' }}>{success}</p> : null}

      <div className="toolbar">
        <Button variant="primary" disabled={!canManage || saving} onClick={() => void save()}>
          {saving ? 'Saving...' : 'Save Home App Controls'}
        </Button>
      </div>
    </div>
  );
}
