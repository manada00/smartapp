import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/network/dio_client.dart';
import '../../data/models/food_model.dart';
import 'auth_provider.dart';

final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, AsyncValue<List<CategoryModel>>>(
      (ref) {
        return CategoriesNotifier(ref.watch(dioClientProvider))..loadCategories();
      },
    );

class CategoriesNotifier extends StateNotifier<AsyncValue<List<CategoryModel>>> {
  CategoriesNotifier(this._dioClient) : super(const AsyncValue.loading());

  final DioClient _dioClient;

  Future<void> loadCategories() async {
    state = const AsyncValue.loading();
    try {
      final response = await _dioClient.get(ApiConstants.categories);
      final list = (response.data['data'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(_mapCategory)
          .toList();
      state = AsyncValue.data(list);
    } on DioException catch (e, st) {
      state = AsyncValue.error(ApiException.fromDioException(e), st);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final foodsProvider = StateNotifierProvider.family<FoodsNotifier,
    AsyncValue<List<FoodModel>>, String?>((ref, categoryId) {
  return FoodsNotifier(ref.watch(dioClientProvider))..loadFoods(categoryId);
});

class FoodsNotifier extends StateNotifier<AsyncValue<List<FoodModel>>> {
  FoodsNotifier(this._dioClient) : super(const AsyncValue.loading());

  final DioClient _dioClient;

  Future<void> loadFoods(String? categoryId) async {
    state = const AsyncValue.loading();
    try {
      final response = await _dioClient.get(
        ApiConstants.foods,
        queryParameters: {
          if (categoryId != null && categoryId.isNotEmpty) 'category': categoryId,
          'limit': 100,
        },
      );

      final foods = (response.data['data'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(_mapFood)
          .toList();
      state = AsyncValue.data(foods);
    } on DioException catch (e, st) {
      state = AsyncValue.error(ApiException.fromDioException(e), st);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final foodDetailProvider = FutureProvider.family<FoodModel, String>((ref, foodId) async {
  final dio = ref.watch(dioClientProvider);
  final response = await dio.get('${ApiConstants.foods}/$foodId');
  final data = response.data['data'] as Map<String, dynamic>?;
  if (data == null) {
    throw Exception('Food not found');
  }
  return _mapFood(data);
});

final recommendationsProvider = FutureProvider.family<
    Map<String, List<FoodModel>>, FeelingType>((ref, feeling) async {
  final dio = ref.watch(dioClientProvider);
  final response = await dio.get(
    '${ApiConstants.recommendations}/${_feelingToApi(feeling)}',
  );

  final data = response.data['data'] as Map<String, dynamic>? ?? {};
  return {
    'perfect': _mapFoodList(data['perfect']),
    'good': _mapFoodList(data['good']),
    'notIdeal': _mapFoodList(data['notIdeal']),
  };
});

final popularFoodsProvider = FutureProvider<List<FoodModel>>((ref) async {
  final dio = ref.watch(dioClientProvider);
  final response = await dio.get(ApiConstants.foods, queryParameters: {'limit': 20});
  return (response.data['data'] as List<dynamic>? ?? [])
      .whereType<Map<String, dynamic>>()
      .map(_mapFood)
      .where((f) => f.rating >= 4.5)
      .toList();
});

final searchFoodsProvider =
    FutureProvider.family<List<FoodModel>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final dio = ref.watch(dioClientProvider);
  final response = await dio.get('${ApiConstants.search}/$query');
  return _mapFoodList(response.data['data']);
});

final favoriteFoodsProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
      return FavoritesNotifier();
    });

class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier() : super({});

  void toggle(String foodId) {
    if (state.contains(foodId)) {
      state = {...state}..remove(foodId);
    } else {
      state = {...state, foodId};
    }
  }

  bool isFavorite(String foodId) => state.contains(foodId);
}

String _feelingToApi(FeelingType feeling) {
  switch (feeling) {
    case FeelingType.needEnergy:
      return 'need_energy';
    case FeelingType.veryHungry:
      return 'very_hungry';
    case FeelingType.somethingLight:
      return 'something_light';
    case FeelingType.trainedToday:
      return 'trained_today';
    case FeelingType.stressed:
      return 'stressed';
    case FeelingType.bloated:
      return 'bloated';
    case FeelingType.helpSleep:
      return 'help_sleep';
    case FeelingType.kidNeedsMeal:
      return 'kid_needs_meal';
    case FeelingType.fastingTomorrow:
      return 'fasting_tomorrow';
    case FeelingType.browseAll:
      return 'need_energy';
  }
}

List<FoodModel> _mapFoodList(dynamic value) {
  if (value is! List) return [];
  return value
      .whereType<Map<String, dynamic>>()
      .map(_mapFood)
      .toList();
}

FoodModel _mapFood(Map<String, dynamic> json) {
  final rawCategory = json['category'];
  String categoryId = '';
  String categoryName = 'Uncategorized';

  if (rawCategory is Map<String, dynamic>) {
    categoryId = _asString(rawCategory['_id']);
    categoryName = _asString(rawCategory['name'], fallback: categoryName);
  } else if (rawCategory != null) {
    categoryId = _asString(rawCategory);
  }

  final name = _asString(json['name'], fallback: 'Unnamed item');
  final description = _asString(json['description']);

  final nutrition = json['nutritionInfo'] as Map<String, dynamic>? ?? {};
  final functional = json['functionalScores'] as Map<String, dynamic>? ?? {};

  final portionOptionsRaw = json['portionOptions'] as List<dynamic>? ?? [];
  final portionOptions = portionOptionsRaw.asMap().entries.map((entry) {
    final index = entry.key;
    final option = entry.value as Map<String, dynamic>? ?? {};
    return PortionOption(
      id: _asString(option['id'], fallback: 'portion_$index'),
      name: _asString(option['name'], fallback: 'Option ${index + 1}'),
      weightGrams: _asInt(option['weightGrams']),
      price: _asDouble(option['price']),
      isPopular: _asBool(option['isPopular']),
    );
  }).toList();

  final customizationsRaw = json['customizations'] as List<dynamic>? ?? [];
  final customizations = customizationsRaw.asMap().entries.map((entry) {
    final index = entry.key;
    final group = entry.value as Map<String, dynamic>? ?? {};
    final optionsRaw = group['options'] as List<dynamic>? ?? [];
    return CustomizationGroup(
      id: _asString(group['id'], fallback: 'group_$index'),
      name: _asString(group['name'], fallback: 'Customization ${index + 1}'),
      type: _asString(group['type']) == 'single'
          ? CustomizationType.single
          : CustomizationType.multiple,
      isRequired: _asBool(group['isRequired']),
      maxSelections: group['maxSelections'] is num
          ? (group['maxSelections'] as num).toInt()
          : null,
      options: optionsRaw.asMap().entries.map((optEntry) {
        final optIndex = optEntry.key;
        final option = optEntry.value as Map<String, dynamic>? ?? {};
        return CustomizationOption(
          id: _asString(option['id'], fallback: 'opt_${index}_$optIndex'),
          name: _asString(option['name'], fallback: 'Option ${optIndex + 1}'),
          priceModifier: _asDouble(option['priceModifier']),
          isDefault: _asBool(option['isDefault']),
        );
      }).toList(),
    );
  }).toList();

  final bestTimes = (json['bestTimes'] as List<dynamic>? ?? [])
      .map((e) => _mealTimeFromApi(_asString(e)))
      .whereType<MealTime>()
      .toList();

  final images = (json['images'] as List<dynamic>? ?? [])
      .map((e) => _asString(e))
      .where((e) => e.isNotEmpty)
      .toList();

  return FoodModel(
    id: _asString(json['_id'], fallback: _asString(json['id'])),
    name: name,
    description: description,
    categoryId: categoryId,
    categoryName: categoryName,
    images: images,
    price: _asDouble(json['price']),
    originalPrice: json['originalPrice'] == null ? null : _asDouble(json['originalPrice']),
    preparationTime: _asInt(json['preparationTime']),
    rating: _asDouble(json['rating']),
    reviewCount: _asInt(json['reviewCount']),
    functionalScores: FunctionalScores(
      energyStability: _asInt(functional['energyStability'], fallback: 3),
      satiety: _asInt(functional['satiety'], fallback: 3),
      insulinImpact: _asInt(functional['insulinImpact'], fallback: 3),
      digestionEase: _asInt(functional['digestionEase'], fallback: 3),
      focusSupport: _asInt(functional['focusSupport'], fallback: 3),
      sleepFriendly: _asInt(functional['sleepFriendly'], fallback: 3),
      kidFriendly: _asInt(functional['kidFriendly'], fallback: 3),
      workoutSupport: _asInt(functional['workoutSupport'], fallback: 3),
    ),
    nutritionInfo: NutritionInfo(
      calories: _asInt(nutrition['calories']),
      protein: _asDouble(nutrition['protein']),
      carbs: _asDouble(nutrition['carbs']),
      fat: _asDouble(nutrition['fat']),
      fiber: _asDouble(nutrition['fiber']),
      sugar: _asDouble(nutrition['sugar']),
      sodium: _asDouble(nutrition['sodium']),
    ),
    bestFor: (json['bestFor'] as List<dynamic>? ?? []).map((e) => _asString(e)).where((e) => e.isNotEmpty).toList(),
    bestTimes: bestTimes,
    portionOptions: portionOptions,
    customizations: customizations,
    dietaryTags: (json['dietaryTags'] as List<dynamic>? ?? []).map((e) => _asString(e)).where((e) => e.isNotEmpty).toList(),
    isAvailable: _asBool(json['isAvailable'], fallback: true),
    isFeatured: _asBool(json['isFeatured']),
    createdAt: DateTime.tryParse(_asString(json['createdAt'])) ?? DateTime.now(),
  );
}

CategoryModel _mapCategory(Map<String, dynamic> json) {
  return CategoryModel(
    id: _asString(json['_id'], fallback: _asString(json['id'])),
    name: _asString(json['name'], fallback: 'Category'),
    description: _asString(json['description']),
    image: _asString(json['image']),
    itemCount: _asInt(json['itemCount']),
    sortOrder: _asInt(json['sortOrder']),
    isActive: _asBool(json['isActive'], fallback: true),
  );
}

MealTime? _mealTimeFromApi(String value) {
  switch (value) {
    case 'breakfast':
      return MealTime.breakfast;
    case 'lunch':
      return MealTime.lunch;
    case 'dinner':
      return MealTime.dinner;
    case 'snack':
      return MealTime.snack;
    case 'pre_workout':
      return MealTime.preWorkout;
    case 'post_workout':
      return MealTime.postWorkout;
    case 'suhoor':
      return MealTime.suhoor;
    case 'iftar':
      return MealTime.iftar;
    default:
      return null;
  }
}

String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final text = value.toString();
  return text.isEmpty ? fallback : text;
}

double _asDouble(dynamic value, {double fallback = 0}) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

bool _asBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  return fallback;
}
