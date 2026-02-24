import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../widgets/common/app_button.dart';

class SubscriptionDetailScreen extends ConsumerWidget {
  final String planId;

  const SubscriptionDetailScreen({super.key, required this.planId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Plan Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppColors.cardShadow,
                image: const DecorationImage(
                  image: NetworkImage('https://picsum.photos/seed/plan/800/400'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Daily Lunch Plan', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              'Nutritious and filling lunches delivered daily to keep you energized throughout the day.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceWarm,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _PlanStat(label: 'Weekly Price', value: 'EGP 650'),
                  _PlanStat(label: 'Per Meal', value: 'EGP 93'),
                  _PlanStat(label: 'You Save', value: '15%'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text("What's Included", style: AppTextStyles.h6),
            const SizedBox(height: 12),
            _FeatureItem(text: '7 delicious lunches per week'),
            _FeatureItem(text: 'Free delivery to your location'),
            _FeatureItem(text: 'Flexible meal selection'),
            _FeatureItem(text: 'Skip or swap any day'),
            _FeatureItem(text: 'Priority customer support'),
            const SizedBox(height: 24),
            Text('Meal Selection', style: AppTextStyles.h6),
            const SizedBox(height: 12),
            _MealSelectionOption(
              title: "Chef's Choice",
              subtitle: 'Let our chefs surprise you with the best meals',
              isSelected: true,
            ),
            _MealSelectionOption(
              title: 'Choose Your Meals',
              subtitle: 'Select your meals for each day',
              isSelected: false,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7A6B50).withValues(alpha: 0.10),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: AppButton(
            text: 'Subscribe - EGP 650/week',
            onPressed: () {
              // Handle subscription
            },
            width: double.infinity,
          ),
        ),
      ),
    );
  }
}

class _PlanStat extends StatelessWidget {
  final String label;
  final String value;

  const _PlanStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.h5.copyWith(color: AppColors.primary)),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String text;

  const _FeatureItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
          const SizedBox(width: 12),
          Text(text, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

class _MealSelectionOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;

  const _MealSelectionOption({
    required this.title,
    required this.subtitle,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.divider,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected ? AppColors.cardShadow : null,
      ),
      child: RadioListTile<bool>(
        value: isSelected,
        groupValue: true,
        onChanged: (_) {},
        title: Text(title, style: AppTextStyles.labelLarge),
        subtitle: Text(subtitle, style: AppTextStyles.caption),
        activeColor: AppColors.primary,
      ),
    );
  }
}
