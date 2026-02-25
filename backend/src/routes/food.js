const express = require('express');
const Food = require('../models/Food');
const Category = require('../models/Category');
const AppConfig = require('../models/AppConfig');
const { protect } = require('../middleware/auth');

const router = express.Router();

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

// Get categories
router.get('/categories', async (req, res) => {
  try {
    const categories = await Category.aggregate([
      { $match: { isActive: true } },
      {
        $lookup: {
          from: 'foods',
          localField: '_id',
          foreignField: 'category',
          as: 'foods',
        },
      },
      {
        $project: {
          name: 1,
          description: 1,
          image: 1,
          sortOrder: 1,
          itemCount: { $size: '$foods' },
        },
      },
      { $sort: { sortOrder: 1 } },
    ]);

    res.json({
      success: true,
      data: categories,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// Get foods (with filters)
router.get('/', async (req, res) => {
  try {
    const {
      category,
      search,
      dietary,
      goals,
      minPrice,
      maxPrice,
      minRating,
      prepTime,
      page = 1,
      limit = 20,
    } = req.query;

    const query = { isAvailable: true };

    if (category) {
      query.category = category;
    }

    if (search) {
      query.$text = { $search: search };
    }

    if (dietary) {
      const tags = dietary.split(',');
      query.dietaryTags = { $all: tags };
    }

    if (goals) {
      const goalList = goals.split(',');
      query.bestFor = { $in: goalList };
    }

    if (minPrice || maxPrice) {
      query.price = {};
      if (minPrice) query.price.$gte = Number(minPrice);
      if (maxPrice) query.price.$lte = Number(maxPrice);
    }

    if (minRating) {
      query.rating = { $gte: Number(minRating) };
    }

    if (prepTime) {
      query.preparationTime = { $lte: Number(prepTime) };
    }

    const foods = await Food.find(query)
      .populate('category', 'name')
      .skip((page - 1) * limit)
      .limit(Number(limit))
      .sort({ sortOrder: 1, rating: -1, createdAt: -1 });

    const total = await Food.countDocuments(query);

    res.json({
      success: true,
      data: foods,
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

// Get home screen config
router.get('/home-config', async (req, res) => {
  try {
    const config = await getOrCreateAppConfig();

    const moods = (Array.isArray(config.moods) ? config.moods : DEFAULT_MOODS)
      .filter((mood) => mood.isVisible !== false)
      .sort((a, b) => Number(a.sortOrder || 0) - Number(b.sortOrder || 0));

    return res.json({
      success: true,
      data: {
        heroTitle: config.homeHero?.title || '',
        heroSubtitle: config.homeHero?.subtitle || '',
        announcementEnabled: Boolean(config.announcement?.enabled),
        announcementMessage: config.announcement?.message || '',
        promotions: Array.isArray(config.promotions)
          ? config.promotions.filter((item) => item?.isActive)
          : [],
        moods,
        popularFoodIds: (config.popularFoodIds || []).map((id) => String(id)),
      },
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// Get support contact config
router.get('/support-config', async (req, res) => {
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
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// Get food by ID
router.get('/:id', async (req, res) => {
  try {
    const food = await Food.findById(req.params.id).populate('category', 'name');

    if (!food) {
      return res.status(404).json({
        success: false,
        message: 'Food not found',
      });
    }

    res.json({
      success: true,
      data: food,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// Get recommendations based on feeling
router.get('/recommendations/:feeling', protect, async (req, res) => {
  try {
    const { feeling } = req.params;
    const user = req.user;

    // Map feelings to functional score priorities
    const feelingScores = {
      need_energy: { field: 'functionalScores.energyStability', order: -1 },
      very_hungry: { field: 'functionalScores.satiety', order: -1 },
      something_light: { field: 'nutritionInfo.calories', order: 1 },
      trained_today: { field: 'functionalScores.workoutSupport', order: -1 },
      stressed: { field: 'functionalScores.digestionEase', order: -1 },
      bloated: { field: 'functionalScores.digestionEase', order: -1 },
      help_sleep: { field: 'functionalScores.sleepFriendly', order: -1 },
      kid_needs_meal: { field: 'functionalScores.kidFriendly', order: -1 },
      fasting_tomorrow: { field: 'functionalScores.satiety', order: -1 },
    };

    const scoreConfig = feelingScores[feeling] || feelingScores.need_energy;

    // Build dietary filters based on user preferences
    const query = { isAvailable: true };
    
    if (user.dietaryPreferences) {
      if (user.dietaryPreferences.isVegetarian) {
        query.dietaryTags = { $in: ['Vegetarian'] };
      }
      if (user.dietaryPreferences.allergies?.length > 0) {
        query.dietaryTags = { 
          ...query.dietaryTags,
          $nin: user.dietaryPreferences.allergies,
        };
      }
    }

    // Get foods sorted by relevant score
    const foods = await Food.find(query)
      .populate('category', 'name')
      .sort({ [scoreConfig.field]: scoreConfig.order })
      .limit(20);

    // Categorize foods
    const perfect = foods.filter(f => f.functionalScores && 
      f.functionalScores[scoreConfig.field.split('.')[1]] >= 4);
    const good = foods.filter(f => f.functionalScores && 
      f.functionalScores[scoreConfig.field.split('.')[1]] === 3);
    const notIdeal = foods.filter(f => f.functionalScores && 
      f.functionalScores[scoreConfig.field.split('.')[1]] < 3);

    res.json({
      success: true,
      data: {
        perfect,
        good,
        notIdeal,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// Search foods
router.get('/search/:query', async (req, res) => {
  try {
    const foods = await Food.find({
      $text: { $search: req.params.query },
      isAvailable: true,
    })
      .populate('category', 'name')
      .limit(20);

    res.json({
      success: true,
      data: foods,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

module.exports = router;
