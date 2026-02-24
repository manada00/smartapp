import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/l10n_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const _ProfileHeader(),
            const SizedBox(height: 24),
            _MenuSection(
              title: context.l10n.tr('account'),
              items: [
                _MenuItem(
                  icon: Icons.person_outline_rounded,
                  label: context.l10n.tr('editProfile'),
                  onTap: () => context.push(Routes.editProfile),
                ),
                _MenuItem(
                  icon: Icons.flag_rounded,
                  label: context.l10n.tr('healthGoals'),
                  onTap: () => context.push(Routes.healthGoals),
                ),
                _MenuItem(
                  icon: Icons.restaurant_rounded,
                  label: context.l10n.tr('dietaryPreferences'),
                  onTap: () => context.push(Routes.dietaryPreferences),
                ),
                _MenuItem(
                  icon: Icons.schedule_rounded,
                  label: context.l10n.tr('dailyRoutine'),
                  onTap: () => context.push(Routes.dailyRoutine),
                ),
              ],
            ),
            _MenuSection(
              title: context.l10n.tr('orders'),
              items: [
                _MenuItem(
                  icon: Icons.receipt_long_rounded,
                  label: context.l10n.tr('orderHistory'),
                  onTap: () => context.go(Routes.orders),
                ),
              ],
            ),
            _MenuSection(
              title: context.l10n.tr('addresses'),
              items: [
                _MenuItem(
                  icon: Icons.location_on_rounded,
                  label: context.l10n.tr('manageAddresses'),
                  onTap: () => context.push(Routes.manageAddresses),
                ),
              ],
            ),
            _MenuSection(
              title: context.l10n.tr('payments'),
              items: [
                _MenuItem(
                  icon: Icons.credit_card_rounded,
                  label: context.l10n.tr('paymentMethods'),
                  onTap: () => context.push(Routes.paymentMethods),
                ),
                _MenuItem(
                  icon: Icons.account_balance_wallet_rounded,
                  label: context.l10n.tr('myWallet'),
                  onTap: () => context.push(Routes.wallet),
                ),
              ],
            ),
            _MenuSection(
              title: context.l10n.tr('rewards'),
              items: [
                _MenuItem(
                  icon: Icons.stars_rounded,
                  label: context.l10n.tr('myPointsRewards'),
                  onTap: () => context.push(Routes.rewards),
                ),
                _MenuItem(
                  icon: Icons.card_giftcard_rounded,
                  label: context.l10n.tr('referFriend'),
                  onTap: () => context.push(Routes.referFriend),
                ),
              ],
            ),
            _MenuSection(
              title: context.l10n.tr('settings'),
              items: [
                _MenuItem(
                  icon: Icons.notifications_rounded,
                  label: context.l10n.tr('notifications'),
                  onTap: () => context.push(Routes.notificationSettings),
                ),
                _MenuItem(
                  icon: Icons.dark_mode_rounded,
                  label: context.l10n.tr('appTheme'),
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.language_rounded,
                  label: context.l10n.tr('language'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        locale.languageCode == 'ar'
                            ? context.l10n.tr('arabic')
                            : context.l10n.tr('english'),
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textHint,
                      ),
                    ],
                  ),
                  onTap: () => _showLanguageSheet(context, ref, locale),
                ),
              ],
            ),
            _MenuSection(
              title: context.l10n.tr('support'),
              items: [
                _MenuItem(
                  icon: Icons.help_rounded,
                  label: context.l10n.tr('helpCenter'),
                  onTap: () => context.push(Routes.helpCenter),
                ),
                _MenuItem(
                  icon: Icons.chat_rounded,
                  label: context.l10n.tr('contactUs'),
                  onTap: () => context.push(Routes.contactSupport),
                ),
                _MenuItem(
                  icon: Icons.report_rounded,
                  label: context.l10n.tr('reportIssue'),
                  onTap: () => context.push(Routes.contactSupport),
                ),
              ],
            ),
            _MenuSection(
              title: context.l10n.tr('legal'),
              items: [
                _MenuItem(
                  icon: Icons.description_rounded,
                  label: context.l10n.tr('termsOfService'),
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.privacy_tip_rounded,
                  label: context.l10n.tr('privacyPolicy'),
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.info_rounded,
                  label: context.l10n.tr('about'),
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                await ref.read(authStateProvider.notifier).logout();
                if (context.mounted) {
                  context.go(Routes.phoneLogin);
                }
              },
              child: Text(
                context.l10n.tr('logOut'),
                style: AppTextStyles.buttonMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '${context.l10n.tr('version')} 1.0.0',
                style: AppTextStyles.caption,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSheet(BuildContext context, WidgetRef ref, Locale current) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        final languageNotifier = ref.read(localeProvider.notifier);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Text(context.l10n.tr('selectLanguage'), style: AppTextStyles.h6),
              const SizedBox(height: 8),
              ListTile(
                title: Text(context.l10n.tr('english')),
                trailing: current.languageCode == 'en'
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () async {
                  await languageNotifier.setLocale(const Locale('en'));
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
              ),
              ListTile(
                title: Text(context.l10n.tr('arabic')),
                trailing: current.languageCode == 'ar'
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () async {
                  await languageNotifier.setLocale(const Locale('ar'));
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.surfaceWarm,
            child: const Icon(
              Icons.person_rounded,
              size: 36,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.tr('userName'), style: AppTextStyles.h5),
                Text('+20 10X XXX XXXX', style: AppTextStyles.bodySmall),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.tierGold, Color(0xFFFFD54F)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🥇', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        context.l10n.tr('goldPoints'),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  item,
                  if (index < items.length - 1)
                    Divider(height: 1, indent: 56, color: AppColors.divider),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(label, style: AppTextStyles.bodyMedium),
      trailing:
          trailing ??
          const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
