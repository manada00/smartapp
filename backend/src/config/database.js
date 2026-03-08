const mongoose = require('mongoose');

mongoose.set('bufferCommands', false);

let connectionPromise = null;
let lastSuccessfulPingAt = 0;

const PING_INTERVAL_MS = 15 * 1000;
const PING_TIMEOUT_MS = 3000;

const pingWithTimeout = async () => {
  if (!mongoose.connection?.db) {
    throw new Error('MongoDB connection is not ready');
  }

  await Promise.race([
    mongoose.connection.db.admin().ping(),
    new Promise((_, reject) => {
      setTimeout(() => reject(new Error('MongoDB ping timeout')), PING_TIMEOUT_MS);
    }),
  ]);
};

const connectDB = async () => {
  try {
    if (mongoose.connection.readyState === 1) {
      const now = Date.now();
      if (now - lastSuccessfulPingAt > PING_INTERVAL_MS) {
        try {
          await pingWithTimeout();
          lastSuccessfulPingAt = Date.now();
        } catch (error) {
          connectionPromise = null;
          lastSuccessfulPingAt = 0;
          await mongoose.disconnect().catch(() => {});
        }
      }

      if (mongoose.connection.readyState === 1) {
        return mongoose.connection;
      }

      return connectDB();
    }

    if (mongoose.connection.readyState === 3) {
      await mongoose.disconnect().catch(() => {});
      connectionPromise = null;
      lastSuccessfulPingAt = 0;
    }

    if (mongoose.connection.readyState === 1) {
      return mongoose.connection;
    }

    if (connectionPromise) {
      return connectionPromise;
    }

    if (mongoose.connection.readyState === 2 && mongoose.connection.asPromise) {
      connectionPromise = mongoose.connection.asPromise()
        .then(async () => {
          await pingWithTimeout();
          lastSuccessfulPingAt = Date.now();
          return mongoose.connection;
        })
        .catch((error) => {
          connectionPromise = null;
          lastSuccessfulPingAt = 0;
          throw error;
        });
      return connectionPromise;
    }

    const mongoUri = process.env.MONGODB_URI;
    if (!mongoUri) {
      throw new Error('MONGODB_URI is not set');
    }

    connectionPromise = mongoose.connect(mongoUri, {
      serverSelectionTimeoutMS: 8000,
      socketTimeoutMS: 10000,
      maxPoolSize: 10,
    })
      .then(async (conn) => {
        await pingWithTimeout();
        lastSuccessfulPingAt = Date.now();
        console.log(`MongoDB Connected: ${conn.connection.host}`);
        return conn.connection;
      })
      .catch((error) => {
        connectionPromise = null;
        lastSuccessfulPingAt = 0;
        throw error;
      });

    return connectionPromise;
  } catch (error) {
    console.error(`Error: ${error.message}`);
    throw error;
  }
};

module.exports = connectDB;
