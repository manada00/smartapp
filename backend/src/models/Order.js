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
  user_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    index: true,
  },
  items: [{
    product_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Food',
    },
    name: String,
    price: Number,
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
    enum: ['pending', 'paid', 'confirmed', 'preparing', 'ready_for_pickup', 'out_for_delivery', 'delivered', 'cancelled'],
    default: 'pending',
  },
  order_type: {
    type: String,
    enum: ['one_time', 'subscription'],
    default: 'one_time',
    index: true,
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
  payment_status: {
    type: String,
    enum: ['pending', 'paid', 'failed', 'awaiting_transfer', 'refunded'],
    default: 'pending',
    index: true,
  },
  payment_provider: {
    type: String,
    default: 'mock',
  },
  payment_reference: {
    type: String,
    index: true,
    sparse: true,
  },
  payment_webhook_processed_at: Date,
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
  delivery_fee: Number,
  deliveryFee: Number,
  discount: { type: Number, default: 0 },
  walletUsed: { type: Number, default: 0 },
  total: Number,
  currency: { type: String, default: 'EGP' },
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
  created_at: {
    type: Date,
    default: Date.now,
    index: true,
  },
  updated_at: {
    type: Date,
    default: Date.now,
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

  if (!this.user_id && this.user) {
    this.user_id = this.user;
  }

  if (!this.user && this.user_id) {
    this.user = this.user_id;
  }

  if (this.delivery_fee == null && this.deliveryFee != null) {
    this.delivery_fee = this.deliveryFee;
  }

  if (this.deliveryFee == null && this.delivery_fee != null) {
    this.deliveryFee = this.delivery_fee;
  }

  if (!this.payment_status && this.paymentStatus) {
    this.payment_status = this.paymentStatus;
  }

  if (!this.paymentStatus && this.payment_status) {
    this.paymentStatus = this.payment_status;
  }

  if (!this.payment_reference && this.paymentReferenceCode) {
    this.payment_reference = this.paymentReferenceCode;
  }

  if (!this.paymentReferenceCode && this.payment_reference) {
    this.paymentReferenceCode = this.payment_reference;
  }

  if (!this.created_at) {
    this.created_at = this.createdAt || new Date();
  }

  this.updated_at = new Date();

  next();
});

orderSchema.index({ user_id: 1, created_at: -1 });
orderSchema.index({ payment_status: 1 });
orderSchema.index({ created_at: -1 });

module.exports = mongoose.model('Order', orderSchema);
