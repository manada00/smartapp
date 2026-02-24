const express = require('express');
const Food = require('../models/Food');
const Category = require('../models/Category');
const { protect } = require('../middleware/auth');

const router = express.Router();

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
