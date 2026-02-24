import 'package:json_annotation/json_annotation.dart';

part 'food_model.g.dart';

@JsonSerializable()
class FoodModel {
  final String id;
  final String name;
  final String description;
  final String categoryId;
  final String categoryName;
  final List<String> images;
  final double price;
  final double? originalPrice;
  final int preparationTime;
  final double rating;
  final int reviewCount;
  final FunctionalScores functionalScores;
  final NutritionInfo nutritionInfo;
  final List<String> bestFor;
  final List<MealTime> bestTimes;
  final List<PortionOption> portionOptions;
  final List<CustomizationGroup> customizations;
  final List<String> dietaryTags;
  final bool isAvailable;
  final bool isFeatured;
  final DateTime createdAt;

  FoodModel({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    required this.images,
    required this.price,
    this.originalPrice,
    required this.preparationTime,
    this.rating = 0,
    this.reviewCount = 0,
    required this.functionalScores,
    required this.nutritionInfo,
    this.bestFor = const [],
    this.bestTimes = const [],
    this.portionOptions = const [],
    this.customizations = const [],
    this.dietaryTags = const [],
    this.isAvailable = true,
    this.isFeatured = false,
    required this.createdAt,
  });

  factory FoodModel.fromJson(Map<String, dynamic> json) =>
      _$FoodModelFromJson(json);

  Map<String, dynamic> toJson() => _$FoodModelToJson(this);

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  double get discountPercentage {
    if (!hasDiscount) return 0;
    return ((originalPrice! - price) / originalPrice! * 100).roundToDouble();
  }
}

@JsonSerializable()
class FunctionalScores {
  final int energyStability;
  final int satiety;
  final int insulinImpact;
  final int digestionEase;
  final int focusSupport;
  final int sleepFriendly;
  final int kidFriendly;
  final int workoutSupport;

  FunctionalScores({
    this.energyStability = 3,
    this.satiety = 3,
    this.insulinImpact = 3,
    this.digestionEase = 3,
    this.focusSupport = 3,
    this.sleepFriendly = 3,
    this.kidFriendly = 3,
    this.workoutSupport = 3,
  });

  factory FunctionalScores.fromJson(Map<String, dynamic> json) =>
      _$FunctionalScoresFromJson(json);

  Map<String, dynamic> toJson() => _$FunctionalScoresToJson(this);
}

@JsonSerializable()
class NutritionInfo {
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium;

  NutritionInfo({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0,
    this.sugar = 0,
    this.sodium = 0,
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) =>
      _$NutritionInfoFromJson(json);

  Map<String, dynamic> toJson() => _$NutritionInfoToJson(this);
}

@JsonSerializable()
class PortionOption {
  final String id;
  final String name;
  final int weightGrams;
  final double price;
  final bool isPopular;

  PortionOption({
    required this.id,
    required this.name,
    required this.weightGrams,
    required this.price,
    this.isPopular = false,
  });

  factory PortionOption.fromJson(Map<String, dynamic> json) =>
      _$PortionOptionFromJson(json);

  Map<String, dynamic> toJson() => _$PortionOptionToJson(this);
}

@JsonSerializable()
class CustomizationGroup {
  final String id;
  final String name;
  final CustomizationType type;
  final bool isRequired;
  final int? maxSelections;
  final List<CustomizationOption> options;

  CustomizationGroup({
    required this.id,
    required this.name,
    required this.type,
    this.isRequired = false,
    this.maxSelections,
    required this.options,
  });

  factory CustomizationGroup.fromJson(Map<String, dynamic> json) =>
      _$CustomizationGroupFromJson(json);

  Map<String, dynamic> toJson() => _$CustomizationGroupToJson(this);
}

@JsonSerializable()
class CustomizationOption {
  final String id;
  final String name;
  final double priceModifier;
  final bool isDefault;

  CustomizationOption({
    required this.id,
    required this.name,
    this.priceModifier = 0,
    this.isDefault = false,
  });

  factory CustomizationOption.fromJson(Map<String, dynamic> json) =>
      _$CustomizationOptionFromJson(json);

  Map<String, dynamic> toJson() => _$CustomizationOptionToJson(this);
}

enum CustomizationType {
  single,
  multiple,
}

enum MealTime {
  breakfast('Breakfast', '🌅'),
  lunch('Lunch', '☀️'),
  dinner('Dinner', '🌙'),
  snack('Snack', '🍎'),
  preWorkout('Pre-Workout', '💪'),
  postWorkout('Post-Workout', '🏋️'),
  suhoor('Suhoor', '🌙'),
  iftar('Iftar', '🌅');

  final String label;
  final String emoji;

  const MealTime(this.label, this.emoji);
}

@JsonSerializable()
class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String image;
  final int itemCount;
  final int sortOrder;
  final bool isActive;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    this.itemCount = 0,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);
}

enum FeelingType {
  needEnergy('I need energy', '⚡', 'Energy Boosting Meals'),
  veryHungry("I'm very hungry", '🍽️', 'Filling & Satisfying'),
  somethingLight('Something light', '🥗', 'Light & Fresh'),
  trainedToday('I trained today', '💪', 'Post-Workout Recovery'),
  stressed("I'm stressed", '😰', 'Comfort & Calm'),
  bloated("I'm bloated", '🫄', 'Gentle on Digestion'),
  helpSleep('Help me sleep', '😴', 'Sleep-Friendly Options'),
  kidNeedsMeal('Kid needs meal', '👶', 'Kid-Approved Meals'),
  fastingTomorrow('Fasting tomorrow', '🌙', 'Suhoor Sustaining Meals'),
  browseAll('Browse all', '🔍', 'All Meals');

  final String label;
  final String emoji;
  final String recommendationTitle;

  const FeelingType(this.label, this.emoji, this.recommendationTitle);
}
