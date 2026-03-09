'use client';

import { useEffect, useMemo, useState } from 'react';
import { Badge, Card } from '@/components/ui/primitives';

type ServiceState = {
  service: string;
  status: 'online' | 'offline';
  latency?: string | null;
  error?: string;
};

type HealthPayload = {
  api: {
    uptime: number;
    cpuUsage: number;
    memory: { rss: number; heapUsed: number };
    nodeVersion: string;
  };
  database: { database: string; latencyMs: number; totalUsers: number; totalOrders: number; message?: string };
  services: ServiceState[];
  github: { status: string; latestCommit?: string; ciStatus?: string; lastPush?: string; error?: string };
  vercel: { status: string; vercelStatus?: string; lastDeployment?: string; deploymentUrl?: string; buildLogs?: string; error?: string };
  activeUsers: { activeUsers: number; mobileUsers: number; webUsers: number };
  requestMetrics: { requestCount: number; errorRate: number };
};

type MetricPoint = {
  timestamp: string;
  cpuUsage: number;
  requestCount: number;
  errorRate: number;
  activeUsers: number;
  memoryUsage?: { heapUsed?: number };
};

type SystemLog = {
  _id: string;
  timestamp: string;
  service: string;
  level: 'error' | 'warning' | 'info';
  message: string;
  requestPath?: string;
};

type RecentError = {
  _id: string;
  timestamp: string;
  service: string;
  level: 'error' | 'warning' | 'info';
  message: string;
  requestPath?: string;
};

type MetricsSummary = {
  dailyRevenue: number;
  ordersToday: number;
  newUsers: number;
  activeUsers: number;
  revenueOverTime: Array<{ date: string; revenue: number }>;
  ordersPerHour: Array<{ hour: number; count: number }>;
  activeUsersTrend: Array<{ timestamp: string; activeUsers: number }>;
  recentErrors: RecentError[];
};

function TinyChart({ values, color }: { values: number[]; color: string }) {
  if (!values.length) return <div className="muted">No data</div>;

  const max = Math.max(...values, 1);
  const min = Math.min(...values, 0);
  const points = values.map((value, index) => {
    const x = values.length === 1 ? 0 : (index / (values.length - 1)) * 100;
    const y = max === min ? 50 : 100 - ((value - min) / (max - min)) * 100;
    return `${x},${y}`;
  }).join(' ');

  return (
    <svg viewBox="0 0 100 100" preserveAspectRatio="none" style={{ width: '100%', height: 90 }}>
      <polyline fill="none" stroke={color} strokeWidth="2" points={points} />
    </svg>
  );
}

