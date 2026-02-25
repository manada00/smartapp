import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/food_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/l10n_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../providers/food_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/empty_state_widget.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<_SearchSuggestion> _buildSuggestions({
    required BuildContext context,
    required List<CategoryModel> categories,
    required List<FoodModel> foods,
  }) {
    if (_searchQuery.isEmpty) return [];

    final suggestions = <_SearchSuggestion>[];
    final addedCategoryIds = <String>{};
    final addedFoodIds = <String>{};

    for (final category in categories) {
      final categoryName = category.name.toLowerCase();
      final localizedCategoryName = category.name.localize(context).toLowerCase();
      final categoryDescription = category.description.toLowerCase();
      final localizedCategoryDescription = category.description
          .localize(context)
          .toLowerCase();

      final isMatch = categoryName.contains(_searchQuery) ||
          localizedCategoryName.contains(_searchQuery) ||
          categoryDescription.contains(_searchQuery) ||
          localizedCategoryDescription.contains(_searchQuery);

      if (isMatch && addedCategoryIds.add(category.id)) {
        suggestions.add(
          _SearchSuggestion.category(
            id: category.id,
            title: category.name,
            subtitle: context.l10n.categories,
          ),
        );
      }
    }

    for (final food in foods) {
      final foodName = food.name.toLowerCase();
      final localizedFoodName = food.name.localize(context).toLowerCase();
      final foodDescription = food.description.toLowerCase();
      final localizedFoodDescription = food.description.localize(context).toLowerCase();

      final isMatch = foodName.contains(_searchQuery) ||
          localizedFoodName.contains(_searchQuery) ||
          foodDescription.contains(_searchQuery) ||
          localizedFoodDescription.contains(_searchQuery);

      if (isMatch && addedFoodIds.add(food.id)) {
        suggestions.add(
          _SearchSuggestion.food(
            id: food.id,
            title: food.name,
            subtitle: food.categoryName,
          ),
        );
      }
    }

    return suggestions.take(8).toList();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final foodsAsync = ref.watch(foodsProvider(null));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(context.l10n.categories)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                SearchTextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  hint: context.l10n.searchForMeals,
                  onChanged: (query) {
                    setState(() => _searchQuery = query.trim().toLowerCase());
                  },
                ),
                if (_searchQuery.isNotEmpty)
                  categoriesAsync.when(
                    data: (categories) {
                      final foods = foodsAsync.valueOrNull ?? <FoodModel>[];
                      final suggestions = _buildSuggestions(
                        context: context,
                        categories: categories,
                        foods: foods,
                      );

                      if (suggestions.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Container(
                        margin: const EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Column(
                          children: suggestions.map((suggestion) {
                            return ListTile(
                              dense: true,
                              leading: Icon(
                                suggestion.type == _SearchSuggestionType.category
                                    ? Icons.category_outlined
                                    : Icons.restaurant_menu_rounded,
                                color: AppColors.primary,
                              ),
                              title: Text(suggestion.title.localize(context)),
                              subtitle: Text(suggestion.subtitle.localize(context)),
                              onTap: () {
                                _searchController.text = suggestion.title;
                                _searchController.selection = TextSelection.fromPosition(
                                  TextPosition(offset: _searchController.text.length),
                                );
                                setState(
                                  () => _searchQuery = suggestion.title.toLowerCase(),
                                );
                                _searchFocusNode.unfocus();

                                if (suggestion.type == _SearchSuggestionType.category) {
                                  context.push(
                                    '${Routes.categoryDetail}/${suggestion.id}',
                                    extra: suggestion.title,
                                  );
                                  return;
                                }

                                context.push('${Routes.foodDetail}/${suggestion.id}');
                              },
                            );
                          }).toList(),
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
              ],
            ),
          ),
          Expanded(
            child: categoriesAsync.when(
              data: (categories) {
                final foods = foodsAsync.valueOrNull ?? <FoodModel>[];
                final matchingCategoryIdsFromFoodNames = foods
                    .where((food) {
                      if (_searchQuery.isEmpty) return false;
                      final foodName = food.name.toLowerCase();
                      final localizedFoodName = food.name.localize(context).toLowerCase();
                      final foodDescription = food.description.toLowerCase();
                      final localizedFoodDescription = food.description
                          .localize(context)
                          .toLowerCase();

                      return foodName.contains(_searchQuery) ||
                          localizedFoodName.contains(_searchQuery) ||
                          foodDescription.contains(_searchQuery) ||
                          localizedFoodDescription.contains(_searchQuery);
                    })
                    .map((food) => food.categoryId)
                    .where((id) => id.isNotEmpty)
                    .toSet();

                final filteredCategories = _searchQuery.isEmpty
                    ? categories
                    : categories.where((category) {
                        final rawName = category.name.toLowerCase();
                        final localizedName = category.name
                            .localize(context)
                            .toLowerCase();
                        final rawDescription = category.description
                            .toLowerCase();
                        final localizedDescription = category.description
                            .localize(context)
                            .toLowerCase();

                        return rawName.contains(_searchQuery) ||
                            localizedName.contains(_searchQuery) ||
                            rawDescription.contains(_searchQuery) ||
                            localizedDescription.contains(_searchQuery) ||
                            matchingCategoryIdsFromFoodNames.contains(category.id);
                      }).toList();

                if (filteredCategories.isEmpty) {
                  return EmptyStateWidget.search();
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                    final category = filteredCategories[index];
                    return _CategoryCard(
                      name: category.name,
                      itemCount: category.itemCount,
                      image: category.image,
                      onTap: () => context.push(
                        '${Routes.categoryDetail}/${category.id}',
                        extra: category.name,
                      ),
                    );
                  },
                );
              },
              loading: () => const LoadingWidget(),
              error: (e, _) =>
                  Center(child: Text('${context.l10n.errorPrefix}: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

enum _SearchSuggestionType { category, food }

class _SearchSuggestion {
  final String id;
  final String title;
  final String subtitle;
  final _SearchSuggestionType type;

  const _SearchSuggestion._({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
  });

  factory _SearchSuggestion.category({
    required String id,
    required String title,
    required String subtitle,
  }) {
    return _SearchSuggestion._(
      id: id,
      title: title,
      subtitle: subtitle,
      type: _SearchSuggestionType.category,
    );
  }

  factory _SearchSuggestion.food({
    required String id,
    required String title,
    required String subtitle,
  }) {
    return _SearchSuggestion._(
      id: id,
      title: title,
      subtitle: subtitle,
      type: _SearchSuggestionType.food,
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String name;
  final int itemCount;
  final String image;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.name,
    required this.itemCount,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.cardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: image,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: AppColors.surfaceWarm),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.surfaceWarm,
                child: const Icon(
                  Icons.error_rounded,
                  color: AppColors.textHint,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.localize(context),
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                  Text(
                    context.l10n.itemsCount(itemCount),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textOnPrimary.withValues(alpha: 0.7),
                    ),
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
