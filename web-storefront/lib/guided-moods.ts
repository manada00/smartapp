import type { FoodItem } from '@/lib/types';

export type GuidedMood = {
  id: string;
  emoji: string;
  title: string;
};

export const guidedMoods: GuidedMood[] = [
  { id: 'energy', emoji: '⚡', title: 'I want energy' },
  { id: 'light', emoji: '🥗', title: 'I want something light' },
  { id: 'muscle', emoji: '💪', title: 'I want to build muscle' },
  { id: 'comfort', emoji: '🫶', title: 'I want comfort' },
  { id: 'focus', emoji: '🧠', title: 'I want focus' },
  { id: 'smart-sweet', emoji: '🍫', title: 'I want something sweet but smart' },
  { id: 'filling', emoji: '🍽️', title: 'I want something filling' },
  { id: 'balance', emoji: '⚖️', title: 'I want balance' },
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
