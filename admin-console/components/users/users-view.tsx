'use client';

import { Fragment, useMemo, useState } from 'react';
import { Badge, Button } from '@/components/ui/primitives';

type UserRecord = {
  id: string;
  accountType: 'basic' | 'admin';
  name?: string;
  email?: string;
  phone?: string;
  totalSpend: number;
  totalOrders: number;
  points: number;
  walletBalance?: number;
  isBlocked: boolean;
  role: string;
  lastActivity?: string;
};

type UserOrder = {
  _id: string;
  orderNumber: string;
  status: string;
  paymentStatus: string;
  total: number;
  createdAt: string;
};

export function UsersView({
  initialUsers,
  canManage,
  canCreateAdmin,
}: {
  initialUsers: UserRecord[];
  canManage: boolean;
  canCreateAdmin: boolean;
}) {
  const [users, setUsers] = useState<UserRecord[]>(initialUsers);
  const [ordersByUser, setOrdersByUser] = useState<Record<string, UserOrder[]>>({});
  const [loadingOrdersFor, setLoadingOrdersFor] = useState<string | null>(null);
  const [notice, setNotice] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [form, setForm] = useState({
    accountType: 'basic' as 'basic' | 'admin',
    name: '',
    email: '',
    phone: '',
    password: '',
    role: 'SUPPORT_ADMIN',
  });

  const sortedUsers = useMemo(
    () => users.slice().sort((a, b) => (new Date(b.lastActivity || 0).getTime() - new Date(a.lastActivity || 0).getTime())),
    [users],
  );

  function resetMessages() {
    setNotice(null);
    setError(null);
  }

  async function createUser() {
    resetMessages();
    const payload = form.accountType === 'admin'
      ? { accountType: 'admin', email: form.email, password: form.password, role: form.role }
      : { accountType: 'basic', name: form.name, email: form.email, phone: form.phone };

    const res = await fetch('/api/admin/users', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });
    const body = await res.json().catch(() => null);

    if (!res.ok || !body?.success) {
      setError(body?.message || 'Failed to create user');
      return;
    }

    await refreshUsers();
    setForm({ accountType: 'basic', name: '', email: '', phone: '', password: '', role: 'SUPPORT_ADMIN' });
    setNotice('User created successfully.');
  }

  async function refreshUsers() {
    const res = await fetch('/api/admin/users');
    const body = await res.json().catch(() => null);
    if (res.ok && body?.success) {
      setUsers(body.data as UserRecord[]);
    }
  }

  async function toggleBlock(user: UserRecord) {
    resetMessages();
    const res = await fetch(`/api/admin/users/${user.id}/block`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ accountType: user.accountType, isBlocked: !user.isBlocked }),
    });
    const body = await res.json().catch(() => null);

    if (!res.ok || !body?.success) {
      setError(body?.message || 'Failed to update user status');
      return;
    }

    setUsers((prev) => prev.map((item) => item.id === user.id ? { ...item, isBlocked: !item.isBlocked } : item));
    setNotice(`User ${user.isBlocked ? 'unblocked' : 'blocked'} successfully.`);
  }

  async function deleteUser(user: UserRecord) {
    resetMessages();
    const confirmed = window.confirm(`Delete ${user.email || user.name || 'this user'}?`);
    if (!confirmed) return;

    const res = await fetch(`/api/admin/users/${user.id}?accountType=${user.accountType}`, { method: 'DELETE' });
    const body = await res.json().catch(() => null);

    if (!res.ok || !body?.success) {
      setError(body?.message || 'Failed to delete user');
      return;
    }

    setUsers((prev) => prev.filter((item) => item.id !== user.id));
    setNotice('User deleted successfully.');
  }

  async function resetPassword(user: UserRecord) {
    resetMessages();
    const newPassword = user.accountType === 'admin'
      ? (window.prompt('Enter new password for this admin user (leave empty to auto-generate):') || '')
      : '';

    const res = await fetch(`/api/admin/users/${user.id}/reset-password`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ accountType: user.accountType, newPassword }),
    });
    const body = await res.json().catch(() => null);

    if (!res.ok || !body?.success) {
      setError(body?.message || 'Failed to reset password');
      return;
    }

    const temp = body?.data?.temporaryPassword;
    setNotice(temp ? `Temporary password: ${temp}` : (body?.message || 'Password reset complete.'));
  }

  async function issueCredit(user: UserRecord) {
    resetMessages();
    const value = window.prompt('Credit amount to issue (EGP):');
    const amount = Number(value || 0);
    if (!Number.isFinite(amount) || amount <= 0) {
      setError('Please enter a valid amount greater than zero.');
      return;
    }

    const res = await fetch(`/api/admin/users/${user.id}/issue-credit`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ accountType: user.accountType, amount }),
    });
    const body = await res.json().catch(() => null);

    if (!res.ok || !body?.success) {
      setError(body?.message || 'Failed to issue credit');
      return;
    }

    await refreshUsers();
    setNotice('Credit issued successfully.');
  }

  async function loadOrderHistory(user: UserRecord) {
    resetMessages();
    if (user.accountType === 'admin') {
      setOrdersByUser((prev) => ({ ...prev, [user.id]: [] }));
      return;
    }

    setLoadingOrdersFor(user.id);
    const res = await fetch(`/api/admin/users/${user.id}/orders?accountType=${user.accountType}`);
    const body = await res.json().catch(() => null);
    setLoadingOrdersFor(null);

    if (!res.ok || !body?.success) {
      setError(body?.message || 'Failed to load order history');
      return;
    }

    setOrdersByUser((prev) => ({ ...prev, [user.id]: body.data as UserOrder[] }));
  }

  return (
    <>
      <div className="card" style={{ marginBottom: 12 }}>
        <h4 style={{ marginTop: 0 }}>Create User</h4>
        <div style={{ display: 'grid', gridTemplateColumns: '160px 1fr 1fr 1fr', gap: 8 }}>
          <select
            value={form.accountType}
            onChange={(e) => setForm((s) => ({ ...s, accountType: e.target.value as 'basic' | 'admin' }))}
            disabled={!canManage}
          >
            <option value="basic">Basic user</option>
            <option value="admin" disabled={!canCreateAdmin}>Admin user</option>
          </select>
          <input
            placeholder="Name"
            value={form.name}
            disabled={!canManage || form.accountType === 'admin'}
            onChange={(e) => setForm((s) => ({ ...s, name: e.target.value }))}
          />
          <input
            placeholder="Email"
            value={form.email}
            disabled={!canManage}
            onChange={(e) => setForm((s) => ({ ...s, email: e.target.value }))}
          />
          <input
            placeholder="Phone"
            value={form.phone}
            disabled={!canManage || form.accountType === 'admin'}
            onChange={(e) => setForm((s) => ({ ...s, phone: e.target.value }))}
          />
          {form.accountType === 'admin' ? (
            <>
              <input
                placeholder="Password"
                type="password"
                value={form.password}
                disabled={!canManage || !canCreateAdmin}
                onChange={(e) => setForm((s) => ({ ...s, password: e.target.value }))}
              />
              <select
                value={form.role}
                disabled={!canManage || !canCreateAdmin}
                onChange={(e) => setForm((s) => ({ ...s, role: e.target.value }))}
              >
                <option value="SUPPORT_ADMIN">Support Admin</option>
                <option value="OPERATIONS_ADMIN">Operations Admin</option>
                <option value="SUPER_ADMIN">Super Admin</option>
              </select>
            </>
          ) : null}
        </div>
        <div className="toolbar" style={{ marginTop: 8 }}>
          <Button
            variant="primary"
            onClick={() => void createUser()}
            disabled={!canManage || (form.accountType === 'admin' && !canCreateAdmin)}
          >
            Create
          </Button>
        </div>
      </div>

      {error ? <p className="muted" style={{ color: '#b42318' }}>{error}</p> : null}
      {notice ? <p className="muted" style={{ color: '#027a48' }}>{notice}</p> : null}

      <div className="table-wrap">
        <table>
          <thead>
            <tr>
              <th>User</th>
              <th>Type/Role</th>
              <th>Total Spend</th>
              <th>Total Orders</th>
              <th>Wallet</th>
              <th>Status</th>
              <th>Last Activity</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {sortedUsers.map((u) => (
              <Fragment key={u.id}>
                <tr>
                  <td>{u.name || u.email || 'Unnamed user'}</td>
                  <td>{u.accountType} · {u.role}</td>
                  <td>${Number(u.totalSpend || 0).toFixed(2)}</td>
                  <td>{u.totalOrders}</td>
                  <td>{Number(u.walletBalance || 0).toFixed(2)}</td>
                  <td>
                    <Badge tone={u.isBlocked ? 'danger' : 'success'}>{u.isBlocked ? 'Blocked' : 'Active'}</Badge>
                  </td>
                  <td>{u.lastActivity ? new Date(u.lastActivity).toLocaleString() : '-'}</td>
                  <td>
                    <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
                      <Button variant="ghost" disabled={!canManage || loadingOrdersFor === u.id} onClick={() => void loadOrderHistory(u)}>
                        {loadingOrdersFor === u.id ? 'Loading...' : 'Order History'}
                      </Button>
                      <Button variant="ghost" disabled={!canManage} onClick={() => void resetPassword(u)}>Reset Password</Button>
                      <Button variant="ghost" disabled={!canManage || u.accountType !== 'basic'} onClick={() => void issueCredit(u)}>Issue Credit</Button>
                      <Button variant="danger" disabled={!canManage} onClick={() => void toggleBlock(u)}>{u.isBlocked ? 'Unblock' : 'Block'}</Button>
                      <Button variant="danger" disabled={!canManage} onClick={() => void deleteUser(u)}>Delete</Button>
                    </div>
                  </td>
                </tr>
                {ordersByUser[u.id] ? (
                  <tr>
                    <td colSpan={8} style={{ background: 'var(--surface)' }}>
                      {ordersByUser[u.id].length === 0 ? (
                        <p className="muted" style={{ margin: 0 }}>No order history.</p>
                      ) : (
                        <div style={{ display: 'grid', gap: 6 }}>
                          {ordersByUser[u.id].map((order) => (
                            <div key={order._id} style={{ display: 'flex', gap: 10, flexWrap: 'wrap' }}>
                              <strong>{order.orderNumber}</strong>
                              <span>{order.status}</span>
                              <span>{order.paymentStatus}</span>
                              <span>${Number(order.total || 0).toFixed(2)}</span>
                              <span>{new Date(order.createdAt).toLocaleString()}</span>
                            </div>
                          ))}
                        </div>
                      )}
                    </td>
                  </tr>
                ) : null}
              </Fragment>
            ))}
          </tbody>
        </table>
      </div>
    </>
  );
}
