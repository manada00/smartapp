import 'package:json_annotation/json_annotation.dart';
import 'address_model.dart';
import 'cart_model.dart';

part 'order_model.g.dart';

@JsonSerializable()
class OrderModel {
  final String id;
  final String orderNumber;
  final String userId;
  final List<CartItemModel> items;
  final AddressModel deliveryAddress;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final String? driverId;
  final DriverInfo? driver;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double walletUsed;
  final double total;
  final double amountDue;
  final String? promoCode;
  final String? specialInstructions;
  final int? changeFor;
  final DeliverySchedule? scheduledDelivery;
  final int estimatedMinutes;
  final List<OrderTimeline> timeline;
  final int pointsEarned;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.items,
    required this.deliveryAddress,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    this.driverId,
    this.driver,
    required this.subtotal,
    required this.deliveryFee,
    this.discount = 0,
    this.walletUsed = 0,
    required this.total,
    required this.amountDue,
    this.promoCode,
    this.specialInstructions,
    this.changeFor,
    this.scheduledDelivery,
    required this.estimatedMinutes,
    this.timeline = const [],
    this.pointsEarned = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  bool get isActive =>
      status != OrderStatus.delivered && status != OrderStatus.cancelled;

  bool get canCancel =>
      status == OrderStatus.pending || status == OrderStatus.confirmed;

  bool get hasDriver => driver != null;

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? userId,
    List<CartItemModel>? items,
    AddressModel? deliveryAddress,
    OrderStatus? status,
    PaymentMethod? paymentMethod,
    PaymentStatus? paymentStatus,
    String? driverId,
    DriverInfo? driver,
    double? subtotal,
    double? deliveryFee,
    double? discount,
    double? walletUsed,
    double? total,
    double? amountDue,
    String? promoCode,
    String? specialInstructions,
    int? changeFor,
    DeliverySchedule? scheduledDelivery,
    int? estimatedMinutes,
    List<OrderTimeline>? timeline,
    int? pointsEarned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      driverId: driverId ?? this.driverId,
      driver: driver ?? this.driver,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discount: discount ?? this.discount,
      walletUsed: walletUsed ?? this.walletUsed,
      total: total ?? this.total,
      amountDue: amountDue ?? this.amountDue,
      promoCode: promoCode ?? this.promoCode,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      changeFor: changeFor ?? this.changeFor,
      scheduledDelivery: scheduledDelivery ?? this.scheduledDelivery,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      timeline: timeline ?? this.timeline,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class DriverInfo {
  final String id;
  final String name;
  final String? photo;
  final String phone;
  final double rating;
  final double? latitude;
  final double? longitude;

  DriverInfo({
    required this.id,
    required this.name,
    this.photo,
    required this.phone,
    this.rating = 5.0,
    this.latitude,
    this.longitude,
  });

  factory DriverInfo.fromJson(Map<String, dynamic> json) =>
      _$DriverInfoFromJson(json);

  Map<String, dynamic> toJson() => _$DriverInfoToJson(this);
}

@JsonSerializable()
class DeliverySchedule {
  final DateTime date;
  final String timeSlot;

  DeliverySchedule({
    required this.date,
    required this.timeSlot,
  });

  factory DeliverySchedule.fromJson(Map<String, dynamic> json) =>
      _$DeliveryScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$DeliveryScheduleToJson(this);
}

@JsonSerializable()
class OrderTimeline {
  final OrderStatus status;
  final String message;
  final DateTime timestamp;

  OrderTimeline({
    required this.status,
    required this.message,
    required this.timestamp,
  });

  factory OrderTimeline.fromJson(Map<String, dynamic> json) =>
      _$OrderTimelineFromJson(json);

  Map<String, dynamic> toJson() => _$OrderTimelineToJson(this);
}

enum OrderStatus {
  pending('Pending', '🕐'),
  confirmed('Confirmed', '✓'),
  preparing('Preparing', '👨‍🍳'),
  readyForPickup('Ready', '📦'),
  outForDelivery('Out for Delivery', '🚗'),
  delivered('Delivered', '✅'),
  cancelled('Cancelled', '❌');

  final String label;
  final String emoji;

  const OrderStatus(this.label, this.emoji);
}

enum PaymentMethod {
  cod('Cash on Delivery', '💵'),
  card('Credit/Debit Card', '💳'),
  mobileWallet('Mobile Wallet', '📱'),
  fawry('Fawry', '🏪'),
  instaPay('InstaPay', '🏦'),
  wallet('App Wallet', '💰');

  final String label;
  final String emoji;

  const PaymentMethod(this.label, this.emoji);
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
}

enum MobileWalletProvider {
  vodafoneCash('Vodafone Cash'),
  orangeCash('Orange Cash'),
  etisalatCash('Etisalat Cash'),
  wePay('WE Pay'),
  cibSmartWallet('CIB Smart Wallet');

  final String label;

  const MobileWalletProvider(this.label);
}
