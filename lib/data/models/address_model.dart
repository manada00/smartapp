import 'package:json_annotation/json_annotation.dart';

part 'address_model.g.dart';

@JsonSerializable()
class AddressModel {
  final String id;
  final String userId;
  final AddressLabel label;
  final String governorate;
  final String area;
  final String streetName;
  final String buildingNumber;
  final String? floor;
  final String? apartmentNumber;
  final String landmark;
  final String? deliveryInstructions;
  final double latitude;
  final double longitude;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  AddressModel({
    required this.id,
    required this.userId,
    required this.label,
    required this.governorate,
    required this.area,
    required this.streetName,
    required this.buildingNumber,
    this.floor,
    this.apartmentNumber,
    required this.landmark,
    this.deliveryInstructions,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      _$AddressModelFromJson(json);

  Map<String, dynamic> toJson() => _$AddressModelToJson(this);

  String get fullAddress {
    final parts = <String>[
      buildingNumber,
      streetName,
      if (floor != null) 'Floor $floor',
      if (apartmentNumber != null) 'Apt $apartmentNumber',
      area,
      governorate,
    ];
    return parts.join(', ');
  }

  String get shortAddress => '$area, $governorate';

  AddressModel copyWith({
    String? id,
    String? userId,
    AddressLabel? label,
    String? governorate,
    String? area,
    String? streetName,
    String? buildingNumber,
    String? floor,
    String? apartmentNumber,
    String? landmark,
    String? deliveryInstructions,
    double? latitude,
    double? longitude,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      governorate: governorate ?? this.governorate,
      area: area ?? this.area,
      streetName: streetName ?? this.streetName,
      buildingNumber: buildingNumber ?? this.buildingNumber,
      floor: floor ?? this.floor,
      apartmentNumber: apartmentNumber ?? this.apartmentNumber,
      landmark: landmark ?? this.landmark,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum AddressLabel {
  home('Home', '🏠'),
  office('Office', '🏢'),
  gym('Gym', '🏋️'),
  other('Other', '📍');

  final String label;
  final String emoji;

  const AddressLabel(this.label, this.emoji);
}
