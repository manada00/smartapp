// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
  id: json['id'] as String,
  orderNumber: json['orderNumber'] as String,
  userId: json['userId'] as String,
  items: (json['items'] as List<dynamic>)
      .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  deliveryAddress: AddressModel.fromJson(
    json['deliveryAddress'] as Map<String, dynamic>,
  ),
  status: $enumDecode(_$OrderStatusEnumMap, json['status']),
  paymentMethod: $enumDecode(_$PaymentMethodEnumMap, json['paymentMethod']),
  paymentStatus: $enumDecode(_$PaymentStatusEnumMap, json['paymentStatus']),
  driverId: json['driverId'] as String?,
  driver: json['driver'] == null
      ? null
      : DriverInfo.fromJson(json['driver'] as Map<String, dynamic>),
  subtotal: (json['subtotal'] as num).toDouble(),
  deliveryFee: (json['deliveryFee'] as num).toDouble(),
  discount: (json['discount'] as num?)?.toDouble() ?? 0,
  walletUsed: (json['walletUsed'] as num?)?.toDouble() ?? 0,
  total: (json['total'] as num).toDouble(),
  amountDue: (json['amountDue'] as num).toDouble(),
  promoCode: json['promoCode'] as String?,
  specialInstructions: json['specialInstructions'] as String?,
  changeFor: (json['changeFor'] as num?)?.toInt(),
  scheduledDelivery: json['scheduledDelivery'] == null
      ? null
      : DeliverySchedule.fromJson(
          json['scheduledDelivery'] as Map<String, dynamic>,
        ),
  estimatedMinutes: (json['estimatedMinutes'] as num).toInt(),
  timeline:
      (json['timeline'] as List<dynamic>?)
          ?.map((e) => OrderTimeline.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  pointsEarned: (json['pointsEarned'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderNumber': instance.orderNumber,
      'userId': instance.userId,
      'items': instance.items,
      'deliveryAddress': instance.deliveryAddress,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'paymentMethod': _$PaymentMethodEnumMap[instance.paymentMethod]!,
      'paymentStatus': _$PaymentStatusEnumMap[instance.paymentStatus]!,
      'driverId': instance.driverId,
      'driver': instance.driver,
      'subtotal': instance.subtotal,
      'deliveryFee': instance.deliveryFee,
      'discount': instance.discount,
      'walletUsed': instance.walletUsed,
      'total': instance.total,
      'amountDue': instance.amountDue,
      'promoCode': instance.promoCode,
      'specialInstructions': instance.specialInstructions,
      'changeFor': instance.changeFor,
      'scheduledDelivery': instance.scheduledDelivery,
      'estimatedMinutes': instance.estimatedMinutes,
      'timeline': instance.timeline,
      'pointsEarned': instance.pointsEarned,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.confirmed: 'confirmed',
  OrderStatus.preparing: 'preparing',
  OrderStatus.readyForPickup: 'readyForPickup',
  OrderStatus.outForDelivery: 'outForDelivery',
  OrderStatus.delivered: 'delivered',
  OrderStatus.cancelled: 'cancelled',
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.cod: 'cod',
  PaymentMethod.card: 'card',
  PaymentMethod.mobileWallet: 'mobileWallet',
  PaymentMethod.fawry: 'fawry',
  PaymentMethod.instaPay: 'instaPay',
  PaymentMethod.wallet: 'wallet',
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'pending',
  PaymentStatus.processing: 'processing',
  PaymentStatus.completed: 'completed',
  PaymentStatus.failed: 'failed',
  PaymentStatus.refunded: 'refunded',
};

DriverInfo _$DriverInfoFromJson(Map<String, dynamic> json) => DriverInfo(
  id: json['id'] as String,
  name: json['name'] as String,
  photo: json['photo'] as String?,
  phone: json['phone'] as String,
  rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
);

Map<String, dynamic> _$DriverInfoToJson(DriverInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'photo': instance.photo,
      'phone': instance.phone,
      'rating': instance.rating,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

DeliverySchedule _$DeliveryScheduleFromJson(Map<String, dynamic> json) =>
    DeliverySchedule(
      date: DateTime.parse(json['date'] as String),
      timeSlot: json['timeSlot'] as String,
    );

Map<String, dynamic> _$DeliveryScheduleToJson(DeliverySchedule instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'timeSlot': instance.timeSlot,
    };

OrderTimeline _$OrderTimelineFromJson(Map<String, dynamic> json) =>
    OrderTimeline(
      status: $enumDecode(_$OrderStatusEnumMap, json['status']),
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$OrderTimelineToJson(OrderTimeline instance) =>
    <String, dynamic>{
      'status': _$OrderStatusEnumMap[instance.status]!,
      'message': instance.message,
      'timestamp': instance.timestamp.toIso8601String(),
    };
