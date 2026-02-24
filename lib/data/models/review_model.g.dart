// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewModel _$ReviewModelFromJson(Map<String, dynamic> json) => ReviewModel(
  id: json['id'] as String,
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  userImage: json['userImage'] as String?,
  orderId: json['orderId'] as String,
  foodId: json['foodId'] as String?,
  overallRating: (json['overallRating'] as num).toInt(),
  foodRating: (json['foodRating'] as num?)?.toInt(),
  deliveryRating: (json['deliveryRating'] as num?)?.toInt(),
  packagingRating: (json['packagingRating'] as num?)?.toInt(),
  feedbackTags:
      (json['feedbackTags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  comment: json['comment'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ReviewModelToJson(ReviewModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userName': instance.userName,
      'userImage': instance.userImage,
      'orderId': instance.orderId,
      'foodId': instance.foodId,
      'overallRating': instance.overallRating,
      'foodRating': instance.foodRating,
      'deliveryRating': instance.deliveryRating,
      'packagingRating': instance.packagingRating,
      'feedbackTags': instance.feedbackTags,
      'comment': instance.comment,
      'createdAt': instance.createdAt.toIso8601String(),
    };
