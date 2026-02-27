import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/l10n_extensions.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../providers/cart_provider.dart';
import '../../providers/support_provider.dart';

class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith(Routes.home)) return 0;
    if (location.startsWith(Routes.guided)) return 0;
    if (location.startsWith(Routes.categories)) return 1;
    if (location.startsWith(Routes.orders)) return 2;
    if (location.startsWith(Routes.subscriptions)) return 3;
    if (location.startsWith(Routes.profile)) return 4;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(Routes.home);
      case 1:
        context.go(Routes.categories);
      case 2:
        context.go(Routes.orders);
      case 3:
        context.go(Routes.subscriptions);
      case 4:
        context.go(Routes.profile);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItemCount = ref.watch(cartItemCountProvider);
    final supportUnreadCount = ref.watch(
      supportInboxProvider.select((state) => state.unreadCount),
    );
    final selectedIndex = _getSelectedIndex(context);
    final activeColor = _activeMoodColor(selectedIndex);

    return Scaffold(
      body: child,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.45),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF383838).withValues(alpha: 0.14),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.25),
                    blurRadius: 1,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _DockItem(
                      icon: Icons.home_rounded,
                      label: context.l10n.tr('home'),
                      selected: selectedIndex == 0,
                      activeColor: activeColor,
                      onTap: () => _onItemTapped(context, 0),
                    ),
                  ),
                  Expanded(
                    child: _DockItem(
                      icon: Icons.grid_view_rounded,
                      label: context.l10n.tr('categories'),
                      selected: selectedIndex == 1,
                      activeColor: activeColor,
                      onTap: () => _onItemTapped(context, 1),
                    ),
                  ),
                  Expanded(
                    child: _DockItem(
                      icon: Icons.receipt_long_rounded,
                      label: context.l10n.tr('orders'),
                      selected: selectedIndex == 2,
                      activeColor: activeColor,
                      badge: cartItemCount > 0 ? '$cartItemCount' : null,
                      onTap: () => _onItemTapped(context, 2),
                    ),
                  ),
                  Expanded(
                    child: _DockItem(
                      icon: Icons.calendar_month_rounded,
                      label: context.l10n.tr('plans'),
                      selected: selectedIndex == 3,
                      activeColor: activeColor,
                      onTap: () => _onItemTapped(context, 3),
                    ),
                  ),
                  Expanded(
                    child: _DockItem(
                      icon: Icons.person_rounded,
                      label: context.l10n.tr('profile'),
                      selected: selectedIndex == 4,
                      activeColor: activeColor,
                      badge: supportUnreadCount > 0
                          ? '$supportUnreadCount'
                          : null,
                      onTap: () => _onItemTapped(context, 4),
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

  Color _activeMoodColor(int index) {
    switch (index) {
      case 0:
        return AppColors.primary;
      case 1:
        return AppColors.focusColor;
      case 2:
        return AppColors.calmColor;
      case 3:
        return AppColors.sleepColor;
      case 4:
        return AppColors.secondaryDark;
      default:
        return AppColors.primary;
    }
  }
}

class _DockItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color activeColor;
  final String? badge;
  final VoidCallback onTap;

  const _DockItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.activeColor,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.textHint.withValues(alpha: 0.85);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: EdgeInsets.symmetric(
          horizontal: selected ? 10 : 6,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected
              ? activeColor.withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.22),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: selected ? 26 : 24,
                  color: selected ? activeColor : muted,
                ),
                if (badge != null)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badge!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.only(left: selected ? 6 : 4),
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? activeColor : muted.withValues(alpha: 0.72),
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: selected ? 12 : 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
