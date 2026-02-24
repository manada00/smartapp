import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../widgets/common/loading_widget.dart';

class OrderTrackingScreen extends ConsumerWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return orderAsync.when(
      data: (order) => _OrderTrackingContent(order: order),
      loading: () => const Scaffold(body: LoadingWidget()),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _OrderTrackingContent extends StatelessWidget {
  final OrderModel order;

  const _OrderTrackingContent({required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Track Your Order'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (order.hasDriver) _MapSection(order: order),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order.orderNumber}',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 12),
                  _StatusCard(order: order),
                  if (order.status == OrderStatus.confirmed) ...[
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => context.go(Routes.home),
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: const Text('Continue Shopping'),
                    ),
                  ],
                  const SizedBox(height: 24),
                  _TimelineSection(timeline: order.timeline),
                  if (order.hasDriver) ...[
                    const SizedBox(height: 24),
                    _DriverCard(driver: order.driver!),
                  ],
                  if (order.paymentMethod == PaymentMethod.cod) ...[
                    const SizedBox(height: 24),
                    _CodReminder(amount: order.amountDue),
                  ],
                  const SizedBox(height: 24),
                  _OrderDetails(order: order),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapSection extends StatelessWidget {
  final OrderModel order;

  const _MapSection({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: AppColors.surfaceWarm,
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.map_rounded, size: 48, color: AppColors.textHint),
                const SizedBox(height: 8),
                Text(
                  'Map view would appear here',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppColors.cardShadow,
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time_rounded, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Arriving in ${order.estimatedMinutes} min',
                    style: AppTextStyles.labelLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final OrderModel order;

  const _StatusCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              order.status.emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.status.label,
                  style: AppTextStyles.h5,
                ),
                Text(
                  _getStatusMessage(order.status),
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusMessage(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Waiting for restaurant confirmation';
      case OrderStatus.confirmed:
        return 'Your order has been confirmed';
      case OrderStatus.preparing:
        return 'Our chefs are preparing your meal';
      case OrderStatus.readyForPickup:
        return 'Your order is ready for pickup';
      case OrderStatus.outForDelivery:
        return 'Your order is on its way';
      case OrderStatus.delivered:
        return 'Order delivered successfully';
      case OrderStatus.cancelled:
        return 'Order was cancelled';
    }
  }
}

class _TimelineSection extends StatelessWidget {
  final List<OrderTimeline> timeline;

  const _TimelineSection({required this.timeline});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceWarm,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Progress', style: AppTextStyles.h6),
          const SizedBox(height: 16),
          ...timeline.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == timeline.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isLast
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: isLast
                          ? const Icon(Icons.check_rounded, size: 14, color: AppColors.textOnPrimary)
                          : null,
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 40,
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${item.status.emoji} ${item.status.label}',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: isLast
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              _formatTime(item.timestamp),
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.message,
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class _DriverCard extends StatelessWidget {
  final DriverInfo driver;

  const _DriverCard({required this.driver});

  Future<void> _callDriver() async {
    final url = Uri.parse('tel:${driver.phone}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _whatsAppDriver() async {
    final url = Uri.parse('https://wa.me/${driver.phone.replaceAll('+', '')}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.surfaceWarm,
            backgroundImage:
                driver.photo != null ? NetworkImage(driver.photo!) : null,
            child: driver.photo == null
                ? const Icon(Icons.person_rounded, size: 28, color: AppColors.textHint)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(driver.name, style: AppTextStyles.labelLarge),
                Text(
                  'Your delivery partner',
                  style: AppTextStyles.caption,
                ),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: AppColors.ratingStar),
                    const SizedBox(width: 4),
                    Text(
                      '${driver.rating} rating',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _callDriver,
            icon: const Icon(Icons.phone_rounded, color: AppColors.primary),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primarySurface,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _whatsAppDriver,
            icon: const Icon(Icons.chat_rounded, color: AppColors.success),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.success.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}

class _CodReminder extends StatelessWidget {
  final double amount;

  const _CodReminder({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Text('💵', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cash on Delivery',
                  style: AppTextStyles.labelMedium,
                ),
                Text(
                  'Please prepare EGP ${amount.toStringAsFixed(0)}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderDetails extends StatelessWidget {
  final OrderModel order;

  const _OrderDetails({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: ExpansionTile(
        title: Text('Order Details', style: AppTextStyles.labelLarge),
        tilePadding: const EdgeInsets.symmetric(horizontal: 20),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        children: [
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${item.quantity}x ${item.foodName}'),
                    Text('EGP ${item.totalPrice.toStringAsFixed(0)}'),
                  ],
                ),
              )),
          Divider(height: 24, color: AppColors.divider),
          _DetailRow('Subtotal', 'EGP ${order.subtotal.toStringAsFixed(0)}'),
          _DetailRow('Delivery Fee', 'EGP ${order.deliveryFee.toStringAsFixed(0)}'),
          if (order.discount > 0)
            _DetailRow('Discount', '-EGP ${order.discount.toStringAsFixed(0)}',
                isDiscount: true),
          Divider(height: 24, color: AppColors.divider),
          _DetailRow('Total', 'EGP ${order.total.toStringAsFixed(0)}', isBold: true),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final bool isDiscount;

  const _DetailRow(
    this.label,
    this.value, {
    this.isBold = false,
    this.isDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold ? AppTextStyles.labelMedium : AppTextStyles.bodySmall,
          ),
          Text(
            value,
            style: (isBold ? AppTextStyles.priceMedium : AppTextStyles.bodySmall)
                .copyWith(color: isDiscount ? AppColors.success : null),
          ),
        ],
      ),
    );
  }
}
