import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/l10n_extensions.dart';
import '../../../data/models/food_model.dart';
import '../../providers/food_provider.dart';

class FoodCard extends ConsumerWidget {
  final FoodModel food;
  final VoidCallback onTap;
  final bool showFunctionalScores;

  const FoodCard({
    super.key,
    required this.food,
    required this.onTap,
    this.showFunctionalScores = true,
  });

  String _getMicrocopy(BuildContext context) {
    final hour = DateTime.now().hour;
    if (food.functionalScores.energyStability >= 4 && hour < 12) {
      return context.l10n.greatPickForMorning;
    }
    if (food.functionalScores.satiety >= 4) {
      return context.l10n.keepsYouFullLonger;
    }
    if (food.functionalScores.sleepFriendly >= 4 && hour >= 19) {
      return context.l10n.perfectBeforeBedtime;
    }
    if (food.functionalScores.digestionEase >= 4) {
      return context.l10n.gentleOnYourStomach;
    }
    if (food.functionalScores.focusSupport >= 4) {
      return context.l10n.helpsYouStayFocused;
    }
    return '';
  }

  double _displayPrice() {
    return _foodDisplayPrice(food);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteFoodsProvider);
    final isFavorite = favorites.contains(food.id);
    final microcopy = _getMicrocopy(context);
    final displayPrice = _displayPrice();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(22),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: food.images.isNotEmpty
                        ? food.images.first
                        : 'https://via.placeholder.com/400x300',
                    height: 170,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 170,
                      color: AppColors.surfaceWarm,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 170,
                      color: AppColors.surfaceWarm,
                      child: const Icon(
                        Icons.restaurant_rounded,
                        size: 40,
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
                ),
                // Favorite button
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      ref.read(favoriteFoodsProvider.notifier).toggle(food.id);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.95),
                        shape: BoxShape.circle,
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 20,
                        color: isFavorite
                            ? AppColors.error
                            : AppColors.textHint,
                      ),
                    ),
                  ),
                ),
                // Discount badge
                if (food.hasDiscount)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '-${food.discountPercentage.toInt()}%',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name.localize(context),
                    style: AppTextStyles.labelLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Microcopy
                  if (microcopy.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      microcopy,
                      style: AppTextStyles.microcopy.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],

                  if (showFunctionalScores) ...[
                    const SizedBox(height: 12),
                    _FunctionalLabels(scores: food.functionalScores),
                    const SizedBox(height: 12),
                  ] else
                    const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            context.l10n.readyInMin(food.preparationTime),
                            style: AppTextStyles.caption,
                          ),
                          const SizedBox(width: 14),
                          Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${food.rating} (${food.reviewCount})',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (food.hasDiscount)
                            Text(
                              'EGP ${food.originalPrice!.toStringAsFixed(0)}',
                              style: AppTextStyles.priceStrikethrough,
                            ),
                          Text(
                            'EGP ${displayPrice.toStringAsFixed(0)}',
                            style: AppTextStyles.priceMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FunctionalLabels extends StatelessWidget {
  final FunctionalScores scores;

  const _FunctionalLabels({required this.scores});

  @override
  Widget build(BuildContext context) {
    final labels = <_LabelData>[];

    if (scores.satiety >= 4) {
      labels.add(_LabelData(context.l10n.keepsYouFull, AppColors.satietyColor));
    }
    if (scores.energyStability >= 4) {
      labels.add(_LabelData(context.l10n.steadyEnergy, AppColors.energyColor));
    }
    if (scores.digestionEase >= 4) {
      labels.add(_LabelData(context.l10n.easyToDigest, AppColors.digestColor));
    }
    if (scores.sleepFriendly >= 4) {
      labels.add(
        _LabelData(context.l10n.goodBeforeSleep, AppColors.sleepColor),
      );
    }
    if (scores.focusSupport >= 4) {
      labels.add(_LabelData(context.l10n.focusSupport, AppColors.focusColor));
    }
    if (scores.workoutSupport >= 4) {
      labels.add(_LabelData(context.l10n.workoutFuel, AppColors.fitnessColor));
    }

    if (labels.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: labels.take(3).map((l) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: l.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            l.label,
            style: AppTextStyles.labelSmall.copyWith(
              color: l.color,
              fontSize: 11,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _LabelData {
  final String label;
  final Color color;
  const _LabelData(this.label, this.color);
}

double _foodDisplayPrice(FoodModel food) {
  if (food.portionOptions.isEmpty) return food.price;
  final popular = food.portionOptions.where((p) => p.isPopular).toList();
  if (popular.isNotEmpty) return popular.first.price;
  return food.portionOptions.first.price;
}

class CompactFoodCard extends StatelessWidget {
  final FoodModel food;
  final VoidCallback onTap;

  const CompactFoodCard({super.key, required this.food, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 165,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: CachedNetworkImage(
                imageUrl: food.images.isNotEmpty
                    ? food.images.first
                    : 'https://via.placeholder.com/200x150',
                height: 110,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name.localize(context),
                    style: AppTextStyles.labelMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 13,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 3),
                      Text('${food.rating}', style: AppTextStyles.caption),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'EGP ${_foodDisplayPrice(food).toStringAsFixed(0)}',
                    style: AppTextStyles.priceSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
