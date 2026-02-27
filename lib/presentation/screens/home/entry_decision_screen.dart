import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';

class EntryDecisionScreen extends StatelessWidget {
  const EntryDecisionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.creamGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How would you like to order today?',
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose your flow and switch anytime.',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 28),
                _EntryOptionCard(
                  title: 'I know what I want',
                  subtitle:
                      'Go straight to full menu browsing with categories, search, filters, and Drinks & Sweets.',
                  icon: Icons.grid_view_rounded,
                  onTap: () => context.go(Routes.categories),
                ),
                const SizedBox(height: 14),
                _EntryOptionCard(
                  title: 'Help me choose',
                  subtitle:
                      'Get mood-based recommendations powered by SmartScore alignment.',
                  icon: Icons.auto_awesome_rounded,
                  onTap: () => context.go(Routes.guided),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EntryOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _EntryOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.divider),
            boxShadow: AppColors.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.h6),
                    const SizedBox(height: 6),
                    Text(subtitle, style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
