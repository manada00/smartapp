import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import 'app_button.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.surfaceWarm,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 56,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              title,
              style: AppTextStyles.h5,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 10),
              Text(
                subtitle!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 28),
              AppButton(
                text: actionText!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }

  factory EmptyStateWidget.cart({VoidCallback? onBrowse}) {
    return EmptyStateWidget(
      icon: Icons.shopping_bag_outlined,
      title: 'Your cart is empty',
      subtitle: 'Find something delicious to nourish your day',
      actionText: 'Browse Menu',
      onAction: onBrowse,
    );
  }

  factory EmptyStateWidget.orders({VoidCallback? onBrowse}) {
    return EmptyStateWidget(
      icon: Icons.receipt_long_outlined,
      title: 'No orders yet',
      subtitle: 'Your order history will appear here',
      actionText: 'Start Ordering',
      onAction: onBrowse,
    );
  }

  factory EmptyStateWidget.search() {
    return const EmptyStateWidget(
      icon: Icons.search_off_rounded,
      title: 'No results found',
      subtitle: 'Try a different search term',
    );
  }

  factory EmptyStateWidget.error({
    String? message,
    VoidCallback? onRetry,
  }) {
    return EmptyStateWidget(
      icon: Icons.cloud_off_rounded,
      title: 'Something went wrong',
      subtitle: message ?? 'Please try again later',
      actionText: 'Retry',
      onAction: onRetry,
    );
  }
}

class ErrorWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const ErrorWidget({
    super.key,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget.error(
      message: message,
      onRetry: onRetry,
    );
  }
}
