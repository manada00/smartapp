const express = require('express');
const Order = require('../models/Order');
const User = require('../models/User');
const { protect } = require('../middleware/auth');
const { PaymentService } = require('../services/payment/paymentService');
const {
  PAYMENT_METHODS,
  PAYMENT_STATUSES,
} = require('../services/payment/mockPaymentGateway');
const { syncOrderPaymentToSupabase } = require('../services/payment/supabaseOrderSync');
const { sendOrderConfirmationEmail } = require('../services/email/orderConfirmationService');

const router = express.Router();
const paymentService = new PaymentService();

const persistOrderPaymentState = async (order) => {
  try {
    await syncOrderPaymentToSupabase(order);
  } catch (error) {
    console.error(error.message);
  }
};

const updateOrderEmailStatus = async ({ order, user }) => {
  try {
    const emailResult = await sendOrderConfirmationEmail({ order, user });

    order.emailDeliveryStatus = emailResult.status;
    order.emailSent = emailResult.success;
    order.emailSentAt = emailResult.success ? emailResult.sentAt || new Date() : null;
    order.emailError = emailResult.error || null;
    order.emailProviderMessageId = emailResult.providerMessageId || null;

    await order.save();
    await persistOrderPaymentState(order);
  } catch (error) {
    console.error(`Failed to persist email status for order ${order._id}: ${error.message}`);
  }
};

