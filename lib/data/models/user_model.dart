import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String phone;
  final String? name;
  final String? email;
  final String? profileImage;
  final DateTime? dateOfBirth;
  final String? gender;
  final List<String> healthGoals;
  final DietaryPreferences? dietaryPreferences;
  final DailyRoutine? dailyRoutine;
  final LoyaltyInfo? loyaltyInfo;
  final bool isOnboardingComplete;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.phone,
    this.name,
    this.email,
    this.profileImage,
    this.dateOfBirth,
    this.gender,
    this.healthGoals = const [],
    this.dietaryPreferences,
    this.dailyRoutine,
    this.loyaltyInfo,
    this.isOnboardingComplete = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    String? id,
    String? phone,
    String? name,
    String? email,
    String? profileImage,
    DateTime? dateOfBirth,
    String? gender,
    List<String>? healthGoals,
    DietaryPreferences? dietaryPreferences,
    DailyRoutine? dailyRoutine,
    LoyaltyInfo? loyaltyInfo,
    bool? isOnboardingComplete,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      healthGoals: healthGoals ?? this.healthGoals,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      dailyRoutine: dailyRoutine ?? this.dailyRoutine,
      loyaltyInfo: loyaltyInfo ?? this.loyaltyInfo,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class DietaryPreferences {
  final bool isVegetarian;
  final bool isVegan;
  final bool isDairyFree;
  final bool isGlutenFree;
  final bool isKetoFriendly;
  final List<String> allergies;
  final List<String> dislikes;

  DietaryPreferences({
    this.isVegetarian = false,
    this.isVegan = false,
    this.isDairyFree = false,
    this.isGlutenFree = false,
    this.isKetoFriendly = false,
    this.allergies = const [],
    this.dislikes = const [],
  });

  factory DietaryPreferences.fromJson(Map<String, dynamic> json) =>
      _$DietaryPreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$DietaryPreferencesToJson(this);
}

@JsonSerializable()
class DailyRoutine {
  final String workStartTime;
  final String workEndTime;
  final List<String> trainingDays;
  final String? trainingTime;
  final String sleepTime;

  DailyRoutine({
    this.workStartTime = '09:00',
    this.workEndTime = '18:00',
    this.trainingDays = const [],
    this.trainingTime,
    this.sleepTime = '23:00',
  });

  factory DailyRoutine.fromJson(Map<String, dynamic> json) =>
      _$DailyRoutineFromJson(json);

  Map<String, dynamic> toJson() => _$DailyRoutineToJson(this);
}

@JsonSerializable()
class LoyaltyInfo {
  final int points;
  final String tier;
  final int totalOrders;
  final double totalSpent;

  LoyaltyInfo({
    this.points = 0,
    this.tier = 'Bronze',
    this.totalOrders = 0,
    this.totalSpent = 0,
  });

  factory LoyaltyInfo.fromJson(Map<String, dynamic> json) =>
      _$LoyaltyInfoFromJson(json);

  Map<String, dynamic> toJson() => _$LoyaltyInfoToJson(this);
}

enum HealthGoal {
  loseWeight('Lose Weight', '🔥'),
  buildMuscle('Build Muscle', '💪'),
  maintainWeight('Maintain Weight', '⚖️'),
  stableEnergy('Stable Energy', '⚡'),
  betterDigestion('Better Digestion', '🫄'),
  improveSleep('Improve Sleep', '😴'),
  hormonalBalance('Hormonal Balance', '🧬'),
  gymPerformance('Gym Performance', '🏋️'),
  kidsNutrition('Kids Nutrition', '👶'),
  reduceCravings('Reduce Cravings', '🍪'),
  ramadanFasting('Ramadan Fasting', '🌙');

  final String label;
  final String emoji;

  const HealthGoal(this.label, this.emoji);
}

enum Gender {
  male('Male'),
  female('Female'),
  preferNotToSay('Prefer not to say');

  final String label;

  const Gender(this.label);
}
