import 'package:json_annotation/json_annotation.dart';
import 'address_model.dart';

part 'subscription_model.g.dart';

@JsonSerializable()
class SubscriptionPlanModel {
  final String id;
  final String name;
  final String description;
  final String image;
  final SubscriptionType type;
  final double weeklyPrice;
  final double mealPrice;
  final int mealsPerWeek;
  final int savingsPercentage;
  final List<String> features;
  final List<String> includedMealTypes;
  final bool isActive;

  SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.type,
    required this.weeklyPrice,
    required this.mealPrice,
    required this.mealsPerWeek,
    this.savingsPercentage = 0,
    this.features = const [],
    this.includedMealTypes = const [],
    this.isActive = true,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionPlanModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionPlanModelToJson(this);
}

@JsonSerializable()
class UserSubscriptionModel {
  final String id;
  final String userId;
  final String planId;
  final SubscriptionPlanModel plan;
  final SubscriptionStatus status;
  final MealSelectionType mealSelection;
  final AddressModel deliveryAddress;
  final String deliveryTimeSlot;
  final List<ScheduledDeliveryModel> upcomingDeliveries;
  final DateTime startDate;
  final DateTime? pausedUntil;
  final DateTime nextBillingDate;
  final List<SubscriptionBillingModel> billingHistory;
  final DateTime createdAt;

  UserSubscriptionModel({
    required this.id,
    required this.userId,
    required this.planId,
    required this.plan,
    required this.status,
    required this.mealSelection,
    required this.deliveryAddress,
    required this.deliveryTimeSlot,
    this.upcomingDeliveries = const [],
    required this.startDate,
    this.pausedUntil,
    required this.nextBillingDate,
    this.billingHistory = const [],
    required this.createdAt,
  });

  factory UserSubscriptionModel.fromJson(Map<String, dynamic> json) =>
      _$UserSubscriptionModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserSubscriptionModelToJson(this);

  bool get isActive => status == SubscriptionStatus.active;
  bool get isPaused => status == SubscriptionStatus.paused;
}

@JsonSerializable()
class ScheduledDeliveryModel {
  final String id;
  final DateTime date;
  final String? mealId;
  final String? mealName;
  final String? mealImage;
  final DeliveryStatus status;
  final bool canSwap;
  final bool canSkip;

  ScheduledDeliveryModel({
    required this.id,
    required this.date,
    this.mealId,
    this.mealName,
    this.mealImage,
    required this.status,
    this.canSwap = true,
    this.canSkip = true,
  });

  factory ScheduledDeliveryModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduledDeliveryModelFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduledDeliveryModelToJson(this);
}

@JsonSerializable()
class SubscriptionBillingModel {
  final String id;
  final DateTime date;
  final double amount;
  final String status;
  final String? paymentMethod;

  SubscriptionBillingModel({
    required this.id,
    required this.date,
    required this.amount,
    required this.status,
    this.paymentMethod,
  });

  factory SubscriptionBillingModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionBillingModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionBillingModelToJson(this);
}

enum SubscriptionType {
  dailyBreakfast('Daily Breakfast'),
  dailyLunch('Daily Lunch'),
  gymPerformance('Gym Performance'),
  kidsWeekly('Kids Weekly'),
  fullDay('Full Day');

  final String label;

  const SubscriptionType(this.label);
}

enum SubscriptionStatus {
  active,
  paused,
  cancelled,
  expired,
}

enum MealSelectionType {
  chefsChoice("Chef's Choice"),
  userChoice('Choose Your Meals');

  final String label;

  const MealSelectionType(this.label);
}

enum DeliveryStatus {
  scheduled,
  skipped,
  preparing,
  outForDelivery,
  delivered,
}
