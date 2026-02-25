const mongoose = require('mongoose');

const promotionSchema = new mongoose.Schema({
  title: { type: String, default: '' },
  message: { type: String, default: '' },
  imageUrl: { type: String, default: '' },
  ctaText: { type: String, default: '' },
  isActive: { type: Boolean, default: false },
}, { _id: false });

const moodConfigSchema = new mongoose.Schema({
  type: {
    type: String,
    enum: [
      'need_energy',
      'very_hungry',
      'something_light',
      'trained_today',
      'stressed',
      'bloated',
      'help_sleep',
      'kid_needs_meal',
      'fasting_tomorrow',
      'browse_all',
    ],
    required: true,
  },
  title: { type: String, default: '' },
  subtitle: { type: String, default: '' },
  emoji: { type: String, default: '' },
  isVisible: { type: Boolean, default: true },
  sortOrder: { type: Number, default: 0 },
}, { _id: false });

const appConfigSchema = new mongoose.Schema({
  key: { type: String, required: true, unique: true, default: 'default' },
  homeHero: {
    title: { type: String, default: '' },
    subtitle: { type: String, default: '' },
  },
  announcement: {
    enabled: { type: Boolean, default: false },
    message: { type: String, default: '' },
  },
  promotions: {
    type: [promotionSchema],
    default: [],
  },
  moods: {
    type: [moodConfigSchema],
    default: [],
  },
  popularFoodIds: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Food' }],
  supportContact: {
    phone: { type: String, default: '01552785430' },
    email: { type: String, default: 'support@smartfood.app' },
    whatsapp: { type: String, default: '01552785430' },
  },
}, {
  timestamps: true,
});

module.exports = mongoose.model('AppConfig', appConfigSchema);
