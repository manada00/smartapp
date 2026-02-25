const express = require('express');
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const crypto = require('crypto');
const Order = require('../models/Order');
const Food = require('../models/Food');
const Category = require('../models/Category');
const AppConfig = require('../models/AppConfig');
const User = require('../models/User');
const AdminUser = require('../models/AdminUser');
const SupportTicket = require('../models/SupportTicket');
const { protectAdmin, requireRoles } = require('../middleware/adminAuth');
const { syncOrderPaymentToSupabase } = require('../services/payment/supabaseOrderSync');
const { sendOrderConfirmationEmail } = require('../services/email/orderConfirmationService');
const { sendSupportReplyEmail } = require('../services/email/supportEmailService');

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

const DEFAULT_MOODS = [
  { type: 'need_energy', isVisible: true, sortOrder: 0 },
  { type: 'very_hungry', isVisible: true, sortOrder: 1 },
  { type: 'something_light', isVisible: true, sortOrder: 2 },
  { type: 'trained_today', isVisible: true, sortOrder: 3 },
  { type: 'stressed', isVisible: true, sortOrder: 4 },
  { type: 'bloated', isVisible: true, sortOrder: 5 },
  { type: 'help_sleep', isVisible: true, sortOrder: 6 },
  { type: 'kid_needs_meal', isVisible: true, sortOrder: 7 },
  { type: 'fasting_tomorrow', isVisible: true, sortOrder: 8 },
  { type: 'browse_all', isVisible: true, sortOrder: 9 },
];

const getOrCreateAppConfig = async () => {
  let config = await AppConfig.findOne({ key: 'default' });
  if (!config) {
    config = await AppConfig.create({
      key: 'default',
      moods: DEFAULT_MOODS,
      supportContact: {
        phone: '01552785430',
        email: 'support@smartfood.app',
        whatsapp: '01552785430',
      },
    });
  }
  return config;
};

const ADMIN_ROLES = ['SUPER_ADMIN', 'OPERATIONS_ADMIN', 'SUPPORT_ADMIN'];

