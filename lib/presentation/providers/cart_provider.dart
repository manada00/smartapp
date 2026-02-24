import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/cart_model.dart';
import '../../data/models/food_model.dart';

final cartProvider = StateNotifierProvider<CartNotifier, CartModel>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<CartModel> {
  CartNotifier() : super(CartModel());

  void addItem({
    required FoodModel food,
    required PortionOption? portion,
    required List<SelectedCustomization> customizations,
    String? specialInstructions,
    int quantity = 1,
  }) {
    final customizationsPrice = customizations.fold<double>(
      0,
      (sum, c) => sum + c.priceModifier,
    );

    final newItem = CartItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      foodId: food.id,
      foodName: food.name,
      foodImage: food.images.isNotEmpty ? food.images.first : '',
      portionId: portion?.id,
      portionName: portion?.name,
      customizations: customizations,
      specialInstructions: specialInstructions,
      quantity: quantity,
      unitPrice: portion?.price ?? food.price,
      customizationsPrice: customizationsPrice,
    );

    state = state.copyWith(items: [...state.items, newItem]);
  }

  void updateQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      removeItem(itemId);
      return;
    }

    final updatedItems = state.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    state = state.copyWith(items: updatedItems);
  }

  void removeItem(String itemId) {
    final updatedItems =
        state.items.where((item) => item.id != itemId).toList();
    state = state.copyWith(items: updatedItems);
  }

  void applyPromoCode(String code, double discount, String message) {
    state = state.copyWith(
      promoCode: code,
      promoDiscount: discount,
      promoMessage: message,
    );
  }

  void removePromoCode() {
    state = CartModel(items: state.items);
  }

  void clearCart() {
    state = CartModel();
  }
}

final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).itemCount;
});

final cartSubtotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).subtotal;
});

final deliveryFeeProvider = Provider<double>((ref) {
  // Could be dynamic based on distance, time, etc.
  return 25.0;
});

final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  final deliveryFee = ref.watch(deliveryFeeProvider);
  return cart.subtotal - cart.discount + deliveryFee;
});
