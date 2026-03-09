const mongoose = require('mongoose');
const SystemLog = require('../../models/SystemLog');

const toStack = (value) => {
  if (!value) return undefined;
  if (value instanceof Error) return value.stack;
  return String(value);
};

const logSystemEvent = async ({
  level = 'info',
  service = 'api',
  message,
  stackTrace,
  requestPath,
}) => {
  if (!message) return;

  const normalizedStack = toStack(stackTrace);

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
      requestPath: requestPath ? String(requestPath) : undefined,
      stack: normalizedStack,
      stackTrace: normalizedStack,
    });
  } catch (error) {
    console.error(`[system-logger] ${error.message}`);
  }
};

module.exports = {
  logSystemEvent,
};
