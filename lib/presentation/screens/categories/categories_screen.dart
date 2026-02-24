import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/l10n_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../providers/food_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/app_text_field.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(context.l10n.categories)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: SearchTextField(
              hint: context.l10n.searchForMeals,
              onChanged: (query) {
                // TODO: Implement search
              },
            ),
          ),
          Expanded(
            child: categoriesAsync.when(
              data: (categories) => GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
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
              ),
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
