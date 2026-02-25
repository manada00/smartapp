'use client';

import { useMemo, useState } from 'react';
import { Badge, Button } from '@/components/ui/primitives';

type Category = {
  _id: string;
  name: string;
  description?: string;
  image?: string;
  sortOrder?: number;
  isActive?: boolean;
};

type CategoryForm = {
  name: string;
  description: string;
  image: string;
  sortOrder: string;
  isActive: boolean;
};

export function CategoriesView({
  initialCategories,
  canManage,
}: {
  initialCategories: Category[];
  canManage: boolean;
}) {
  const [categories, setCategories] = useState<Category[]>(initialCategories);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [showCreate, setShowCreate] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  const sortedCategories = useMemo(
    () => [...categories].sort((a, b) => Number(a.sortOrder || 0) - Number(b.sortOrder || 0)),
    [categories],
  );

  const [createForm, setCreateForm] = useState<CategoryForm>({
    name: '',
    description: '',
    image: '',
    sortOrder: '0',
    isActive: true,
  });

  const [editForm, setEditForm] = useState<CategoryForm>({
    name: '',
    description: '',
    image: '',
    sortOrder: '0',
    isActive: true,
  });

  function resetMessages() {
    setError(null);
    setSuccess(null);
  }

  function openEdit(category: Category) {
    resetMessages();
    setEditingId(category._id);
    setShowCreate(false);
    setEditForm({
      name: category.name || '',
      description: category.description || '',
      image: category.image || '',
      sortOrder: String(category.sortOrder ?? 0),
      isActive: Boolean(category.isActive ?? true),
    });
  }

  function closeEdit() {
    setEditingId(null);
  }

  async function createCategory() {
    if (!createForm.name.trim()) {
      setError('Category name is required.');
      return;
    }

    setSaving(true);
    resetMessages();

    const payload = {
      name: createForm.name.trim(),
      description: createForm.description.trim(),
      image: createForm.image.trim(),
      sortOrder: Number(createForm.sortOrder || 0),
      isActive: createForm.isActive,
    };

    const res = await fetch('/api/admin/menu/categories', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });

    const body = await res.json().catch(() => null);
    if (!res.ok || !body?.success) {
      setError(body?.message || 'Failed to create category');
      setSaving(false);
      return;
    }

    setCategories((prev) => [...prev, body.data as Category]);
    setShowCreate(false);
    setCreateForm({
      name: '',
      description: '',
      image: '',
      sortOrder: '0',
      isActive: true,
    });
    setSuccess('Category created successfully.');
    setSaving(false);
  }

  async function saveCategory() {
    if (!editingId) return;
    if (!editForm.name.trim()) {
      setError('Category name is required.');
      return;
    }

    setSaving(true);
    resetMessages();

    const payload = {
      name: editForm.name.trim(),
      description: editForm.description.trim(),
      image: editForm.image.trim(),
      sortOrder: Number(editForm.sortOrder || 0),
      isActive: editForm.isActive,
    };

    const res = await fetch(`/api/admin/menu/categories/${editingId}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });

    const body = await res.json().catch(() => null);
    if (!res.ok || !body?.success) {
      setError(body?.message || 'Failed to update category');
      setSaving(false);
      return;
    }

    const updated = body.data as Category;
    setCategories((prev) => prev.map((item) => (item._id === updated._id ? updated : item)));
    setEditingId(null);
    setSuccess('Category updated successfully.');
    setSaving(false);
  }

  return (
    <>
      <div className="toolbar">
        <Button
          variant="primary"
          disabled={!canManage}
          onClick={() => {
            setShowCreate((v) => !v);
            setEditingId(null);
            resetMessages();
          }}
        >
          {showCreate ? 'Close' : 'Add Category'}
        </Button>
      </div>

      {showCreate ? (
        <div className="card" style={{ marginBottom: 12 }}>
          <h4 style={{ marginTop: 0 }}>Create Category</h4>
          <CategoryFormFields form={createForm} onChange={setCreateForm} />
          <div style={{ marginTop: 12, display: 'flex', gap: 8 }}>
            <Button onClick={() => void createCategory()} disabled={saving || !canManage}>
              {saving ? 'Saving...' : 'Create Category'}
            </Button>
            <Button variant="ghost" onClick={() => setShowCreate(false)} disabled={saving}>Cancel</Button>
          </div>
        </div>
      ) : null}

      {editingId ? (
        <div className="card" style={{ marginBottom: 12 }}>
          <h4 style={{ marginTop: 0 }}>Edit Category</h4>
          <CategoryFormFields form={editForm} onChange={setEditForm} />
          <div style={{ marginTop: 12, display: 'flex', gap: 8 }}>
            <Button onClick={() => void saveCategory()} disabled={saving || !canManage}>
              {saving ? 'Saving...' : 'Save Changes'}
            </Button>
            <Button variant="ghost" onClick={closeEdit} disabled={saving}>Cancel</Button>
          </div>
        </div>
      ) : null}

      {error ? <p className="muted" style={{ color: '#b42318' }}>{error}</p> : null}
      {success ? <p className="muted" style={{ color: '#027a48' }}>{success}</p> : null}

      <div className="table-wrap">
        <table>
          <thead>
            <tr>
              <th>Name</th>
              <th>Description</th>
              <th>Image</th>
              <th>Sort</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {sortedCategories.map((category) => (
              <tr key={category._id}>
                <td>{category.name}</td>
                <td>{category.description || '—'}</td>
                <td>
                  {category.image ? (
                    <a href={category.image} target="_blank" rel="noreferrer">View image</a>
                  ) : (
                    '—'
                  )}
                </td>
                <td>{Number(category.sortOrder || 0)}</td>
                <td>
                  <Badge tone={category.isActive ? 'success' : 'warning'}>
                    {category.isActive ? 'Active' : 'Inactive'}
                  </Badge>
                </td>
                <td>
                  <Button variant="ghost" disabled={!canManage} onClick={() => openEdit(category)}>Edit</Button>
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

function CategoryFormFields({
  form,
  onChange,
}: {
  form: CategoryForm;
  onChange: (updater: (state: CategoryForm) => CategoryForm) => void;
}) {
  return (
    <div style={{ display: 'grid', gap: 10, gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))' }}>
      <label>
        Name
        <input value={form.name} onChange={(e) => onChange((s) => ({ ...s, name: e.target.value }))} />
      </label>
      <label>
        Sort Order
        <input
          type="number"
          step="1"
          value={form.sortOrder}
          onChange={(e) => onChange((s) => ({ ...s, sortOrder: e.target.value }))}
        />
      </label>
      <label>
        Image URL
        <input
          value={form.image}
          placeholder="https://..."
          onChange={(e) => onChange((s) => ({ ...s, image: e.target.value }))}
        />
      </label>
      <label style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 24 }}>
        <input
          type="checkbox"
          checked={form.isActive}
          onChange={(e) => onChange((s) => ({ ...s, isActive: e.target.checked }))}
        />
        Active
      </label>
      <label style={{ gridColumn: '1 / -1' }}>
        Description
        <textarea value={form.description} rows={3} onChange={(e) => onChange((s) => ({ ...s, description: e.target.value }))} />
      </label>
    </div>
  );
}
