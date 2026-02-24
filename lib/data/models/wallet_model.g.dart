// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletModel _$WalletModelFromJson(Map<String, dynamic> json) => WalletModel(
  userId: json['userId'] as String,
  balance: (json['balance'] as num?)?.toDouble() ?? 0,
  recentTransactions:
      (json['recentTransactions'] as List<dynamic>?)
          ?.map(
            (e) => WalletTransactionModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$WalletModelToJson(WalletModel instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'balance': instance.balance,
      'recentTransactions': instance.recentTransactions,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

WalletTransactionModel _$WalletTransactionModelFromJson(
  Map<String, dynamic> json,
) => WalletTransactionModel(
  id: json['id'] as String,
  type: $enumDecode(_$WalletTransactionTypeEnumMap, json['type']),
  amount: (json['amount'] as num).toDouble(),
  description: json['description'] as String,
  referenceId: json['referenceId'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$WalletTransactionModelToJson(
  WalletTransactionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': _$WalletTransactionTypeEnumMap[instance.type]!,
  'amount': instance.amount,
  'description': instance.description,
  'referenceId': instance.referenceId,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$WalletTransactionTypeEnumMap = {
  WalletTransactionType.topUp: 'topUp',
  WalletTransactionType.payment: 'payment',
  WalletTransactionType.refund: 'refund',
  WalletTransactionType.referralBonus: 'referralBonus',
  WalletTransactionType.cashback: 'cashback',
};

RewardsModel _$RewardsModelFromJson(Map<String, dynamic> json) => RewardsModel(
  userId: json['userId'] as String,
  points: (json['points'] as num?)?.toInt() ?? 0,
  tier: json['tier'] as String? ?? 'Bronze',
  pointsToNextTier: (json['pointsToNextTier'] as num?)?.toInt() ?? 500,
  availableRewards:
      (json['availableRewards'] as List<dynamic>?)
          ?.map((e) => RewardModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  redeemedRewards:
      (json['redeemedRewards'] as List<dynamic>?)
          ?.map((e) => RedeemedRewardModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  referralInfo: ReferralInfo.fromJson(
    json['referralInfo'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$RewardsModelToJson(RewardsModel instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'points': instance.points,
      'tier': instance.tier,
      'pointsToNextTier': instance.pointsToNextTier,
      'availableRewards': instance.availableRewards,
      'redeemedRewards': instance.redeemedRewards,
      'referralInfo': instance.referralInfo,
    };

RewardModel _$RewardModelFromJson(Map<String, dynamic> json) => RewardModel(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$RewardTypeEnumMap, json['type']),
  pointsCost: (json['pointsCost'] as num).toInt(),
  discountValue: (json['discountValue'] as num?)?.toDouble(),
  discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
  freeItemId: json['freeItemId'] as String?,
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
);

Map<String, dynamic> _$RewardModelToJson(RewardModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': _$RewardTypeEnumMap[instance.type]!,
      'pointsCost': instance.pointsCost,
      'discountValue': instance.discountValue,
      'discountPercentage': instance.discountPercentage,
      'freeItemId': instance.freeItemId,
      'expiresAt': instance.expiresAt?.toIso8601String(),
    };

const _$RewardTypeEnumMap = {
  RewardType.discount: 'discount',
  RewardType.freeItem: 'freeItem',
  RewardType.freeDelivery: 'freeDelivery',
  RewardType.percentageOff: 'percentageOff',
};

RedeemedRewardModel _$RedeemedRewardModelFromJson(Map<String, dynamic> json) =>
    RedeemedRewardModel(
      id: json['id'] as String,
      reward: RewardModel.fromJson(json['reward'] as Map<String, dynamic>),
      code: json['code'] as String?,
      isUsed: json['isUsed'] as bool? ?? false,
      redeemedAt: DateTime.parse(json['redeemedAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$RedeemedRewardModelToJson(
  RedeemedRewardModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'reward': instance.reward,
  'code': instance.code,
  'isUsed': instance.isUsed,
  'redeemedAt': instance.redeemedAt.toIso8601String(),
  'expiresAt': instance.expiresAt.toIso8601String(),
};

ReferralInfo _$ReferralInfoFromJson(Map<String, dynamic> json) => ReferralInfo(
  code: json['code'] as String,
  shareLink: json['shareLink'] as String,
  totalReferrals: (json['totalReferrals'] as num?)?.toInt() ?? 0,
  totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0,
  bonusPerReferral: (json['bonusPerReferral'] as num?)?.toDouble() ?? 50,
);

Map<String, dynamic> _$ReferralInfoToJson(ReferralInfo instance) =>
    <String, dynamic>{
      'code': instance.code,
      'shareLink': instance.shareLink,
      'totalReferrals': instance.totalReferrals,
      'totalEarnings': instance.totalEarnings,
      'bonusPerReferral': instance.bonusPerReferral,
    };
