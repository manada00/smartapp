import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/dio_client.dart';
import '../../data/models/address_model.dart';
import '../../data/models/cart_model.dart';
import '../../data/models/order_model.dart';
import 'auth_provider.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.watch(dioClientProvider));
});

final ordersProvider = StateNotifierProvider<OrdersNotifier, AsyncValue<List<OrderModel>>>((ref) {
  return OrdersNotifier(ref.watch(orderRepositoryProvider))..loadOrders();
});

class OrdersNotifier extends StateNotifier<AsyncValue<List<OrderModel>>> {
  OrdersNotifier(this._repository) : super(const AsyncValue.loading());

  final OrderRepository _repository;

  Future<void> loadOrders() async {
    state = const AsyncValue.loading();
    try {
      final orders = await _repository.getOrders();
      state = AsyncValue.data(orders);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refreshOrder(String orderId) async {
    try {
      final latestOrder = await _repository.getOrderById(orderId);
      state.whenData((orders) {
        final existing = orders.any((order) => order.id == orderId);
        final updated = existing
            ? orders.map((order) => order.id == orderId ? latestOrder : order).toList()
            : [latestOrder, ...orders];
        state = AsyncValue.data(updated);
      });
    } catch (_) {}
  }
}

final activeOrdersProvider = Provider<List<OrderModel>>((ref) {
  final ordersAsync = ref.watch(ordersProvider);
  return ordersAsync.when(
    data: (orders) => orders.where((o) => o.isActive).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

final pastOrdersProvider = Provider<List<OrderModel>>((ref) {
  final ordersAsync = ref.watch(ordersProvider);
  return ordersAsync.when(
    data: (orders) => orders.where((o) => !o.isActive).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

final orderDetailProvider = FutureProvider.family<OrderModel, String>((ref, orderId) {
  return ref.read(orderRepositoryProvider).getOrderById(orderId);
});

class PaymentSimulationResponse {
  final OrderModel order;
  final String paymentStatus;
  final String? paymentMessage;
  final String? transactionId;
  final String? referenceCode;
  final String? fakeIban;

  const PaymentSimulationResponse({
    required this.order,
    required this.paymentStatus,
    this.paymentMessage,
    this.transactionId,
    this.referenceCode,
    this.fakeIban,
  });
}

class OrderRepository {
  final DioClient _dioClient;

  OrderRepository(this._dioClient);

  Future<List<OrderModel>> getOrders() async {
    final response = await _dioClient.get(ApiConstants.orders);
    final list = (response.data['data'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(_mapOrder)
        .toList();
    return list;
  }

  Future<OrderModel> getOrderById(String orderId) async {
    final response = await _dioClient.get('${ApiConstants.orders}/$orderId');
    final data = response.data['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Order not found');
    }
    return _mapOrder(data);
  }

  Future<PaymentSimulationResponse> placeOrder({
    required List<CartItemModel> items,
    required AddressModel address,
    required PaymentMethod paymentMethod,
    Map<String, String>? cardDetails,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.orders,
      data: {
        'items': items.map(_mapCartItemForApi).toList(),
        'deliveryAddress': _mapAddressForApi(address),
        'paymentMethod': _paymentMethodToApi(paymentMethod),
        if (cardDetails != null) 'cardDetails': cardDetails,
      },
    );

    return _mapPaymentResponse(response.data);
  }

  Future<PaymentSimulationResponse> retryCardPayment({
    required String orderId,
    required Map<String, String> cardDetails,
  }) async {
    final response = await _dioClient.post(
      '${ApiConstants.orders}/$orderId/pay/card',
      data: {'cardDetails': cardDetails},
    );

    return _mapPaymentResponse(response.data);
  }

  Future<PaymentSimulationResponse> verifyInstapayTransfer({required String orderId}) async {
    final response = await _dioClient.post('${ApiConstants.orders}/$orderId/pay/instapay/verify');
    return _mapPaymentResponse(response.data);
  }

  PaymentSimulationResponse _mapPaymentResponse(Map<String, dynamic> body) {
    final order = _mapOrder((body['data'] as Map<String, dynamic>? ?? {}));
    final payment = body['payment'] as Map<String, dynamic>? ?? {};
    return PaymentSimulationResponse(
      order: order,
      paymentStatus: _asString(payment['status']),
      paymentMessage: _asString(payment['message']),
      transactionId: _asString(payment['transactionId']),
      referenceCode: _asString(payment['referenceCode']),
      fakeIban: _asString(payment['fakeIban']),
    );
  }
}

Map<String, dynamic> _mapCartItemForApi(CartItemModel item) {
  return {
    'food': item.foodId,
    'foodName': item.foodName,
    'foodImage': item.foodImage,
    'portionId': item.portionId,
    'portionName': item.portionName,
    'customizations': item.customizations.map((c) => c.toJson()).toList(),
    'specialInstructions': item.specialInstructions,
    'quantity': item.quantity,
    'unitPrice': item.unitPrice,
    'customizationsPrice': item.customizationsPrice,
    'totalPrice': item.totalPrice,
  };
}

Map<String, dynamic> _mapAddressForApi(AddressModel address) {
  return {
    'label': address.label.label,
    'governorate': address.governorate,
    'area': address.area,
    'streetName': address.streetName,
    'buildingNumber': address.buildingNumber,
    'floor': address.floor,
    'apartmentNumber': address.apartmentNumber,
    'landmark': address.landmark,
    'deliveryInstructions': address.deliveryInstructions,
    'latitude': address.latitude,
    'longitude': address.longitude,
  };
}

OrderModel _mapOrder(Map<String, dynamic> json) {
  final rawItems = (json['items'] as List<dynamic>? ?? []).whereType<Map<String, dynamic>>();
  final createdAt = DateTime.tryParse(_asString(json['createdAt'])) ?? DateTime.now();
  final updatedAt = DateTime.tryParse(_asString(json['updatedAt'])) ?? createdAt;
  final userId = _extractUserId(json['user']);

  return OrderModel(
    id: _asString(json['_id'], fallback: _asString(json['id'])),
    orderNumber: _asString(json['orderNumber'], fallback: 'Order'),
    userId: userId,
    items: rawItems.map((item) => CartItemModel(
          id: _asString(item['_id'], fallback: _asString(item['food'])),
          foodId: _asString(item['food']),
          foodName: _asString(item['foodName'], fallback: 'Item'),
          foodImage: _asString(item['foodImage']),
          portionId: _asString(item['portionId']),
          portionName: _asString(item['portionName']),
          customizations: (item['customizations'] as List<dynamic>? ?? [])
              .whereType<Map<String, dynamic>>()
              .map((c) => SelectedCustomization(
                    groupId: _asString(c['groupId']),
                    groupName: _asString(c['groupName']),
                    optionId: _asString(c['optionId']),
                    optionName: _asString(c['optionName']),
                    priceModifier: _asDouble(c['priceModifier']),
                  ))
              .toList(),
          specialInstructions: _asString(item['specialInstructions']),
          quantity: _asInt(item['quantity'], fallback: 1),
          unitPrice: _asDouble(item['unitPrice']),
          customizationsPrice: _asDouble(item['customizationsPrice']),
        )).toList(),
    deliveryAddress: _mapOrderAddress(
      (json['deliveryAddress'] as Map<String, dynamic>? ?? {}),
      userId: userId,
      orderId: _asString(json['_id'], fallback: _asString(json['id'])),
      createdAt: createdAt,
      updatedAt: updatedAt,
    ),
    status: _orderStatusFromApi(_asString(json['status'])),
    paymentMethod: _paymentMethodFromApi(_asString(json['paymentMethod'])),
    paymentStatus: _paymentStatusFromApi(_asString(json['paymentStatus'])),
    driverId: _extractId(json['driver']),
    driver: _mapDriver(json['driver']),
    subtotal: _asDouble(json['subtotal']),
    deliveryFee: _asDouble(json['deliveryFee']),
    discount: _asDouble(json['discount']),
    walletUsed: _asDouble(json['walletUsed']),
    total: _asDouble(json['total']),
    amountDue: _asDouble(json['amountDue']),
    promoCode: _asString(json['promoCode']),
    specialInstructions: _asString(json['specialInstructions']),
    changeFor: json['changeFor'] is num ? (json['changeFor'] as num).toInt() : null,
    scheduledDelivery: _mapSchedule(json['scheduledDelivery']),
    estimatedMinutes: _asInt(json['estimatedMinutes'], fallback: 35),
    timeline: _mapTimeline(json['timeline']),
    pointsEarned: _asInt(json['pointsEarned']),
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

AddressModel _mapOrderAddress(
  Map<String, dynamic> json, {
  required String userId,
  required String orderId,
  required DateTime createdAt,
  required DateTime updatedAt,
}) {
  final labelText = _asString(json['label']).toLowerCase();
  return AddressModel(
    id: 'order_address_$orderId',
    userId: userId,
    label: switch (labelText) {
      'office' => AddressLabel.office,
      'gym' => AddressLabel.gym,
      'other' => AddressLabel.other,
      _ => AddressLabel.home,
    },
    governorate: _asString(json['governorate']),
    area: _asString(json['area']),
    streetName: _asString(json['streetName']),
    buildingNumber: _asString(json['buildingNumber']),
    floor: _asString(json['floor']),
    apartmentNumber: _asString(json['apartmentNumber']),
    landmark: _asString(json['landmark']),
    deliveryInstructions: _asString(json['deliveryInstructions']),
    latitude: _asDouble(json['latitude']),
    longitude: _asDouble(json['longitude']),
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

DriverInfo? _mapDriver(dynamic rawDriver) {
  if (rawDriver is! Map<String, dynamic>) return null;
  final id = _asString(rawDriver['_id'], fallback: _asString(rawDriver['id']));
  if (id.isEmpty) return null;
  return DriverInfo(
    id: id,
    name: _asString(rawDriver['name'], fallback: 'Driver'),
    photo: _asString(rawDriver['photo']),
    phone: _asString(rawDriver['phone'], fallback: 'N/A'),
    rating: _asDouble(rawDriver['rating'], fallback: 5),
    latitude: rawDriver['latitude'] is num ? (rawDriver['latitude'] as num).toDouble() : null,
    longitude: rawDriver['longitude'] is num ? (rawDriver['longitude'] as num).toDouble() : null,
  );
}

DeliverySchedule? _mapSchedule(dynamic rawSchedule) {
  if (rawSchedule is! Map<String, dynamic>) return null;
  final date = DateTime.tryParse(_asString(rawSchedule['date']));
  final timeSlot = _asString(rawSchedule['timeSlot']);
  if (date == null || timeSlot.isEmpty) return null;
  return DeliverySchedule(date: date, timeSlot: timeSlot);
}

List<OrderTimeline> _mapTimeline(dynamic rawTimeline) {
  if (rawTimeline is! List) return const [];
  return rawTimeline.whereType<Map<String, dynamic>>().map((event) {
    final timestamp = DateTime.tryParse(_asString(event['timestamp'])) ?? DateTime.now();
    return OrderTimeline(
      status: _orderStatusFromApi(_asString(event['status'])),
      message: _asString(event['message']),
      timestamp: timestamp,
    );
  }).toList();
}

String _paymentMethodToApi(PaymentMethod method) {
  switch (method) {
    case PaymentMethod.cod:
      return 'cod';
    case PaymentMethod.card:
      return 'card';
    case PaymentMethod.instaPay:
      return 'instapay';
    default:
      return 'cod';
  }
}

PaymentMethod _paymentMethodFromApi(String value) {
  switch (value) {
    case 'card':
      return PaymentMethod.card;
    case 'instapay':
      return PaymentMethod.instaPay;
    default:
      return PaymentMethod.cod;
  }
}

PaymentStatus _paymentStatusFromApi(String value) {
  switch (value) {
    case 'paid':
      return PaymentStatus.completed;
    case 'failed':
      return PaymentStatus.failed;
    case 'refunded':
      return PaymentStatus.refunded;
    default:
      return PaymentStatus.pending;
  }
}

OrderStatus _orderStatusFromApi(String value) {
  switch (value) {
    case 'confirmed':
      return OrderStatus.confirmed;
    case 'preparing':
      return OrderStatus.preparing;
    case 'ready_for_pickup':
      return OrderStatus.readyForPickup;
    case 'out_for_delivery':
      return OrderStatus.outForDelivery;
    case 'delivered':
      return OrderStatus.delivered;
    case 'cancelled':
      return OrderStatus.cancelled;
    default:
      return OrderStatus.pending;
  }
}

String _extractUserId(dynamic rawUser) {
  if (rawUser is Map<String, dynamic>) {
    return _asString(rawUser['_id'], fallback: _asString(rawUser['id']));
  }
  return _asString(rawUser);
}

String? _extractId(dynamic value) {
  final id = value is Map<String, dynamic>
      ? _asString(value['_id'], fallback: _asString(value['id']))
      : _asString(value);
  return id.isEmpty ? null : id;
}

String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final text = value.toString();
  return text.isEmpty ? fallback : text;
}

double _asDouble(dynamic value, {double fallback = 0}) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

final checkoutStateProvider =
    StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  return CheckoutNotifier();
});

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  CheckoutNotifier() : super(CheckoutState());

  void setDeliveryAddress(AddressModel address) {
    state = state.copyWith(deliveryAddress: address);
  }

  void setDeliveryTime(DeliverySchedule? schedule) {
    state = state.copyWith(
      isAsap: schedule == null,
      scheduledDelivery: schedule,
    );
  }

  void setPaymentMethod(PaymentMethod method) {
    state = state.copyWith(paymentMethod: method);
  }

  void setMobileWalletProvider(MobileWalletProvider? provider) {
    state = state.copyWith(mobileWalletProvider: provider);
  }

  void setUseWallet(bool use) {
    state = state.copyWith(useWallet: use);
  }

  void setChangeFor(int? amount) {
    state = state.copyWith(changeFor: amount);
  }

  void setDeliveryInstructions(String? instructions) {
    state = state.copyWith(deliveryInstructions: instructions);
  }

  void reset() {
    state = CheckoutState();
  }
}

class CheckoutState {
  final AddressModel? deliveryAddress;
  final bool isAsap;
  final DeliverySchedule? scheduledDelivery;
  final PaymentMethod paymentMethod;
  final MobileWalletProvider? mobileWalletProvider;
  final bool useWallet;
  final int? changeFor;
  final String? deliveryInstructions;

  CheckoutState({
    this.deliveryAddress,
    this.isAsap = true,
    this.scheduledDelivery,
    this.paymentMethod = PaymentMethod.cod,
    this.mobileWalletProvider,
    this.useWallet = false,
    this.changeFor,
    this.deliveryInstructions,
  });

  CheckoutState copyWith({
    AddressModel? deliveryAddress,
    bool? isAsap,
    DeliverySchedule? scheduledDelivery,
    PaymentMethod? paymentMethod,
    MobileWalletProvider? mobileWalletProvider,
    bool? useWallet,
    int? changeFor,
    String? deliveryInstructions,
  }) {
    return CheckoutState(
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      isAsap: isAsap ?? this.isAsap,
      scheduledDelivery: scheduledDelivery ?? this.scheduledDelivery,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      mobileWalletProvider: mobileWalletProvider ?? this.mobileWalletProvider,
      useWallet: useWallet ?? this.useWallet,
      changeFor: changeFor ?? this.changeFor,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
    );
  }

  bool get isValid =>
      deliveryAddress != null &&
      (paymentMethod == PaymentMethod.cod ||
          paymentMethod == PaymentMethod.card ||
          paymentMethod == PaymentMethod.instaPay);
}
