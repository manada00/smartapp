import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _orderUpdates = true;
  bool _promotions = true;
  bool _newMenuItems = false;
  bool _subscriptionReminders = true;
  bool _weeklySummary = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Choose which notifications you want to receive',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          _SettingTile(
            icon: Icons.local_shipping_rounded,
            title: 'Order Updates',
            subtitle: 'Status changes, delivery updates, and driver location',
            value: _orderUpdates,
            onChanged: (v) => setState(() => _orderUpdates = v),
          ),
          _SettingTile(
            icon: Icons.local_offer_rounded,
            title: 'Promotions',
            subtitle: 'Discounts, special offers, and promo codes',
            value: _promotions,
            onChanged: (v) => setState(() => _promotions = v),
          ),
          _SettingTile(
            icon: Icons.restaurant_menu_rounded,
            title: 'New Menu Items',
            subtitle: 'Be the first to know about new dishes',
            value: _newMenuItems,
            onChanged: (v) => setState(() => _newMenuItems = v),
          ),
          _SettingTile(
            icon: Icons.calendar_today_rounded,
            title: 'Subscription Reminders',
            subtitle: 'Upcoming deliveries and billing reminders',
            value: _subscriptionReminders,
            onChanged: (v) => setState(() => _subscriptionReminders = v),
          ),
          _SettingTile(
            icon: Icons.summarize_rounded,
            title: 'Weekly Summary',
            subtitle: 'Your nutrition summary and recommendations',
            value: _weeklySummary,
            onChanged: (v) => setState(() => _weeklySummary = v),
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelLarge),
                Text(
                  subtitle,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
