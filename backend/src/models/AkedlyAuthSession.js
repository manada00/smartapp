const mongoose = require('mongoose');

const akedlyAuthSessionSchema = new mongoose.Schema({
  attemptId: {
    type: String,
    unique: true,
    sparse: true,
    index: true,
  },
  transactionId: {
    type: String,
    unique: true,
    sparse: true,
    index: true,
  },
  phone: {
    type: String,
    index: true,
  },
  status: {
    type: String,
    enum: ['pending', 'success', 'failed'],
    default: 'pending',
    index: true,
  },
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    index: true,
  },
  accessToken: String,
  refreshToken: String,
  isNewUser: {
    type: Boolean,
    default: false,
  },
  payload: mongoose.Schema.Types.Mixed,
  expiresAt: {
    type: Date,
  },
}, {
  timestamps: true,
});

akedlyAuthSessionSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });

module.exports = mongoose.model('AkedlyAuthSession', akedlyAuthSessionSchema);
