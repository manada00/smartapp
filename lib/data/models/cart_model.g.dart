// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartModel _$CartModelFromJson(Map<String, dynamic> json) => CartModel(
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  promoCode: json['promoCode'] as String?,
  promoDiscount: (json['promoDiscount'] as num?)?.toDouble(),
  promoMessage: json['promoMessage'] as String?,
);

Map<String, dynamic> _$CartModelToJson(CartModel instance) => <String, dynamic>{
  'items': instance.items,
  'promoCode': instance.promoCode,
  'promoDiscount': instance.promoDiscount,
  'promoMessage': instance.promoMessage,
};

CartItemModel _$CartItemModelFromJson(Map<String, dynamic> json) =>
    CartItemModel(
      id: json['id'] as String,
      foodId: json['foodId'] as String,
      foodName: json['foodName'] as String,
      foodImage: json['foodImage'] as String,
      portionId: json['portionId'] as String?,
      portionName: json['portionName'] as String?,
      customizations:
          (json['customizations'] as List<dynamic>?)
              ?.map(
                (e) =>
                    SelectedCustomization.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      specialInstructions: json['specialInstructions'] as String?,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      customizationsPrice:
          (json['customizationsPrice'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$CartItemModelToJson(CartItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'foodId': instance.foodId,
      'foodName': instance.foodName,
      'foodImage': instance.foodImage,
      'portionId': instance.portionId,
      'portionName': instance.portionName,
      'customizations': instance.customizations,
      'specialInstructions': instance.specialInstructions,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'customizationsPrice': instance.customizationsPrice,
    };

SelectedCustomization _$SelectedCustomizationFromJson(
  Map<String, dynamic> json,
) => SelectedCustomization(
  groupId: json['groupId'] as String,
  groupName: json['groupName'] as String,
  optionId: json['optionId'] as String,
  optionName: json['optionName'] as String,
  priceModifier: (json['priceModifier'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$SelectedCustomizationToJson(
  SelectedCustomization instance,
) => <String, dynamic>{
  'groupId': instance.groupId,
  'groupName': instance.groupName,
  'optionId': instance.optionId,
  'optionName': instance.optionName,
  'priceModifier': instance.priceModifier,
};
