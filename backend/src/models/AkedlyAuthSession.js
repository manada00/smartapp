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
  phoneNumber: {
    type: String,
    index: true,
  },
  status: {
    type: String,
    enum: ['pending', 'verified', 'success', 'failed'],
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
  metadata: mongoose.Schema.Types.Mixed,
  verifiedAt: {
    type: Date,
  },
  expiresAt: {
    type: Date,
  },
}, {
  timestamps: true,
});

akedlyAuthSessionSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });
akedlyAuthSessionSchema.index({ createdAt: -1 });

akedlyAuthSessionSchema.pre('validate', function(next) {
  if (!this.phoneNumber && this.phone) {
    this.phoneNumber = this.phone;
  }

  if (!this.phone && this.phoneNumber) {
    this.phone = this.phoneNumber;
  }

  next();
});

module.exports = mongoose.model('AkedlyAuthSession', akedlyAuthSessionSchema);
