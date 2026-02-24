import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';

class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Meal Subscriptions'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Save time and money with our weekly meal plans',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          _SubscriptionPlanCard(
            id: '1',
            name: 'Daily Breakfast Plan',
            description: 'Start your day right with balanced breakfast meals',
            price: 450,
            mealsPerWeek: 7,
            savings: 15,
            image: 'https://picsum.photos/seed/breakfast/400/200',
          ),
          _SubscriptionPlanCard(
            id: '2',
            name: 'Daily Lunch Plan',
            description: 'Nutritious and filling lunches delivered daily',
            price: 650,
            mealsPerWeek: 7,
            savings: 15,
            image: 'https://picsum.photos/seed/lunch/400/200',
          ),
          _SubscriptionPlanCard(
            id: '3',
            name: 'Gym Performance Pack',
            description: 'High-protein meals for fitness enthusiasts',
            price: 550,
            mealsPerWeek: 5,
            savings: 20,
            image: 'https://picsum.photos/seed/gym2/400/200',
          ),
          _SubscriptionPlanCard(
            id: '4',
            name: 'Kids Weekly Box',
            description: 'Healthy and fun meals that kids love',
            price: 400,
            mealsPerWeek: 5,
            savings: 10,
            image: 'https://picsum.photos/seed/kids2/400/200',
          ),
          _SubscriptionPlanCard(
            id: '5',
            name: 'Full Day Plan',
            description: 'Complete nutrition - breakfast, lunch, and dinner',
            price: 1200,
            mealsPerWeek: 21,
            savings: 25,
            image: 'https://picsum.photos/seed/fullday/400/200',
          ),
        ],
      ),
    );
  }
}

class _SubscriptionPlanCard extends StatelessWidget {
  final String id;
  final String name;
  final String description;
  final double price;
  final int mealsPerWeek;
  final int savings;
  final String image;

  const _SubscriptionPlanCard({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.mealsPerWeek,
    required this.savings,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: CachedNetworkImage(
                  imageUrl: image,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Save $savings%',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.h6),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.restaurant_menu_rounded,
                        size: 16, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text(
                      '$mealsPerWeek meals/week',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'EGP ${(price / mealsPerWeek).toStringAsFixed(0)}/meal',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EGP ${price.toStringAsFixed(0)}/week',
                          style: AppTextStyles.priceMedium,
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppColors.softGlow(AppColors.primary),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          context.push('${Routes.subscriptionDetail}/$id');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'View Plan',
                          style: AppTextStyles.buttonMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
