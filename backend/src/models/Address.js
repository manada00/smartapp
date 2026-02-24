const mongoose = require('mongoose');

const addressSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  label: {
    type: String,
    enum: ['home', 'office', 'gym', 'other'],
    default: 'home',
  },
  governorate: {
    type: String,
    required: true,
  },
  area: {
    type: String,
    required: true,
  },
  streetName: {
    type: String,
    required: true,
  },
  buildingNumber: {
    type: String,
    required: true,
  },
  floor: String,
  apartmentNumber: String,
  landmark: {
    type: String,
    required: true,
  },
  deliveryInstructions: String,
  location: {
    type: {
      type: String,
      enum: ['Point'],
      default: 'Point',
    },
    coordinates: {
      type: [Number],
      default: [0, 0],
    },
  },
  isDefault: {
    type: Boolean,
    default: false,
  },
}, {
  timestamps: true,
});

addressSchema.index({ location: '2dsphere' });

module.exports = mongoose.model('Address', addressSchema);
