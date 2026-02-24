import 'package:json_annotation/json_annotation.dart';

part 'cart_model.g.dart';

@JsonSerializable()
class CartModel {
  final List<CartItemModel> items;
  final String? promoCode;
  final double? promoDiscount;
  final String? promoMessage;

  CartModel({
    this.items = const [],
    this.promoCode,
    this.promoDiscount,
    this.promoMessage,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) =>
      _$CartModelFromJson(json);

  Map<String, dynamic> toJson() => _$CartModelToJson(this);

  double get subtotal => items.fold(0, (sum, item) => sum + item.totalPrice);

  double get discount => promoDiscount ?? 0;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  CartModel copyWith({
    List<CartItemModel>? items,
    String? promoCode,
    double? promoDiscount,
    String? promoMessage,
  }) {
    return CartModel(
      items: items ?? this.items,
      promoCode: promoCode ?? this.promoCode,
      promoDiscount: promoDiscount ?? this.promoDiscount,
      promoMessage: promoMessage ?? this.promoMessage,
    );
  }
}

@JsonSerializable()
class CartItemModel {
  final String id;
  final String foodId;
  final String foodName;
  final String foodImage;
  final String? portionId;
  final String? portionName;
  final List<SelectedCustomization> customizations;
  final String? specialInstructions;
  final int quantity;
  final double unitPrice;
  final double customizationsPrice;

  CartItemModel({
    required this.id,
    required this.foodId,
    required this.foodName,
    required this.foodImage,
    this.portionId,
    this.portionName,
    this.customizations = const [],
    this.specialInstructions,
    required this.quantity,
    required this.unitPrice,
    this.customizationsPrice = 0,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) =>
      _$CartItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$CartItemModelToJson(this);

  double get itemPrice => unitPrice + customizationsPrice;

  double get totalPrice => itemPrice * quantity;

  String get customizationsSummary {
    if (customizations.isEmpty) return '';
    return customizations.map((c) => c.optionName).join(' • ');
  }

  CartItemModel copyWith({
    String? id,
    String? foodId,
    String? foodName,
    String? foodImage,
    String? portionId,
    String? portionName,
    List<SelectedCustomization>? customizations,
    String? specialInstructions,
    int? quantity,
    double? unitPrice,
    double? customizationsPrice,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      foodId: foodId ?? this.foodId,
      foodName: foodName ?? this.foodName,
      foodImage: foodImage ?? this.foodImage,
      portionId: portionId ?? this.portionId,
      portionName: portionName ?? this.portionName,
      customizations: customizations ?? this.customizations,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      customizationsPrice: customizationsPrice ?? this.customizationsPrice,
    );
  }
}

@JsonSerializable()
class SelectedCustomization {
  final String groupId;
  final String groupName;
  final String optionId;
  final String optionName;
  final double priceModifier;

  SelectedCustomization({
    required this.groupId,
    required this.groupName,
    required this.optionId,
    required this.optionName,
    this.priceModifier = 0,
  });

  factory SelectedCustomization.fromJson(Map<String, dynamic> json) =>
      _$SelectedCustomizationFromJson(json);

  Map<String, dynamic> toJson() => _$SelectedCustomizationToJson(this);
}
