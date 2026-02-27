import type { FoodItem } from '@/lib/types';

export type GuidedMood = {
  id: string;
  emoji: string;
  title: string;
  titleAr: string;
  image: string;
};

export const guidedMoods: GuidedMood[] = [
  { id: 'energy', emoji: '⚡', title: 'Energy', titleAr: 'طاقة', image: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=900&q=80' },
  { id: 'light', emoji: '🥗', title: 'Lightness', titleAr: 'خفة', image: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=900&q=80' },
  { id: 'muscle', emoji: '💪', title: 'Strength', titleAr: 'قوة', image: 'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?auto=format&fit=crop&w=900&q=80' },
  { id: 'comfort', emoji: '🫶', title: 'Comfort', titleAr: 'راحة', image: 'https://images.unsplash.com/photo-1498837167922-ddd27525d352?auto=format&fit=crop&w=900&q=80' },
  { id: 'focus', emoji: '🧠', title: 'Focus', titleAr: 'تركيز', image: 'https://images.unsplash.com/photo-1505576399279-565b52d4ac71?auto=format&fit=crop&w=900&q=80' },
  { id: 'smart-sweet', emoji: '🍫', title: 'Sweet Balance', titleAr: 'حلا متوازن', image: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=900&q=80' },
  { id: 'filling', emoji: '🍽️', title: 'Deep Satiety', titleAr: 'شبع عميق', image: 'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?auto=format&fit=crop&w=900&q=80' },
  { id: 'balance', emoji: '⚖️', title: 'Balance', titleAr: 'توازن', image: 'https://images.unsplash.com/photo-1490474418585-ba9bad8fd0ea?auto=format&fit=crop&w=900&q=80' },
];

export function filterFoodsByMood(foods: FoodItem[], moodId: string): FoodItem[] {
  const matched = foods.filter((food) => {
    const s = food.functionalScores;
    switch (moodId) {
      case 'energy':
        return s.energyStability >= 4;
      case 'light':
        return s.digestionEase >= 4;
      case 'muscle':
        return s.workoutSupport >= 4;
      case 'comfort':
        return s.satiety >= 4 && s.focusSupport >= 4;
      case 'focus':
        return s.focusSupport >= 4;
      case 'smart-sweet':
        return (food.category?.name || '').toLowerCase().includes('sweet') || (s.insulinImpact >= 4 && s.satiety >= 3);
      case 'filling':
        return s.satiety >= 4;
      case 'balance': {
        const avg = (s.energyStability + s.satiety + s.insulinImpact + s.digestionEase + s.focusSupport + s.sleepFriendly) / 6;
        return avg >= 3.8;
      }
      default:
        return true;
    }
  });

  return matched.sort((a, b) => scoreForMood(b, moodId) - scoreForMood(a, moodId));
}

function scoreForMood(food: FoodItem, moodId: string): number {
  const s = food.functionalScores;
  switch (moodId) {
    case 'energy':
      return s.energyStability;
    case 'light':
      return s.digestionEase;
    case 'muscle':
      return s.workoutSupport;
    case 'comfort':
      return s.satiety + s.focusSupport;
    case 'focus':
      return s.focusSupport;
    case 'smart-sweet':
      return s.insulinImpact + s.satiety;
    case 'filling':
      return s.satiety;
    case 'balance':
      return s.energyStability + s.satiety + s.insulinImpact + s.digestionEase + s.focusSupport + s.sleepFriendly;
    default:
      return 0;
  }
}
