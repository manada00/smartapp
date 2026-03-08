const crypto = require('crypto');
const os = require('os');

const ACTIVE_TTL_MS = 15 * 60 * 1000;

const state = {
  sessions: new Map(),
  requestCount: 0,
  errorCount: 0,
  lastWindowStartedAt: Date.now(),
  lastWindowRequestCount: 0,
  lastWindowErrorCount: 0,
};

const cleanupSessions = () => {
  const now = Date.now();
  for (const [key, session] of state.sessions.entries()) {
    if (now - session.lastSeenAt > ACTIVE_TTL_MS) {
      state.sessions.delete(key);
    }
  }
};

const detectPlatform = (req) => {
  const declared = String(req.headers['x-client-platform'] || '').toLowerCase();
  if (declared.includes('mobile')) return 'mobile';
  if (declared.includes('web')) return 'web';

  const userAgent = String(req.headers['user-agent'] || '').toLowerCase();
  if (userAgent.includes('dart') || userAgent.includes('flutter') || userAgent.includes('android') || userAgent.includes('iphone')) {
    return 'mobile';
  }

  return 'web';
};

const resolveUserId = (req) => {
  if (req.user?._id) return String(req.user._id);
  if (req.admin?._id) return String(req.admin._id);
  return null;
};

const buildSessionId = (req) => {
  const userId = resolveUserId(req);
  const ip = String(req.ip || req.headers['x-forwarded-for'] || 'unknown');
  const ua = String(req.headers['user-agent'] || 'unknown');
  const hash = crypto.createHash('sha1').update(`${ip}:${ua}`).digest('hex').slice(0, 16);
  return { userId, key: userId ? `user:${userId}` : `anon:${hash}` };
};

const registerRequest = (req) => {
  const platform = detectPlatform(req);
  const { userId, key } = buildSessionId(req);
  state.requestCount += 1;
  state.sessions.set(key, {
    userId,
    platform,
    lastSeenAt: Date.now(),
  });
  cleanupSessions();
};

const registerError = () => {
  state.errorCount += 1;
};

const rotateWindow = () => {
  const now = Date.now();
  if (now - state.lastWindowStartedAt < 60 * 1000) {
    return;
  }

  state.lastWindowRequestCount = state.requestCount;
  state.lastWindowErrorCount = state.errorCount;
  state.requestCount = 0;
  state.errorCount = 0;
  state.lastWindowStartedAt = now;
};

const getActiveUsers = () => {
  cleanupSessions();
  const mobileUsers = new Set();
  const webUsers = new Set();

  for (const [key, session] of state.sessions.entries()) {
    const identifier = session.userId || key;
    if (session.platform === 'mobile') {
      mobileUsers.add(identifier);
    } else {
      webUsers.add(identifier);
    }
  }

  const combined = new Set([...mobileUsers, ...webUsers]);

  return {
    activeUsers: combined.size,
    mobileUsers: mobileUsers.size,
    webUsers: webUsers.size,
  };
};

const getRequestMetrics = () => {
  rotateWindow();

  const requestCount = state.lastWindowRequestCount;
  const errorCount = state.lastWindowErrorCount;
  const errorRate = requestCount > 0 ? Number(((errorCount / requestCount) * 100).toFixed(2)) : 0;

  return {
    requestCount,
    errorCount,
    errorRate,
  };
};

const getProcessMetrics = () => {
  const cpuCount = os.cpus()?.length || 1;
  const oneMinuteLoad = os.loadavg()[0] || 0;
  const cpuUsage = Number(Math.min(100, (oneMinuteLoad / cpuCount) * 100).toFixed(2));
  return {
    cpuUsage,
    memoryUsage: process.memoryUsage(),
  };
};

module.exports = {
  registerRequest,
  registerError,
  getActiveUsers,
  getRequestMetrics,
  getProcessMetrics,
};
