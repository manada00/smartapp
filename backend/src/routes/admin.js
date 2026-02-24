const express = require('express');
const mongoose = require('mongoose');
const Order = require('../models/Order');
const Food = require('../models/Food');
const Category = require('../models/Category');
const User = require('../models/User');
const { protectAdmin, requireRoles } = require('../middleware/adminAuth');
const { syncOrderPaymentToSupabase } = require('../services/payment/supabaseOrderSync');
const { sendOrderConfirmationEmail } = require('../services/email/orderConfirmationService');

const router = express.Router();

const persistOrderPaymentState = async (order) => {
  try {
    await syncOrderPaymentToSupabase(order);
  } catch (error) {
    console.error(error.message);
  }
};

const getDisplayPriceFromFood = (food) => {
  if (!Array.isArray(food.portionOptions) || food.portionOptions.length === 0) {
    return Number(food.price || 0);
  }

  const popularOption = food.portionOptions.find((portion) => portion?.isPopular);
  const regularOption = food.portionOptions.find((portion) =>
    String(portion?.name || '').toLowerCase().includes('regular'),
  );
  const fallbackOption = food.portionOptions[0];
  return Number((popularOption || regularOption || fallbackOption)?.price || food.price || 0);
};

router.use(protectAdmin);

router.get('/overview', async (req, res) => {
  try {
    const todayStart = new Date();
    todayStart.setHours(0, 0, 0, 0);

    const [
      totalOrdersToday,
      revenueToday,
      activeUsers,
      pendingOrders,
      failedPayments,
      lowStockItems,
      ordersByPaymentMethod,
      paymentStatusSummary,
    ] = await Promise.all([
      Order.countDocuments({ createdAt: { $gte: todayStart } }),
      Order.aggregate([
        { $match: { createdAt: { $gte: todayStart } } },
        { $group: { _id: null, total: { $sum: '$total' } } },
      ]),
      User.countDocuments({ updatedAt: { $gte: new Date(Date.now() - 24 * 60 * 60 * 1000) } }),
      Order.countDocuments({ status: { $in: ['pending', 'confirmed', 'preparing'] } }),
      Order.countDocuments({ paymentStatus: 'failed' }),
      Food.countDocuments({ isAvailable: false }),
      Order.aggregate([
        { $match: { createdAt: { $gte: todayStart } } },
        { $group: { _id: '$paymentMethod', count: { $sum: 1 } } },
      ]),
      Order.aggregate([
        { $match: { createdAt: { $gte: todayStart } } },
        { $group: { _id: '$paymentStatus', count: { $sum: 1 } } },
      ]),
    ]);

    return res.json({
      success: true,
      data: {
        totalOrdersToday,
        revenueToday: revenueToday[0]?.total || 0,
        activeUsers,
        pendingOrders,
        failedPayments,
        lowStockItems,
        ordersByPaymentMethod,
        paymentStatusSummary,
      },
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.get('/orders', async (req, res) => {
  try {
    const { status, paymentMethod, paymentStatus, emailStatus, search, page = 1, limit = 20, from, to } = req.query;
    const query = {};

    if (status && status !== 'all') query.status = status;
    if (paymentMethod && paymentMethod !== 'all') query.paymentMethod = paymentMethod;
    if (paymentStatus && paymentStatus !== 'all') query.paymentStatus = paymentStatus;
    if (emailStatus && emailStatus !== 'all') query.emailDeliveryStatus = emailStatus;
    if (from || to) {
      query.createdAt = {};
      if (from) query.createdAt.$gte = new Date(from);
      if (to) query.createdAt.$lte = new Date(to);
    }
    if (search) {
      const maybeObjectId = mongoose.Types.ObjectId.isValid(search);
      query.$or = [
        { orderNumber: { $regex: search, $options: 'i' } },
        ...(maybeObjectId ? [{ _id: search }] : []),
      ];
    }

    const orders = await Order.find(query)
      .populate('user', 'name email phone')
      .sort({ createdAt: -1 })
      .skip((Number(page) - 1) * Number(limit))
      .limit(Number(limit));

    const total = await Order.countDocuments(query);
    return res.json({
      success: true,
      data: orders,
      pagination: {
        page: Number(page),
        limit: Number(limit),
        total,
        pages: Math.ceil(total / Number(limit)),
      },
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.put('/orders/:id/status', async (req, res) => {
  try {
    const { status } = req.body;
    if (!status) {
      return res.status(400).json({ success: false, message: 'status is required' });
    }

    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ success: false, message: 'Order not found' });

    order.status = status;
    order.timeline.push({
      status,
      message: `Status updated by ${req.admin.role}`,
      timestamp: new Date(),
    });

    await order.save();
    await persistOrderPaymentState(order);
    const io = req.app.get('io');
    if (io) {
      io.emit('orderStatusChanged', { orderId: order._id, status });
    }

    return res.json({ success: true, data: order });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.post('/orders/:id/refund', requireRoles('SUPER_ADMIN', 'SUPPORT_ADMIN'), async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ success: false, message: 'Order not found' });

    order.paymentStatus = 'refunded';
    order.paymentTimestamp = new Date();
    order.timeline.push({
      status: 'refunded',
      message: `Refunded by ${req.admin.role}`,
      timestamp: new Date(),
    });
    await order.save();
    await persistOrderPaymentState(order);

    return res.json({ success: true, data: order });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.put('/orders/:id/payment-status', requireRoles('SUPER_ADMIN'), async (req, res) => {
  try {
    const { paymentStatus } = req.body;
    if (!paymentStatus) {
      return res.status(400).json({ success: false, message: 'paymentStatus is required' });
    }

    const allowed = ['pending', 'paid', 'failed', 'awaiting_transfer', 'refunded'];
    if (!allowed.includes(paymentStatus)) {
      return res.status(400).json({ success: false, message: 'Invalid payment status value' });
    }

    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ success: false, message: 'Order not found' });

    order.paymentStatus = paymentStatus;
    if (paymentStatus === 'paid' || paymentStatus === 'refunded') {
      order.paymentTimestamp = new Date();
    }
    if (paymentStatus === 'paid' && order.status === 'pending') {
      order.status = 'confirmed';
    }

    order.timeline.push({
      status: order.status,
      message: `Payment status manually set to ${paymentStatus} by ${req.admin.role}`,
      timestamp: new Date(),
    });

    await order.save();
    await persistOrderPaymentState(order);

    return res.json({ success: true, data: order });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.post('/orders/:id/resend-confirmation-email', requireRoles('SUPER_ADMIN', 'SUPPORT_ADMIN'), async (req, res) => {
  try {
    const order = await Order.findById(req.params.id).populate('user', 'name email');
    if (!order) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }

    const emailResult = await sendOrderConfirmationEmail({ order, user: order.user });

    order.emailDeliveryStatus = emailResult.status;
    order.emailSent = emailResult.success;
    order.emailSentAt = emailResult.success ? emailResult.sentAt || new Date() : null;
    order.emailError = emailResult.error || null;
    order.emailProviderMessageId = emailResult.providerMessageId || null;
    order.timeline.push({
      status: order.status,
      message: emailResult.success
        ? `Order confirmation email resent by ${req.admin.role}`
        : `Email resend failed: ${emailResult.error}`,
      timestamp: new Date(),
    });

    await order.save();
    await persistOrderPaymentState(order);

    return res.json({ success: true, data: order, email: emailResult });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.delete('/orders/:id', requireRoles('SUPER_ADMIN'), async (req, res) => {
  try {
    const deleted = await Order.findByIdAndDelete(req.params.id);
    if (!deleted) return res.status(404).json({ success: false, message: 'Order not found' });

    return res.json({ success: true, message: 'Order deleted' });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.get('/menu', async (req, res) => {
  try {
    const foods = await Food.find({}).populate('category', 'name').sort({ sortOrder: 1, createdAt: -1 });
    return res.json({ success: true, data: foods });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.get('/menu/categories', async (req, res) => {
  try {
    const categories = await Category.find({ isActive: true }).sort({ sortOrder: 1, createdAt: -1 });
    return res.json({ success: true, data: categories });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.post('/menu', requireRoles('SUPER_ADMIN', 'OPERATIONS_ADMIN'), async (req, res) => {
  try {
    const {
      name,
      description,
      categoryId,
      imageUrl,
      preparationTime,
      regularPortionPrice,
      largePortionPrice,
      dietaryTags,
      isAvailable,
      isFeatured,
    } = req.body;

    if (!name || !description || !categoryId) {
      return res.status(400).json({ success: false, message: 'name, description, and categoryId are required' });
    }

    const category = await Category.findById(categoryId);
    if (!category) {
      return res.status(404).json({ success: false, message: 'Category not found' });
    }

    const regPrice = Number(regularPortionPrice ?? 0);
    const largePrice = Number(largePortionPrice ?? 0);

    const food = await Food.create({
      name: String(name).trim(),
      description: String(description).trim(),
      category: category._id,
      images: imageUrl ? [String(imageUrl).trim()] : [],
      price: regPrice || largePrice || 0,
      preparationTime: Number(preparationTime || 10),
      dietaryTags: Array.isArray(dietaryTags)
        ? dietaryTags.map((tag) => String(tag).trim()).filter(Boolean)
        : [],
      isAvailable: typeof isAvailable === 'boolean' ? isAvailable : true,
      isFeatured: typeof isFeatured === 'boolean' ? isFeatured : false,
      portionOptions: [
        { name: 'Regular', weightGrams: 350, price: regPrice || 0, isPopular: true },
        { name: 'Large', weightGrams: 450, price: largePrice || regPrice || 0, isPopular: false },
      ],
    });

    await food.populate('category', 'name');
    return res.status(201).json({ success: true, data: food });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.put('/menu/:id', requireRoles('SUPER_ADMIN', 'OPERATIONS_ADMIN'), async (req, res) => {
  try {
    const {
      name,
      description,
      price,
      regularPortionPrice,
      largePortionPrice,
      preparationTime,
      isAvailable,
      dietaryTags,
      isFeatured,
    } = req.body;

    const update = {};

    if (typeof name === 'string') update.name = name.trim();
    if (typeof description === 'string') update.description = description.trim();
    if (price !== undefined) update.price = Number(price);
    if (regularPortionPrice !== undefined) update.regularPortionPrice = Number(regularPortionPrice);
    if (largePortionPrice !== undefined) update.largePortionPrice = Number(largePortionPrice);
    if (preparationTime !== undefined) update.preparationTime = Number(preparationTime);
    if (typeof isAvailable === 'boolean') update.isAvailable = isAvailable;
    if (typeof isFeatured === 'boolean') update.isFeatured = isFeatured;
    if (Array.isArray(dietaryTags)) {
      update.dietaryTags = dietaryTags
        .map((tag) => String(tag).trim())
        .filter(Boolean);
    }

    if (Object.keys(update).length === 0) {
      return res.status(400).json({ success: false, message: 'No valid fields to update' });
    }

    const food = await Food.findById(req.params.id);
    if (!food) {
      return res.status(404).json({ success: false, message: 'Menu item not found' });
    }

    Object.entries(update).forEach(([key, value]) => {
      if (key === 'regularPortionPrice' || key === 'largePortionPrice') return;
      food.set(key, value);
    });

    if (Array.isArray(food.portionOptions) && food.portionOptions.length > 0) {
      const regularIndex = food.portionOptions.findIndex((portion) =>
        String(portion?.name || '').toLowerCase().includes('regular'),
      );
      const largeIndex = food.portionOptions.findIndex((portion) =>
        String(portion?.name || '').toLowerCase().includes('large'),
      );

      if (update.price !== undefined) {
        const targetIndex = regularIndex >= 0 ? regularIndex : 0;
        food.portionOptions[targetIndex].price = Number(update.price);
      }

      if (update.regularPortionPrice !== undefined && regularIndex >= 0) {
        food.portionOptions[regularIndex].price = Number(update.regularPortionPrice);
      }

      if (update.largePortionPrice !== undefined && largeIndex >= 0) {
        food.portionOptions[largeIndex].price = Number(update.largePortionPrice);
      }

      food.price = getDisplayPriceFromFood(food);
    }

    await food.save();
    await food.populate('category', 'name');

    return res.json({ success: true, data: food });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.put('/menu/:id/image', requireRoles('SUPER_ADMIN', 'OPERATIONS_ADMIN'), async (req, res) => {
  try {
    const { imageUrl } = req.body;
    if (!imageUrl || typeof imageUrl !== 'string') {
      return res.status(400).json({ success: false, message: 'imageUrl is required' });
    }

    const food = await Food.findById(req.params.id);
    if (!food) {
      return res.status(404).json({ success: false, message: 'Menu item not found' });
    }

    const trimmed = imageUrl.trim();
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      return res.status(400).json({ success: false, message: 'imageUrl must start with http:// or https://' });
    }

    const otherImages = (food.images || []).slice(1);
    food.images = [trimmed, ...otherImages];
    await food.save();
    await food.populate('category', 'name');

    return res.json({ success: true, data: food });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.post('/menu/:id/duplicate', requireRoles('SUPER_ADMIN', 'OPERATIONS_ADMIN'), async (req, res) => {
  try {
    const source = await Food.findById(req.params.id);
    if (!source) {
      return res.status(404).json({ success: false, message: 'Menu item not found' });
    }

    const duplicateData = source.toObject();
    delete duplicateData._id;
    delete duplicateData.createdAt;
    delete duplicateData.updatedAt;
    delete duplicateData.__v;

    duplicateData.name = `${source.name} (Copy)`;
    duplicateData.isFeatured = false;
    duplicateData.rating = 0;
    duplicateData.reviewCount = 0;
    duplicateData.sortOrder = Number(source.sortOrder || 0) + 1;

    const duplicate = await Food.create(duplicateData);
    await duplicate.populate('category', 'name');

    return res.status(201).json({ success: true, data: duplicate });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.post('/menu/reorder', requireRoles('SUPER_ADMIN', 'OPERATIONS_ADMIN'), async (req, res) => {
  try {
    const { itemIds } = req.body;
    if (!Array.isArray(itemIds) || itemIds.length === 0) {
      return res.status(400).json({ success: false, message: 'itemIds array is required' });
    }

    await Promise.all(
      itemIds.map((id, index) =>
        Food.findByIdAndUpdate(id, { $set: { sortOrder: index } }),
      ),
    );

    return res.json({ success: true, message: 'Menu order updated' });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.post('/menu/bulk-pricing', requireRoles('SUPER_ADMIN', 'OPERATIONS_ADMIN'), async (req, res) => {
  try {
    const { itemIds, mode, amount, target = 'display' } = req.body;
    if (!Array.isArray(itemIds) || itemIds.length === 0) {
      return res.status(400).json({ success: false, message: 'itemIds array is required' });
    }
    if (!['fixed', 'percentage'].includes(mode)) {
      return res.status(400).json({ success: false, message: 'mode must be fixed or percentage' });
    }

    const delta = Number(amount);
    if (!Number.isFinite(delta)) {
      return res.status(400).json({ success: false, message: 'amount must be a valid number' });
    }

    const foods = await Food.find({ _id: { $in: itemIds } });
    await Promise.all(foods.map(async (food) => {
      const apply = (value) => {
        const current = Number(value || 0);
        const next = mode === 'percentage'
          ? current + (current * delta / 100)
          : current + delta;
        return Math.max(0, Number(next.toFixed(2)));
      };

      if (target === 'regular' || target === 'all') {
        const regular = food.portionOptions.find((p) => String(p?.name || '').toLowerCase().includes('regular'));
        if (regular) regular.price = apply(regular.price);
      }

      if (target === 'large' || target === 'all') {
        const large = food.portionOptions.find((p) => String(p?.name || '').toLowerCase().includes('large'));
        if (large) large.price = apply(large.price);
      }

      if (target === 'display') {
        food.price = apply(food.price);
      }

      food.price = getDisplayPriceFromFood(food);
      await food.save();
    }));

    return res.json({ success: true, message: 'Bulk pricing applied' });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.post('/menu/:id/schedule', requireRoles('SUPER_ADMIN', 'OPERATIONS_ADMIN'), async (req, res) => {
  try {
    const { startAt, endAt, enabled = true } = req.body;
    const food = await Food.findById(req.params.id);
    if (!food) {
      return res.status(404).json({ success: false, message: 'Menu item not found' });
    }

    food.availabilitySchedule = {
      enabled: Boolean(enabled),
      startAt: startAt ? new Date(startAt) : undefined,
      endAt: endAt ? new Date(endAt) : undefined,
    };

    await food.save();
    await food.populate('category', 'name');
    return res.json({ success: true, data: food });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.get('/users', async (req, res) => {
  try {
    const users = await User.find({}).sort({ createdAt: -1 }).limit(200);
    return res.json({
      success: true,
      data: users.map((user) => ({
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        totalSpend: user.loyaltyInfo?.totalSpent || 0,
        totalOrders: user.loyaltyInfo?.totalOrders || 0,
        points: user.loyaltyInfo?.points || 0,
        lastActivity: user.updatedAt,
      })),
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
