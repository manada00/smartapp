const mongoose = require('mongoose');

const systemMetricSchema = new mongoose.Schema({
  timestamp: {
    type: Date,
    default: Date.now,
    index: true,
  },
  cpuUsage: Number,
  memoryUsage: {
    rss: Number,
    heapTotal: Number,
    heapUsed: Number,
    external: Number,
    arrayBuffers: Number,
  },
  requestCount: {
    type: Number,
    default: 0,
  },
  errorRate: {
    type: Number,
    default: 0,
  },
  activeUsers: {
    type: Number,
    default: 0,
  },
  apiLatencyMs: Number,
  databaseStatus: String,
  services: [{
    name: String,
    status: String,
    latencyMs: Number,
    error: String,
  }],
}, {
  timestamps: true,
  collection: 'system_metrics',
});

module.exports = mongoose.model('SystemMetric', systemMetricSchema);