// Get user orders
router.get('/', protect, async (req, res) => {
  try {
    const { status, page = 1, limit = 10 } = req.query;
    
    const query = { user: req.user._id };
    
    if (status === 'active') {
      query.status = { $nin: ['delivered', 'cancelled'] };
    } else if (status === 'past') {
      query.status = { $in: ['delivered', 'cancelled'] };
    }

    const orders = await Order.find(query)
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(Number(limit));

    const total = await Order.countDocuments(query);

    res.json({
      success: true,
      data: orders,
      pagination: {
        page: Number(page),
        limit: Number(limit),
        total,
        pages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// Get active orders
router.get('/active', protect, async (req, res) => {
  try {
    const orders = await Order.find({
      user: req.user._id,
      status: { $nin: ['delivered', 'cancelled'] },
    }).sort({ createdAt: -1 });

    res.json({
      success: true,
      data: orders,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// Get order by ID
router.get('/:id', protect, async (req, res) => {
  try {
    const order = await Order.findOne({
      _id: req.params.id,
      user: req.user._id,
    }).populate('driver');

    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found',
      });
    }

    res.json({
      success: true,
      data: order,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// Create order
router.post('/', protect, async (req, res) => {
  try {
    const {
      items,
      deliveryAddress,
      paymentMethod,
      promoCode,
      specialInstructions,
      changeFor,
      scheduledDelivery,
      useWallet,
      walletAmount,
      cardDetails,
    } = req.body;

    if (!Object.values(PAYMENT_METHODS).includes(paymentMethod)) {
      return res.status(400).json({
        success: false,
        message: 'Unsupported payment method',
      });
    }

    if (paymentMethod === PAYMENT_METHODS.CARD) {
      const hasCardDetails = cardDetails
        && cardDetails.number
        && cardDetails.expiry
        && cardDetails.cvv;
      if (!hasCardDetails) {
        return res.status(400).json({
          success: false,
          message: 'Card details are required for card payment',
        });
      }
    }

    // Calculate totals
    const subtotal = items.reduce((sum, item) => sum + item.totalPrice, 0);
    const deliveryFee = 25; // Fixed for now
    let discount = 0;

    // Apply promo code if provided
    if (promoCode) {
      // TODO: Validate promo code and calculate discount
      discount = 50; // Mock discount
    }

    // Calculate wallet usage
    let walletUsed = 0;
    if (useWallet && req.user.wallet.balance > 0) {
      walletUsed = Math.min(req.user.wallet.balance, walletAmount || req.user.wallet.balance);
    }

    const total = subtotal + deliveryFee - discount;
    const amountDue = total - walletUsed;

    // Calculate points earned (1 point per 10 EGP)
    const pointsEarned = Math.floor(total / 10);
    const paymentResult = paymentService.processInitialPayment({ paymentMethod });
    const paymentTimestamp = paymentResult.paymentStatus === PAYMENT_STATUSES.PAID
      ? new Date()
      : null;

    const order = await Order.create({
      user: req.user._id,
      userEmail: req.user.email || null,
      items,
      deliveryAddress,
      paymentMethod,
      subtotal,
      deliveryFee,
      discount,
      walletUsed,
      total,
      amountDue,
      promoCode,
      specialInstructions,
      changeFor,
      scheduledDelivery,
      estimatedMinutes: 35,
      pointsEarned,
      status: paymentResult.orderStatus,
      paymentStatus: paymentResult.paymentStatus,
      transactionId: paymentResult.transactionId,
      paymentReferenceCode: paymentResult.referenceCode,
      paymentTimestamp,
      paymentMessage: paymentResult.message,
      emailDeliveryStatus: 'email_pending',
      timeline: [{
        status: paymentResult.orderStatus,
        message: 'Order placed',
        timestamp: new Date(),
      }, {
        status: paymentResult.orderStatus,
        message: paymentResult.message,
        timestamp: new Date(),
      }],
    });

    // Deduct wallet if used
    if (walletUsed > 0) {
      req.user.wallet.balance -= walletUsed;
    }

    // Add points
    req.user.addPoints(pointsEarned);
    req.user.loyaltyInfo.totalOrders += 1;
    req.user.loyaltyInfo.totalSpent += total;
    await req.user.save();

    // Emit socket event for kitchen
    const io = req.app.get('io');
    if (io) {
      io.emit('newOrder', order);
    }

    await persistOrderPaymentState(order);
    await updateOrderEmailStatus({ order, user: req.user });

    res.status(201).json({
      success: true,
      data: order,
      payment: {
        method: paymentMethod,
        status: paymentResult.paymentStatus,
        message: paymentResult.message,
        transactionId: paymentResult.transactionId,
        referenceCode: paymentResult.referenceCode,
        fakeIban: paymentResult.fakeIban,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

router.post('/:id/pay/card', protect, async (req, res) => {
  try {
    const { cardDetails } = req.body;
    const hasCardDetails = cardDetails
      && cardDetails.number
      && cardDetails.expiry
      && cardDetails.cvv;

    if (!hasCardDetails) {
      return res.status(400).json({
        success: false,
        message: 'Card details are required',
      });
    }

    const order = await Order.findOne({
      _id: req.params.id,
      user: req.user._id,
      paymentMethod: PAYMENT_METHODS.CARD,
    });

    if (!order) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }

    const paymentResult = paymentService.processInitialPayment({ paymentMethod: PAYMENT_METHODS.CARD });
    order.paymentStatus = paymentResult.paymentStatus;
    order.status = paymentResult.orderStatus;
    order.transactionId = paymentResult.transactionId;
    order.paymentMessage = paymentResult.message;
    order.paymentTimestamp = paymentResult.paymentStatus === PAYMENT_STATUSES.PAID
      ? new Date()
      : null;
    order.timeline.push({
      status: order.status,
      message: `Card retry: ${paymentResult.message}`,
      timestamp: new Date(),
    });

    await order.save();
    await persistOrderPaymentState(order);

    return res.json({
      success: true,
      data: order,
      payment: {
        status: paymentResult.paymentStatus,
        message: paymentResult.message,
        transactionId: paymentResult.transactionId,
      },
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.post('/:id/pay/instapay/verify', protect, async (req, res) => {
  try {
    const order = await Order.findOne({
      _id: req.params.id,
      user: req.user._id,
      paymentMethod: PAYMENT_METHODS.INSTAPAY,
    });

    if (!order) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }

    const verification = paymentService.verifyInstapayTransfer();
    order.paymentStatus = verification.paymentStatus;
    order.status = verification.orderStatus;
    order.paymentMessage = verification.message;
    if (verification.paymentStatus === PAYMENT_STATUSES.PAID) {
      order.paymentTimestamp = new Date();
    }
    order.timeline.push({
      status: order.status,
      message: verification.message,
      timestamp: new Date(),
    });

    await order.save();
    await persistOrderPaymentState(order);

    return res.json({
      success: true,
      data: order,
      payment: {
        status: verification.paymentStatus,
        message: verification.message,
        transactionId: order.transactionId,
        referenceCode: order.paymentReferenceCode,
      },
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// Cancel order
router.put('/:id/cancel', protect, async (req, res) => {
  try {
    const order = await Order.findOne({
      _id: req.params.id,
      user: req.user._id,
    });

    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found',
      });
    }

    if (!['pending', 'confirmed'].includes(order.status)) {
      return res.status(400).json({
        success: false,
        message: 'Order cannot be cancelled at this stage',
      });
    }

    order.status = 'cancelled';
    order.timeline.push({
      status: 'cancelled',
      message: 'Order cancelled by customer',
      timestamp: new Date(),
    });

    // Refund wallet if used
    if (order.walletUsed > 0) {
      req.user.wallet.balance += order.walletUsed;
      await req.user.save();
    }

    // TODO: Process refund for card payments

    await order.save();
    await persistOrderPaymentState(order);

    res.json({
      success: true,
      data: order,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// Rate order
router.post('/:id/rate', protect, async (req, res) => {
  try {
    const { overall, food, delivery, packaging, comment, feedbackTags } = req.body;

    const order = await Order.findOne({
      _id: req.params.id,
      user: req.user._id,
      status: 'delivered',
    });

    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found or not yet delivered',
      });
    }

    order.rating = {
      overall,
      food,
      delivery,
      packaging,
      comment,
      feedbackTags,
      createdAt: new Date(),
    };

    await order.save();

    // Award bonus points for rating
    req.user.addPoints(10);
    await req.user.save();

    res.json({
      success: true,
      data: order,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

module.exports = router;
