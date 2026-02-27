export type FunctionalScores = {
  energyStability: number;
  satiety: number;
  insulinImpact: number;
  digestionEase: number;
  focusSupport: number;
  sleepFriendly: number;
  kidFriendly: number;
  workoutSupport: number;
};

export type FoodItem = {
  _id: string;
  name: string;
  nameAr?: string;
  description: string;
  descriptionAr?: string;
  images?: string[];
  price: number;
  category?: { _id: string; name: string; nameAr?: string };
  functionalScores: FunctionalScores;
};

export type Category = {
  _id: string;
  name: string;
  nameAr?: string;
  description?: string;
  descriptionAr?: string;
  itemCount?: number;
};

export type CartItem = {
  id: string;
  name: string;
  price: number;
  quantity: number;
};
