const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  phone: {
    type: String,
    unique: true,
    sparse: true,
  },
  firebaseUid: {
    type: String,
    unique: true,
    sparse: true,
  },
  socialProvider: {
    type: String,
    enum: ['phone', 'google', 'facebook', 'apple'],
  },
  name: String,
  email: String,
  profileImage: String,
  dateOfBirth: Date,
  gender: {
    type: String,
    enum: ['male', 'female', 'prefer_not_to_say'],
  },
  healthGoals: [{
    type: String,
    enum: [
      'lose_weight', 'build_muscle', 'maintain_weight', 'stable_energy',
      'better_digestion', 'improve_sleep', 'hormonal_balance', 'gym_performance',
      'kids_nutrition', 'reduce_cravings', 'ramadan_fasting'
    ],
  }],
  dietaryPreferences: {
    isVegetarian: { type: Boolean, default: false },
    isVegan: { type: Boolean, default: false },
    isDairyFree: { type: Boolean, default: false },
    isGlutenFree: { type: Boolean, default: false },
    isKetoFriendly: { type: Boolean, default: false },
    allergies: [String],
    dislikes: [String],
  },
  dailyRoutine: {
    workStartTime: { type: String, default: '09:00' },
    workEndTime: { type: String, default: '18:00' },
    trainingDays: [String],
    trainingTime: String,
    sleepTime: { type: String, default: '23:00' },
  },
  loyaltyInfo: {
    points: { type: Number, default: 0 },
    tier: { type: String, default: 'Bronze', enum: ['Bronze', 'Silver', 'Gold', 'Platinum'] },
    totalOrders: { type: Number, default: 0 },
    totalSpent: { type: Number, default: 0 },
  },
  wallet: {
    balance: { type: Number, default: 0 },
  },
  referralCode: String,
  referredBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  isOnboardingComplete: { type: Boolean, default: false },
  fcmToken: String,
  refreshTokens: [String],
  isBlocked: {
    type: Boolean,
    default: false,
  },
}, {
  timestamps: true,
});

userSchema.methods.addPoints = function(points) {
  this.loyaltyInfo.points += points;
  
  // Update tier based on points
  if (this.loyaltyInfo.points >= 5000) {
    this.loyaltyInfo.tier = 'Platinum';
  } else if (this.loyaltyInfo.points >= 1500) {
    this.loyaltyInfo.tier = 'Gold';
  } else if (this.loyaltyInfo.points >= 500) {
    this.loyaltyInfo.tier = 'Silver';
  }
};

module.exports = mongoose.model('User', userSchema);
