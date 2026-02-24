import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state_widget.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Orders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Past'),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          indicatorColor: AppColors.primary,
        ),
      ),
      body: ordersAsync.when(
        data: (orders) {
          final activeOrders = orders.where((o) => o.isActive).toList();
          final pastOrders = orders.where((o) => !o.isActive).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _OrdersList(
                orders: activeOrders,
                emptyMessage: 'No active orders',
                isActive: true,
              ),
              _OrdersList(
                orders: pastOrders,
                emptyMessage: 'No past orders',
                isActive: false,
              ),
            ],
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, _) => EmptyStateWidget.error(
          message: e.toString(),
          onRetry: () => ref.refresh(ordersProvider),
        ),
      ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  final List<OrderModel> orders;
  final String emptyMessage;
  final bool isActive;

  const _OrdersList({
    required this.orders,
    required this.emptyMessage,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.receipt_long_rounded,
        title: emptyMessage,
        subtitle: isActive
            ? 'Your active orders will appear here'
            : 'Your order history will appear here',
        actionText: 'Browse Menu',
        onAction: () => context.go(Routes.home),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _OrderCard(
          order: order,
          isActive: isActive,
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final bool isActive;

  const _OrderCard({
    required this.order,
    required this.isActive,
  });

  Color get _statusColor {
    switch (order.status) {
      case OrderStatus.pending:
        return AppColors.orderPending;
      case OrderStatus.confirmed:
        return AppColors.orderConfirmed;
      case OrderStatus.preparing:
        return AppColors.orderPreparing;
      case OrderStatus.readyForPickup:
        return AppColors.orderConfirmed;
      case OrderStatus.outForDelivery:
        return AppColors.orderOutForDelivery;
      case OrderStatus.delivered:
        return AppColors.orderDelivered;
      case OrderStatus.cancelled:
        return AppColors.orderCancelled;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order.orderNumber,
                      style: AppTextStyles.labelLarge,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${order.status.emoji} ${order.status.label}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: _statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  order.items.map((i) => '${i.quantity}x ${i.foodName}').join(', '),
                  style: AppTextStyles.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'EGP ${order.total.toStringAsFixed(0)}',
                      style: AppTextStyles.priceMedium,
                    ),
                    if (isActive)
                      Text(
                        'ETA: ${order.estimatedMinutes} min',
                        style: AppTextStyles.caption,
                      ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.divider),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (isActive) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          context.push('${Routes.orderTracking}/${order.id}'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Track Order'),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Reorder functionality
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Reorder'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // View details
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Details'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
