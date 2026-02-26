const mongoose = require('mongoose');

const subscriptionSchema = new mongoose.Schema({
  user_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true,
  },
  plan_id: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
  },
  status: {
    type: String,
    enum: ['active', 'paused', 'cancelled'],
    default: 'active',
    index: true,
  },
  billing_cycle: {
    type: String,
    enum: ['weekly', 'monthly'],
    required: true,
  },
  next_billing_date: {
    type: Date,
    required: true,
    index: true,
  },
  last_payment_date: Date,
  payment_provider: {
    type: String,
    default: 'mock',
  },
  payment_token: {
    type: String,
    default: null,
  },
  payment_reference: {
    type: String,
    sparse: true,
    index: true,
  },
  created_at: {
    type: Date,
    default: Date.now,
  },
  updated_at: {
    type: Date,
    default: Date.now,
  },
}, {
  timestamps: true,
});

subscriptionSchema.pre('save', function(next) {
  if (!this.created_at) {
    this.created_at = this.createdAt || new Date();
  }

  this.updated_at = new Date();
  next();
});

subscriptionSchema.index({ user_id: 1 });
subscriptionSchema.index({ status: 1 });
subscriptionSchema.index({ next_billing_date: 1 });

module.exports = mongoose.model('Subscription', subscriptionSchema);
