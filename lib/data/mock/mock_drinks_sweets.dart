import '../models/food_model.dart';

const String drinksAndSweetsCategoryId = 'mock_drinks_sweets';
const String healthyDrinksCategoryId = 'mock_healthy_drinks';
const String smartSweetsCategoryId = 'mock_smart_sweets';

List<CategoryModel> drinksAndSweetsMockCategories() {
  return [
    CategoryModel(
      id: drinksAndSweetsCategoryId,
      name: 'Drinks & Sweets',
      description: 'Premium healthy drinks and smart sweets.',
      image:
          'https://images.unsplash.com/photo-1464306076886-da185f6a9d05?auto=format&fit=crop&w=1200&q=80',
      itemCount: 10,
      sortOrder: 90,
      isActive: true,
    ),
    CategoryModel(
      id: healthyDrinksCategoryId,
      name: 'Healthy Drinks',
      description: 'Functional beverages with premium ingredients.',
      image:
          'https://images.unsplash.com/photo-1556881286-fc6915169721?auto=format&fit=crop&w=1200&q=80',
      itemCount: 5,
      sortOrder: 91,
      isActive: true,
    ),
    CategoryModel(
      id: smartSweetsCategoryId,
      name: 'Smart Sweets',
      description: 'Balanced desserts designed for better choices.',
      image:
          'https://images.unsplash.com/photo-1499636136210-6f4ee915583e?auto=format&fit=crop&w=1200&q=80',
      itemCount: 5,
      sortOrder: 92,
      isActive: true,
    ),
  ];
}

List<FoodModel> drinksAndSweetsMockFoods() {
  final now = DateTime.now();
  return [
    _item(
      id: 'mock_drink_protein_smoothie',
      name: 'Protein Smoothie',
      categoryId: healthyDrinksCategoryId,
      categoryName: 'Healthy Drinks',
      image:
          'https://images.unsplash.com/photo-1589733955941-5eeaf752f6dd?auto=format&fit=crop&w=1200&q=80',
      price: 185,
      energy: 5,
      satiety: 4,
      muscle: 5,
      now: now,
    ),
    _item(
      id: 'mock_drink_matcha_latte',
      name: 'Matcha Latte',
      categoryId: healthyDrinksCategoryId,
      categoryName: 'Healthy Drinks',
      image:
          'https://images.unsplash.com/photo-1515823064-d6e0c04616a7?auto=format&fit=crop&w=1200&q=80',
      price: 165,
      energy: 4,
      focus: 5,
      insulin: 4,
      now: now,
    ),
    _item(
      id: 'mock_drink_iced_oat_coffee',
      name: 'Iced Oat Coffee',
      categoryId: healthyDrinksCategoryId,
      categoryName: 'Healthy Drinks',
      image:
          'https://images.unsplash.com/photo-1517701550927-30cf4ba1f7f1?auto=format&fit=crop&w=1200&q=80',
      price: 155,
      energy: 4,
      satiety: 3,
      focus: 4,
      now: now,
    ),
    _item(
      id: 'mock_drink_electrolyte_refresher',
      name: 'Electrolyte Refresher',
      categoryId: healthyDrinksCategoryId,
      categoryName: 'Healthy Drinks',
      image:
          'https://images.unsplash.com/photo-1502741224143-90386d7f8c82?auto=format&fit=crop&w=1200&q=80',
      price: 145,
      energy: 4,
      digestion: 4,
      sleep: 3,
      now: now,
    ),
    _item(
      id: 'mock_drink_collagen_berry',
      name: 'Collagen Berry Drink',
      categoryId: healthyDrinksCategoryId,
      categoryName: 'Healthy Drinks',
      image:
          'https://images.unsplash.com/photo-1610970881699-44a5587cabec?auto=format&fit=crop&w=1200&q=80',
      price: 195,
      energy: 4,
      satiety: 4,
      digestion: 4,
      now: now,
    ),
    _item(
      id: 'mock_sweet_protein_brownie',
      name: 'Protein Brownie',
      categoryId: smartSweetsCategoryId,
      categoryName: 'Smart Sweets',
      image:
          'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?auto=format&fit=crop&w=1200&q=80',
      price: 135,
      satiety: 4,
      muscle: 4,
      insulin: 4,
      now: now,
    ),
    _item(
      id: 'mock_sweet_date_energy_bites',
      name: 'Date Energy Bites',
      categoryId: smartSweetsCategoryId,
      categoryName: 'Smart Sweets',
      image:
          'https://images.unsplash.com/photo-1515003197210-e0cd71810b5f?auto=format&fit=crop&w=1200&q=80',
      price: 120,
      energy: 5,
      satiety: 4,
      insulin: 3,
      now: now,
    ),
    _item(
      id: 'mock_sweet_keto_cheesecake',
      name: 'Keto Cheesecake Cup',
      categoryId: smartSweetsCategoryId,
      categoryName: 'Smart Sweets',
      image:
          'https://images.unsplash.com/photo-1533134242443-d4fd215305ad?auto=format&fit=crop&w=1200&q=80',
      price: 150,
      focus: 5,
      insulin: 4,
      sleep: 3,
      now: now,
    ),
    _item(
      id: 'mock_sweet_dark_choco_mousse',
      name: 'Dark Chocolate Mousse',
      categoryId: smartSweetsCategoryId,
      categoryName: 'Smart Sweets',
      image:
          'https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=1200&q=80',
      price: 140,
      satiety: 3,
      focus: 4,
      sleep: 4,
      now: now,
    ),
    _item(
      id: 'mock_sweet_almond_coconut_balls',
      name: 'Almond Coconut Balls',
      categoryId: smartSweetsCategoryId,
      categoryName: 'Smart Sweets',
      image:
          'https://images.unsplash.com/photo-1505253758473-96b7015fcd40?auto=format&fit=crop&w=1200&q=80',
      price: 125,
      energy: 4,
      satiety: 4,
      digestion: 4,
      now: now,
    ),
  ];
}

FoodModel _item({
  required String id,
  required String name,
  required String categoryId,
  required String categoryName,
  required String image,
  required double price,
  int energy = 3,
  int satiety = 3,
  int insulin = 3,
  int digestion = 3,
  int focus = 3,
  int sleep = 3,
  int muscle = 3,
  required DateTime now,
}) {
  return FoodModel(
    id: id,
    name: name,
    description:
        'Mock item for Drinks & Sweets section. Premium healthy profile.',
    categoryId: categoryId,
    categoryName: categoryName,
    images: [image],
    price: price,
    preparationTime: 6,
    rating: 4.7,
    reviewCount: 24,
    functionalScores: FunctionalScores(
      energyStability: energy,
      satiety: satiety,
      insulinImpact: insulin,
      digestionEase: digestion,
      focusSupport: focus,
      sleepFriendly: sleep,
      kidFriendly: 3,
      workoutSupport: muscle,
    ),
    nutritionInfo: NutritionInfo(
      calories: 240,
      protein: 16,
      carbs: 18,
      fat: 11,
      fiber: 4,
      sugar: 8,
      sodium: 80,
    ),
    dietaryTags: const ['Mock', 'Drinks & Sweets'],
    isAvailable: true,
    isFeatured: true,
    createdAt: now,
  );
}
