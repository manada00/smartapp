const mongoose = require('mongoose');
require('dotenv').config();
const Category = require('../models/Category');
const Food = require('../models/Food');

const categories = [
  {
    name: 'Daily Meals',
    description: 'Balanced meals for everyday nutrition',
    image: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
    sortOrder: 1,
  },
  {
    name: 'Smart Salads',
    description: 'Fresh and nutritious salads',
    image: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd',
    sortOrder: 2,
  },
  {
    name: 'Functional Snacks',
    description: 'Healthy snacks to fuel your day',
    image: 'https://images.unsplash.com/photo-1490474418585-ba9bad8fd0ea',
    sortOrder: 3,
  },
  {
    name: 'Gym Performance',
    description: 'High-protein meals for athletes',
    image: 'https://images.unsplash.com/photo-1532550907401-a500c9a57435',
    sortOrder: 4,
  },
  {
    name: 'Kids Meals',
    description: 'Nutritious and fun meals for kids',
    image: 'https://images.unsplash.com/photo-1484723091739-30a097e8f929',
    sortOrder: 5,
  },
  {
    name: 'Digestive Comfort',
    description: 'Easy to digest, gentle meals',
    image: 'https://images.unsplash.com/photo-1547592166-23ac45744acd',
    sortOrder: 6,
  },
  {
    name: 'Night & Calm',
    description: 'Light meals for better sleep',
    image: 'https://images.unsplash.com/photo-1476224203421-9ac39bcb3327',
    sortOrder: 7,
  },
  {
    name: 'Meal Bundles',
    description: 'Value bundles for the whole day',
    image: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836',
    sortOrder: 8,
  },
];

