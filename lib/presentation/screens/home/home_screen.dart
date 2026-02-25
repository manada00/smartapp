import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/l10n_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/food_model.dart';
import '../../providers/food_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/address_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/food/food_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return context.l10n.goodMorning;
    if (hour >= 12 && hour < 17) return context.l10n.goodAfternoon;
    if (hour >= 17 && hour < 21) return context.l10n.goodEvening;
    return context.l10n.sweetDreams;
  }

  String _getSubGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return context.l10n.startYourDayRight;
    if (hour >= 12 && hour < 17) return context.l10n.timeToRecharge;
    if (hour >= 17 && hour < 21) {
      return context.l10n.windDownWithSomethingGood;
    }
    return context.l10n.lightBiteBeforeBed;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final popularFoodsAsync = ref.watch(popularFoodsProvider);
    final allFoodsAsync = ref.watch(foodsProvider(null));
    final homeConfigAsync = ref.watch(homeConfigProvider);
    final selectedAddress = ref.watch(selectedAddressProvider);
    final cartItemCount = ref.watch(cartItemCountProvider);

    final homeConfig = homeConfigAsync.valueOrNull;
    final heroTitle = (homeConfig?.heroTitle ?? '').trim().isNotEmpty
        ? homeConfig!.heroTitle
        : context.l10n.homeHeroTitle;
    final heroSubtitle = (homeConfig?.heroSubtitle ?? '').trim().isNotEmpty
        ? homeConfig!.heroSubtitle
        : context.l10n.homeHeroSubtitle;
    final activePromotions = homeConfig?.promotions ?? const <HomePromotion>[];

    final curatedPopularFoods = _resolvePopularFoods(
      config: homeConfig,
      allFoods: allFoodsAsync.valueOrNull,
      fallbackPopularFoods: popularFoodsAsync.valueOrNull,
    );

    final moodOverrides = {
      for (final mood in homeConfig?.moods ?? const <HomeMood>[])
        _feelingFromApiType(mood.type): mood,
    };

    final visibleFeelings = (homeConfig?.moods ?? const <HomeMood>[])
        .where((mood) => mood.isVisible)
        .map((mood) => _feelingFromApiType(mood.type))
        .whereType<FeelingType>()
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getGreeting(context),
                                style: AppTextStyles.h3,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getSubGreeting(context),
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            _HeaderIconButton(
                              icon: Icons.notifications_none_rounded,
                              onPressed: () =>
                                  context.push(Routes.notifications),
                            ),
                            const SizedBox(width: 8),
                            _HeaderIconButton(
                              icon: Icons.shopping_bag_outlined,
                              badge: cartItemCount > 0
                                  ? '$cartItemCount'
                                  : null,
                              onPressed: () => context.push(Routes.cart),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Delivery address
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => context.push(Routes.manageAddresses),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWarm,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                selectedAddress?.shortAddress ??
                                    context.l10n.setDeliveryAddress,
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 20,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: AppColors.elevatedShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            heroTitle,
                            style: AppTextStyles.h5.copyWith(
                              color: AppColors.textOnPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            heroSubtitle,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textOnPrimary.withValues(
                                alpha: 0.9,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if ((homeConfig?.announcementEnabled ?? false) &&
                        (homeConfig?.announcementMessage.trim().isNotEmpty ??
                            false))
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            homeConfig!.announcementMessage,
                            style: AppTextStyles.labelMedium,
                          ),
                        ),
                      ),

                    if (activePromotions.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: SizedBox(
                          height: 108,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              final promo = activePromotions[index];
                              return _PromotionCard(promotion: promo);
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemCount: activePromotions.length,
                          ),
                        ),
                      ),

                    const SizedBox(height: 30),

                    // Quick Actions
                    _QuickActions(),

                    const SizedBox(height: 24),
                    Text(
                      context.l10n.howDoYouWantToFeel,
                      style: AppTextStyles.h5,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.howDoYouWantToFeelSubtitle,
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    _FeelingGrid(
                      visibleFeelings: visibleFeelings,
                      moodOverrides: moodOverrides,
                    ),

                    const SizedBox(height: 36),

                    _SectionHeader(
                      title: context.l10n.browseByCategory,
                      onSeeAll: () => context.go(Routes.categories),
                    ),
                  ],
                ),
              ),
            ),

            // Categories horizontal list
            SliverToBoxAdapter(
              child: SizedBox(
                height: 130,
                child: categoriesAsync.when(
                  data: (categories) => ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return _CategoryCard(
                        name: category.name.localize(context),
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
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: _SectionHeader(
                  title: context.l10n.popularRightNow,
                  onSeeAll: () => context.push(
                    Routes.recommendations,
                    extra: FeelingType.browseAll,
                  ),
                ),
              ),
            ),

            // Popular foods
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: (curatedPopularFoods != null)
                  ? SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final food = curatedPopularFoods[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: FoodCard(
                        food: food,
                        onTap: () =>
                            context.push('${Routes.foodDetail}/${food.id}'),
                      ),
                    );
                  }, childCount: curatedPopularFoods.length.clamp(0, 3)),
                )
                  : popularFoodsAsync.when(
                data: (foods) => SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final food = foods[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: FoodCard(
                        food: food,
                        onTap: () =>
                            context.push('${Routes.foodDetail}/${food.id}'),
                      ),
                    );
                  }, childCount: foods.length.clamp(0, 3)),
                ),
                loading: () => const SliverToBoxAdapter(child: LoadingWidget()),
                error: (e, _) => SliverToBoxAdapter(
                  child: Center(child: Text('${context.l10n.errorPrefix}: $e')),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

List<FoodModel>? _resolvePopularFoods({
  required HomeConfigModel? config,
  required List<FoodModel>? allFoods,
  required List<FoodModel>? fallbackPopularFoods,
}) {
  final curatedIds = config?.popularFoodIds ?? const <String>[];
  if (curatedIds.isEmpty) {
    return fallbackPopularFoods;
  }
  if (allFoods == null) {
    return null;
  }

  final byId = {for (final food in allFoods) food.id: food};
  return curatedIds
      .map((id) => byId[id])
      .whereType<FoodModel>()
      .toList();
}

FeelingType? _feelingFromApiType(String value) {
  switch (value) {
    case 'need_energy':
      return FeelingType.needEnergy;
    case 'very_hungry':
      return FeelingType.veryHungry;
    case 'something_light':
      return FeelingType.somethingLight;
    case 'trained_today':
      return FeelingType.trainedToday;
    case 'stressed':
      return FeelingType.stressed;
    case 'bloated':
      return FeelingType.bloated;
    case 'help_sleep':
      return FeelingType.helpSleep;
    case 'kid_needs_meal':
      return FeelingType.kidNeedsMeal;
    case 'fasting_tomorrow':
      return FeelingType.fastingTomorrow;
    case 'browse_all':
      return FeelingType.browseAll;
    default:
      return null;
  }
}

class _PromotionCard extends StatelessWidget {
  final HomePromotion promotion;

  const _PromotionCard({required this.promotion});

  @override
  Widget build(BuildContext context) {
    final hasImage = promotion.imageUrl.trim().isNotEmpty;
    return Container(
      width: 240,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.surface,
        image: hasImage
            ? DecorationImage(
                image: NetworkImage(promotion.imageUrl),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.25),
                  BlendMode.darken,
                ),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            promotion.title,
            style: AppTextStyles.labelLarge.copyWith(
              color: hasImage ? Colors.white : AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            promotion.message,
            style: AppTextStyles.caption.copyWith(
              color: hasImage
                  ? Colors.white.withValues(alpha: 0.95)
                  : AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String? badge;
  final VoidCallback onPressed;

  const _HeaderIconButton({
    required this.icon,
    this.badge,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surfaceWarm,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 22, color: AppColors.textPrimary),
            if (badge != null)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      badge!,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _QuickActionChip(
            icon: Icons.replay_rounded,
            label: context.l10n.quickActionReorder,
            onTap: () {},
          ),
          _QuickActionChip(
            icon: Icons.favorite_border_rounded,
            label: context.l10n.quickActionFavorites,
            onTap: () {},
          ),
          _QuickActionChip(
            icon: Icons.auto_awesome_rounded,
            label: context.l10n.quickActionSpecials,
            onTap: () {},
          ),
          _QuickActionChip(
            icon: Icons.calendar_today_rounded,
            label: context.l10n.plans,
            onTap: () => context.go(Routes.subscriptions),
          ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(label, style: AppTextStyles.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}

// Feeling colors mapped to each FeelingType
Color _feelingColor(FeelingType feeling) {
  switch (feeling) {
    case FeelingType.needEnergy:
      return AppColors.energyColor;
    case FeelingType.veryHungry:
      return AppColors.satietyColor;
    case FeelingType.somethingLight:
      return AppColors.digestColor;
    case FeelingType.trainedToday:
      return AppColors.fitnessColor;
    case FeelingType.stressed:
      return AppColors.calmColor;
    case FeelingType.bloated:
      return AppColors.digestColor;
    case FeelingType.helpSleep:
      return AppColors.sleepColor;
    case FeelingType.kidNeedsMeal:
      return AppColors.kidsColor;
    case FeelingType.fastingTomorrow:
      return AppColors.fastingColor;
    case FeelingType.browseAll:
      return AppColors.browseColor;
  }
}

Color _feelingSurface(FeelingType feeling) {
  switch (feeling) {
    case FeelingType.needEnergy:
      return AppColors.energySurface;
    case FeelingType.veryHungry:
      return AppColors.satietySurface;
    case FeelingType.somethingLight:
      return AppColors.digestSurface;
    case FeelingType.trainedToday:
      return AppColors.fitnessSurface;
    case FeelingType.stressed:
      return AppColors.calmSurface;
    case FeelingType.bloated:
      return AppColors.digestSurface;
    case FeelingType.helpSleep:
      return AppColors.sleepSurface;
    case FeelingType.kidNeedsMeal:
      return AppColors.kidsSurface;
    case FeelingType.fastingTomorrow:
      return AppColors.fastingSurface;
    case FeelingType.browseAll:
      return AppColors.browseSurface;
  }
}

class _FeelingGrid extends StatelessWidget {
  final List<FeelingType> visibleFeelings;
  final Map<FeelingType?, HomeMood> moodOverrides;

  const _FeelingGrid({
    required this.visibleFeelings,
    required this.moodOverrides,
  });

  @override
  Widget build(BuildContext context) {
    final feelings = visibleFeelings.isNotEmpty
        ? visibleFeelings
        : FeelingType.values.take(10).toList();
    final recommended = _recommendedFeeling();

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 14.0;
        final cardWidth = (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: feelings.map((feeling) {
            final isRecommended = feeling == recommended;
            return SizedBox(
              width: cardWidth,
              height: 162,
              child: _FeelingCard(
                feeling: feeling,
                isRecommended: isRecommended,
                moodOverride: moodOverrides[feeling],
                onTap: () =>
                    context.push(Routes.recommendations, extra: feeling),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _FeelingCard extends StatefulWidget {
  final FeelingType feeling;
  final bool isRecommended;
  final VoidCallback onTap;
  final HomeMood? moodOverride;

  const _FeelingCard({
    required this.feeling,
    this.isRecommended = false,
    this.moodOverride,
    required this.onTap,
  });

  @override
  State<_FeelingCard> createState() => _FeelingCardState();
}

class _FeelingCardState extends State<_FeelingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isElevated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 180),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.015,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _feelingColor(widget.feeling);
    final surface = _feelingSurface(widget.feeling);
    final title = (widget.moodOverride?.title.trim().isNotEmpty ?? false)
        ? widget.moodOverride!.title
        : _supportiveTitle(context, widget.feeling);
    final subtitle = (widget.moodOverride?.subtitle.trim().isNotEmpty ?? false)
        ? widget.moodOverride!.subtitle
        : _supportiveSubtitle(context, widget.feeling);
    final trustLine = _trustLine(context, widget.feeling);
    final isActive = _isElevated;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isElevated = true);
        _controller.forward();
      },
      onTapUp: (_) async {
        setState(() => _isElevated = false);
        _controller.reverse();
        await Future.delayed(const Duration(milliseconds: 120));
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isElevated = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          alignment: Alignment.center,
          child: child,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.25, -0.35),
              radius: 1.05,
              colors: [
                color.withValues(alpha: isActive ? 0.36 : 0.29),
                surface,
              ],
              stops: const [0.0, 1.0],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: color.withValues(alpha: isActive ? 0.42 : 0.22),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.55),
                blurRadius: 1,
                offset: const Offset(0, -1),
              ),
              BoxShadow(
                color: color.withValues(alpha: isActive ? 0.30 : 0.16),
                blurRadius: isActive ? 24 : 14,
                offset: Offset(0, isActive ? 12 : 6),
              ),
              BoxShadow(
                color: AppColors.textPrimary.withValues(alpha: 0.08),
                blurRadius: isActive ? 20 : 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 22,
                child: widget.isRecommended
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          context.l10n.recommendedNow,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 6),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.30),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.22),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    (widget.moodOverride?.emoji.trim().isNotEmpty ?? false)
                        ? widget.moodOverride!.emoji
                        : _feelingIcon(widget.feeling),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                trustLine,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textPrimary.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

FeelingType _recommendedFeeling() {
  final hour = DateTime.now().hour;
  if (hour >= 5 && hour < 11) return FeelingType.needEnergy;
  if (hour >= 11 && hour < 16) return FeelingType.somethingLight;
  if (hour >= 16 && hour < 21) return FeelingType.veryHungry;
  return FeelingType.helpSleep;
}

String _feelingIcon(FeelingType feeling) {
  switch (feeling) {
    case FeelingType.needEnergy:
      return '⚡';
    case FeelingType.veryHungry:
      return '🍽️';
    case FeelingType.somethingLight:
      return '🥗';
    case FeelingType.trainedToday:
      return '💪';
    case FeelingType.stressed:
      return '🫶';
    case FeelingType.bloated:
      return '🌿';
    case FeelingType.helpSleep:
      return '🌙';
    case FeelingType.kidNeedsMeal:
      return '🧒';
    case FeelingType.fastingTomorrow:
      return '✨';
    case FeelingType.browseAll:
      return '🧭';
  }
}

String _supportiveTitle(BuildContext context, FeelingType feeling) {
  switch (feeling) {
    case FeelingType.needEnergy:
      return context.l10n.boostMyEnergy;
    case FeelingType.veryHungry:
      return context.l10n.needSomethingFilling;
    case FeelingType.somethingLight:
      return context.l10n.keepItLight;
    case FeelingType.trainedToday:
      return context.l10n.refuelAfterTraining;
    case FeelingType.stressed:
      return context.l10n.helpMeFeelCalm;
    case FeelingType.bloated:
      return context.l10n.easeHeaviness;
    case FeelingType.helpSleep:
      return context.l10n.helpMeWindDown;
    case FeelingType.kidNeedsMeal:
      return context.l10n.pickForMyKid;
    case FeelingType.fastingTomorrow:
      return context.l10n.prepForFast;
    case FeelingType.browseAll:
      return context.l10n.showMeGoodOptions;
  }
}

String _supportiveSubtitle(BuildContext context, FeelingType feeling) {
  switch (feeling) {
    case FeelingType.needEnergy:
      return context.l10n.staySharp;
    case FeelingType.veryHungry:
      return context.l10n.balancedMealsSatisfy;
    case FeelingType.somethingLight:
      return context.l10n.gentleChoicesEasy;
    case FeelingType.trainedToday:
      return context.l10n.proteinRecovery;
    case FeelingType.stressed:
      return context.l10n.comfortSteadyEnergy;
    case FeelingType.bloated:
      return context.l10n.softerOptions;
    case FeelingType.helpSleep:
      return context.l10n.lighterDinners;
    case FeelingType.kidNeedsMeal:
      return context.l10n.kidsEnjoy;
    case FeelingType.fastingTomorrow:
      return context.l10n.preFastMeals;
    case FeelingType.browseAll:
      return context.l10n.exploreByMood;
  }
}

String _trustLine(BuildContext context, FeelingType feeling) {
  switch (feeling) {
    case FeelingType.needEnergy:
      return context.l10n.balancedCarbsProtein;
    case FeelingType.veryHungry:
      return context.l10n.fullnessPortion;
    case FeelingType.somethingLight:
      return context.l10n.lowerHeaviness;
    case FeelingType.trainedToday:
      return context.l10n.recoveryFocused;
    case FeelingType.stressed:
      return context.l10n.steadyMood;
    case FeelingType.bloated:
      return context.l10n.gentlerIngredients;
    case FeelingType.helpSleep:
      return context.l10n.eveningFriendly;
    case FeelingType.kidNeedsMeal:
      return context.l10n.kidApproved;
    case FeelingType.fastingTomorrow:
      return context.l10n.longLastingEnergy;
    case FeelingType.browseAll:
      return context.l10n.exploreAllPaths;
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.h5),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: Text(
              context.l10n.seeAll,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String name;
  final String image;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.name,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 145,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: NetworkImage(image),
              fit: BoxFit.cover,
            ),
            boxShadow: AppColors.cardShadow,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.55),
                ],
              ),
            ),
            padding: const EdgeInsets.all(14),
            alignment: Alignment.bottomLeft,
            child: Text(
              name,
              style: AppTextStyles.labelMedium.copyWith(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
