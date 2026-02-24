import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/l10n_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/food_model.dart';
import '../../providers/food_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/food/food_card.dart';

class RecommendationsScreen extends ConsumerStatefulWidget {
  final FeelingType feeling;

  const RecommendationsScreen({super.key, required this.feeling});

  @override
  ConsumerState<RecommendationsScreen> createState() =>
      _RecommendationsScreenState();
}

class _RecommendationsScreenState extends ConsumerState<RecommendationsScreen> {
  String _selectedFilter = 'all';

  static const _filters = [
    'all',
    'highProtein',
    'lowCarb',
    'under150Egp',
    'quickUnder15Min',
  ];

  @override
  Widget build(BuildContext context) {
    final recommendationsAsync = ref.watch(
      recommendationsProvider(widget.feeling),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.feeling.recommendationTitle.localize(context)),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: FilterChip(
                    label: Text(_localizedFilter(context, filter)),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedFilter = filter);
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surfaceWarm,
                    side: BorderSide.none,
                    labelStyle: AppTextStyles.labelMedium.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: recommendationsAsync.when(
              data: (recommendations) =>
                  _buildRecommendationsList(recommendations),
              loading: () => const LoadingWidget(),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsList(
    Map<String, List<FoodModel>> recommendations,
  ) {
    final perfect = recommendations['perfect'] ?? [];
    final good = recommendations['good'] ?? [];
    final notIdeal = recommendations['notIdeal'] ?? [];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (perfect.isNotEmpty) ...[
          _SectionHeader(
            title: context.l10n.perfectForYou,
            subtitle: context.l10n.perfectForYouSubtitle,
            badgeColor: AppColors.badgePerfect,
          ),
          const SizedBox(height: 16),
          ...perfect.map(
            (food) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: FoodCard(
                food: food,
                onTap: () => context.push('${Routes.foodDetail}/${food.id}'),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (good.isNotEmpty) ...[
          _SectionHeader(
            title: context.l10n.alsoGreatChoices,
            subtitle: context.l10n.alsoGreatChoicesSubtitle,
            badgeColor: AppColors.badgeGood,
          ),
          const SizedBox(height: 16),
          ...good.map(
            (food) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: FoodCard(
                food: food,
                onTap: () => context.push('${Routes.foodDetail}/${food.id}'),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (notIdeal.isNotEmpty) ...[
          _CollapsibleSection(
            title: context.l10n.maybeNotRightNow,
            subtitle: context.l10n.maybeNotRightNowSubtitle,
            badgeColor: AppColors.badgeNotIdeal,
            foods: notIdeal,
          ),
        ],
      ],
    );
  }

  String _localizedFilter(BuildContext context, String key) {
    switch (key) {
      case 'all':
        return context.l10n.all;
      case 'highProtein':
        return context.l10n.highProtein;
      case 'lowCarb':
        return context.l10n.lowCarb;
      case 'under150Egp':
        return context.l10n.under150Egp;
      case 'quickUnder15Min':
        return context.l10n.quickUnder15Min;
      default:
        return key;
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color badgeColor;

  const _SectionHeader({
    required this.title,
    this.subtitle,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Text(title, style: AppTextStyles.h6),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 22),
            child: Text(subtitle!, style: AppTextStyles.bodySmall),
          ),
        ],
      ],
    );
  }
}

class _CollapsibleSection extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Color badgeColor;
  final List<FoodModel> foods;

  const _CollapsibleSection({
    required this.title,
    this.subtitle,
    required this.badgeColor,
    required this.foods,
  });

  @override
  State<_CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<_CollapsibleSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: widget.badgeColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(widget.title, style: AppTextStyles.h6),
                    ),
                    Icon(
                      _isExpanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 22),
                    child: Text(
                      widget.subtitle!,
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: [
              const SizedBox(height: 16),
              ...widget.foods.map(
                (food) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Opacity(
                    opacity: 0.55,
                    child: FoodCard(
                      food: food,
                      onTap: () =>
                          context.push('${Routes.foodDetail}/${food.id}'),
                    ),
                  ),
                ),
              ),
            ],
          ),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }
}
