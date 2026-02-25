import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../providers/support_provider.dart';

class SupportNotificationListener extends ConsumerStatefulWidget {
  final Widget child;

  const SupportNotificationListener({super.key, required this.child});

  @override
  ConsumerState<SupportNotificationListener> createState() => _SupportNotificationListenerState();
}

class _SupportNotificationListenerState extends ConsumerState<SupportNotificationListener> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(supportInboxProvider.notifier).startPolling();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SupportInboxState>(supportInboxProvider, (previous, next) {
      final preview = next.latestUnreadPreview;
      if (preview == null || !mounted) return;

      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) return;

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.surface,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('New message from support', style: AppTextStyles.labelLarge),
                const SizedBox(height: 2),
                Text(preview.subject, style: AppTextStyles.bodySmall),
              ],
            ),
            action: SnackBarAction(
              label: 'View',
              textColor: AppColors.primary,
              onPressed: () {
                context.push(Routes.contactSupport);
                ref.read(supportInboxProvider.notifier).markAllSeen();
              },
            ),
            duration: const Duration(seconds: 6),
          ),
        );
    });

    return widget.child;
  }
}
