import 'package:json_annotation/json_annotation.dart';

part 'review_model.g.dart';

@JsonSerializable()
class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final String? userImage;
  final String orderId;
  final String? foodId;
  final int overallRating;
  final int? foodRating;
  final int? deliveryRating;
  final int? packagingRating;
  final List<String> feedbackTags;
  final String? comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userImage,
    required this.orderId,
    this.foodId,
    required this.overallRating,
    this.foodRating,
    this.deliveryRating,
    this.packagingRating,
    this.feedbackTags = const [],
    this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewModelToJson(this);
}

class FeedbackTag {
  static const List<String> positive = [
    'Great taste',
    'Good portions',
    'Fast delivery',
    'Well packaged',
    'Fresh ingredients',
    'Accurate order',
    'Friendly driver',
  ];

  static const List<String> negative = [
    'Late delivery',
    'Wrong order',
    'Poor packaging',
    'Small portions',
    'Not fresh',
    'Missing items',
    'Cold food',
  ];
}
