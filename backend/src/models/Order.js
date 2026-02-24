const mongoose = require('mongoose');

const orderSchema = new mongoose.Schema({
  orderNumber: {
    type: String,
    required: true,
    unique: true,
  },
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  items: [{
    food: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Food',
    },
    foodName: String,
    foodImage: String,
    portionId: String,
    portionName: String,
    customizations: [{
      groupId: String,
      groupName: String,
      optionId: String,
      optionName: String,
      priceModifier: Number,
    }],
    specialInstructions: String,
    quantity: Number,
    unitPrice: Number,
    customizationsPrice: Number,
    totalPrice: Number,
  }],
  deliveryAddress: {
    label: String,
    governorate: String,
    area: String,
    streetName: String,
    buildingNumber: String,
    floor: String,
    apartmentNumber: String,
    landmark: String,
    deliveryInstructions: String,
    latitude: Number,
    longitude: Number,
  },
  status: {
    type: String,
    enum: ['pending', 'confirmed', 'preparing', 'ready_for_pickup', 'out_for_delivery', 'delivered', 'cancelled'],
    default: 'pending',
  },
  paymentMethod: {
    type: String,
    enum: ['cod', 'card', 'mobile_wallet', 'fawry', 'instapay', 'wallet'],
    required: true,
  },
  paymentStatus: {
    type: String,
    enum: ['pending', 'paid', 'failed', 'awaiting_transfer', 'refunded'],
    default: 'pending',
  },
  userEmail: String,
  emailSent: {
    type: Boolean,
    default: false,
  },
  emailDeliveryStatus: {
    type: String,
    enum: ['email_pending', 'email_sent', 'email_failed'],
    default: 'email_pending',
    index: true,
  },
  emailSentAt: Date,
  emailError: String,
  emailProviderMessageId: String,
  transactionId: {
    type: String,
    index: true,
  },
  paymentReferenceCode: String,
  paymentTimestamp: Date,
  paymentMessage: String,
  driver: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Driver',
  },
  subtotal: Number,
  deliveryFee: Number,
  discount: { type: Number, default: 0 },
  walletUsed: { type: Number, default: 0 },
  total: Number,
  amountDue: Number,
  promoCode: String,
  specialInstructions: String,
  changeFor: Number,
  scheduledDelivery: {
    date: Date,
    timeSlot: String,
  },
  estimatedMinutes: Number,
  timeline: [{
    status: String,
    message: String,
    timestamp: { type: Date, default: Date.now },
  }],
  pointsEarned: { type: Number, default: 0 },
  rating: {
    overall: Number,
    food: Number,
    delivery: Number,
    packaging: Number,
    comment: String,
    feedbackTags: [String],
    createdAt: Date,
  },
}, {
  timestamps: true,
});

orderSchema.pre('validate', async function(next) {
  if (!this.orderNumber) {
    const date = new Date();
    const year = date.getFullYear();
    const count = await mongoose.model('Order').countDocuments();
    this.orderNumber = `SF-${year}-${String(count + 1).padStart(6, '0')}`;
  }
  next();
});

module.exports = mongoose.model('Order', orderSchema);
