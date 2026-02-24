const mongoose = require('mongoose');

const foodSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
  },
  description: {
    type: String,
    required: true,
  },
  category: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Category',
    required: true,
  },
  images: [String],
  price: {
    type: Number,
    required: true,
  },
  originalPrice: Number,
  preparationTime: {
    type: Number,
    required: true,
  },
  rating: {
    type: Number,
    default: 0,
  },
  reviewCount: {
    type: Number,
    default: 0,
  },
  functionalScores: {
    energyStability: { type: Number, min: 1, max: 5, default: 3 },
    satiety: { type: Number, min: 1, max: 5, default: 3 },
    insulinImpact: { type: Number, min: 1, max: 5, default: 3 },
    digestionEase: { type: Number, min: 1, max: 5, default: 3 },
    focusSupport: { type: Number, min: 1, max: 5, default: 3 },
    sleepFriendly: { type: Number, min: 1, max: 5, default: 3 },
    kidFriendly: { type: Number, min: 1, max: 5, default: 3 },
    workoutSupport: { type: Number, min: 1, max: 5, default: 3 },
  },
  nutritionInfo: {
    calories: Number,
    protein: Number,
    carbs: Number,
    fat: Number,
    fiber: Number,
    sugar: Number,
    sodium: Number,
  },
  bestFor: [String],
  bestTimes: [{
    type: String,
    enum: ['breakfast', 'lunch', 'dinner', 'snack', 'pre_workout', 'post_workout', 'suhoor', 'iftar'],
  }],
  portionOptions: [{
    name: String,
    weightGrams: Number,
    price: Number,
    isPopular: { type: Boolean, default: false },
  }],
  customizations: [{
    name: String,
    type: { type: String, enum: ['single', 'multiple'] },
    isRequired: { type: Boolean, default: false },
    maxSelections: Number,
    options: [{
      name: String,
      priceModifier: { type: Number, default: 0 },
      isDefault: { type: Boolean, default: false },
    }],
  }],
  dietaryTags: [String],
  isAvailable: {
    type: Boolean,
    default: true,
  },
  isFeatured: {
    type: Boolean,
    default: false,
  },
  sortOrder: {
    type: Number,
    default: 0,
  },
  availabilitySchedule: {
    enabled: {
      type: Boolean,
      default: false,
    },
    startAt: Date,
    endAt: Date,
  },
}, {
  timestamps: true,
});

foodSchema.index({ name: 'text', description: 'text' });

module.exports = mongoose.model('Food', foodSchema);
