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
                Text('How would you like to feel?', style: AppTextStyles.h4),
                const SizedBox(height: 6),
                Text(
                  'Pick a mood. We will guide you to meals, drinks, and sweets that match SmartScore signals.',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 176,
                  child: GridView.builder(
                    scrollDirection: Axis.horizontal,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.36,
                        ),
                    itemCount: guidedMoods.length,
                    itemBuilder: (context, index) {
                      final mood = guidedMoods[index];
                      final selected = mood.type == _selectedMood;
                      return _MoodCard(
                        mood: mood,
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

  const GuidedMood({
    required this.type,
    required this.emoji,
    required this.title,
  });
}

const guidedMoods = <GuidedMood>[
  GuidedMood(type: GuidedMoodType.energy, emoji: '⚡', title: 'I want energy'),
  GuidedMood(
    type: GuidedMoodType.light,
    emoji: '🥗',
    title: 'I want something light',
  ),
  GuidedMood(
    type: GuidedMoodType.muscle,
    emoji: '💪',
    title: 'I want to build muscle',
  ),
  GuidedMood(
    type: GuidedMoodType.comfort,
    emoji: '🫶',
    title: 'I want comfort',
  ),
  GuidedMood(type: GuidedMoodType.focus, emoji: '🧠', title: 'I want focus'),
  GuidedMood(
    type: GuidedMoodType.smartSweet,
    emoji: '🍫',
    title: 'I want something sweet but smart',
  ),
  GuidedMood(
    type: GuidedMoodType.filling,
    emoji: '🍽️',
    title: 'I want something filling',
  ),
  GuidedMood(
    type: GuidedMoodType.balance,
    emoji: '⚖️',
    title: 'I want balance',
  ),
];

class _MoodCard extends StatelessWidget {
  final GuidedMood mood;
  final bool selected;
  final VoidCallback onTap;

  const _MoodCard({
    required this.mood,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.secondaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
          ),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            Text(mood.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                mood.title,
                style: AppTextStyles.labelMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
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
