const mongoose = require('mongoose');

const categorySchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
  },
  description: String,
  image: String,
  sortOrder: {
    type: Number,
    default: 0,
  },
  isActive: {
    type: Boolean,
    default: true,
  },
}, {
  timestamps: true,
});

categorySchema.index({ isActive: 1 });
categorySchema.index({ sortOrder: 1 });

module.exports = mongoose.model('Category', categorySchema);
