import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../providers/food_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/food/food_card.dart';

class CategoryDetailScreen extends ConsumerStatefulWidget {
  final String categoryId;
  final String categoryName;

  const CategoryDetailScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  ConsumerState<CategoryDetailScreen> createState() =>
      _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends ConsumerState<CategoryDetailScreen> {
  String _sortBy = 'Recommended';

  static const _sortOptions = [
    'Recommended',
    'Price Low-High',
    'Price High-Low',
    'Rating',
  ];

  @override
  Widget build(BuildContext context) {
    final foodsAsync = ref.watch(foodsProvider(widget.categoryId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.categoryName),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Sort by: ', style: AppTextStyles.bodySmall),
                DropdownButton<String>(
                  value: _sortBy,
                  underline: const SizedBox(),
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  items: _sortOptions.map((option) {
                    return DropdownMenuItem(value: option, child: Text(option));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _sortBy = value);
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: foodsAsync.when(
              data: (foods) => ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: foods.length,
                itemBuilder: (context, index) {
                  final food = foods[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: FoodCard(
                      food: food,
                      onTap: () =>
                          context.push('${Routes.foodDetail}/${food.id}'),
                    ),
                  );
                },
              ),
              loading: () => const LoadingWidget(),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) =>
            _FilterSheet(scrollController: scrollController),
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final ScrollController scrollController;

  const _FilterSheet({required this.scrollController});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  final Set<String> _dietary = {};
  final Set<String> _goals = {};
  RangeValues _priceRange = const RangeValues(50, 300);
  double _minRating = 0;
  String _prepTime = 'Any';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filters', style: AppTextStyles.h5),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              children: [
                const SizedBox(height: 16),
                Text('Dietary', style: AppTextStyles.h6),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['Vegetarian', 'Vegan', 'Dairy-Free', 'Gluten-Free']
                      .map(
                        (d) => FilterChip(
                          label: Text(d),
                          selected: _dietary.contains(d),
                          backgroundColor: AppColors.surfaceWarm,
                          selectedColor: AppColors.primarySurface,
                          checkmarkColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: _dietary.contains(d)
                                  ? AppColors.primary
                                  : AppColors.divider,
                            ),
                          ),
                          onSelected: (v) {
                            setState(() {
                              if (v) {
                                _dietary.add(d);
                              } else {
                                _dietary.remove(d);
                              }
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
                Text('Goals', style: AppTextStyles.h6),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['Weight Loss', 'Muscle', 'Energy', 'Sleep']
                      .map(
                        (g) => FilterChip(
                          label: Text(g),
                          selected: _goals.contains(g),
                          backgroundColor: AppColors.surfaceWarm,
                          selectedColor: AppColors.primarySurface,
                          checkmarkColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: _goals.contains(g)
                                  ? AppColors.primary
                                  : AppColors.divider,
                            ),
                          ),
                          onSelected: (v) {
                            setState(() {
                              if (v) {
                                _goals.add(g);
                              } else {
                                _goals.remove(g);
                              }
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
                Text('Price Range', style: AppTextStyles.h6),
                const SizedBox(height: 12),
                RangeSlider(
                  values: _priceRange,
                  min: 50,
                  max: 300,
                  divisions: 25,
                  labels: RangeLabels(
                    'EGP ${_priceRange.start.round()}',
                    'EGP ${_priceRange.end.round()}',
                  ),
                  onChanged: (v) => setState(() => _priceRange = v),
                ),
                const SizedBox(height: 24),
                Text('Minimum Rating', style: AppTextStyles.h6),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [0.0, 3.0, 4.0, 4.5].map((r) {
                    return ChoiceChip(
                      label: Text(r == 0 ? 'Any' : '$r+'),
                      selected: _minRating == r,
                      backgroundColor: AppColors.surfaceWarm,
                      selectedColor: AppColors.primarySurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: _minRating == r
                              ? AppColors.primary
                              : AppColors.divider,
                        ),
                      ),
                      onSelected: (_) => setState(() => _minRating = r),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Text('Prep Time', style: AppTextStyles.h6),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: ['Any', '<10 min', '<20 min'].map((t) {
                    return ChoiceChip(
                      label: Text(t),
                      selected: _prepTime == t,
                      backgroundColor: AppColors.surfaceWarm,
                      selectedColor: AppColors.primarySurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: _prepTime == t
                              ? AppColors.primary
                              : AppColors.divider,
                        ),
                      ),
                      onSelected: (_) => setState(() => _prepTime = t),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _dietary.clear();
                      _goals.clear();
                      _priceRange = const RangeValues(50, 300);
                      _minRating = 0;
                      _prepTime = 'Any';
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Apply filters
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
