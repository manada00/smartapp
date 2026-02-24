// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddressModel _$AddressModelFromJson(Map<String, dynamic> json) => AddressModel(
  id: json['id'] as String,
  userId: json['userId'] as String,
  label: $enumDecode(_$AddressLabelEnumMap, json['label']),
  governorate: json['governorate'] as String,
  area: json['area'] as String,
  streetName: json['streetName'] as String,
  buildingNumber: json['buildingNumber'] as String,
  floor: json['floor'] as String?,
  apartmentNumber: json['apartmentNumber'] as String?,
  landmark: json['landmark'] as String,
  deliveryInstructions: json['deliveryInstructions'] as String?,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  isDefault: json['isDefault'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$AddressModelToJson(AddressModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'label': _$AddressLabelEnumMap[instance.label]!,
      'governorate': instance.governorate,
      'area': instance.area,
      'streetName': instance.streetName,
      'buildingNumber': instance.buildingNumber,
      'floor': instance.floor,
      'apartmentNumber': instance.apartmentNumber,
      'landmark': instance.landmark,
      'deliveryInstructions': instance.deliveryInstructions,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'isDefault': instance.isDefault,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$AddressLabelEnumMap = {
  AddressLabel.home: 'home',
  AddressLabel.office: 'office',
  AddressLabel.gym: 'gym',
  AddressLabel.other: 'other',
};
