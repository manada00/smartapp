import type { Category, FoodItem } from '@/lib/types';

export const drinksSweetsCategoryId = 'mock_drinks_sweets';
export const healthyDrinksCategoryId = 'mock_healthy_drinks';
export const smartSweetsCategoryId = 'mock_smart_sweets';

export const mockDrinksSweetsCategories: Category[] = [
  { _id: drinksSweetsCategoryId, name: 'Drinks & Sweets', description: 'Premium healthy drinks and smart desserts.', itemCount: 10 },
  { _id: healthyDrinksCategoryId, name: 'Healthy Drinks', description: 'Functional drinks for energy and focus.', itemCount: 5 },
  { _id: smartSweetsCategoryId, name: 'Smart Sweets', description: 'Balanced sweets with better macros.', itemCount: 5 },
];

function scores(partial: Partial<FoodItem['functionalScores']>): FoodItem['functionalScores'] {
  return {
    energyStability: 3,
    satiety: 3,
    insulinImpact: 3,
    digestionEase: 3,
    focusSupport: 3,
    sleepFriendly: 3,
    kidFriendly: 3,
    workoutSupport: 3,
    ...partial,
  };
}

export const mockDrinksSweetsFoods: FoodItem[] = [
  {
    _id: 'mock_drink_protein_smoothie',
    name: 'Protein Smoothie',
    description: 'Premium smoothie with whey isolate, banana, and almond butter.',
    images: ['https://images.unsplash.com/photo-1589733955941-5eeaf752f6dd?auto=format&fit=crop&w=1200&q=80'],
    price: 185,
    category: { _id: healthyDrinksCategoryId, name: 'Healthy Drinks' },
    functionalScores: scores({ energyStability: 5, satiety: 4, workoutSupport: 5 }),
  },
  {
    _id: 'mock_drink_matcha_latte',
    name: 'Matcha Latte',
    description: 'Ceremonial matcha with oat milk for calm sustained focus.',
    images: ['https://images.unsplash.com/photo-1515823064-d6e0c04616a7?auto=format&fit=crop&w=1200&q=80'],
    price: 165,
    category: { _id: healthyDrinksCategoryId, name: 'Healthy Drinks' },
    functionalScores: scores({ energyStability: 4, focusSupport: 5, insulinImpact: 4 }),
  },
  {
    _id: 'mock_drink_iced_oat_coffee',
    name: 'Iced Oat Coffee',
    description: 'Cold brew, oat milk, and cinnamon over ice.',
    images: ['https://images.unsplash.com/photo-1517701550927-30cf4ba1f7f1?auto=format&fit=crop&w=1200&q=80'],
    price: 155,
    category: { _id: healthyDrinksCategoryId, name: 'Healthy Drinks' },
    functionalScores: scores({ energyStability: 4, focusSupport: 4, satiety: 3 }),
  },
  {
    _id: 'mock_drink_electrolyte_refresher',
    name: 'Electrolyte Refresher',
    description: 'Hydration blend with citrus and mineral support.',
    images: ['https://images.unsplash.com/photo-1502741224143-90386d7f8c82?auto=format&fit=crop&w=1200&q=80'],
    price: 145,
    category: { _id: healthyDrinksCategoryId, name: 'Healthy Drinks' },
    functionalScores: scores({ energyStability: 4, digestionEase: 4, sleepFriendly: 3 }),
  },
  {
    _id: 'mock_drink_collagen_berry',
    name: 'Collagen Berry Drink',
    description: 'Berry antioxidant blend with marine collagen peptides.',
    images: ['https://images.unsplash.com/photo-1610970881699-44a5587cabec?auto=format&fit=crop&w=1200&q=80'],
    price: 195,
    category: { _id: healthyDrinksCategoryId, name: 'Healthy Drinks' },
    functionalScores: scores({ energyStability: 4, satiety: 4, digestionEase: 4 }),
  },
  {
    _id: 'mock_sweet_protein_brownie',
    name: 'Protein Brownie',
    description: 'Dark cocoa brownie with high-protein base and low sugar.',
    images: ['https://images.unsplash.com/photo-1606313564200-e75d5e30476c?auto=format&fit=crop&w=1200&q=80'],
    price: 135,
    category: { _id: smartSweetsCategoryId, name: 'Smart Sweets' },
    functionalScores: scores({ satiety: 4, workoutSupport: 4, insulinImpact: 4 }),
  },
  {
    _id: 'mock_sweet_date_energy_bites',
    name: 'Date Energy Bites',
    description: 'Date, almond, and chia bites for natural quick energy.',
    images: ['https://images.unsplash.com/photo-1515003197210-e0cd71810b5f?auto=format&fit=crop&w=1200&q=80'],
    price: 120,
    category: { _id: smartSweetsCategoryId, name: 'Smart Sweets' },
    functionalScores: scores({ energyStability: 5, satiety: 4, insulinImpact: 3 }),
  },
  {
    _id: 'mock_sweet_keto_cheesecake',
    name: 'Keto Cheesecake Cup',
    description: 'Creamy vanilla cheesecake cup with low-carb profile.',
    images: ['https://images.unsplash.com/photo-1533134242443-d4fd215305ad?auto=format&fit=crop&w=1200&q=80'],
    price: 150,
    category: { _id: smartSweetsCategoryId, name: 'Smart Sweets' },
    functionalScores: scores({ focusSupport: 5, insulinImpact: 4, sleepFriendly: 3 }),
  },
  {
    _id: 'mock_sweet_dark_choco_mousse',
    name: 'Dark Chocolate Mousse',
    description: 'Silky mousse with 70% dark chocolate and Greek yogurt.',
    images: ['https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=1200&q=80'],
    price: 140,
    category: { _id: smartSweetsCategoryId, name: 'Smart Sweets' },
    functionalScores: scores({ satiety: 3, focusSupport: 4, sleepFriendly: 4 }),
  },
  {
    _id: 'mock_sweet_almond_coconut_balls',
    name: 'Almond Coconut Balls',
    description: 'No-bake almond coconut balls with gentle sweetness.',
    images: ['https://images.unsplash.com/photo-1505253758473-96b7015fcd40?auto=format&fit=crop&w=1200&q=80'],
    price: 125,
    category: { _id: smartSweetsCategoryId, name: 'Smart Sweets' },
    functionalScores: scores({ energyStability: 4, satiety: 4, digestionEase: 4 }),
  },
];

export function findMockFoodById(id: string): FoodItem | undefined {
  return mockDrinksSweetsFoods.find((item) => item._id === id);
}
