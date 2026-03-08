const mongoose = require('mongoose');

const systemAlertSchema = new mongoose.Schema({
  timestamp: {
    type: Date,
    default: Date.now,
    index: true,
  },
  type: {
    type: String,
    required: true,
    index: true,
  },
  severity: {
    type: String,
    enum: ['warning', 'critical'],
    default: 'warning',
  },
  service: {
    type: String,
    required: true,
    index: true,
  },
  message: {
    type: String,
    required: true,
  },
  data: mongoose.Schema.Types.Mixed,
  resolved: {
    type: Boolean,
    default: false,
    index: true,
  },
}, {
  timestamps: true,
  collection: 'system_alerts',
});

module.exports = mongoose.model('SystemAlert', systemAlertSchema);
