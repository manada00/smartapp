const mongoose = require('mongoose');

let connectionPromise = null;

const connectDB = async () => {
  try {
    if (mongoose.connection.readyState === 1) {
      return mongoose.connection;
    }

    if (connectionPromise) {
      return connectionPromise;
    }

    const mongoUri = process.env.MONGODB_URI;
    if (!mongoUri) {
      throw new Error('MONGODB_URI is not set');
    }

    connectionPromise = mongoose.connect(mongoUri, {
      serverSelectionTimeoutMS: 20000,
    })
      .then((conn) => {
        console.log(`MongoDB Connected: ${conn.connection.host}`);
        return conn.connection;
      })
      .catch((error) => {
        connectionPromise = null;
        throw error;
      });

    return connectionPromise;
  } catch (error) {
    console.error(`Error: ${error.message}`);
    throw error;
  }
};

module.exports = connectDB;
