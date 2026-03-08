const mongoose = require('mongoose');

const systemLogSchema = new mongoose.Schema({
  timestamp: {
    type: Date,
    default: Date.now,
    index: true,
  },
  level: {
    type: String,
    enum: ['error', 'warning', 'info'],
    required: true,
    index: true,
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
  stackTrace: String,
}, {
  timestamps: true,
  collection: 'system_logs',
});

module.exports = mongoose.model('SystemLog', systemLogSchema);
