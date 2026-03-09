let sentry = null;

const initCrashReporter = () => {
  const dsn = process.env.SENTRY_DSN;
  if (!dsn) {
    return false;
  }

  try {
    sentry = require('@sentry/node');
    sentry.init({
      dsn,
      environment: process.env.NODE_ENV || 'development',
      tracesSampleRate: Number(process.env.SENTRY_TRACES_SAMPLE_RATE || 0),
    });
    return true;
  } catch (_) {
    sentry = null;
    return false;
  }
};

const captureException = (error, context = {}) => {
  if (!sentry || !error) {
    return;
  }

  sentry.captureException(error, {
    extra: context,
  });
};

module.exports = {
  initCrashReporter,
  captureException,
};
