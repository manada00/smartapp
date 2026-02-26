const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const adminUserSchema = new mongoose.Schema(
  {
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },
    passwordHash: {
      type: String,
      required: true,
    },
    role: {
      type: String,
      enum: ['SUPER_ADMIN', 'OPERATIONS_ADMIN', 'SUPPORT_ADMIN'],
      default: 'SUPPORT_ADMIN',
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    lastLoginAt: Date,
  },
  { timestamps: true },
);

adminUserSchema.pre('save', async function(next) {
  if (!this.isModified('passwordHash')) return next();
  if (typeof this.passwordHash === 'string' && this.passwordHash.startsWith('$2')) return next();
  this.passwordHash = await bcrypt.hash(this.passwordHash, 10);
  next();
});

module.exports = mongoose.model('AdminUser', adminUserSchema);
