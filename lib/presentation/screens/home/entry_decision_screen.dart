import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';

class EntryDecisionScreen extends StatefulWidget {
  const EntryDecisionScreen({super.key});

  @override
  State<EntryDecisionScreen> createState() => _EntryDecisionScreenState();
}

class _EntryDecisionScreenState extends State<EntryDecisionScreen> {
  String _pressedId = '';

  Future<void> _handleSelect(String id, String route) async {
    setState(() => _pressedId = id);
    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1498837167922-ddd27525d352?auto=format&fit=crop&w=1500&q=80',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background.withValues(alpha: 0.92),
                    AppColors.background.withValues(alpha: 0.97),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.secondaryLight),
                    ),
                    child: Text(
                      'SMART WELLNESS JOURNEY',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Let’s choose what your body needs today.',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Take a calm moment, then follow the path that feels right for you.',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  _EntryOptionCard(
                    selected: _pressedId == 'browse',
                    title: 'I know what I want',
                    subtitle:
                        'Browse the full menu with categories, search, and clean discovery.',
                    imageUrl:
                        'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=1200&q=80',
                    onTap: () => _handleSelect('browse', Routes.categories),
                  ),
                  const SizedBox(height: 14),
                  _EntryOptionCard(
                    selected: _pressedId == 'guided',
                    title: 'Help me choose',
                    subtitle:
                        'Get guided suggestions based on your mood and SmartScore signals.',
                    imageUrl:
                        'https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=1200&q=80',
                    onTap: () => _handleSelect('guided', Routes.guided),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryOptionCard extends StatelessWidget {
  final bool selected;
  final String title;
  final String subtitle;
  final String imageUrl;
  final VoidCallback onTap;

  const _EntryOptionCard({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          scale: selected ? 0.98 : 1,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: selected
                    ? AppColors.secondary
                    : AppColors.secondaryLight,
              ),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
              boxShadow: AppColors.elevatedShadow,
            ),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.black.withValues(alpha: 0.3),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.h5.copyWith(
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textOnPrimary.withValues(alpha: 0.92),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
