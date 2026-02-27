import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/food_model.dart';
import '../../providers/food_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/food/food_card.dart';

class GuidedMoodScreen extends ConsumerStatefulWidget {
  const GuidedMoodScreen({super.key});

  @override
  ConsumerState<GuidedMoodScreen> createState() => _GuidedMoodScreenState();
}

class _GuidedMoodScreenState extends ConsumerState<GuidedMoodScreen> {
  GuidedMoodType _selectedMood = GuidedMoodType.energy;

  @override
  Widget build(BuildContext context) {
    final foodsAsync = ref.watch(foodsProvider(null));
    final screenSize = MediaQuery.sizeOf(context);
    final compactMoodLayout = screenSize.height < 760 || screenSize.width < 370;
    final moodRows = compactMoodLayout ? 1 : 2;
    final moodGridHeight = compactMoodLayout ? 158.0 : 246.0;
    final moodCardAspectRatio = compactMoodLayout ? 1.28 : 0.56;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Help me choose'),
        actions: [
          TextButton(
            onPressed: () => context.go(Routes.categories),
            child: const Text('Browse Menu Instead'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
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
                const SizedBox(height: 12),
                Text('How do you want to feel now?', style: AppTextStyles.h4),
                const SizedBox(height: 6),
                Text(
                  'Pick a mood and we will gently guide you to meals that align with your body today.',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: moodGridHeight,
                  child: GridView.builder(
                    scrollDirection: Axis.horizontal,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: moodRows,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: moodCardAspectRatio,
                    ),
                    itemCount: guidedMoods.length,
                    itemBuilder: (context, index) {
                      final mood = guidedMoods[index];
                      final selected = mood.type == _selectedMood;
                      return _MoodCard(
                        mood: mood,
                        compact: compactMoodLayout,
                        selected: selected,
                        onTap: () => setState(() => _selectedMood = mood.type),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: foodsAsync.when(
              data: (foods) {
                final matched = _filterFoodsByMood(foods, _selectedMood);
                if (matched.isEmpty) {
                  return Center(
                    child: Text(
                      'No matching items right now.',
                      style: AppTextStyles.bodyMedium,
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                  itemBuilder: (context, index) {
                    final food = matched[index];
                    return FoodCard(
                      food: food,
                      onTap: () =>
                          context.push('${Routes.foodDetail}/${food.id}'),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemCount: matched.length.clamp(0, 8),
                );
              },
              loading: () => const LoadingWidget(),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

enum GuidedMoodType {
  energy,
  light,
  muscle,
  comfort,
  focus,
  smartSweet,
  filling,
  balance,
}

class GuidedMood {
  final GuidedMoodType type;
  final String emoji;
  final String title;
  final String subtitle;
  final String image;

  const GuidedMood({
    required this.type,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.image,
  });
}

const guidedMoods = <GuidedMood>[
  GuidedMood(
    type: GuidedMoodType.energy,
    emoji: '⚡',
    title: 'Energy',
    subtitle: 'Steady fuel for your day',
    image:
        'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=900&q=80',
  ),
  GuidedMood(
    type: GuidedMoodType.light,
    emoji: '🥗',
    title: 'Lightness',
    subtitle: 'Lighter choices, easy digestion',
    image:
        'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=900&q=80',
  ),
  GuidedMood(
    type: GuidedMoodType.muscle,
    emoji: '💪',
    title: 'Strength',
    subtitle: 'Protein support for recovery',
    image:
        'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?auto=format&fit=crop&w=900&q=80',
  ),
  GuidedMood(
    type: GuidedMoodType.comfort,
    emoji: '🫶',
    title: 'Comfort',
    subtitle: 'Warm, grounding meal ideas',
    image:
        'https://images.unsplash.com/photo-1498837167922-ddd27525d352?auto=format&fit=crop&w=900&q=80',
  ),
  GuidedMood(
    type: GuidedMoodType.focus,
    emoji: '🧠',
    title: 'Focus',
    subtitle: 'Clear and balanced support',
    image:
        'https://images.unsplash.com/photo-1505576399279-565b52d4ac71?auto=format&fit=crop&w=900&q=80',
  ),
  GuidedMood(
    type: GuidedMoodType.smartSweet,
    emoji: '🍫',
    title: 'Sweet Balance',
    subtitle: 'Smart sweet moments',
    image:
        'https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=900&q=80',
  ),
  GuidedMood(
    type: GuidedMoodType.filling,
    emoji: '🍽️',
    title: 'Deep Satiety',
    subtitle: 'Filling options without heaviness',
    image:
        'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?auto=format&fit=crop&w=900&q=80',
  ),
  GuidedMood(
    type: GuidedMoodType.balance,
    emoji: '⚖️',
    title: 'Balance',
    subtitle: 'Harmony across your day',
    image:
        'https://images.unsplash.com/photo-1490474418585-ba9bad8fd0ea?auto=format&fit=crop&w=900&q=80',
  ),
];

class _MoodCard extends StatelessWidget {
  final GuidedMood mood;
  final bool compact;
  final bool selected;
  final VoidCallback onTap;

  const _MoodCard({
    required this.mood,
    required this.compact,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 180),
      scale: selected ? 0.98 : 1,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.all(compact ? 10 : 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: NetworkImage(mood.image),
              fit: BoxFit.cover,
            ),
            border: Border.all(
              color: selected ? AppColors.secondary : AppColors.secondaryLight,
            ),
            boxShadow: AppColors.elevatedShadow,
          ),
          child: Container(
            padding: EdgeInsets.all(compact ? 8 : 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.black.withValues(alpha: 0.32),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(mood.emoji, style: TextStyle(fontSize: compact ? 18 : 22)),
                SizedBox(height: compact ? 4 : 6),
                Text(
                  mood.title,
                  style:
                      (compact
                              ? AppTextStyles.labelMedium
                              : AppTextStyles.labelLarge)
                          .copyWith(color: AppColors.textOnPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: compact ? 1 : 2),
                Text(
                  mood.subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textOnPrimary.withValues(alpha: 0.9),
                    fontSize: compact ? 11 : 12,
                  ),
                  maxLines: compact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

List<FoodModel> _filterFoodsByMood(List<FoodModel> foods, GuidedMoodType mood) {
  final filtered = foods.where((food) {
    final s = food.functionalScores;
    switch (mood) {
      case GuidedMoodType.energy:
        return s.energyStability >= 4;
      case GuidedMoodType.light:
        return s.digestionEase >= 4;
      case GuidedMoodType.muscle:
        return s.workoutSupport >= 4;
      case GuidedMoodType.comfort:
        return s.satiety >= 4 && s.focusSupport >= 4;
      case GuidedMoodType.focus:
        return s.focusSupport >= 4;
      case GuidedMoodType.smartSweet:
        return food.categoryName.toLowerCase().contains('sweet') ||
            (s.insulinImpact >= 4 && s.satiety >= 3);
      case GuidedMoodType.filling:
        return s.satiety >= 4;
      case GuidedMoodType.balance:
        final avg =
            (s.energyStability +
                s.satiety +
                s.insulinImpact +
                s.digestionEase +
                s.focusSupport +
                s.sleepFriendly) /
            6;
        return avg >= 3.8;
    }
  }).toList();

  filtered.sort((a, b) => _moodScore(b, mood).compareTo(_moodScore(a, mood)));
  return filtered;
}

int _moodScore(FoodModel food, GuidedMoodType mood) {
  final s = food.functionalScores;
  switch (mood) {
    case GuidedMoodType.energy:
      return s.energyStability;
    case GuidedMoodType.light:
      return s.digestionEase;
    case GuidedMoodType.muscle:
      return s.workoutSupport;
    case GuidedMoodType.comfort:
      return s.satiety + s.focusSupport;
    case GuidedMoodType.focus:
      return s.focusSupport;
    case GuidedMoodType.smartSweet:
      return s.insulinImpact + s.satiety;
    case GuidedMoodType.filling:
      return s.satiety;
    case GuidedMoodType.balance:
      return s.energyStability +
          s.satiety +
          s.insulinImpact +
          s.digestionEase +
          s.focusSupport +
          s.sleepFriendly;
  }
}
