'use client';

import { useMemo, useState } from 'react';
import type { DragEvent, ReactNode } from 'react';
import { Badge, Button } from '@/components/ui/primitives';

type MenuItem = {
  _id: string;
  name: string;
  description?: string;
  category?: { _id?: string; name?: string };
  portionOptions?: { name?: string; price?: number; isPopular?: boolean }[];
  dietaryTags?: string[];
  images?: string[];
  price?: number;
  preparationTime?: number;
  isAvailable?: boolean;
  isFeatured?: boolean;
};

type Category = {
  _id: string;
  name: string;
};

type EditForm = {
  name: string;
  description: string;
  price: string;
  regularPortionPrice: string;
  largePortionPrice: string;
  preparationTime: string;
  dietaryTags: string;
  isAvailable: boolean;
  isFeatured: boolean;
};

type CreateForm = {
  name: string;
  description: string;
  categoryId: string;
  imageUrl: string;
  regularPortionPrice: string;
  largePortionPrice: string;
  preparationTime: string;
  dietaryTags: string;
  isAvailable: boolean;
  isFeatured: boolean;
};

export function MenuItemsView({
  initialItems,
  categories,
  canManage,
}: {
  initialItems: MenuItem[];
  categories: Category[];
  canManage: boolean;
}) {
  const [items, setItems] = useState<MenuItem[]>(initialItems);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [showCreate, setShowCreate] = useState(false);
  const [dragMode, setDragMode] = useState(false);
  const [dragIndex, setDragIndex] = useState<number | null>(null);
  const [selectedIds, setSelectedIds] = useState<Set<string>>(new Set());

  const [form, setForm] = useState<EditForm>({
    name: '',
    description: '',
    price: '',
    regularPortionPrice: '',
    largePortionPrice: '',
    preparationTime: '',
    dietaryTags: '',
    isAvailable: true,
    isFeatured: false,
  });

  const [createForm, setCreateForm] = useState<CreateForm>({
    name: '',
    description: '',
    categoryId: categories[0]?._id || '',
    imageUrl: '',
    regularPortionPrice: '',
    largePortionPrice: '',
    preparationTime: '10',
    dietaryTags: '',
    isAvailable: true,
    isFeatured: false,
  });

  const selectedCount = selectedIds.size;
  const activeIds = useMemo(() => (selectedIds.size > 0 ? Array.from(selectedIds) : items.map((i) => i._id)), [selectedIds, items]);

  function setMessage(nextError: string | null, nextSuccess: string | null) {
    setError(nextError);
    setSuccess(nextSuccess);
  }

  function startEdit(item: MenuItem) {
    setMessage(null, null);
    setEditingId(item._id);
    setForm({
      name: item.name || '',
      description: item.description || '',
      price: String(item.price ?? 0),
      regularPortionPrice: getPortionPrice(item, 'regular'),
      largePortionPrice: getPortionPrice(item, 'large'),
      preparationTime: String(item.preparationTime ?? 0),
      dietaryTags: (item.dietaryTags || []).join(', '),
      isAvailable: Boolean(item.isAvailable),
      isFeatured: Boolean(item.isFeatured),
    });
  }

  function cancelEdit() {
    setEditingId(null);
    setError(null);
  }

  async function saveEdit() {
    if (!editingId) return;
    setSaving(true);
    setMessage(null, null);

    const payload = {
      name: form.name.trim(),
      description: form.description.trim(),
      price: Number(form.price),
      regularPortionPrice: parsePrice(form.regularPortionPrice),
      largePortionPrice: parsePrice(form.largePortionPrice),
      preparationTime: Number(form.preparationTime),
      dietaryTags: form.dietaryTags.split(',').map((tag) => tag.trim()).filter(Boolean),
      isAvailable: form.isAvailable,
      isFeatured: form.isFeatured,
    };

    const res = await fetch(`/api/admin/menu/${editingId}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });
    const body = await res.json().catch(() => null);

    if (!res.ok || !body?.success) {
      setMessage(body?.message || 'Failed to update menu item', null);
      setSaving(false);
      return;
    }

    const updated = body.data as MenuItem;
    setItems((prev) => prev.map((item) => (item._id === updated._id ? updated : item)));
    setMessage(null, 'Menu item updated successfully.');
    setEditingId(null);
    setSaving(false);
  }

  async function createItem() {
    if (!createForm.name.trim() || !createForm.description.trim() || !createForm.categoryId) {
      setMessage('Name, description and category are required.', null);
      return;
    }

    setSaving(true);
    setMessage(null, null);

    const payload = {
      name: createForm.name.trim(),
      description: createForm.description.trim(),
      categoryId: createForm.categoryId,
      imageUrl: createForm.imageUrl.trim() || undefined,
      regularPortionPrice: Number(createForm.regularPortionPrice || 0),
      largePortionPrice: Number(createForm.largePortionPrice || 0),
      preparationTime: Number(createForm.preparationTime || 10),
      dietaryTags: createForm.dietaryTags.split(',').map((tag) => tag.trim()).filter(Boolean),
      isAvailable: createForm.isAvailable,
      isFeatured: createForm.isFeatured,
    };

    const res = await fetch('/api/admin/menu', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });
    const body = await res.json().catch(() => null);

    if (!res.ok || !body?.success) {
      setMessage(body?.message || 'Failed to create item', null);
      setSaving(false);
      return;
    }

    setItems((prev) => [body.data as MenuItem, ...prev]);
    setShowCreate(false);
    setCreateForm({
      name: '',
      description: '',
      categoryId: categories[0]?._id || '',
      imageUrl: '',
      regularPortionPrice: '',
      largePortionPrice: '',
      preparationTime: '10',
      dietaryTags: '',
      isAvailable: true,
      isFeatured: false,
    });
    setMessage(null, 'New item added successfully.');
    setSaving(false);
  }

  async function uploadImage(item: MenuItem) {
    const imageUrl = window.prompt('Paste the new image URL (http/https):', item.images?.[0] || '');
    if (!imageUrl) return;

    const res = await fetch(`/api/admin/menu/${item._id}/image`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ imageUrl }),
    });
    const body = await res.json().catch(() => null);

    if (!res.ok || !body?.success) {
      setMessage(body?.message || 'Failed to upload image', null);
      return;
    }

    const updated = body.data as MenuItem;
    setItems((prev) => prev.map((m) => (m._id === updated._id ? updated : m)));
    setMessage(null, `Image updated for ${updated.name}.`);
  }

  async function scheduleItem(item: MenuItem) {
    const startAt = window.prompt('Start datetime (ISO or YYYY-MM-DDTHH:mm). Leave empty to clear start:', '');
    if (startAt === null) return;
    const endAt = window.prompt('End datetime (ISO or YYYY-MM-DDTHH:mm). Leave empty to clear end:', '');
    if (endAt === null) return;

    const res = await fetch(`/api/admin/menu/${item._id}/schedule`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        enabled: true,
        startAt: startAt.trim() || undefined,
        endAt: endAt.trim() || undefined,
      }),
    });

    const body = await res.json().catch(() => null);
    if (!res.ok || !body?.success) {
      setMessage(body?.message || 'Failed to schedule item', null);
      return;
    }

    setMessage(null, `Schedule saved for ${item.name}.`);
  }

  async function duplicateItem(itemId?: string) {
    let id = itemId;
    if (!id) {
      const firstSelected = Array.from(selectedIds)[0];
      if (firstSelected) {
        id = firstSelected;
      } else {
        const search = window.prompt('Enter item name to duplicate:');
        if (!search) return;
        const found = items.find((it) => it.name.toLowerCase().includes(search.toLowerCase()));
        if (!found) {
          setMessage('No matching item found to duplicate.', null);
          return;
        }
        id = found._id;
      }
    }

    const res = await fetch(`/api/admin/menu/${id}/duplicate`, { method: 'POST' });
    const body = await res.json().catch(() => null);

    if (!res.ok || !body?.success) {
      setMessage(body?.message || 'Failed to duplicate item', null);
      return;
    }

    setItems((prev) => [body.data as MenuItem, ...prev]);
    setMessage(null, 'Item duplicated successfully.');
  }

  async function bulkEditPrices() {
    const modeInput = window.prompt('Bulk mode: type "fixed" for +EGP amount, or "percentage" for +% amount', 'fixed');
    if (!modeInput) return;
    const mode = modeInput.toLowerCase() === 'percentage' ? 'percentage' : modeInput.toLowerCase() === 'fixed' ? 'fixed' : null;
    if (!mode) {
      setMessage('Invalid mode. Use fixed or percentage.', null);
      return;
    }

    const amountInput = window.prompt(`Enter ${mode === 'fixed' ? 'amount in EGP' : 'percentage'} (negative allowed):`, '0');
    if (amountInput == null) return;
    const amount = Number(amountInput);
    if (!Number.isFinite(amount)) {
      setMessage('Invalid amount.', null);
      return;
    }

    const targetInput = window.prompt('Target: display, regular, large, or all', 'display');
    if (!targetInput) return;
    const target = targetInput.toLowerCase();
    if (!['display', 'regular', 'large', 'all'].includes(target)) {
      setMessage('Invalid target.', null);
      return;
    }

    const res = await fetch('/api/admin/menu/bulk-pricing', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ itemIds: activeIds, mode, amount, target }),
    });
    const body = await res.json().catch(() => null);

    if (!res.ok || !body?.success) {
      setMessage(body?.message || 'Bulk edit failed', null);
      return;
    }

    await refreshMenu();
    setMessage(null, `Bulk pricing applied to ${activeIds.length} item(s).`);
  }

  async function refreshMenu() {
    const res = await fetch('/api/admin/menu');
    if (!res.ok) return;
    const body = await res.json().catch(() => null);
    if (body?.success && Array.isArray(body.data)) {
      setItems(body.data as MenuItem[]);
    }
  }

  async function saveOrder(nextItems: MenuItem[]) {
    const res = await fetch('/api/admin/menu/reorder', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ itemIds: nextItems.map((item) => item._id) }),
    });

    const body = await res.json().catch(() => null);
    if (!res.ok || !body?.success) {
      setMessage(body?.message || 'Failed to save new order', null);
      return;
    }

    setMessage(null, 'Menu order updated.');
  }

  function onDragStart(index: number) {
    setDragIndex(index);
  }

  async function onDrop(dropIndex: number) {
    if (dragIndex == null || dragIndex === dropIndex) return;
    const next = [...items];
    const [moved] = next.splice(dragIndex, 1);
    next.splice(dropIndex, 0, moved);
    setItems(next);
    setDragIndex(null);
    await saveOrder(next);
  }

  function toggleSelection(itemId: string) {
    setSelectedIds((prev) => {
      const next = new Set(prev);
      if (next.has(itemId)) next.delete(itemId);
      else next.add(itemId);
      return next;
    });
  }

  function onRowDragOver(e: DragEvent<HTMLTableRowElement>) {
    e.preventDefault();
  }

  return (
    <>
      <div className="toolbar">
        <Button variant="primary" disabled={!canManage} onClick={() => setShowCreate(true)}>Add Item</Button>
        <Button disabled={!canManage} onClick={bulkEditPrices}>Bulk Edit Prices</Button>
        <Button disabled={!canManage} onClick={() => setDragMode((v) => !v)}>{dragMode ? 'Stop Drag & Drop' : 'Drag & Drop Reorder'}</Button>
        <Button disabled={!canManage} onClick={() => duplicateItem()}>Duplicate Item</Button>
      </div>

      <p className="muted">{selectedCount > 0 ? `${selectedCount} selected item(s). Bulk actions apply to selected items.` : 'No selection: bulk actions apply to all visible items.'}</p>

      {showCreate ? (
        <CardLike>
          <h4 style={{ marginTop: 0 }}>Add Menu Item</h4>
          <div style={{ display: 'grid', gap: 10, gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))' }}>
            <label>
              Name
              <input value={createForm.name} onChange={(e) => setCreateForm((s) => ({ ...s, name: e.target.value }))} />
            </label>
            <label>
              Category
              <select value={createForm.categoryId} onChange={(e) => setCreateForm((s) => ({ ...s, categoryId: e.target.value }))}>
                {categories.map((category) => (
                  <option key={category._id} value={category._id}>{category.name}</option>
                ))}
              </select>
            </label>
            <label>
              Regular Portion Price
              <input type="number" min="0" step="0.01" value={createForm.regularPortionPrice} onChange={(e) => setCreateForm((s) => ({ ...s, regularPortionPrice: e.target.value }))} />
            </label>
            <label>
              Large Portion Price
              <input type="number" min="0" step="0.01" value={createForm.largePortionPrice} onChange={(e) => setCreateForm((s) => ({ ...s, largePortionPrice: e.target.value }))} />
            </label>
            <label>
              Prep Time (min)
              <input type="number" min="1" step="1" value={createForm.preparationTime} onChange={(e) => setCreateForm((s) => ({ ...s, preparationTime: e.target.value }))} />
            </label>
            <label>
              Image URL
              <input value={createForm.imageUrl} onChange={(e) => setCreateForm((s) => ({ ...s, imageUrl: e.target.value }))} placeholder="https://..." />
            </label>
            <label>
              Dietary Tags (comma separated)
              <input value={createForm.dietaryTags} onChange={(e) => setCreateForm((s) => ({ ...s, dietaryTags: e.target.value }))} />
            </label>
          </div>
          <label style={{ display: 'block', marginTop: 10 }}>
            Description
            <textarea value={createForm.description} onChange={(e) => setCreateForm((s) => ({ ...s, description: e.target.value }))} rows={3} />
          </label>
          <div style={{ display: 'flex', gap: 16, marginTop: 10 }}>
            <label><input type="checkbox" checked={createForm.isAvailable} onChange={(e) => setCreateForm((s) => ({ ...s, isAvailable: e.target.checked }))} /> In Stock</label>
            <label><input type="checkbox" checked={createForm.isFeatured} onChange={(e) => setCreateForm((s) => ({ ...s, isFeatured: e.target.checked }))} /> Featured</label>
          </div>
          <div style={{ display: 'flex', gap: 8, marginTop: 12 }}>
            <Button onClick={createItem} disabled={saving}>{saving ? 'Saving...' : 'Create Item'}</Button>
            <Button variant="ghost" onClick={() => setShowCreate(false)} disabled={saving}>Cancel</Button>
          </div>
        </CardLike>
      ) : null}

      {editingId ? (
        <CardLike>
          <h4 style={{ marginTop: 0 }}>Edit Menu Item</h4>
          <div style={{ display: 'grid', gap: 10, gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))' }}>
            <label>
              Name
              <input value={form.name} onChange={(e) => setForm((s) => ({ ...s, name: e.target.value }))} />
            </label>
            <label>
              Display Price
              <input type="number" min="0" step="0.01" value={form.price} onChange={(e) => setForm((s) => ({ ...s, price: e.target.value }))} />
            </label>
            <label>
              Regular Portion Price
              <input type="number" min="0" step="0.01" value={form.regularPortionPrice} onChange={(e) => setForm((s) => ({ ...s, regularPortionPrice: e.target.value }))} />
            </label>
            <label>
              Large Portion Price
              <input type="number" min="0" step="0.01" value={form.largePortionPrice} onChange={(e) => setForm((s) => ({ ...s, largePortionPrice: e.target.value }))} />
            </label>
            <label>
              Prep Time (min)
              <input type="number" min="0" step="1" value={form.preparationTime} onChange={(e) => setForm((s) => ({ ...s, preparationTime: e.target.value }))} />
            </label>
            <label>
              Dietary Tags (comma separated)
              <input value={form.dietaryTags} onChange={(e) => setForm((s) => ({ ...s, dietaryTags: e.target.value }))} />
            </label>
          </div>
          <label style={{ display: 'block', marginTop: 10 }}>
            Description
            <textarea value={form.description} onChange={(e) => setForm((s) => ({ ...s, description: e.target.value }))} rows={3} />
          </label>
          <div style={{ display: 'flex', gap: 16, marginTop: 10 }}>
            <label><input type="checkbox" checked={form.isAvailable} onChange={(e) => setForm((s) => ({ ...s, isAvailable: e.target.checked }))} /> In Stock</label>
            <label><input type="checkbox" checked={form.isFeatured} onChange={(e) => setForm((s) => ({ ...s, isFeatured: e.target.checked }))} /> Featured</label>
          </div>
          <div style={{ display: 'flex', gap: 8, marginTop: 12 }}>
            <Button onClick={saveEdit} disabled={saving}>{saving ? 'Saving...' : 'Save Changes'}</Button>
            <Button variant="ghost" onClick={cancelEdit} disabled={saving}>Cancel</Button>
          </div>
        </CardLike>
      ) : null}

      {error ? <p className="muted" style={{ color: '#b42318' }}>{error}</p> : null}
      {success ? <p className="muted" style={{ color: '#027a48' }}>{success}</p> : null}

      <div className="table-wrap">
        <table>
          <thead><tr><th></th><th>Item</th><th>Category</th><th>Tags</th><th>Price</th><th>Stock</th><th>Actions</th></tr></thead>
          <tbody>
            {items.map((item, index) => (
              <tr
                key={item._id}
                draggable={dragMode && canManage}
                onDragStart={() => onDragStart(index)}
                onDragOver={onRowDragOver}
                onDrop={() => void onDrop(index)}
                style={dragMode ? { cursor: 'grab' } : undefined}
              >
                <td>
                  <input
                    type="checkbox"
                    checked={selectedIds.has(item._id)}
                    onChange={() => toggleSelection(item._id)}
                    aria-label={`Select ${item.name}`}
                  />
                </td>
                <td>{item.name}</td>
                <td>{item.category?.name || 'Uncategorized'}</td>
                <td>{(item.dietaryTags || []).join(', ') || '—'}</td>
                <td>${Number(item.price || 0).toFixed(2)}</td>
                <td><Badge tone={item.isAvailable ? 'success' : 'danger'}>{item.isAvailable ? 'In Stock' : 'Out of Stock'}</Badge></td>
                <td>
                  <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
                    <Button variant="ghost" disabled={!canManage} onClick={() => startEdit(item)}>Edit</Button>
                    <Button variant="ghost" disabled={!canManage} onClick={() => void uploadImage(item)}>Upload Image</Button>
                    <Button variant="ghost" disabled={!canManage} onClick={() => void scheduleItem(item)}>Schedule</Button>
                    <Button variant="ghost" disabled={!canManage} onClick={() => void duplicateItem(item._id)}>Duplicate</Button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      {!canManage ? <p className="muted">Read-only for your role.</p> : null}
    </>
  );
}

function CardLike({ children }: { children: ReactNode }) {
  return <div className="card" style={{ marginBottom: 12 }}>{children}</div>;
}

function getPortionPrice(item: MenuItem, portionName: string) {
  const portion = (item.portionOptions || []).find((option) =>
    String(option?.name || '').toLowerCase().includes(portionName),
  );
  if (portion?.price == null) {
    return String(item.price ?? 0);
  }
  return String(portion.price);
}

function parsePrice(value: string) {
  const trimmed = value.trim();
  if (!trimmed) return undefined;
  const parsed = Number(trimmed);
  return Number.isFinite(parsed) ? parsed : undefined;
}
