const axios = require('axios');
const mongoose = require('mongoose');
const os = require('os');
const User = require('../../models/User');
const Order = require('../../models/Order');

const HTTP_TIMEOUT_MS = 5000;

const measure = async (fn) => {
  const start = Date.now();
  try {
    const data = await fn();
    return { ok: true, latencyMs: Date.now() - start, data };
  } catch (error) {
    return { ok: false, latencyMs: Date.now() - start, error };
  }
};

const probeService = async ({ name, url }) => {
  const result = await measure(async () => {
    const response = await axios.get(url, { timeout: HTTP_TIMEOUT_MS });
    return { statusCode: response.status };
  });

  if (!result.ok) {
    const isTimeout = result.error?.code === 'ECONNABORTED';
    return {
      service: name,
      status: 'offline',
      latency: `${result.latencyMs}ms`,
      latencyMs: result.latencyMs,
      error: isTimeout ? 'timeout' : (result.error?.message || 'request failed'),
    };
  }

  return {
    service: name,
    status: 'online',
    latency: `${result.latencyMs}ms`,
    latencyMs: result.latencyMs,
    statusCode: result.data.statusCode,
  };
};

const getApiHealth = () => {
  const cpuCount = os.cpus()?.length || 1;
  const oneMinuteLoad = os.loadavg()[0] || 0;

  return {
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    cpuUsage: Number(Math.min(100, (oneMinuteLoad / cpuCount) * 100).toFixed(2)),
    nodeVersion: process.version,
  };
};

const getDatabaseHealth = async () => {
  const start = Date.now();
  try {
    await mongoose.connection.db.admin().ping();
    const [collections, totalUsers, totalOrders] = await Promise.all([
      mongoose.connection.db.listCollections().toArray(),
      User.countDocuments(),
      Order.countDocuments(),
    ]);

    return {
      database: 'connected',
      collections: collections.length,
      totalUsers,
      totalOrders,
      latencyMs: Date.now() - start,
    };
  } catch (error) {
    return {
      database: 'error',
      message: error.message,
      collections: 0,
      totalUsers: 0,
      totalOrders: 0,
      latencyMs: Date.now() - start,
    };
  }
};

const getExternalServicesHealth = async () => {
  const checks = await Promise.all([
    probeService({ name: 'Akedly', url: 'https://api.akedly.io' }),
    probeService({ name: 'Kashier', url: 'https://api.kashier.io' }),
    probeService({ name: 'GitHub', url: 'https://github.com' }),
    probeService({ name: 'Vercel API', url: 'https://api.vercel.com' }),
  ]);

  return checks;
};

const getGithubStatus = async () => {
  const owner = process.env.GITHUB_REPO_OWNER;
  const repo = process.env.GITHUB_REPO_NAME;
  const token = process.env.GITHUB_TOKEN;

  if (!owner || !repo || !token) {
    return {
      status: 'offline',
      error: 'github configuration missing',
    };
  }

  try {
    const headers = {
      Authorization: `Bearer ${token}`,
      Accept: 'application/vnd.github+json',
    };

    const [repoRes, commitsRes] = await Promise.all([
      axios.get(`https://api.github.com/repos/${owner}/${repo}`, { headers, timeout: HTTP_TIMEOUT_MS }),
      axios.get(`https://api.github.com/repos/${owner}/${repo}/commits?per_page=1`, { headers, timeout: HTTP_TIMEOUT_MS }),
    ]);

    const latest = commitsRes.data?.[0];
    const sha = latest?.sha;
    let ciStatus = 'unknown';

    if (sha) {
      const checksRes = await axios.get(`https://api.github.com/repos/${owner}/${repo}/commits/${sha}/check-runs`, {
        headers,
        timeout: HTTP_TIMEOUT_MS,
      });
      const runs = checksRes.data?.check_runs || [];
      const failed = runs.find((run) => run.conclusion === 'failure' || run.conclusion === 'timed_out');
      const successful = runs.length > 0 && runs.every((run) => run.conclusion === 'success' || run.status === 'completed');
      ciStatus = failed ? 'failed' : successful ? 'success' : 'pending';
    }

    return {
      status: 'online',
      latestCommit: sha || null,
      latestCommitMessage: latest?.commit?.message || null,
      branch: repoRes.data?.default_branch || null,
      ciStatus,
      lastPush: repoRes.data?.pushed_at || latest?.commit?.committer?.date || null,
    };
  } catch (error) {
    return {
      status: 'offline',
      error: error.message,
    };
  }
};

const getVercelStatus = async () => {
  const token = process.env.VERCEL_TOKEN;
  const projectId = process.env.VERCEL_PROJECT_ID;
  const teamId = process.env.VERCEL_TEAM_ID;

  if (!token || !projectId) {
    return {
      status: 'offline',
      error: 'vercel configuration missing',
    };
  }

  try {
    const params = new URLSearchParams({ projectId, limit: '1' });
    if (teamId) {
      params.append('teamId', teamId);
    }

    const response = await axios.get(`https://api.vercel.com/v6/deployments?${params.toString()}`, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
      timeout: HTTP_TIMEOUT_MS,
    });

    const deployment = response.data?.deployments?.[0];

    return {
      status: 'online',
      vercelStatus: deployment?.readyState || 'UNKNOWN',
      lastDeployment: deployment?.createdAt ? new Date(deployment.createdAt).toISOString() : null,
      deploymentUrl: deployment?.url ? `https://${deployment.url}` : null,
      buildLogs: deployment?.inspectorUrl || null,
    };
  } catch (error) {
    return {
      status: 'offline',
      error: error.message,
    };
  }
};

const getMobileApiConnectivity = async () => {
  const endpoint = process.env.MOBILE_API_HEALTH_URL || process.env.PUBLIC_API_URL;
  if (!endpoint) {
    return {
      service: 'Mobile API',
      status: 'offline',
      error: 'mobile api health url missing',
    };
  }

  return probeService({ name: 'Mobile API', url: endpoint });
};

module.exports = {
  getApiHealth,
  getDatabaseHealth,
  getExternalServicesHealth,
  getGithubStatus,
  getVercelStatus,
  getMobileApiConnectivity,
};
