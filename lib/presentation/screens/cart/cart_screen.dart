import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../providers/cart_provider.dart';
import '../../providers/address_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/empty_state_widget.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _promoController = TextEditingController();
  bool _isApplyingPromo = false;

  Future<void> _applyPromo() async {
    if (_promoController.text.isEmpty) return;

    setState(() => _isApplyingPromo = true);
    
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock promo code application
    ref.read(cartProvider.notifier).applyPromoCode(
      _promoController.text,
      50.0,
      'You saved EGP 50!',
    );
    
    setState(() => _isApplyingPromo = false);
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final deliveryFee = ref.watch(deliveryFeeProvider);
    final total = ref.watch(cartTotalProvider);
    final selectedAddress = ref.watch(selectedAddressProvider);

    if (cart.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Your Cart')),
        body: EmptyStateWidget.cart(
          onBrowse: () => context.go(Routes.home),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Your Cart (${cart.itemCount})'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                ...cart.items.map((item) => _CartItemCard(
                      item: item,
                      onQuantityChanged: (qty) {
                        ref.read(cartProvider.notifier).updateQuantity(
                              item.id,
                              qty,
                            );
                      },
                      onRemove: () {
                        ref.read(cartProvider.notifier).removeItem(item.id);
                      },
                    )),
                const SizedBox(height: 24),
                _PromoCodeSection(
                  controller: _promoController,
                  isApplying: _isApplyingPromo,
                  appliedCode: cart.promoCode,
                  appliedMessage: cart.promoMessage,
                  onApply: _applyPromo,
                  onRemove: () {
                    ref.read(cartProvider.notifier).removePromoCode();
                    _promoController.clear();
                  },
                ),
                const SizedBox(height: 24),
                _OrderSummary(
                  subtotal: cart.subtotal,
                  deliveryFee: deliveryFee,
                  discount: cart.discount,
                  total: total,
                ),
                const SizedBox(height: 24),
                _DeliveryPreview(
                  address: selectedAddress,
                  onChangeAddress: () => context.push(Routes.manageAddresses),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: AppColors.cardShadow,
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Total', style: AppTextStyles.caption),
                      Text(
                        'EGP ${total.toStringAsFixed(0)}',
                        style: AppTextStyles.priceLarge,
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: AppButton(
                      text: 'Proceed to Checkout',
                      onPressed: () => context.push(Routes.checkout),
                      gradient: AppColors.primaryGradient,
                      icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.textOnPrimary),
                    ),
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

class _CartItemCard extends StatelessWidget {
  final dynamic item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: item.foodImage,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.foodName,
                        style: AppTextStyles.labelLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: AppColors.error),
                      onPressed: onRemove,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                if (item.portionName != null)
                  Text(
                    item.portionName!,
                    style: AppTextStyles.caption,
                  ),
                if (item.customizationsSummary.isNotEmpty)
                  Text(
                    item.customizationsSummary,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (item.specialInstructions != null)
                  Text(
                    '"${item.specialInstructions}"',
                    style: AppTextStyles.caption.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _QuantityButton(
                          icon: Icons.remove_rounded,
                          onPressed: () => onQuantityChanged(item.quantity - 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '${item.quantity}',
                            style: AppTextStyles.labelLarge,
                          ),
                        ),
                        _QuantityButton(
                          icon: Icons.add_rounded,
                          onPressed: () => onQuantityChanged(item.quantity + 1),
                        ),
                      ],
                    ),
                    Text(
                      'EGP ${item.totalPrice.toStringAsFixed(0)}',
                      style: AppTextStyles.priceMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _QuantityButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.surfaceWarm,
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}

class _PromoCodeSection extends StatelessWidget {
  final TextEditingController controller;
  final bool isApplying;
  final String? appliedCode;
  final String? appliedMessage;
  final VoidCallback onApply;
  final VoidCallback onRemove;

  const _PromoCodeSection({
    required this.controller,
    required this.isApplying,
    this.appliedCode,
    this.appliedMessage,
    required this.onApply,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (appliedCode != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.success),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$appliedCode applied',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                  if (appliedMessage != null)
                    Text(
                      appliedMessage!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                ],
              ),
            ),
            TextButton(
              onPressed: onRemove,
              child: const Text('Remove'),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter promo code',
              fillColor: AppColors.surfaceWarm,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: isApplying ? null : onApply,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
          child: isApplying
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textOnPrimary),
                )
              : const Text('Apply'),
        ),
      ],
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;

  const _OrderSummary({
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceWarm,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _SummaryRow(label: 'Subtotal', value: 'EGP ${subtotal.toStringAsFixed(0)}'),
          _SummaryRow(label: 'Delivery Fee', value: 'EGP ${deliveryFee.toStringAsFixed(0)}'),
          if (discount > 0)
            _SummaryRow(
              label: 'Discount',
              value: '-EGP ${discount.toStringAsFixed(0)}',
              valueColor: AppColors.success,
            ),
          Divider(height: 24, color: AppColors.divider),
          _SummaryRow(
            label: 'Total',
            value: 'EGP ${total.toStringAsFixed(0)}',
            isBold: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
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
            style: isBold ? AppTextStyles.labelLarge : AppTextStyles.bodyMedium,
          ),
          Text(
            value,
            style: (isBold ? AppTextStyles.priceMedium : AppTextStyles.bodyMedium)
                .copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}

class _DeliveryPreview extends StatelessWidget {
  final dynamic address;
  final VoidCallback onChangeAddress;

  const _DeliveryPreview({
    this.address,
    required this.onChangeAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on_rounded,
                      size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    address?.label.label ?? 'No address selected',
                    style: AppTextStyles.labelMedium,
                  ),
                ],
              ),
              TextButton(
                onPressed: onChangeAddress,
                child: const Text('Change'),
              ),
            ],
          ),
          if (address != null)
            Text(
              address.shortAddress,
              style: AppTextStyles.bodySmall,
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 20, color: AppColors.textHint),
              const SizedBox(width: 8),
              Text(
                'Estimated: 30-45 min',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
