// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  phone: json['phone'] as String,
  name: json['name'] as String?,
  email: json['email'] as String?,
  profileImage: json['profileImage'] as String?,
  dateOfBirth: json['dateOfBirth'] == null
      ? null
      : DateTime.parse(json['dateOfBirth'] as String),
  gender: json['gender'] as String?,
  healthGoals:
      (json['healthGoals'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  dietaryPreferences: json['dietaryPreferences'] == null
      ? null
      : DietaryPreferences.fromJson(
          json['dietaryPreferences'] as Map<String, dynamic>,
        ),
  dailyRoutine: json['dailyRoutine'] == null
      ? null
      : DailyRoutine.fromJson(json['dailyRoutine'] as Map<String, dynamic>),
  loyaltyInfo: json['loyaltyInfo'] == null
      ? null
      : LoyaltyInfo.fromJson(json['loyaltyInfo'] as Map<String, dynamic>),
  isOnboardingComplete: json['isOnboardingComplete'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'phone': instance.phone,
  'name': instance.name,
  'email': instance.email,
  'profileImage': instance.profileImage,
  'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
  'gender': instance.gender,
  'healthGoals': instance.healthGoals,
  'dietaryPreferences': instance.dietaryPreferences,
  'dailyRoutine': instance.dailyRoutine,
  'loyaltyInfo': instance.loyaltyInfo,
  'isOnboardingComplete': instance.isOnboardingComplete,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

DietaryPreferences _$DietaryPreferencesFromJson(
  Map<String, dynamic> json,
) => DietaryPreferences(
  isVegetarian: json['isVegetarian'] as bool? ?? false,
  isVegan: json['isVegan'] as bool? ?? false,
  isDairyFree: json['isDairyFree'] as bool? ?? false,
  isGlutenFree: json['isGlutenFree'] as bool? ?? false,
  isKetoFriendly: json['isKetoFriendly'] as bool? ?? false,
  allergies:
      (json['allergies'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  dislikes:
      (json['dislikes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$DietaryPreferencesToJson(DietaryPreferences instance) =>
    <String, dynamic>{
      'isVegetarian': instance.isVegetarian,
      'isVegan': instance.isVegan,
      'isDairyFree': instance.isDairyFree,
      'isGlutenFree': instance.isGlutenFree,
      'isKetoFriendly': instance.isKetoFriendly,
      'allergies': instance.allergies,
      'dislikes': instance.dislikes,
    };

DailyRoutine _$DailyRoutineFromJson(Map<String, dynamic> json) => DailyRoutine(
  workStartTime: json['workStartTime'] as String? ?? '09:00',
  workEndTime: json['workEndTime'] as String? ?? '18:00',
  trainingDays:
      (json['trainingDays'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  trainingTime: json['trainingTime'] as String?,
  sleepTime: json['sleepTime'] as String? ?? '23:00',
);

Map<String, dynamic> _$DailyRoutineToJson(DailyRoutine instance) =>
    <String, dynamic>{
      'workStartTime': instance.workStartTime,
      'workEndTime': instance.workEndTime,
      'trainingDays': instance.trainingDays,
      'trainingTime': instance.trainingTime,
      'sleepTime': instance.sleepTime,
    };

LoyaltyInfo _$LoyaltyInfoFromJson(Map<String, dynamic> json) => LoyaltyInfo(
  points: (json['points'] as num?)?.toInt() ?? 0,
  tier: json['tier'] as String? ?? 'Bronze',
  totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
  totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$LoyaltyInfoToJson(LoyaltyInfo instance) =>
    <String, dynamic>{
      'points': instance.points,
      'tier': instance.tier,
      'totalOrders': instance.totalOrders,
      'totalSpent': instance.totalSpent,
    };
