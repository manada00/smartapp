import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/l10n_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/food_model.dart';
import '../../../data/models/cart_model.dart';
import '../../providers/food_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/app_button.dart';

class FoodDetailScreen extends ConsumerStatefulWidget {
  final String foodId;

  const FoodDetailScreen({super.key, required this.foodId});

  @override
  ConsumerState<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends ConsumerState<FoodDetailScreen> {
  int _quantity = 1;
  PortionOption? _selectedPortion;
  final Map<String, Set<String>> _selectedCustomizations = {};
  final _instructionsController = TextEditingController();

  double get _totalPrice {
    if (_selectedPortion == null) return 0;

    double price = _selectedPortion!.price;

    for (final entry in _selectedCustomizations.entries) {
      for (final optionId in entry.value) {
        final food = ref.read(foodDetailProvider(widget.foodId)).value;
        if (food != null) {
          final group = food.customizations.firstWhere(
            (g) => g.id == entry.key,
            orElse: () => CustomizationGroup(
              id: '',
              name: '',
              type: CustomizationType.single,
              options: [],
            ),
          );
          final option = group.options.firstWhere(
            (o) => o.id == optionId,
            orElse: () => CustomizationOption(id: '', name: ''),
          );
          price += option.priceModifier;
        }
      }
    }

    return price * _quantity;
  }

  void _addToCart(FoodModel food) {
    final customizations = <SelectedCustomization>[];

    for (final entry in _selectedCustomizations.entries) {
      final group = food.customizations.firstWhere((g) => g.id == entry.key);
      for (final optionId in entry.value) {
        final option = group.options.firstWhere((o) => o.id == optionId);
        customizations.add(
          SelectedCustomization(
            groupId: group.id,
            groupName: group.name,
            optionId: option.id,
            optionName: option.name,
            priceModifier: option.priceModifier,
          ),
        );
      }
    }

    ref
        .read(cartProvider.notifier)
        .addItem(
          food: food,
          portion: _selectedPortion,
          customizations: customizations,
          specialInstructions: _instructionsController.text.isNotEmpty
              ? _instructionsController.text
              : null,
          quantity: _quantity,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.addedToCart(food.name.localize(context))),
        action: SnackBarAction(
          label: context.l10n.viewCart,
          onPressed: () => context.push(Routes.cart),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final foodAsync = ref.watch(foodDetailProvider(widget.foodId));
    final favorites = ref.watch(favoriteFoodsProvider);

    return foodAsync.when(
      data: (food) {
        final isFavorite = favorites.contains(food.id);

        if (_selectedPortion == null && food.portionOptions.isNotEmpty) {
          _selectedPortion = food.portionOptions.firstWhere(
            (p) => p.isPopular,
            orElse: () => food.portionOptions.first,
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: AppColors.background,
                flexibleSpace: FlexibleSpaceBar(
                  background: CachedNetworkImage(
                    imageUrl: food.images.isNotEmpty
                        ? food.images.first
                        : 'https://via.placeholder.com/800x600',
                    fit: BoxFit.cover,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.share_rounded, size: 20),
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 20,
                        color: isFavorite ? AppColors.error : null,
                      ),
                    ),
                    onPressed: () {
                      ref.read(favoriteFoodsProvider.notifier).toggle(food.id);
                    },
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food.name.localize(context),
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 18,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            context.l10n.reviewsCount(
                              food.rating.toString(),
                              food.reviewCount,
                            ),
                            style: AppTextStyles.bodyMedium,
                          ),
                          const SizedBox(width: 18),
                          Icon(
                            Icons.access_time_rounded,
                            size: 18,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            context.l10n.readyInMin(food.preparationTime),
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'EGP ${food.price.toStringAsFixed(0)}',
                        style: AppTextStyles.priceLarge,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        food.description.localize(context),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _FunctionalScoresSection(scores: food.functionalScores),
                      const SizedBox(height: 28),
                      if (food.bestFor.isNotEmpty) ...[
                        Text(context.l10n.bestFor, style: AppTextStyles.h6),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: food.bestFor.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                tag.localize(context),
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 28),
                      ],
                      if (food.portionOptions.isNotEmpty) ...[
                        Text(context.l10n.portionSize, style: AppTextStyles.h6),
                        const SizedBox(height: 14),
                        ...food.portionOptions.map((portion) {
                          return RadioListTile<PortionOption>(
                            value: portion,
                            groupValue: _selectedPortion,
                            onChanged: (v) {
                              setState(() => _selectedPortion = v);
                            },
                            title: Row(
                              children: [
                                Text(
                                  '${portion.name.localize(context)} (${portion.weightGrams}g)',
                                  style: AppTextStyles.bodyMedium,
                                ),
                                if (portion.isPopular) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      context.l10n.popular,
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            subtitle: Text(
                              'EGP ${portion.price.toStringAsFixed(0)}',
                              style: AppTextStyles.priceSmall,
                            ),
                            activeColor: AppColors.primary,
                            contentPadding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          );
                        }),
                        const SizedBox(height: 28),
                      ],
                      if (food.customizations.isNotEmpty) ...[
                        Text(
                          'Customizations'.localize(context),
                          style: AppTextStyles.h6,
                        ),
                        const SizedBox(height: 14),
                        ...food.customizations.map((group) {
                          return _CustomizationSection(
                            group: group,
                            selectedOptions:
                                _selectedCustomizations[group.id] ?? {},
                            onChanged: (options) {
                              setState(() {
                                _selectedCustomizations[group.id] = options;
                              });
                            },
                          );
                        }),
                        const SizedBox(height: 28),
                      ],
                      Text(
                        context.l10n.specialInstructions,
                        style: AppTextStyles.h6,
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _instructionsController,
                        maxLines: 2,
                        style: AppTextStyles.bodyMedium,
                        decoration: InputDecoration(
                          hintText: context.l10n.specialInstructionsHint,
                          filled: true,
                          fillColor: AppColors.surfaceWarm,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomSheet: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B7A5E).withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWarm,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_rounded),
                          onPressed: _quantity > 1
                              ? () => setState(() => _quantity--)
                              : null,
                        ),
                        Text('$_quantity', style: AppTextStyles.labelLarge),
                        IconButton(
                          icon: const Icon(Icons.add_rounded),
                          onPressed: () => setState(() => _quantity++),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppButton(
                      text: context.l10n.addToCartPrice(
                        _totalPrice.toStringAsFixed(0),
                      ),
                      onPressed: () => _addToCart(food),
                      gradient: AppColors.primaryGradient,
                      icon: const Icon(
                        Icons.shopping_bag_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: LoadingWidget()),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('${context.l10n.errorPrefix}: $e')),
      ),
    );
  }
}

class _FunctionalScoresSection extends StatelessWidget {
  final FunctionalScores scores;

  const _FunctionalScoresSection({required this.scores});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceWarm,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What this meal does for you'.localize(context),
            style: AppTextStyles.h6,
          ),
          const SizedBox(height: 18),
          _ScoreBar(
            emoji: '⚡',
            label: context.l10n.steadyEnergy,
            score: scores.energyStability,
            color: AppColors.energyColor,
          ),
          _ScoreBar(
            emoji: '😊',
            label: context.l10n.keepsYouFull,
            score: scores.satiety,
            color: AppColors.satietyColor,
          ),
          _ScoreBar(
            emoji: '📉',
            label: 'Gentle on insulin'.localize(context),
            score: scores.insulinImpact,
            color: AppColors.digestColor,
            isInverted: true,
          ),
          _ScoreBar(
            emoji: '🫄',
            label: context.l10n.easyToDigest,
            score: scores.digestionEase,
            color: AppColors.digestColor,
          ),
          _ScoreBar(
            emoji: '🧠',
            label: context.l10n.focusSupport,
            score: scores.focusSupport,
            color: AppColors.focusColor,
          ),
          _ScoreBar(
            emoji: '😴',
            label: context.l10n.goodBeforeSleep,
            score: scores.sleepFriendly,
            color: AppColors.sleepColor,
          ),
          _ScoreBar(
            emoji: '👶',
            label: 'Kid friendly'.localize(context),
            score: scores.kidFriendly,
            color: AppColors.kidsColor,
          ),
          _ScoreBar(
            emoji: '💪',
            label: context.l10n.workoutFuel,
            score: scores.workoutSupport,
            color: AppColors.fitnessColor,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final String emoji;
  final String label;
  final int score;
  final Color color;
  final bool isInverted;
  final bool isLast;

  const _ScoreBar({
    required this.emoji,
    required this.label,
    required this.score,
    required this.color,
    this.isInverted = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveScore = isInverted ? 6 - score : score;
    final barColor = effectiveScore >= 4
        ? AppColors.scoreExcellent
        : (effectiveScore == 3 ? AppColors.scoreMedium : AppColors.scoreLow);

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          SizedBox(
            width: 120,
            child: Text(label, style: AppTextStyles.bodySmall),
          ),
          Expanded(
            child: Row(
              children: List.generate(5, (index) {
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    height: 8,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: index < score
                          ? barColor
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
          ),
          if (isInverted && score <= 2) ...[
            const SizedBox(width: 6),
            Icon(
              Icons.check_circle_rounded,
              size: 16,
              color: AppColors.success,
            ),
          ],
        ],
      ),
    );
  }
}

class _CustomizationSection extends StatelessWidget {
  final CustomizationGroup group;
  final Set<String> selectedOptions;
  final ValueChanged<Set<String>> onChanged;

  const _CustomizationSection({
    required this.group,
    required this.selectedOptions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        group.name.localize(context),
        style: AppTextStyles.labelLarge,
      ),
      initiallyExpanded: group.isRequired,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      children: group.options.map((option) {
        final isSelected = selectedOptions.contains(option.id);

        if (group.type == CustomizationType.single) {
          return RadioListTile<String>(
            value: option.id,
            groupValue: selectedOptions.isEmpty ? null : selectedOptions.first,
            onChanged: (v) {
              if (v != null) onChanged({v});
            },
            title: Text(
              option.name.localize(context),
              style: AppTextStyles.bodyMedium,
            ),
            subtitle: option.priceModifier != 0
                ? Text(
                    option.priceModifier > 0
                        ? '+EGP ${option.priceModifier.toStringAsFixed(0)}'
                        : '-EGP ${option.priceModifier.abs().toStringAsFixed(0)}',
                    style: AppTextStyles.caption.copyWith(
                      color: option.priceModifier > 0
                          ? AppColors.textSecondary
                          : AppColors.success,
                    ),
                  )
                : null,
            activeColor: AppColors.primary,
          );
        }

        return CheckboxListTile(
          value: isSelected,
          onChanged: (v) {
            final newSelection = Set<String>.from(selectedOptions);
            if (v == true) {
              newSelection.add(option.id);
            } else {
              newSelection.remove(option.id);
            }
            onChanged(newSelection);
          },
          title: Text(
            option.name.localize(context),
            style: AppTextStyles.bodyMedium,
          ),
          subtitle: option.priceModifier != 0
              ? Text(
                  option.priceModifier > 0
                      ? '+EGP ${option.priceModifier.toStringAsFixed(0)}'
                      : '-EGP ${option.priceModifier.abs().toStringAsFixed(0)}',
                  style: AppTextStyles.caption.copyWith(
                    color: option.priceModifier > 0
                        ? AppColors.textSecondary
                        : AppColors.success,
                  ),
                )
              : null,
          activeColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }).toList(),
    );
  }
}
