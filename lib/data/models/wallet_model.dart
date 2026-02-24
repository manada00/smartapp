import 'package:json_annotation/json_annotation.dart';

part 'wallet_model.g.dart';

@JsonSerializable()
class WalletModel {
  final String userId;
  final double balance;
  final List<WalletTransactionModel> recentTransactions;
  final DateTime updatedAt;

  WalletModel({
    required this.userId,
    this.balance = 0,
    this.recentTransactions = const [],
    required this.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) =>
      _$WalletModelFromJson(json);

  Map<String, dynamic> toJson() => _$WalletModelToJson(this);
}

@JsonSerializable()
class WalletTransactionModel {
  final String id;
  final WalletTransactionType type;
  final double amount;
  final String description;
  final String? referenceId;
  final DateTime createdAt;

  WalletTransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    this.referenceId,
    required this.createdAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) =>
      _$WalletTransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$WalletTransactionModelToJson(this);

  bool get isCredit =>
      type == WalletTransactionType.topUp ||
      type == WalletTransactionType.refund ||
      type == WalletTransactionType.referralBonus ||
      type == WalletTransactionType.cashback;
}

enum WalletTransactionType {
  topUp('Top Up', '+'),
  payment('Payment', '-'),
  refund('Refund', '+'),
  referralBonus('Referral Bonus', '+'),
  cashback('Cashback', '+');

  final String label;
  final String sign;

  const WalletTransactionType(this.label, this.sign);
}

@JsonSerializable()
class RewardsModel {
  final String userId;
  final int points;
  final String tier;
  final int pointsToNextTier;
  final List<RewardModel> availableRewards;
  final List<RedeemedRewardModel> redeemedRewards;
  final ReferralInfo referralInfo;

  RewardsModel({
    required this.userId,
    this.points = 0,
    this.tier = 'Bronze',
    this.pointsToNextTier = 500,
    this.availableRewards = const [],
    this.redeemedRewards = const [],
    required this.referralInfo,
  });

  factory RewardsModel.fromJson(Map<String, dynamic> json) =>
      _$RewardsModelFromJson(json);

  Map<String, dynamic> toJson() => _$RewardsModelToJson(this);
}

@JsonSerializable()
class RewardModel {
  final String id;
  final String name;
  final String description;
  final RewardType type;
  final int pointsCost;
  final double? discountValue;
  final double? discountPercentage;
  final String? freeItemId;
  final DateTime? expiresAt;

  RewardModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.pointsCost,
    this.discountValue,
    this.discountPercentage,
    this.freeItemId,
    this.expiresAt,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) =>
      _$RewardModelFromJson(json);

  Map<String, dynamic> toJson() => _$RewardModelToJson(this);
}

@JsonSerializable()
class RedeemedRewardModel {
  final String id;
  final RewardModel reward;
  final String? code;
  final bool isUsed;
  final DateTime redeemedAt;
  final DateTime expiresAt;

  RedeemedRewardModel({
    required this.id,
    required this.reward,
    this.code,
    this.isUsed = false,
    required this.redeemedAt,
    required this.expiresAt,
  });

  factory RedeemedRewardModel.fromJson(Map<String, dynamic> json) =>
      _$RedeemedRewardModelFromJson(json);

  Map<String, dynamic> toJson() => _$RedeemedRewardModelToJson(this);
}

@JsonSerializable()
class ReferralInfo {
  final String code;
  final String shareLink;
  final int totalReferrals;
  final double totalEarnings;
  final double bonusPerReferral;

  ReferralInfo({
    required this.code,
    required this.shareLink,
    this.totalReferrals = 0,
    this.totalEarnings = 0,
    this.bonusPerReferral = 50,
  });

  factory ReferralInfo.fromJson(Map<String, dynamic> json) =>
      _$ReferralInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ReferralInfoToJson(this);
}

enum RewardType {
  discount,
  freeItem,
  freeDelivery,
  percentageOff,
}

enum LoyaltyTier {
  bronze('Bronze', 0, '🥉'),
  silver('Silver', 500, '🥈'),
  gold('Gold', 1500, '🥇'),
  platinum('Platinum', 5000, '💎');

  final String label;
  final int minPoints;
  final String emoji;

  const LoyaltyTier(this.label, this.minPoints, this.emoji);
}
