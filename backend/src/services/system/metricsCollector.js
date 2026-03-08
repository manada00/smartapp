const SystemMetric = require('../../models/SystemMetric');
const SystemAlert = require('../../models/SystemAlert');
const {
  getProcessMetrics,
  getRequestMetrics,
  getActiveUsers,
} = require('./runtimeState');
const {
  getDatabaseHealth,
  getExternalServicesHealth,
  getVercelStatus,
} = require('./systemHealthService');
const { logSystemEvent } = require('./systemLogger');

let collector = null;

const createAlertIfNeeded = async ({ type, service, message, severity = 'warning', data }) => {
  const existing = await SystemAlert.findOne({
    type,
    service,
    resolved: false,
    createdAt: { $gte: new Date(Date.now() - 30 * 60 * 1000) },
  });

  if (existing) {
    return existing;
  }

  return SystemAlert.create({
    timestamp: new Date(),
    type,
    service,
    message,
    severity,
    data,
    resolved: false,
  });
};

const runMetricsCollection = async () => {
  const [{ cpuUsage, memoryUsage }, requestMetrics, activeUsers, database, services, vercel] = await Promise.all([
    Promise.resolve(getProcessMetrics()),
    Promise.resolve(getRequestMetrics()),
    Promise.resolve(getActiveUsers()),
    getDatabaseHealth(),
    getExternalServicesHealth(),
    getVercelStatus(),
  ]);

  const apiLatencyMs = Number(memoryUsage?.rss ? Math.round((memoryUsage.rss / (1024 * 1024)) / 10) : 0);

  await SystemMetric.create({
    timestamp: new Date(),
    cpuUsage,
    memoryUsage,
    requestCount: requestMetrics.requestCount,
    errorRate: requestMetrics.errorRate,
    activeUsers: activeUsers.activeUsers,
    apiLatencyMs,
    databaseStatus: database.database,
    services: services.map((service) => ({
      name: service.service,
      status: service.status,
      latencyMs: service.latencyMs,
      error: service.error,
    })),
  });

  if (database.database !== 'connected') {
    await createAlertIfNeeded({
      type: 'database_disconnected',
      service: 'mongodb',
      severity: 'critical',
      message: database.message || 'MongoDB disconnected',
      data: database,
    });
  }

  if (requestMetrics.errorRate > 10) {
    await createAlertIfNeeded({
      type: 'high_error_rate',
      service: 'backend_api',
      severity: 'critical',
      message: `Error rate is ${requestMetrics.errorRate}%`,
      data: requestMetrics,
    });
  }

  for (const service of services) {
    if (service.status !== 'online') {
      await createAlertIfNeeded({
        type: 'external_service_unreachable',
        service: service.service,
        severity: 'warning',
        message: service.error || `${service.service} is unreachable`,
        data: service,
      });
    }
  }

  if (vercel.vercelStatus && vercel.vercelStatus !== 'READY') {
    await createAlertIfNeeded({
      type: 'deployment_failed',
      service: 'vercel',
      severity: 'critical',
      message: `Latest deployment state: ${vercel.vercelStatus}`,
      data: vercel,
    });
  }
};

const startMetricsCollector = () => {
  if (collector) {
    return;
  }

  const tick = async () => {
    try {
      await runMetricsCollection();
    } catch (error) {
      await logSystemEvent({
        level: 'error',
        service: 'metrics_collector',
        message: error.message,
        stackTrace: error,
      });
    }
  };

  void tick();
  collector = setInterval(() => {
    void tick();
  }, 60 * 1000);
};

module.exports = {
  startMetricsCollector,
  runMetricsCollection,
};
