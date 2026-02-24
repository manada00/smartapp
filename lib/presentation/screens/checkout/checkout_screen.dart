import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/order_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/address_provider.dart';
import '../../widgets/common/app_button.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _currentStep = 0;
  bool _isPlacingOrder = false;

  Future<void> _placeOrder() async {
    final checkoutState = ref.read(checkoutStateProvider);
    final address = checkoutState.deliveryAddress;
    if (address == null) return;

    final cart = ref.read(cartProvider);
    if (cart.items.isEmpty) return;

    final repository = ref.read(orderRepositoryProvider);
    setState(() => _isPlacingOrder = true);

    try {
      if (checkoutState.paymentMethod == PaymentMethod.cod) {
        final response = await repository.placeOrder(
          items: cart.items,
          address: address,
          paymentMethod: PaymentMethod.cod,
        );
        await _finishCheckout(response);
        return;
      }

      if (checkoutState.paymentMethod == PaymentMethod.card) {
        final cardDetails = await Navigator.of(context).push<Map<String, String>>(
          MaterialPageRoute(builder: (_) => const _MockCardPaymentScreen()),
        );

        if (cardDetails == null) {
          return;
        }

        var response = await repository.placeOrder(
          items: cart.items,
          address: address,
          paymentMethod: PaymentMethod.card,
          cardDetails: cardDetails,
        );

        if (!mounted) {
          return;
        }

        if (response.paymentStatus == 'failed' && mounted) {
          final shouldRetry = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Payment Failed'),
              content: const Text('Would you like to retry card payment now?'),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Later')),
                FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Retry')),
              ],
            ),
          );

          if (shouldRetry == true) {
            response = await repository.retryCardPayment(
              orderId: response.order.id,
              cardDetails: cardDetails,
            );
          }
        }

        await _finishCheckout(response);
        return;
      }

      if (checkoutState.paymentMethod == PaymentMethod.instaPay) {
        final initialResponse = await repository.placeOrder(
          items: cart.items,
          address: address,
          paymentMethod: PaymentMethod.instaPay,
        );

        if (!mounted) {
          return;
        }

        final resolvedResponse = await Navigator.of(context).push<PaymentSimulationResponse>(
              MaterialPageRoute(
                builder: (_) => _InstaPayTransferScreen(
                  initialResponse: initialResponse,
                  onVerifyTransfer: () => repository.verifyInstapayTransfer(orderId: initialResponse.order.id),
                ),
              ),
            ) ??
            initialResponse;

        await _finishCheckout(resolvedResponse);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Checkout failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isPlacingOrder = false);
      }
    }
  }

  Future<void> _finishCheckout(PaymentSimulationResponse response) async {
    ref.read(cartProvider.notifier).clearCart();
    ref.read(checkoutStateProvider.notifier).reset();
    await ref.read(ordersProvider.notifier).loadOrders();

    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _OrderConfirmationScreen(response: response),
      ),
    );
    if (mounted) {
      context.go('${Routes.orderTracking}/${response.order.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = ref.watch(cartTotalProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Checkout')),
      body: Column(
        children: [
          _StepIndicator(currentStep: _currentStep),
          Expanded(
            child: IndexedStack(
              index: _currentStep,
              children: [
                _DeliveryStep(
                  onContinue: () => setState(() => _currentStep = 1),
                ),
                _PaymentStep(
                  onContinue: () => setState(() => _currentStep = 2),
                  onBack: () => setState(() => _currentStep = 0),
                ),
                _ReviewStep(
                  onEdit: (step) => setState(() => _currentStep = step),
                ),
              ],
            ),
          ),
          if (_currentStep == 2)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: AppColors.cardShadow,
              ),
              child: SafeArea(
                child: AppButton(
                  text: 'Place Order - EGP ${total.toStringAsFixed(0)}',
                  onPressed: _placeOrder,
                  isLoading: _isPlacingOrder,
                  gradient: AppColors.primaryGradient,
                  width: double.infinity,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;

  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _StepDot(
            label: 'Delivery',
            isActive: currentStep >= 0,
            isCompleted: currentStep > 0,
          ),
          Expanded(child: _StepLine(isActive: currentStep > 0)),
          _StepDot(
            label: 'Payment',
            isActive: currentStep >= 1,
            isCompleted: currentStep > 1,
          ),
          Expanded(child: _StepLine(isActive: currentStep > 1)),
          _StepDot(
            label: 'Review',
            isActive: currentStep >= 2,
            isCompleted: false,
          ),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isCompleted;

  const _StepDot({
    required this.label,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(
                    Icons.check_rounded,
                    color: AppColors.textOnPrimary,
                    size: 18,
                  )
                : null,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isActive ? AppColors.primary : AppColors.textHint,
          ),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool isActive;

  const _StepLine({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}

class _DeliveryStep extends ConsumerWidget {
  final VoidCallback onContinue;

  const _DeliveryStep({required this.onContinue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(addressesProvider);
    final checkoutState = ref.watch(checkoutStateProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Delivery Address', style: AppTextStyles.h6),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceWarm,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: addressesAsync.when(
              data: (addresses) => Column(
                children: [
                  ...addresses.map(
                    (address) => RadioListTile(
                      value: address,
                      groupValue: checkoutState.deliveryAddress,
                      onChanged: (v) {
                        ref
                            .read(checkoutStateProvider.notifier)
                            .setDeliveryAddress(v!);
                      },
                      title: Text(address.label.label),
                      subtitle: Text(address.fullAddress),
                      secondary: Text(address.label.emoji),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: OutlinedButton.icon(
                      onPressed: () => context.push(Routes.addAddress),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add New Address'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
          ),
          const SizedBox(height: 32),
          Text('Delivery Time', style: AppTextStyles.h6),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceWarm,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                RadioListTile<bool>(
                  value: true,
                  groupValue: checkoutState.isAsap,
                  onChanged: (v) {
                    ref
                        .read(checkoutStateProvider.notifier)
                        .setDeliveryTime(null);
                  },
                  title: const Text('As soon as possible'),
                  subtitle: const Text('Estimated 30-45 min'),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                RadioListTile<bool>(
                  value: false,
                  groupValue: checkoutState.isAsap,
                  onChanged: (v) {
                    // Show schedule picker
                  },
                  title: const Text('Schedule for later'),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          AppButton(
            text: 'Continue to Payment',
            onPressed: checkoutState.deliveryAddress != null
                ? onContinue
                : null,
            width: double.infinity,
            gradient: checkoutState.deliveryAddress != null
                ? AppColors.primaryGradient
                : null,
            icon: const Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.textOnPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentStep extends ConsumerWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const _PaymentStep({required this.onContinue, required this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkoutState = ref.watch(checkoutStateProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Method', style: AppTextStyles.h6),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceWarm,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: PaymentMethod.values
                  .where((method) =>
                      method == PaymentMethod.cod ||
                      method == PaymentMethod.card ||
                      method == PaymentMethod.instaPay)
                  .map(
                    (method) => RadioListTile<PaymentMethod>(
                      value: method,
                      groupValue: checkoutState.paymentMethod,
                      onChanged: (v) {
                        ref
                            .read(checkoutStateProvider.notifier)
                            .setPaymentMethod(v!);
                      },
                      title: Text('${method.emoji} ${method.label}'),
                      subtitle: _getMethodSubtitle(method),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          if (checkoutState.paymentMethod == PaymentMethod.cod) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Max COD amount: EGP ${AppConstants.maxCodAmount}',
                      style: AppTextStyles.caption,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onBack,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppButton(
                  text: 'Continue to Review',
                  onPressed: onContinue,
                  gradient: AppColors.primaryGradient,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget? _getMethodSubtitle(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cod:
        return const Text('Pay driver when you receive order');
      case PaymentMethod.card:
        return const Text('Visa, Mastercard, Meeza accepted');
      case PaymentMethod.mobileWallet:
      case PaymentMethod.instaPay:
        return const Text('Transfer then verify payment in-app');
      default:
        return null;
    }
  }
}

class _MockCardPaymentScreen extends StatefulWidget {
  const _MockCardPaymentScreen();

  @override
  State<_MockCardPaymentScreen> createState() => _MockCardPaymentScreenState();
}

class _MockCardPaymentScreenState extends State<_MockCardPaymentScreen> {
  final _cardController = TextEditingController(text: '4111111111111111');
  final _expiryController = TextEditingController(text: '12/29');
  final _cvvController = TextEditingController(text: '123');

  @override
  void dispose() {
    _cardController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_cardController.text.trim().length < 12 || _cvvController.text.trim().length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter valid mock card details')));
      return;
    }

    Navigator.of(context).pop({
      'number': _cardController.text.trim(),
      'expiry': _expiryController.text.trim(),
      'cvv': _cvvController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Secure Card Payment')),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text('Mock Payment Gateway', style: AppTextStyles.h5.copyWith(color: AppColors.textOnPrimary)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Column(
                  children: [
                    TextField(controller: _cardController, decoration: const InputDecoration(labelText: 'Card Number')),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(controller: _expiryController, decoration: const InputDecoration(labelText: 'Expiry (MM/YY)')),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(controller: _cvvController, decoration: const InputDecoration(labelText: 'CVV')),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      text: 'Pay Now',
                      onPressed: _submit,
                      gradient: AppColors.primaryGradient,
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InstaPayTransferScreen extends StatefulWidget {
  const _InstaPayTransferScreen({
    required this.initialResponse,
    required this.onVerifyTransfer,
  });

  final PaymentSimulationResponse initialResponse;
  final Future<PaymentSimulationResponse> Function() onVerifyTransfer;

  @override
  State<_InstaPayTransferScreen> createState() => _InstaPayTransferScreenState();
}

class _InstaPayTransferScreenState extends State<_InstaPayTransferScreen> {
  bool _isVerifying = false;
  String? _status;

  Future<void> _verifyTransfer() async {
    setState(() => _isVerifying = true);
    final response = await widget.onVerifyTransfer();
    setState(() {
      _isVerifying = false;
      _status = response.paymentMessage;
    });

    if (response.paymentStatus == 'paid' && mounted) {
      Navigator.of(context).pop(response);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('InstaPay Transfer')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transfer Instructions', style: AppTextStyles.h5),
            const SizedBox(height: 16),
            _InfoCard(label: 'IBAN', value: widget.initialResponse.fakeIban ?? 'EG00MOCK0000001234567890123456'),
            const SizedBox(height: 12),
            _InfoCard(label: 'Reference', value: widget.initialResponse.referenceCode ?? 'INST-XXXXXX'),
            const SizedBox(height: 12),
            _InfoCard(label: 'Transaction ID', value: widget.initialResponse.transactionId ?? 'INST-XXXXXX'),
            if (_status != null) ...[
              const SizedBox(height: 16),
              Text(_status!, style: AppTextStyles.bodyMedium),
            ],
            const Spacer(),
            AppButton(
              text: 'I Have Transferred',
              onPressed: _verifyTransfer,
              isLoading: _isVerifying,
              gradient: AppColors.primaryGradient,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderConfirmationScreen extends StatelessWidget {
  const _OrderConfirmationScreen({required this.response});

  final PaymentSimulationResponse response;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Order Confirmation')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order ${response.order.orderNumber}', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 8),
                  Text('Payment: ${response.order.paymentMethod.label}', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 6),
                  Text('Payment Status: ${_paymentStatusLabel(response.paymentStatus)}', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 6),
                  Text('Transaction ID: ${response.transactionId ?? '-'}', style: AppTextStyles.bodyMedium),
                  if (response.paymentMessage != null && response.paymentMessage!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(response.paymentMessage!, style: AppTextStyles.bodySmall),
                  ],
                ],
              ),
            ),
            const Spacer(),
            AppButton(
              text: 'Continue to Order Tracking',
              onPressed: () => Navigator.of(context).pop(),
              width: double.infinity,
              gradient: AppColors.primaryGradient,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.labelLarge),
        ],
      ),
    );
  }
}

String _paymentStatusLabel(String status) {
  switch (status) {
    case 'paid':
      return 'Paid';
    case 'failed':
      return 'Failed';
    case 'awaiting_transfer':
      return 'Awaiting Transfer';
    default:
      return 'Pending';
  }
}

class _ReviewStep extends ConsumerWidget {
  final ValueChanged<int> onEdit;

  const _ReviewStep({required this.onEdit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkoutState = ref.watch(checkoutStateProvider);
    final cart = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);
    final deliveryFee = ref.watch(deliveryFeeProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReviewSection(
            title: 'Order Items (${cart.itemCount})',
            onEdit: () => context.pop(),
            child: Column(
              children: cart.items
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${item.quantity}x ${item.foodName}'),
                          Text('EGP ${item.totalPrice.toStringAsFixed(0)}'),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          _ReviewSection(
            title: 'Delivery Details',
            onEdit: () => onEdit(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        checkoutState.deliveryAddress?.fullAddress ??
                            'No address',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      checkoutState.isAsap
                          ? 'As soon as possible'
                          : 'Scheduled delivery',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _ReviewSection(
            title: 'Payment',
            onEdit: () => onEdit(1),
            child: Row(
              children: [
                Text(checkoutState.paymentMethod.emoji),
                const SizedBox(width: 8),
                Text(checkoutState.paymentMethod.label),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceWarm,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _PriceRow(label: 'Subtotal', value: cart.subtotal),
                _PriceRow(label: 'Delivery Fee', value: deliveryFee),
                if (cart.discount > 0)
                  _PriceRow(
                    label: 'Discount',
                    value: -cart.discount,
                    isDiscount: true,
                  ),
                Divider(height: 24, color: AppColors.divider),
                _PriceRow(label: 'Total', value: total, isBold: true),
              ],
            ),
          ),
          if (checkoutState.paymentMethod == PaymentMethod.cod) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Text('💵', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Please prepare EGP ${total.toStringAsFixed(0)} for the driver',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewSection extends StatelessWidget {
  final String title;
  final VoidCallback? onEdit;
  final Widget child;

  const _ReviewSection({required this.title, this.onEdit, required this.child});

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
              Text(title, style: AppTextStyles.labelLarge),
              if (onEdit != null)
                TextButton(onPressed: onEdit, child: const Text('Edit')),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isBold;
  final bool isDiscount;

  const _PriceRow({
    required this.label,
    required this.value,
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
            style: isBold ? AppTextStyles.labelLarge : AppTextStyles.bodyMedium,
          ),
          Text(
            '${isDiscount ? "-" : ""}EGP ${value.abs().toStringAsFixed(0)}',
            style:
                (isBold ? AppTextStyles.priceMedium : AppTextStyles.bodyMedium)
                    .copyWith(color: isDiscount ? AppColors.success : null),
          ),
        ],
      ),
    );
  }
}