const createFoods = (categoryMap) => [
  {
    name: 'Grilled Salmon Power Bowl',
    description: 'Wild-caught salmon fillet served with quinoa, roasted vegetables, and a lemon tahini dressing. Perfect for sustained energy and muscle recovery.',
    category: categoryMap['Daily Meals'],
    images: ['https://images.unsplash.com/photo-1467003909585-2f8a72700288'],
    price: 165,
    preparationTime: 15,
    rating: 4.8,
    reviewCount: 120,
    functionalScores: {
      energyStability: 4,
      satiety: 5,
      insulinImpact: 2,
      digestionEase: 4,
      focusSupport: 5,
      sleepFriendly: 3,
      kidFriendly: 3,
      workoutSupport: 5,
    },
    nutritionInfo: {
      calories: 520,
      protein: 42,
      carbs: 35,
      fat: 22,
      fiber: 8,
    },
    bestFor: ['Post-Workout', 'High Energy', 'Weight Loss'],
    bestTimes: ['lunch', 'dinner', 'post_workout'],
    portionOptions: [
      { name: 'Regular', weightGrams: 350, price: 165 },
      { name: 'Large', weightGrams: 450, price: 195, isPopular: true },
    ],
    customizations: [
      {
        name: 'Extra Protein',
        type: 'multiple',
        options: [
          { name: 'Extra Salmon (+50g)', priceModifier: 45 },
          { name: 'Add Grilled Chicken', priceModifier: 35 },
          { name: 'Add 2 Boiled Eggs', priceModifier: 20 },
        ],
      },
      {
        name: 'Modifications',
        type: 'multiple',
        options: [
          { name: 'No Sauce', priceModifier: 0 },
          { name: 'Sauce on Side', priceModifier: 0 },
          { name: 'Extra Vegetables', priceModifier: 15 },
        ],
      },
      {
        name: 'Carb Options',
        type: 'single',
        isRequired: true,
        options: [
          { name: 'Quinoa (default)', priceModifier: 0, isDefault: true },
          { name: 'Brown Rice', priceModifier: 0 },
          { name: 'No Carbs', priceModifier: -15 },
        ],
      },
    ],
    dietaryTags: ['High Protein', 'Omega-Rich', 'Gluten-Free'],
    isFeatured: true,
  },
  {
    name: 'Green Goddess Salad',
    description: 'Fresh mixed greens with avocado, cucumber, chickpeas, and our signature green goddess dressing. Light yet satisfying.',
    category: categoryMap['Smart Salads'],
    images: ['https://images.unsplash.com/photo-1540420773420-3366772f4999'],
    price: 95,
    preparationTime: 8,
    rating: 4.6,
    reviewCount: 85,
    functionalScores: {
      energyStability: 3,
      satiety: 3,
      insulinImpact: 1,
      digestionEase: 5,
      focusSupport: 4,
      sleepFriendly: 4,
      kidFriendly: 2,
      workoutSupport: 2,
    },
    nutritionInfo: {
      calories: 320,
      protein: 12,
      carbs: 28,
      fat: 18,
      fiber: 12,
    },
    bestFor: ['Light Meal', 'Digestion', 'Detox'],
    bestTimes: ['lunch', 'dinner'],
    portionOptions: [
      { name: 'Regular', weightGrams: 300, price: 95 },
      { name: 'Large', weightGrams: 400, price: 125 },
    ],
    dietaryTags: ['Vegetarian', 'Low Carb', 'Detox'],
  },
  {
    name: 'Protein Overnight Oats',
    description: 'Creamy overnight oats with protein powder, chia seeds, almond butter, and fresh berries. Perfect fuel for your morning.',
    category: categoryMap['Daily Meals'],
    images: ['https://images.unsplash.com/photo-1517673400267-0251440c45dc'],
    price: 75,
    preparationTime: 0,
    rating: 4.7,
    reviewCount: 95,
    functionalScores: {
      energyStability: 5,
      satiety: 4,
      insulinImpact: 2,
      digestionEase: 4,
      focusSupport: 4,
      sleepFriendly: 3,
      kidFriendly: 5,
      workoutSupport: 4,
    },
    nutritionInfo: {
      calories: 380,
      protein: 25,
      carbs: 42,
      fat: 12,
      fiber: 8,
    },
    bestFor: ['Breakfast', 'Energy', 'Fasting'],
    bestTimes: ['breakfast', 'suhoor'],
    dietaryTags: ['Vegetarian', 'Meal Prep', 'High Fiber'],
  },
  {
    name: 'Grilled Chicken & Quinoa',
    description: 'Herb-marinated grilled chicken breast with fluffy quinoa, roasted vegetables, and homemade chimichurri sauce.',
    category: categoryMap['Daily Meals'],
    images: ['https://images.unsplash.com/photo-1532550907401-a500c9a57435'],
    price: 135,
    preparationTime: 12,
    rating: 4.8,
    reviewCount: 156,
    functionalScores: {
      energyStability: 5,
      satiety: 5,
      insulinImpact: 2,
      digestionEase: 4,
      focusSupport: 4,
      sleepFriendly: 3,
      kidFriendly: 4,
      workoutSupport: 5,
    },
    nutritionInfo: {
      calories: 480,
      protein: 45,
      carbs: 32,
      fat: 18,
      fiber: 6,
    },
    bestFor: ['Hungry', 'Post-Workout', 'Muscle Building'],
    bestTimes: ['lunch', 'dinner', 'post_workout'],
    dietaryTags: ['High Protein', 'Gluten-Free'],
    isFeatured: true,
  },
  {
    name: 'Chamomile Sleep Smoothie',
    description: 'Calming smoothie with chamomile tea, banana, almond butter, and honey. Natural sleep support in a delicious drink.',
    category: categoryMap['Night & Calm'],
    images: ['https://images.unsplash.com/photo-1553530666-ba11a7da3888'],
    price: 65,
    preparationTime: 5,
    rating: 4.4,
    reviewCount: 43,
    functionalScores: {
      energyStability: 3,
      satiety: 2,
      insulinImpact: 1,
      digestionEase: 5,
      focusSupport: 2,
      sleepFriendly: 5,
      kidFriendly: 4,
      workoutSupport: 1,
    },
    nutritionInfo: {
      calories: 220,
      protein: 6,
      carbs: 32,
      fat: 8,
      fiber: 4,
    },
    bestFor: ['Sleep', 'Relaxation', 'Calm'],
    bestTimes: ['dinner', 'snack'],
    dietaryTags: ['Dairy-Free', 'Low Sugar', 'Sleep Support'],
  },
  {
    name: 'Kids Rainbow Veggie Bites',
    description: 'Fun and colorful vegetable bites that kids love. Packed with hidden veggies and served with a tasty yogurt dip.',
    category: categoryMap['Kids Meals'],
    images: ['https://images.unsplash.com/photo-1565958011703-44f9829ba187'],
    price: 85,
    preparationTime: 10,
    rating: 4.5,
    reviewCount: 67,
    functionalScores: {
      energyStability: 4,
      satiety: 3,
      insulinImpact: 2,
      digestionEase: 4,
      focusSupport: 4,
      sleepFriendly: 3,
      kidFriendly: 5,
      workoutSupport: 2,
    },
    nutritionInfo: {
      calories: 280,
      protein: 12,
      carbs: 35,
      fat: 10,
      fiber: 6,
    },
    bestFor: ['Kids', 'Picky Eaters'],
    bestTimes: ['lunch', 'dinner', 'snack'],
    dietaryTags: ['Kid Approved', 'Hidden Veggies', 'Vegetarian'],
  },
  {
    name: 'Pre-Workout Energy Bites (6 pcs)',
    description: 'Energizing date and nut bites with a hint of espresso. Perfect fuel 30 minutes before your workout.',
    category: categoryMap['Gym Performance'],
    images: ['https://images.unsplash.com/photo-1604467794349-0b74285de7e7'],
    price: 55,
    preparationTime: 0,
    rating: 4.6,
    reviewCount: 78,
    functionalScores: {
      energyStability: 4,
      satiety: 2,
      insulinImpact: 3,
      digestionEase: 4,
      focusSupport: 5,
      sleepFriendly: 1,
      kidFriendly: 3,
      workoutSupport: 5,
    },
    nutritionInfo: {
      calories: 180,
      protein: 6,
      carbs: 28,
      fat: 8,
      fiber: 4,
    },
    bestFor: ['Pre-Workout', 'Quick Energy', 'Focus'],
    bestTimes: ['pre_workout', 'snack'],
    dietaryTags: ['Vegan', 'Quick Energy', 'Portable'],
  },
  {
    name: 'Gut-Healing Bone Broth Soup',
    description: 'Slow-simmered bone broth with ginger, turmeric, and healing herbs. Gentle on the stomach and deeply nourishing.',
    category: categoryMap['Digestive Comfort'],
    images: ['https://images.unsplash.com/photo-1547592166-23ac45744acd'],
    price: 85,
    preparationTime: 5,
    rating: 4.7,
    reviewCount: 52,
    functionalScores: {
      energyStability: 3,
      satiety: 3,
      insulinImpact: 1,
      digestionEase: 5,
      focusSupport: 3,
      sleepFriendly: 4,
      kidFriendly: 3,
      workoutSupport: 3,
    },
    nutritionInfo: {
      calories: 120,
      protein: 10,
      carbs: 8,
      fat: 5,
      fiber: 2,
    },
    bestFor: ['Bloated', 'Light Meal', 'Stressed', 'Recovery'],
    bestTimes: ['lunch', 'dinner'],
    dietaryTags: ['Anti-Inflammatory', 'Gut Health', 'Keto-Friendly'],
  },
  {
    name: 'Hormone Balance Bowl',
    description: 'Specially designed bowl with wild-caught fish, cruciferous vegetables, and seeds to support hormonal health.',
    category: categoryMap['Daily Meals'],
    images: ['https://images.unsplash.com/photo-1490645935967-10de6ba17061'],
    price: 145,
    preparationTime: 15,
    rating: 4.5,
    reviewCount: 38,
    functionalScores: {
      energyStability: 5,
      satiety: 4,
      insulinImpact: 1,
      digestionEase: 4,
      focusSupport: 4,
      sleepFriendly: 4,
      kidFriendly: 2,
      workoutSupport: 3,
    },
    nutritionInfo: {
      calories: 420,
      protein: 35,
      carbs: 28,
      fat: 20,
      fiber: 10,
    },
    bestFor: ['Stressed', 'Energy', 'Hormone Support'],
    bestTimes: ['lunch', 'dinner'],
    dietaryTags: ['PCOS Friendly', 'Hormone Support', 'Anti-Inflammatory'],
  },
  {
    name: 'Suhoor Sustain Plate',
    description: 'Specially designed for Ramadan. Slow-release carbs, protein, and healthy fats to keep you full through the fast.',
    category: categoryMap['Daily Meals'],
    images: ['https://images.unsplash.com/photo-1504674900247-0877df9cc836'],
    price: 125,
    preparationTime: 12,
    rating: 4.9,
    reviewCount: 89,
    functionalScores: {
      energyStability: 5,
      satiety: 5,
      insulinImpact: 2,
      digestionEase: 4,
      focusSupport: 4,
      sleepFriendly: 3,
      kidFriendly: 4,
      workoutSupport: 3,
    },
    nutritionInfo: {
      calories: 550,
      protein: 30,
      carbs: 55,
      fat: 22,
      fiber: 12,
    },
    bestFor: ['Fasting', 'Hungry', 'Sustained Energy'],
    bestTimes: ['suhoor', 'breakfast'],
    dietaryTags: ['Ramadan Special', 'Slow Release', 'High Fiber'],
  },
];

const seedDatabase = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to MongoDB');

    // Clear existing data
    await Category.deleteMany({});
    await Food.deleteMany({});
    console.log('Cleared existing data');

    // Insert categories
    const insertedCategories = await Category.insertMany(categories);
    console.log(`Inserted ${insertedCategories.length} categories`);

    // Create category map
    const categoryMap = {};
    insertedCategories.forEach(cat => {
      categoryMap[cat.name] = cat._id;
    });

    // Insert foods
    const foodsData = createFoods(categoryMap);
    const insertedFoods = await Food.insertMany(foodsData);
    console.log(`Inserted ${insertedFoods.length} foods`);

    console.log('Database seeded successfully!');
    process.exit(0);
  } catch (error) {
    console.error('Error seeding database:', error);
    process.exit(1);
  }
};

seedDatabase();
