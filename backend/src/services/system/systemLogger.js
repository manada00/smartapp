const mongoose = require('mongoose');
const SystemLog = require('../../models/SystemLog');

const toStack = (value) => {
  if (!value) return undefined;
  if (value instanceof Error) return value.stack;
  return String(value);
};

const logSystemEvent = async ({ level = 'info', service = 'api', message, stackTrace }) => {
  if (!message) return;

  try {
    if (mongoose.connection.readyState !== 1) {
      console[level === 'error' ? 'error' : 'log'](`[${service}] ${message}`);
      return;
    }

    await SystemLog.create({
      timestamp: new Date(),
      level,
      service,
      message: String(message),
      stackTrace: toStack(stackTrace),
    });
  } catch (error) {
    console.error(`[system-logger] ${error.message}`);
  }
};

module.exports = {
  logSystemEvent,
};
