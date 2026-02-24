// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionPlanModel _$SubscriptionPlanModelFromJson(
  Map<String, dynamic> json,
) => SubscriptionPlanModel(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  image: json['image'] as String,
  type: $enumDecode(_$SubscriptionTypeEnumMap, json['type']),
  weeklyPrice: (json['weeklyPrice'] as num).toDouble(),
  mealPrice: (json['mealPrice'] as num).toDouble(),
  mealsPerWeek: (json['mealsPerWeek'] as num).toInt(),
  savingsPercentage: (json['savingsPercentage'] as num?)?.toInt() ?? 0,
  features:
      (json['features'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  includedMealTypes:
      (json['includedMealTypes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$SubscriptionPlanModelToJson(
  SubscriptionPlanModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'image': instance.image,
  'type': _$SubscriptionTypeEnumMap[instance.type]!,
  'weeklyPrice': instance.weeklyPrice,
  'mealPrice': instance.mealPrice,
  'mealsPerWeek': instance.mealsPerWeek,
  'savingsPercentage': instance.savingsPercentage,
  'features': instance.features,
  'includedMealTypes': instance.includedMealTypes,
  'isActive': instance.isActive,
};

const _$SubscriptionTypeEnumMap = {
  SubscriptionType.dailyBreakfast: 'dailyBreakfast',
  SubscriptionType.dailyLunch: 'dailyLunch',
  SubscriptionType.gymPerformance: 'gymPerformance',
  SubscriptionType.kidsWeekly: 'kidsWeekly',
  SubscriptionType.fullDay: 'fullDay',
};

UserSubscriptionModel _$UserSubscriptionModelFromJson(
  Map<String, dynamic> json,
) => UserSubscriptionModel(
  id: json['id'] as String,
  userId: json['userId'] as String,
  planId: json['planId'] as String,
  plan: SubscriptionPlanModel.fromJson(json['plan'] as Map<String, dynamic>),
  status: $enumDecode(_$SubscriptionStatusEnumMap, json['status']),
  mealSelection: $enumDecode(_$MealSelectionTypeEnumMap, json['mealSelection']),
  deliveryAddress: AddressModel.fromJson(
    json['deliveryAddress'] as Map<String, dynamic>,
  ),
  deliveryTimeSlot: json['deliveryTimeSlot'] as String,
  upcomingDeliveries:
      (json['upcomingDeliveries'] as List<dynamic>?)
          ?.map(
            (e) => ScheduledDeliveryModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  startDate: DateTime.parse(json['startDate'] as String),
  pausedUntil: json['pausedUntil'] == null
      ? null
      : DateTime.parse(json['pausedUntil'] as String),
  nextBillingDate: DateTime.parse(json['nextBillingDate'] as String),
  billingHistory:
      (json['billingHistory'] as List<dynamic>?)
          ?.map(
            (e) => SubscriptionBillingModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$UserSubscriptionModelToJson(
  UserSubscriptionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'planId': instance.planId,
  'plan': instance.plan,
  'status': _$SubscriptionStatusEnumMap[instance.status]!,
  'mealSelection': _$MealSelectionTypeEnumMap[instance.mealSelection]!,
  'deliveryAddress': instance.deliveryAddress,
  'deliveryTimeSlot': instance.deliveryTimeSlot,
  'upcomingDeliveries': instance.upcomingDeliveries,
  'startDate': instance.startDate.toIso8601String(),
  'pausedUntil': instance.pausedUntil?.toIso8601String(),
  'nextBillingDate': instance.nextBillingDate.toIso8601String(),
  'billingHistory': instance.billingHistory,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$SubscriptionStatusEnumMap = {
  SubscriptionStatus.active: 'active',
  SubscriptionStatus.paused: 'paused',
  SubscriptionStatus.cancelled: 'cancelled',
  SubscriptionStatus.expired: 'expired',
};

const _$MealSelectionTypeEnumMap = {
  MealSelectionType.chefsChoice: 'chefsChoice',
  MealSelectionType.userChoice: 'userChoice',
};

ScheduledDeliveryModel _$ScheduledDeliveryModelFromJson(
  Map<String, dynamic> json,
) => ScheduledDeliveryModel(
  id: json['id'] as String,
  date: DateTime.parse(json['date'] as String),
  mealId: json['mealId'] as String?,
  mealName: json['mealName'] as String?,
  mealImage: json['mealImage'] as String?,
  status: $enumDecode(_$DeliveryStatusEnumMap, json['status']),
  canSwap: json['canSwap'] as bool? ?? true,
  canSkip: json['canSkip'] as bool? ?? true,
);

Map<String, dynamic> _$ScheduledDeliveryModelToJson(
  ScheduledDeliveryModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'date': instance.date.toIso8601String(),
  'mealId': instance.mealId,
  'mealName': instance.mealName,
  'mealImage': instance.mealImage,
  'status': _$DeliveryStatusEnumMap[instance.status]!,
  'canSwap': instance.canSwap,
  'canSkip': instance.canSkip,
};

const _$DeliveryStatusEnumMap = {
  DeliveryStatus.scheduled: 'scheduled',
  DeliveryStatus.skipped: 'skipped',
  DeliveryStatus.preparing: 'preparing',
  DeliveryStatus.outForDelivery: 'outForDelivery',
  DeliveryStatus.delivered: 'delivered',
};

SubscriptionBillingModel _$SubscriptionBillingModelFromJson(
  Map<String, dynamic> json,
) => SubscriptionBillingModel(
  id: json['id'] as String,
  date: DateTime.parse(json['date'] as String),
  amount: (json['amount'] as num).toDouble(),
  status: json['status'] as String,
  paymentMethod: json['paymentMethod'] as String?,
);

Map<String, dynamic> _$SubscriptionBillingModelToJson(
  SubscriptionBillingModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'date': instance.date.toIso8601String(),
  'amount': instance.amount,
  'status': instance.status,
  'paymentMethod': instance.paymentMethod,
};