const getDateWindow = ({ range = 'daily', from, to }) => {
  if (from || to) {
    return {
      start: from ? new Date(from) : new Date(0),
      end: to ? new Date(to) : new Date(),
    };
  }

  const now = new Date();
  const start = new Date(now);
  if (range === 'monthly') {
    start.setDate(1);
    start.setHours(0, 0, 0, 0);
  } else if (range === 'weekly') {
    const day = start.getDay();
    const diff = day === 0 ? 6 : day - 1;
    start.setDate(start.getDate() - diff);
    start.setHours(0, 0, 0, 0);
  } else {
    start.setHours(0, 0, 0, 0);
  }

  return { start, end: now };
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

router.get('/app-config/home', async (req, res) => {
  try {
    const config = await getOrCreateAppConfig();

    return res.json({
      success: true,
      data: {
        homeHero: {
          title: config.homeHero?.title || '',
          subtitle: config.homeHero?.subtitle || '',
        },
        announcement: {
          enabled: Boolean(config.announcement?.enabled),
          message: config.announcement?.message || '',
        },
        promotions: Array.isArray(config.promotions) ? config.promotions : [],
        moods: Array.isArray(config.moods) ? config.moods : DEFAULT_MOODS,
        popularFoodIds: (config.popularFoodIds || []).map((id) => String(id)),
      },
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.put('/app-config/home', requireRoles('SUPER_ADMIN', 'OPERATIONS_ADMIN'), async (req, res) => {
  try {
    const config = await getOrCreateAppConfig();
    const {
      homeHero,
      announcement,
      promotions,
      moods,
      popularFoodIds,
    } = req.body;

    if (homeHero && typeof homeHero === 'object') {
      config.homeHero = {
        title: typeof homeHero.title === 'string' ? homeHero.title.trim() : (config.homeHero?.title || ''),
        subtitle: typeof homeHero.subtitle === 'string' ? homeHero.subtitle.trim() : (config.homeHero?.subtitle || ''),
      };
    }

    if (announcement && typeof announcement === 'object') {
      config.announcement = {
        enabled: typeof announcement.enabled === 'boolean' ? announcement.enabled : Boolean(config.announcement?.enabled),
        message: typeof announcement.message === 'string' ? announcement.message.trim() : (config.announcement?.message || ''),
      };
    }

    if (Array.isArray(promotions)) {
      config.promotions = promotions.map((item) => ({
        title: String(item?.title || '').trim(),
        message: String(item?.message || '').trim(),
        imageUrl: String(item?.imageUrl || '').trim(),
        ctaText: String(item?.ctaText || '').trim(),
        isActive: Boolean(item?.isActive),
      }));
    }

    if (Array.isArray(moods)) {
      config.moods = moods
        .map((item) => ({
          type: String(item?.type || '').trim(),
          title: String(item?.title || '').trim(),
          subtitle: String(item?.subtitle || '').trim(),
          emoji: String(item?.emoji || '').trim(),
          isVisible: item?.isVisible !== false,
          sortOrder: Number.isFinite(Number(item?.sortOrder)) ? Number(item.sortOrder) : 0,
        }))
        .filter((item) => DEFAULT_MOODS.some((entry) => entry.type === item.type));
    }

    if (Array.isArray(popularFoodIds)) {
      const uniqueIds = Array.from(new Set(popularFoodIds.map((id) => String(id)).filter(Boolean)));
      const validFoods = await Food.find({ _id: { $in: uniqueIds } }).select('_id');
      config.popularFoodIds = validFoods.map((item) => item._id);
    }

    await config.save();

    return res.json({
      success: true,
      data: {
        homeHero: config.homeHero,
        announcement: config.announcement,
        promotions: config.promotions,
        moods: config.moods,
        popularFoodIds: (config.popularFoodIds || []).map((id) => String(id)),
      },
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.get('/app-config/support', async (req, res) => {
  try {
    const config = await getOrCreateAppConfig();
    return res.json({
      success: true,
      data: {
        phone: config.supportContact?.phone || '01552785430',
        email: config.supportContact?.email || 'support@smartfood.app',
        whatsapp: config.supportContact?.whatsapp || config.supportContact?.phone || '01552785430',
      },
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.put('/app-config/support', requireRoles('SUPER_ADMIN', 'OPERATIONS_ADMIN', 'SUPPORT_ADMIN'), async (req, res) => {
  try {
    const config = await getOrCreateAppConfig();
    const { phone, email, whatsapp } = req.body;

    config.supportContact = {
      phone: String(phone || config.supportContact?.phone || '01552785430').trim(),
      email: String(email || config.supportContact?.email || 'support@smartfood.app').trim(),
      whatsapp: String(whatsapp || phone || config.supportContact?.whatsapp || config.supportContact?.phone || '01552785430').trim(),
    };

    await config.save();

    return res.json({
      success: true,
      data: {
        phone: config.supportContact.phone,
        email: config.supportContact.email,
        whatsapp: config.supportContact.whatsapp,
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
    const includeInactive = String(req.query.includeInactive || '').toLowerCase() === 'true';
    const query = includeInactive ? {} : { isActive: true };
    const categories = await Category.find(query).sort({ sortOrder: 1, createdAt: -1 });
    return res.json({ success: true, data: categories });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.post('/menu/categories', requireRoles('SUPER_ADMIN', 'OPERATIONS_ADMIN'), async (req, res) => {
  try {
    const {
      name,
      description,
      image,
      sortOrder,
      isActive,
    } = req.body;

    const trimmedName = String(name || '').trim();
    if (!trimmedName) {
      return res.status(400).json({ success: false, message: 'name is required' });
    }

    const category = await Category.create({
      name: trimmedName,
      description: typeof description === 'string' ? description.trim() : '',
      image: typeof image === 'string' ? image.trim() : '',
      sortOrder: Number.isFinite(Number(sortOrder)) ? Number(sortOrder) : 0,
      isActive: typeof isActive === 'boolean' ? isActive : true,
    });

    return res.status(201).json({ success: true, data: category });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.put('/menu/categories/:id', requireRoles('SUPER_ADMIN', 'OPERATIONS_ADMIN'), async (req, res) => {
  try {
    const {
      name,
      description,
      image,
      sortOrder,
      isActive,
    } = req.body;

    const category = await Category.findById(req.params.id);
    if (!category) {
      return res.status(404).json({ success: false, message: 'Category not found' });
    }

    if (typeof name === 'string') {
      const trimmedName = name.trim();
      if (!trimmedName) {
        return res.status(400).json({ success: false, message: 'name cannot be empty' });
      }
      category.name = trimmedName;
    }

    if (typeof description === 'string') {
      category.description = description.trim();
    }

    if (typeof image === 'string') {
      category.image = image.trim();
    }

    if (sortOrder !== undefined) {
      const parsedSortOrder = Number(sortOrder);
      if (!Number.isFinite(parsedSortOrder)) {
        return res.status(400).json({ success: false, message: 'sortOrder must be a number' });
      }
      category.sortOrder = parsedSortOrder;
    }

    if (typeof isActive === 'boolean') {
      category.isActive = isActive;
    }

    await category.save();

    return res.json({ success: true, data: category });
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
    const [users, admins] = await Promise.all([
      User.find({}).sort({ createdAt: -1 }).limit(300),
      AdminUser.find({}).sort({ createdAt: -1 }).limit(100),
    ]);

    const basicUsers = users.map((user) => ({
      id: user._id,
      accountType: 'basic',
      name: user.name,
      email: user.email,
      phone: user.phone,
      totalSpend: user.loyaltyInfo?.totalSpent || 0,
      totalOrders: user.loyaltyInfo?.totalOrders || 0,
      points: user.loyaltyInfo?.points || 0,
      walletBalance: user.wallet?.balance || 0,
      isBlocked: Boolean(user.isBlocked),
      role: 'BASIC_USER',
      lastActivity: user.updatedAt,
      createdAt: user.createdAt,
    }));

    const adminUsers = admins.map((admin) => ({
      id: admin._id,
      accountType: 'admin',
      name: admin.email,
      email: admin.email,
      phone: '',
      totalSpend: 0,
      totalOrders: 0,
      points: 0,
      walletBalance: 0,
      isBlocked: !admin.isActive,
      role: admin.role,
      lastActivity: admin.lastLoginAt || admin.updatedAt,
      createdAt: admin.createdAt,
    }));

    return res.json({
      success: true,
      data: [...adminUsers, ...basicUsers].sort(
        (a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime(),
      ),
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.post('/users', requireRoles('SUPER_ADMIN'), async (req, res) => {
  try {
    const { accountType = 'basic' } = req.body;

    if (accountType === 'admin') {
      const { email, password, role = 'SUPPORT_ADMIN' } = req.body;
      const normalizedEmail = String(email || '').trim().toLowerCase();
      if (!normalizedEmail) {
        return res.status(400).json({ success: false, message: 'email is required' });
      }
      if (!String(password || '').trim() || String(password).trim().length < 6) {
        return res.status(400).json({ success: false, message: 'password must be at least 6 characters' });
      }
      if (!ADMIN_ROLES.includes(role)) {
        return res.status(400).json({ success: false, message: 'Invalid admin role' });
      }

      const exists = await AdminUser.findOne({ email: normalizedEmail });
      if (exists) {
        return res.status(409).json({ success: false, message: 'Admin email already exists' });
      }

      const passwordHash = await bcrypt.hash(String(password).trim(), 10);
      const created = await AdminUser.create({
        email: normalizedEmail,
        passwordHash,
        role,
        isActive: true,
      });

      return res.status(201).json({
        success: true,
        data: {
          id: created._id,
          accountType: 'admin',
          email: created.email,
          role: created.role,
        },
      });
    }

    const { name, email, phone } = req.body;
    if (!String(name || '').trim() && !String(email || '').trim() && !String(phone || '').trim()) {
      return res.status(400).json({ success: false, message: 'Provide at least one of name, email, or phone' });
    }

    const user = await User.create({
      name: String(name || '').trim(),
      email: String(email || '').trim().toLowerCase(),
      phone: String(phone || '').trim(),
      socialProvider: 'phone',
      referralCode: `SF${Math.random().toString(36).substring(2, 8).toUpperCase()}`,
    });

    return res.status(201).json({
      success: true,
      data: {
        id: user._id,
        accountType: 'basic',
        name: user.name,
        email: user.email,
        phone: user.phone,
      },
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.put('/users/:id/block', requireRoles('SUPER_ADMIN', 'SUPPORT_ADMIN'), async (req, res) => {
  try {
    const { accountType = 'basic', isBlocked } = req.body;
    const blocked = Boolean(isBlocked);

    if (accountType === 'admin') {
      if (req.admin.role !== 'SUPER_ADMIN') {
        return res.status(403).json({ success: false, message: 'Only super admin can block admin users' });
      }
      if (String(req.admin._id) === String(req.params.id) && blocked) {
        return res.status(400).json({ success: false, message: 'You cannot block your own admin account' });
      }
      const target = await AdminUser.findById(req.params.id);
      if (!target) {
        return res.status(404).json({ success: false, message: 'Admin user not found' });
      }
      target.isActive = !blocked;
      await target.save();
      return res.json({ success: true, data: { id: target._id, accountType: 'admin', isBlocked: !target.isActive } });
    }

    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
    user.isBlocked = blocked;
    if (blocked) {
      user.refreshTokens = [];
    }
    await user.save();
    return res.json({ success: true, data: { id: user._id, accountType: 'basic', isBlocked: user.isBlocked } });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.delete('/users/:id', requireRoles('SUPER_ADMIN'), async (req, res) => {
  try {
    const accountType = String(req.query.accountType || 'basic').toLowerCase();

    if (accountType === 'admin') {
      if (String(req.admin._id) === String(req.params.id)) {
        return res.status(400).json({ success: false, message: 'You cannot delete your own admin account' });
      }
      const deleted = await AdminUser.findByIdAndDelete(req.params.id);
      if (!deleted) {
        return res.status(404).json({ success: false, message: 'Admin user not found' });
      }
      return res.json({ success: true, message: 'Admin user deleted' });
    }

    const deleted = await User.findByIdAndDelete(req.params.id);
    if (!deleted) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    return res.json({ success: true, message: 'User deleted' });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.post('/users/:id/reset-password', requireRoles('SUPER_ADMIN', 'SUPPORT_ADMIN'), async (req, res) => {
  try {
    const { accountType = 'basic', newPassword } = req.body;

    if (accountType === 'admin') {
      if (req.admin.role !== 'SUPER_ADMIN') {
        return res.status(403).json({ success: false, message: 'Only super admin can reset admin password' });
      }
      const admin = await AdminUser.findById(req.params.id);
      if (!admin) {
        return res.status(404).json({ success: false, message: 'Admin user not found' });
      }

      const password = String(newPassword || '').trim() || crypto.randomBytes(6).toString('base64url');
      if (password.length < 6) {
        return res.status(400).json({ success: false, message: 'Password must be at least 6 characters' });
      }
      admin.passwordHash = await bcrypt.hash(password, 10);
      await admin.save();

      return res.json({
        success: true,
        message: 'Admin password reset successfully',
        data: {
          id: admin._id,
          temporaryPassword: String(newPassword || '').trim() ? undefined : password,
        },
      });
    }

    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
    user.refreshTokens = [];
    await user.save();

    return res.json({
      success: true,
      message: 'User sessions revoked. User can sign in again with OTP/social login.',
      data: { id: user._id },
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.post('/users/:id/issue-credit', requireRoles('SUPER_ADMIN', 'SUPPORT_ADMIN'), async (req, res) => {
  try {
    const { accountType = 'basic', amount } = req.body;
    if (accountType === 'admin') {
      return res.status(400).json({ success: false, message: 'Credits can only be issued to basic users' });
    }

    const parsedAmount = Number(amount);
    if (!Number.isFinite(parsedAmount) || parsedAmount <= 0) {
      return res.status(400).json({ success: false, message: 'amount must be greater than 0' });
    }

    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    user.wallet = user.wallet || { balance: 0 };
    user.wallet.balance = Number(user.wallet.balance || 0) + parsedAmount;
    await user.save();

    return res.json({
      success: true,
      message: 'Credit issued successfully',
      data: {
        id: user._id,
        walletBalance: user.wallet.balance,
      },
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.get('/users/:id/orders', async (req, res) => {
  try {
    const accountType = String(req.query.accountType || 'basic').toLowerCase();
    if (accountType === 'admin') {
      return res.json({ success: true, data: [] });
    }

    const orders = await Order.find({ user: req.params.id })
      .sort({ createdAt: -1 })
      .limit(50)
      .select('orderNumber status paymentStatus total createdAt');

    return res.json({ success: true, data: orders });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.get('/support/tickets', requireRoles('SUPER_ADMIN', 'SUPPORT_ADMIN', 'OPERATIONS_ADMIN'), async (req, res) => {
  try {
    const { status, q } = req.query;
    const query = {};

    if (status && ['open', 'pending', 'resolved', 'closed'].includes(String(status))) {
      query.status = String(status);
    }

    if (q) {
      query.subject = { $regex: String(q), $options: 'i' };
    }

    const tickets = await SupportTicket.find(query)
      .sort({ updatedAt: -1 })
      .limit(200)
      .populate('user', 'name email phone')
      .select('subject status priority initialChannel messages createdAt updatedAt user');

    return res.json({ success: true, data: tickets });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.post('/support/tickets/:id/reply', requireRoles('SUPER_ADMIN', 'SUPPORT_ADMIN', 'OPERATIONS_ADMIN'), async (req, res) => {
  try {
    const { message, channel = 'message' } = req.body;
    const trimmedMessage = String(message || '').trim();
    const selectedChannel = ['message', 'email'].includes(String(channel)) ? String(channel) : 'message';

    if (!trimmedMessage) {
      return res.status(400).json({ success: false, message: 'message is required' });
    }

    const ticket = await SupportTicket.findById(req.params.id).populate('user', 'name email');
    if (!ticket) {
      return res.status(404).json({ success: false, message: 'Ticket not found' });
    }

    if (selectedChannel === 'email') {
      const recipient = ticket.user?.email;
      const emailResult = await sendSupportReplyEmail({
        to: recipient,
        subject: `Support Reply: ${ticket.subject}`,
        message: trimmedMessage,
      });

      if (!emailResult.success) {
        return res.status(400).json({ success: false, message: emailResult.error || 'Failed to send email reply' });
      }
    }

    ticket.messages.push({
      senderType: 'admin',
      senderAdmin: req.admin._id,
      channel: selectedChannel,
      content: trimmedMessage,
      createdAt: new Date(),
    });

    ticket.status = selectedChannel === 'email' ? 'pending' : 'open';
    await ticket.save();

    return res.json({ success: true, data: ticket });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.put('/support/tickets/:id/status', requireRoles('SUPER_ADMIN', 'SUPPORT_ADMIN', 'OPERATIONS_ADMIN'), async (req, res) => {
  try {
    const { status } = req.body;
    if (!['open', 'pending', 'resolved', 'closed'].includes(String(status))) {
      return res.status(400).json({ success: false, message: 'Invalid status' });
    }

    const ticket = await SupportTicket.findByIdAndUpdate(
      req.params.id,
      { status: String(status) },
      { new: true },
    );

    if (!ticket) {
      return res.status(404).json({ success: false, message: 'Ticket not found' });
    }

    return res.json({ success: true, data: ticket });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.get('/reports', async (req, res) => {
  try {
    const { range = 'daily', from, to } = req.query;
    const { start, end } = getDateWindow({ range: String(range || 'daily'), from, to });
    const dateQuery = { createdAt: { $gte: start, $lte: end } };

    const completedStatuses = ['delivered'];

    const [
      totalOrders,
      returnedOrders,
      supportCaseCount,
      supportMessagesSent,
      completedSalesAgg,
      orders,
      foods,
      userOrderStats,
    ] = await Promise.all([
      Order.countDocuments(dateQuery),
      Order.countDocuments({ ...dateQuery, status: 'cancelled' }),
      SupportTicket.countDocuments(dateQuery),
      SupportTicket.aggregate([
        { $match: dateQuery },
        { $unwind: '$messages' },
        { $match: { 'messages.senderType': 'admin' } },
        { $count: 'total' },
      ]),
      Order.aggregate([
        { $match: { ...dateQuery, status: { $in: completedStatuses } } },
        { $group: { _id: null, total: { $sum: '$total' } } },
      ]),
      Order.find(dateQuery).select('items total createdAt user status'),
      Food.find({}).select('_id name'),
      Order.aggregate([
        { $match: dateQuery },
        { $group: { _id: '$user', count: { $sum: 1 } } },
      ]),
    ]);

    const itemTotals = new Map();
    orders.forEach((order) => {
      (order.items || []).forEach((item) => {
        const key = String(item.food || item.foodName || 'unknown');
        const entry = itemTotals.get(key) || {
          itemId: item.food ? String(item.food) : key,
          name: item.foodName || 'Unknown item',
          quantity: 0,
          revenue: 0,
        };
        entry.quantity += Number(item.quantity || 0);
        entry.revenue += Number(item.totalPrice || 0);
        itemTotals.set(key, entry);
      });
    });

    const itemStats = Array.from(itemTotals.values())
      .sort((a, b) => b.quantity - a.quantity);

    const foodIdsWithOrders = new Set(itemStats.map((entry) => String(entry.itemId)));
    const zeroOrderFoods = foods
      .filter((food) => !foodIdsWithOrders.has(String(food._id)))
      .map((food) => ({
        itemId: String(food._id),
        name: food.name,
        quantity: 0,
        revenue: 0,
      }));

    const topItems = itemStats.slice(0, 10);
    const lowPerformanceItems = [...zeroOrderFoods, ...itemStats.slice().reverse()].slice(0, 10);

    const customersWithOrders = userOrderStats.length;
    const repeatCustomers = userOrderStats.filter((entry) => entry.count >= 2).length;
    const repeatPurchaseRate = customersWithOrders > 0
      ? Number(((repeatCustomers / customersWithOrders) * 100).toFixed(2))
      : 0;

    const salesByBucket = await Order.aggregate([
      { $match: { ...dateQuery, status: { $in: completedStatuses } } },
      {
        $group: {
          _id: {
            $dateToString: {
              format: String(range) === 'monthly' ? '%Y-%m' : String(range) === 'weekly' ? '%Y-%U' : '%Y-%m-%d',
              date: '$createdAt',
            },
          },
          orders: { $sum: 1 },
          sales: { $sum: '$total' },
        },
      },
      { $sort: { _id: 1 } },
    ]);

    return res.json({
      success: true,
      data: {
        range,
        from: start,
        to: end,
        totalSales: Number(completedSalesAgg[0]?.total || 0),
        totalOrders,
        returnedOrders,
        casesOrMessagesSent: messageCount,
        casesOrMessagesSent: supportCaseCount + Number(supportMessagesSent[0]?.total || 0),
        topItems,
        lowPerformanceItems,
        salesByPeriod: salesByBucket.map((entry) => ({
          label: entry._id,
          orders: Number(entry.orders || 0),
          sales: Number(entry.sales || 0),
        })),
      },
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