export function SystemHealthDashboard() {
  const [health, setHealth] = useState<HealthPayload | null>(null);
  const [metrics, setMetrics] = useState<MetricPoint[]>([]);
  const [summary, setSummary] = useState<MetricsSummary | null>(null);
  const [logs, setLogs] = useState<SystemLog[]>([]);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let active = true;

    const load = async () => {
      try {
        const [healthRes, metricsRes, summaryRes, logsRes] = await Promise.all([
          fetch('/api/admin/system-health'),
          fetch('/api/admin/system-metrics?minutes=180'),
          fetch('/api/admin/metrics'),
          fetch('/api/admin/logs'),
        ]);

        const [healthBody, metricsBody, summaryBody, logsBody] = await Promise.all([
          healthRes.json(),
          metricsRes.json(),
          summaryRes.json(),
          logsRes.json(),
        ]);

        if (!active) return;

        if (!healthRes.ok || !healthBody?.success) {
          setError(healthBody?.message || 'Failed to load health data');
          return;
        }

        setError(null);
        setHealth(healthBody.data as HealthPayload);
        setMetrics(Array.isArray(metricsBody?.data) ? metricsBody.data as MetricPoint[] : []);
        setSummary(summaryBody?.success ? summaryBody.data as MetricsSummary : null);
        setLogs(Array.isArray(logsBody?.data) ? logsBody.data as SystemLog[] : []);
      } catch (requestError) {
        if (!active) return;
        setError(requestError instanceof Error ? requestError.message : 'Failed to load dashboard');
      }
    };

    void load();
    const interval = setInterval(() => void load(), 10000);

    return () => {
      active = false;
      clearInterval(interval);
    };
  }, []);

  const metricSeries = useMemo(() => ({
    activeUsers: (summary?.activeUsersTrend || []).map((point) => Number(point.activeUsers || 0)).slice(-30),
    revenueOverTime: (summary?.revenueOverTime || []).map((point) => Number(point.revenue || 0)).slice(-30),
    ordersPerHour: (summary?.ordersPerHour || []).map((point) => Number(point.count || 0)).slice(-24),
    requestRate: metrics.map((point) => Number(point.requestCount || 0)).slice(-30),
    errorRate: metrics.map((point) => Number(point.errorRate || 0)).slice(-30),
    memoryMb: metrics.map((point) => Number(((point.memoryUsage?.heapUsed || 0) / (1024 * 1024)).toFixed(2))).slice(-30),
    cpuUsage: metrics.map((point) => Number(point.cpuUsage || 0)).slice(-30),
  }), [metrics, summary]);

  const serviceCards = useMemo(() => {
    const dynamicServices = (health?.services || []).map((service) => ({
      label: service.service,
      status: service.status,
      latency: service.latency || null,
      error: service.error,
    }));

    return [
      { label: 'Backend API', status: health ? 'online' : 'offline', latency: null, error: error || undefined },
      {
        label: 'MongoDB',
        status: health?.database.database === 'connected' ? 'online' : 'offline',
        latency: health ? `${health.database.latencyMs}ms` : null,
        error: health?.database.message,
      },
      ...dynamicServices,
    ];
  }, [error, health]);

  return (
    <div className="grid" style={{ gap: 16 }}>
      <Card>
        <h3>System Health Dashboard</h3>
        {error ? <p style={{ color: '#b42318' }}>{error}</p> : <p className="muted">Live refresh every 10 seconds.</p>}
      </Card>

      <div className="grid" style={{ gridTemplateColumns: 'repeat(3, minmax(0, 1fr))' }}>
        {serviceCards.map((service) => (
          <Card key={service.label}>
            <h3>{service.label}</h3>
            <div style={{ display: 'flex', justifyContent: 'space-between' }}>
              <Badge tone={(service.status === 'online' || service.status === 'connected') ? 'success' : 'danger'}>
                {service.status === 'online' ? 'Online' : 'Offline'}
              </Badge>
              <span className="muted">{service.latency || 'n/a'}</span>
            </div>
            {service.error ? <p className="muted" style={{ color: '#b42318' }}>{service.error}</p> : null}
          </Card>
        ))}
      </div>

      <div className="grid" style={{ gridTemplateColumns: 'repeat(4, minmax(0, 1fr))' }}>
        <Card><h3>Daily Revenue</h3><p>EGP {Number(summary?.dailyRevenue || 0).toFixed(2)}</p></Card>
        <Card><h3>Orders Today</h3><p>{summary?.ordersToday || 0}</p></Card>
        <Card><h3>New Users</h3><p>{summary?.newUsers || 0}</p></Card>
        <Card><h3>Active Users</h3><p>{summary?.activeUsers || 0}</p></Card>
      </div>

      <div className="grid" style={{ gridTemplateColumns: 'repeat(3, minmax(0, 1fr))' }}>
        <Card><h3>Revenue over time</h3><TinyChart values={metricSeries.revenueOverTime} color="#22c55e" /></Card>
        <Card><h3>Orders per hour</h3><TinyChart values={metricSeries.ordersPerHour} color="#3b82f6" /></Card>
        <Card><h3>Active users trend</h3><TinyChart values={metricSeries.activeUsers} color="#8b5cf6" /></Card>
      </div>

      <div className="grid" style={{ gridTemplateColumns: '1fr 1fr' }}>
        <Card>
          <h3>Recent Errors</h3>
          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>Time</th>
                  <th>Service</th>
                  <th>Level</th>
                  <th>Path</th>
                  <th>Message</th>
                </tr>
              </thead>
              <tbody>
                {(summary?.recentErrors || []).slice(0, 20).map((item) => (
                  <tr key={item._id}>
                    <td>{new Date(item.timestamp).toLocaleTimeString()}</td>
                    <td>{item.service}</td>
                    <td><Badge tone={item.level === 'error' ? 'danger' : item.level === 'warning' ? 'warning' : 'neutral'}>{item.level}</Badge></td>
                    <td>{item.requestPath || '-'}</td>
                    <td>{item.message}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </Card>

        <Card>
          <h3>Recent Logs</h3>
          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>Timestamp</th>
                  <th>Service</th>
                  <th>Level</th>
                  <th>Message</th>
                </tr>
              </thead>
              <tbody>
                {logs.slice(0, 100).map((log) => (
                  <tr key={log._id}>
                    <td>{new Date(log.timestamp).toLocaleString()}</td>
                    <td>{log.service}</td>
                    <td><Badge tone={log.level === 'error' ? 'danger' : log.level === 'warning' ? 'warning' : 'neutral'}>{log.level}</Badge></td>
                    <td>{log.message}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </Card>
      </div>
    </div>
  );
}
