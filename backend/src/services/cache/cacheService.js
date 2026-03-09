const DEFAULT_TTL_SECONDS = 300;

const memoryStore = new Map();
let redisClient = null;
let redisInitPromise = null;

const now = () => Date.now();

const initRedis = async () => {
  if (redisClient || redisInitPromise) {
    return redisInitPromise;
  }

  const redisUrl = process.env.REDIS_URL;
  if (!redisUrl) {
    return null;
  }

  redisInitPromise = (async () => {
    try {
      const { createClient } = require('redis');
      const client = createClient({ url: redisUrl });
      client.on('error', () => {});
      await client.connect();
      redisClient = client;
      return redisClient;
    } catch (_) {
      redisClient = null;
      return null;
    }
  })();

  return redisInitPromise;
};

const get = async (key) => {
  await initRedis();

  if (redisClient) {
    const value = await redisClient.get(key);
    if (!value) return null;
    return JSON.parse(value);
  }

  const cached = memoryStore.get(key);
  if (!cached) return null;

  if (cached.expiresAt <= now()) {
    memoryStore.delete(key);
    return null;
  }

  return cached.value;
};

const set = async (key, value, ttlSeconds = DEFAULT_TTL_SECONDS) => {
  await initRedis();

  if (redisClient) {
    await redisClient.set(key, JSON.stringify(value), { EX: Math.max(1, ttlSeconds) });
    return;
  }

  memoryStore.set(key, {
    value,
    expiresAt: now() + (Math.max(1, ttlSeconds) * 1000),
  });
};

const del = async (key) => {
  await initRedis();

  if (redisClient) {
    await redisClient.del(key);
    return;
  }

  memoryStore.delete(key);
};

module.exports = {
  get,
  set,
  del,
};
