import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Points & Rewards')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _PointsCard(points: 2500, tier: 'Gold', pointsToNext: 500),
          const SizedBox(height: 24),
          _ReferralCard(),
          const SizedBox(height: 24),
          Text('Available Rewards', style: AppTextStyles.h6),
          const SizedBox(height: 16),
          _RewardCard(
            name: 'Free Delivery',
            description: 'Get free delivery on your next order',
            pointsCost: 200,
            icon: Icons.local_shipping_rounded,
          ),
          _RewardCard(
            name: 'EGP 20 Off',
            description: 'Get EGP 20 discount on orders over EGP 100',
            pointsCost: 400,
            icon: Icons.discount_rounded,
          ),
          _RewardCard(
            name: 'Free Smoothie',
            description: 'Redeem a free Energy Boost Smoothie',
            pointsCost: 500,
            icon: Icons.local_drink_rounded,
          ),
          _RewardCard(
            name: '10% Off',
            description: 'Get 10% off your entire order (max EGP 50)',
            pointsCost: 800,
            icon: Icons.percent_rounded,
          ),
        ],
      ),
    );
  }
}

class _PointsCard extends StatelessWidget {
  final int points;
  final String tier;
  final int pointsToNext;

  const _PointsCard({
    required this.points,
    required this.tier,
    required this.pointsToNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.tierGold, Color(0xFFFFD54F)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.elevatedShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🥇', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$tier Member',
                    style: AppTextStyles.h5.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '$pointsToNext points to Platinum',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '$points',
            style: AppTextStyles.h1.copyWith(
              color: AppColors.textPrimary,
              fontSize: 48,
            ),
          ),
          Text(
            'Points Available',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: points / (points + pointsToNext),
            backgroundColor: AppColors.divider,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.textSecondary,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

class _ReferralCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.card_giftcard_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Refer a Friend', style: AppTextStyles.h6),
                    Text(
                      'You both get EGP 50!',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceWarm,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'SMARTFOOD50',
                    style: AppTextStyles.h5.copyWith(letterSpacing: 2),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Code copied!')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                SharePlus.instance.share(
                  ShareParams(
                    text:
                        'Use my code SMARTFOOD50 to get EGP 50 off your first Smart Food order! Download the app: https://smartfood.app',
                  ),
                );
              },
              icon: const Icon(Icons.share_rounded),
              label: const Text('Share Code'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ReferralStat(label: 'Total Referrals', value: '5'),
              _ReferralStat(label: 'Total Earned', value: 'EGP 250'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReferralStat extends StatelessWidget {
  final String label;
  final String value;

  const _ReferralStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.h5),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

class _RewardCard extends StatelessWidget {
  final String name;
  final String description;
  final int pointsCost;
  final IconData icon;

  const _RewardCard({
    required this.name,
    required this.description,
    required this.pointsCost,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.labelLarge),
                Text(description, style: AppTextStyles.caption),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$pointsCost',
                style: AppTextStyles.h6.copyWith(color: AppColors.primary),
              ),
              Text('points', style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }
}
