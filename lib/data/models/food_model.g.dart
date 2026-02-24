// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FoodModel _$FoodModelFromJson(Map<String, dynamic> json) => FoodModel(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  categoryId: json['categoryId'] as String,
  categoryName: json['categoryName'] as String,
  images: (json['images'] as List<dynamic>).map((e) => e as String).toList(),
  price: (json['price'] as num).toDouble(),
  originalPrice: (json['originalPrice'] as num?)?.toDouble(),
  preparationTime: (json['preparationTime'] as num).toInt(),
  rating: (json['rating'] as num?)?.toDouble() ?? 0,
  reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
  functionalScores: FunctionalScores.fromJson(
    json['functionalScores'] as Map<String, dynamic>,
  ),
  nutritionInfo: NutritionInfo.fromJson(
    json['nutritionInfo'] as Map<String, dynamic>,
  ),
  bestFor:
      (json['bestFor'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  bestTimes:
      (json['bestTimes'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$MealTimeEnumMap, e))
          .toList() ??
      const [],
  portionOptions:
      (json['portionOptions'] as List<dynamic>?)
          ?.map((e) => PortionOption.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  customizations:
      (json['customizations'] as List<dynamic>?)
          ?.map((e) => CustomizationGroup.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  dietaryTags:
      (json['dietaryTags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  isAvailable: json['isAvailable'] as bool? ?? true,
  isFeatured: json['isFeatured'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$FoodModelToJson(FoodModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'categoryId': instance.categoryId,
  'categoryName': instance.categoryName,
  'images': instance.images,
  'price': instance.price,
  'originalPrice': instance.originalPrice,
  'preparationTime': instance.preparationTime,
  'rating': instance.rating,
  'reviewCount': instance.reviewCount,
  'functionalScores': instance.functionalScores,
  'nutritionInfo': instance.nutritionInfo,
  'bestFor': instance.bestFor,
  'bestTimes': instance.bestTimes.map((e) => _$MealTimeEnumMap[e]!).toList(),
  'portionOptions': instance.portionOptions,
  'customizations': instance.customizations,
  'dietaryTags': instance.dietaryTags,
  'isAvailable': instance.isAvailable,
  'isFeatured': instance.isFeatured,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$MealTimeEnumMap = {
  MealTime.breakfast: 'breakfast',
  MealTime.lunch: 'lunch',
  MealTime.dinner: 'dinner',
  MealTime.snack: 'snack',
  MealTime.preWorkout: 'preWorkout',
  MealTime.postWorkout: 'postWorkout',
  MealTime.suhoor: 'suhoor',
  MealTime.iftar: 'iftar',
};

FunctionalScores _$FunctionalScoresFromJson(Map<String, dynamic> json) =>
    FunctionalScores(
      energyStability: (json['energyStability'] as num?)?.toInt() ?? 3,
      satiety: (json['satiety'] as num?)?.toInt() ?? 3,
      insulinImpact: (json['insulinImpact'] as num?)?.toInt() ?? 3,
      digestionEase: (json['digestionEase'] as num?)?.toInt() ?? 3,
      focusSupport: (json['focusSupport'] as num?)?.toInt() ?? 3,
      sleepFriendly: (json['sleepFriendly'] as num?)?.toInt() ?? 3,
      kidFriendly: (json['kidFriendly'] as num?)?.toInt() ?? 3,
      workoutSupport: (json['workoutSupport'] as num?)?.toInt() ?? 3,
    );

Map<String, dynamic> _$FunctionalScoresToJson(FunctionalScores instance) =>
    <String, dynamic>{
      'energyStability': instance.energyStability,
      'satiety': instance.satiety,
      'insulinImpact': instance.insulinImpact,
      'digestionEase': instance.digestionEase,
      'focusSupport': instance.focusSupport,
      'sleepFriendly': instance.sleepFriendly,
      'kidFriendly': instance.kidFriendly,
      'workoutSupport': instance.workoutSupport,
    };

NutritionInfo _$NutritionInfoFromJson(Map<String, dynamic> json) =>
    NutritionInfo(
      calories: (json['calories'] as num).toInt(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      fiber: (json['fiber'] as num?)?.toDouble() ?? 0,
      sugar: (json['sugar'] as num?)?.toDouble() ?? 0,
      sodium: (json['sodium'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$NutritionInfoToJson(NutritionInfo instance) =>
    <String, dynamic>{
      'calories': instance.calories,
      'protein': instance.protein,
      'carbs': instance.carbs,
      'fat': instance.fat,
      'fiber': instance.fiber,
      'sugar': instance.sugar,
      'sodium': instance.sodium,
    };

PortionOption _$PortionOptionFromJson(Map<String, dynamic> json) =>
    PortionOption(
      id: json['id'] as String,
      name: json['name'] as String,
      weightGrams: (json['weightGrams'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
      isPopular: json['isPopular'] as bool? ?? false,
    );

Map<String, dynamic> _$PortionOptionToJson(PortionOption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'weightGrams': instance.weightGrams,
      'price': instance.price,
      'isPopular': instance.isPopular,
    };

CustomizationGroup _$CustomizationGroupFromJson(Map<String, dynamic> json) =>
    CustomizationGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$CustomizationTypeEnumMap, json['type']),
      isRequired: json['isRequired'] as bool? ?? false,
      maxSelections: (json['maxSelections'] as num?)?.toInt(),
      options: (json['options'] as List<dynamic>)
          .map((e) => CustomizationOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CustomizationGroupToJson(CustomizationGroup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$CustomizationTypeEnumMap[instance.type]!,
      'isRequired': instance.isRequired,
      'maxSelections': instance.maxSelections,
      'options': instance.options,
    };

const _$CustomizationTypeEnumMap = {
  CustomizationType.single: 'single',
  CustomizationType.multiple: 'multiple',
};

CustomizationOption _$CustomizationOptionFromJson(Map<String, dynamic> json) =>
    CustomizationOption(
      id: json['id'] as String,
      name: json['name'] as String,
      priceModifier: (json['priceModifier'] as num?)?.toDouble() ?? 0,
      isDefault: json['isDefault'] as bool? ?? false,
    );

Map<String, dynamic> _$CustomizationOptionToJson(
  CustomizationOption instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'priceModifier': instance.priceModifier,
  'isDefault': instance.isDefault,
};

CategoryModel _$CategoryModelFromJson(Map<String, dynamic> json) =>
    CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      image: json['image'] as String,
      itemCount: (json['itemCount'] as num?)?.toInt() ?? 0,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$CategoryModelToJson(CategoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'image': instance.image,
      'itemCount': instance.itemCount,
      'sortOrder': instance.sortOrder,
      'isActive': instance.isActive,
    };
