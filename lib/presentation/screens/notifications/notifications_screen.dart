import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../widgets/common/empty_state_widget.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      type: NotificationType.order,
      title: 'Order Delivered',
      message: 'Your order #SF-2024-001234 has been delivered. Enjoy your meal!',
      time: DateTime.now().subtract(const Duration(minutes: 15)),
      isRead: false,
      deepLink: '/orders/1',
    ),
    NotificationItem(
      id: '2',
      type: NotificationType.promo,
      title: '20% Off This Weekend!',
      message: 'Use code WEEKEND20 for 20% off all orders. Valid until Sunday.',
      time: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    NotificationItem(
      id: '3',
      type: NotificationType.order,
      title: 'Order Confirmed',
      message: 'Your order #SF-2024-001233 has been confirmed and is being prepared.',
      time: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: true,
      deepLink: '/orders/2',
    ),
    NotificationItem(
      id: '4',
      type: NotificationType.reward,
      title: 'You Earned 50 Points!',
      message: 'Congratulations! You earned 50 points from your last order.',
      time: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    NotificationItem(
      id: '5',
      type: NotificationType.subscription,
      title: 'Tomorrow\'s Delivery',
      message: 'Your subscription meal will be delivered tomorrow between 12-2 PM.',
      time: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
  ];

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification.isRead = true;
      }
    });
  }

  void _markAsRead(String id) {
    setState(() {
      final notification = _notifications.firstWhere((n) => n.id == id);
      notification.isRead = true;
    });
  }

  void _deleteNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = _notifications.any((n) => !n.isRead);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Mark all as read'),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.notifications_off_rounded,
              title: 'No notifications yet',
              subtitle: 'You\'ll see your notifications here',
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return Dismissible(
                  key: Key(notification.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => _deleteNotification(notification.id),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    color: AppColors.error,
                    child: const Icon(Icons.delete_rounded, color: AppColors.textOnPrimary),
                  ),
                  child: _NotificationTile(
                    notification: notification,
                    formattedTime: _formatTime(notification.time),
                    onTap: () {
                      _markAsRead(notification.id);
                      if (notification.deepLink != null) {
                        // Navigate to deep link
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}

class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime time;
  bool isRead;
  final String? deepLink;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.time,
    this.isRead = false,
    this.deepLink,
  });
}

enum NotificationType {
  order,
  promo,
  reward,
  subscription,
  general,
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem notification;
  final String formattedTime;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.formattedTime,
    required this.onTap,
  });

  IconData get _icon {
    switch (notification.type) {
      case NotificationType.order:
        return Icons.receipt_long_rounded;
      case NotificationType.promo:
        return Icons.local_offer_rounded;
      case NotificationType.reward:
        return Icons.stars_rounded;
      case NotificationType.subscription:
        return Icons.calendar_today_rounded;
      case NotificationType.general:
        return Icons.notifications_rounded;
    }
  }

  Color get _iconColor {
    switch (notification.type) {
      case NotificationType.order:
        return AppColors.primary;
      case NotificationType.promo:
        return AppColors.secondary;
      case NotificationType.reward:
        return AppColors.tierGold;
      case NotificationType.subscription:
        return AppColors.info;
      case NotificationType.general:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: notification.isRead ? null : AppColors.surfaceWarm,
          border: Border(
            bottom: BorderSide(color: AppColors.divider),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, color: _iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: notification.isRead
                              ? AppTextStyles.labelMedium
                              : AppTextStyles.labelLarge,
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: AppTextStyles.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedTime,
                    style: AppTextStyles.caption,
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
