'use client';

import { useMemo, useState } from 'react';
import { Badge, Button } from '@/components/ui/primitives';

type SupportMessage = {
  senderType: 'user' | 'admin';
  channel: 'message' | 'email';
  content: string;
  createdAt: string;
};

type SupportTicket = {
  _id: string;
  subject: string;
  status: 'open' | 'pending' | 'resolved' | 'closed';
  priority: 'low' | 'medium' | 'high';
  initialChannel: 'message' | 'email';
  createdAt: string;
  updatedAt: string;
  user?: { name?: string; email?: string; phone?: string };
  messages: SupportMessage[];
};

type SupportConfig = {
  phone: string;
  email: string;
  whatsapp: string;
};

export function SupportView({
  initialTickets,
  initialConfig,
  canManage,
}: {
  initialTickets: SupportTicket[];
  initialConfig: SupportConfig;
  canManage: boolean;
}) {
  const [tickets, setTickets] = useState<SupportTicket[]>(initialTickets);
  const [config, setConfig] = useState<SupportConfig>(initialConfig);
  const [selectedTicketId, setSelectedTicketId] = useState<string | null>(initialTickets[0]?._id || null);
  const [replyMessage, setReplyMessage] = useState('');
  const [notice, setNotice] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [statusFilter, setStatusFilter] = useState('all');

  const selectedTicket = useMemo(
    () => tickets.find((item) => item._id === selectedTicketId) || null,
    [tickets, selectedTicketId],
  );

  const filteredTickets = useMemo(
    () => tickets.filter((ticket) => statusFilter === 'all' || ticket.status === statusFilter),
    [tickets, statusFilter],
  );

  function clearFeedback() {
    setNotice(null);
    setError(null);
  }

  async function refreshTickets() {
    const qs = statusFilter !== 'all' ? `?status=${statusFilter}` : '';
    const res = await fetch(`/api/admin/support/tickets${qs}`);
    const body = await res.json().catch(() => null);
    if (!res.ok || !body?.success) {
      setError(body?.message || 'Failed to load tickets');
      return;
    }
    const next = (body.data || []) as SupportTicket[];
    setTickets(next);
    if (next.length > 0 && !next.some((ticket) => ticket._id === selectedTicketId)) {
      setSelectedTicketId(next[0]._id);
    }
  }

  async function saveConfig() {
    clearFeedback();
    setLoading(true);
    const res = await fetch('/api/admin/support/config', {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(config),
    });
    const body = await res.json().catch(() => null);
    setLoading(false);

    if (!res.ok || !body?.success) {
      setError(body?.message || 'Failed to save support contact details');
      return;
    }

    setConfig(body.data as SupportConfig);
    setNotice('Support contact details updated successfully.');
  }

  async function sendReply(channel: 'message' | 'email') {
    if (!selectedTicket) return;
    clearFeedback();
    if (!replyMessage.trim()) {
      setError('Reply message is required.');
      return;
    }

    setLoading(true);
    const res = await fetch(`/api/admin/support/tickets/${selectedTicket._id}/reply`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ message: replyMessage, channel }),
    });
    const body = await res.json().catch(() => null);
    setLoading(false);

    if (!res.ok || !body?.success) {
      setError(body?.message || 'Failed to send reply');
      return;
    }

    setReplyMessage('');
    setNotice(channel === 'email' ? 'Email reply sent.' : 'In-app message sent.');
    await refreshTickets();
  }

  async function updateStatus(status: SupportTicket['status']) {
    if (!selectedTicket) return;
    clearFeedback();
    setLoading(true);
    const res = await fetch(`/api/admin/support/tickets/${selectedTicket._id}/status`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ status }),
    });
    const body = await res.json().catch(() => null);
    setLoading(false);

    if (!res.ok || !body?.success) {
      setError(body?.message || 'Failed to update ticket status');
      return;
    }

    setNotice(`Ticket marked as ${status}.`);
    await refreshTickets();
  }

  return (
    <div className="grid" style={{ gap: 12 }}>
      <div className="card">
        <h4 style={{ marginTop: 0 }}>Support Contact Settings (Mobile App)</h4>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 8 }}>
          <input
            placeholder="Phone"
            value={config.phone}
            disabled={!canManage || loading}
            onChange={(e) => setConfig((prev) => ({ ...prev, phone: e.target.value }))}
          />
          <input
            placeholder="Email"
            value={config.email}
            disabled={!canManage || loading}
            onChange={(e) => setConfig((prev) => ({ ...prev, email: e.target.value }))}
          />
          <input
            placeholder="WhatsApp"
            value={config.whatsapp}
            disabled={!canManage || loading}
            onChange={(e) => setConfig((prev) => ({ ...prev, whatsapp: e.target.value }))}
          />
        </div>
        <div className="toolbar" style={{ marginTop: 8 }}>
          <Button onClick={() => void saveConfig()} disabled={!canManage || loading}>
            {loading ? 'Saving...' : 'Save Contact Settings'}
          </Button>
        </div>
      </div>

      {error ? <p className="muted" style={{ color: '#b42318' }}>{error}</p> : null}
      {notice ? <p className="muted" style={{ color: '#027a48' }}>{notice}</p> : null}

      <div className="card">
        <div className="toolbar" style={{ justifyContent: 'space-between' }}>
          <h4 style={{ margin: 0 }}>Support Inbox</h4>
          <div style={{ display: 'flex', gap: 8 }}>
            <select value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)}>
              <option value="all">All statuses</option>
              <option value="open">Open</option>
              <option value="pending">Pending</option>
              <option value="resolved">Resolved</option>
              <option value="closed">Closed</option>
            </select>
            <Button variant="ghost" onClick={() => void refreshTickets()}>Refresh</Button>
          </div>
        </div>
        <div style={{ display: 'grid', gridTemplateColumns: '340px 1fr', gap: 12 }}>
          <div className="table-wrap" style={{ maxHeight: 560, overflow: 'auto' }}>
            <table>
              <thead>
                <tr>
                  <th>Subject</th>
                  <th>User</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                {filteredTickets.map((ticket) => (
                  <tr
                    key={ticket._id}
                    onClick={() => setSelectedTicketId(ticket._id)}
                    style={{ cursor: 'pointer', backgroundColor: selectedTicketId === ticket._id ? '#f9f4ec' : undefined }}
                  >
                    <td>{ticket.subject}</td>
                    <td>{ticket.user?.name || ticket.user?.email || ticket.user?.phone || 'Unknown'}</td>
                    <td>
                      <Badge tone={ticket.status === 'resolved' ? 'success' : ticket.status === 'pending' ? 'warning' : 'neutral'}>
                        {ticket.status}
                      </Badge>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <div className="card" style={{ minHeight: 400 }}>
            {!selectedTicket ? (
              <p className="muted">No ticket selected.</p>
            ) : (
              <>
                <div className="toolbar" style={{ justifyContent: 'space-between' }}>
                  <div>
                    <h4 style={{ margin: 0 }}>{selectedTicket.subject}</h4>
                    <p className="muted" style={{ marginTop: 4 }}>
                      {selectedTicket.user?.name || 'User'} · {selectedTicket.user?.email || selectedTicket.user?.phone || 'No contact'}
                    </p>
                  </div>
                  <div style={{ display: 'flex', gap: 6 }}>
                    <Button variant="ghost" onClick={() => void updateStatus('pending')} disabled={!canManage || loading}>Pending</Button>
                    <Button variant="ghost" onClick={() => void updateStatus('resolved')} disabled={!canManage || loading}>Resolve</Button>
                    <Button variant="danger" onClick={() => void updateStatus('closed')} disabled={!canManage || loading}>Close</Button>
                  </div>
                </div>

                <div style={{ display: 'grid', gap: 8, maxHeight: 320, overflow: 'auto', margin: '12px 0' }}>
                  {selectedTicket.messages.map((message, index) => (
                    <div
                      key={`${selectedTicket._id}-${index}`}
                      style={{
                        padding: 10,
                        borderRadius: 10,
                        backgroundColor: message.senderType === 'admin' ? '#f9f4ec' : '#ffffff',
                        border: '1px solid #eee4d6',
                      }}
                    >
                      <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 4 }}>
                        <strong>{message.senderType === 'admin' ? 'Admin' : 'User'}</strong>
                        <span className="muted">{new Date(message.createdAt).toLocaleString()} · {message.channel}</span>
                      </div>
                      <p style={{ margin: 0, whiteSpace: 'pre-wrap' }}>{message.content}</p>
                    </div>
                  ))}
                </div>

                <textarea
                  rows={4}
                  placeholder="Type your reply"
                  value={replyMessage}
                  disabled={!canManage || loading}
                  onChange={(e) => setReplyMessage(e.target.value)}
                />
                <div className="toolbar" style={{ marginTop: 8 }}>
                  <Button variant="ghost" onClick={() => void sendReply('message')} disabled={!canManage || loading}>
                    Send In-App Message
                  </Button>
                  <Button onClick={() => void sendReply('email')} disabled={!canManage || loading}>
                    Send Email Reply
                  </Button>
                </div>
              </>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
