const { registerRequest, registerError } = require('../services/system/runtimeState');
const { logSystemEvent } = require('../services/system/systemLogger');
const { captureException } = require('../services/system/crashReporter');

const resolveService = (path) => {
  if (String(path).includes('/webhooks')) return 'webhook';
  if (String(path).includes('/admin')) return 'admin_api';
  return 'backend_api';
};

const trackRequestMetrics = (req, res, next) => {
  registerRequest(req);

  res.on('finish', () => {
    if (res.statusCode >= 500) {
      registerError();
      void logSystemEvent({
        level: 'error',
        service: resolveService(req.path),
        message: `${req.method} ${req.originalUrl} failed with status ${res.statusCode}`,
        requestPath: req.originalUrl,
      });
    }
  });

  next();
};

const captureUnhandledErrors = () => {
  process.on('uncaughtException', (error) => {
    void logSystemEvent({
      level: 'error',
      service: 'process',
      message: `Uncaught exception: ${error.message}`,
      stackTrace: error,
    });
    captureException(error, { source: 'uncaughtException' });
  });

  process.on('unhandledRejection', (reason) => {
    const error = reason instanceof Error ? reason : new Error(String(reason));
    void logSystemEvent({
      level: 'error',
      service: 'process',
      message: `Unhandled rejection: ${error.message}`,
      stackTrace: error,
    });
    captureException(error, { source: 'unhandledRejection' });
  });
};

module.exports = {
  trackRequestMetrics,
  captureUnhandledErrors,
};
