import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/address_model.dart';

final addressesProvider =
    StateNotifierProvider<AddressesNotifier, AsyncValue<List<AddressModel>>>(
        (ref) {
  return AddressesNotifier()..loadAddresses();
});

class AddressesNotifier extends StateNotifier<AsyncValue<List<AddressModel>>> {
  AddressesNotifier() : super(const AsyncValue.loading());

  Future<void> loadAddresses() async {
    state = const AsyncValue.loading();
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      state = AsyncValue.data(_mockAddresses);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addAddress(AddressModel address) async {
    state.whenData((addresses) {
      state = AsyncValue.data([...addresses, address]);
    });
  }

  Future<void> updateAddress(AddressModel address) async {
    state.whenData((addresses) {
      final updatedAddresses = addresses.map((a) {
        if (a.id == address.id) return address;
        return a;
      }).toList();
      state = AsyncValue.data(updatedAddresses);
    });
  }

  Future<void> deleteAddress(String addressId) async {
    state.whenData((addresses) {
      final updatedAddresses =
          addresses.where((a) => a.id != addressId).toList();
      state = AsyncValue.data(updatedAddresses);
    });
  }

  Future<void> setDefault(String addressId) async {
    state.whenData((addresses) {
      final updatedAddresses = addresses.map((a) {
        return a.copyWith(isDefault: a.id == addressId);
      }).toList();
      state = AsyncValue.data(updatedAddresses);
    });
  }

  static final _mockAddresses = [
    AddressModel(
      id: '1',
      userId: 'user1',
      label: AddressLabel.home,
      governorate: 'Cairo',
      area: 'Maadi',
      streetName: 'Street 9',
      buildingNumber: '15',
      floor: '3',
      apartmentNumber: '12',
      landmark: 'Next to Seoudi Market',
      latitude: 29.9602,
      longitude: 31.2569,
      isDefault: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    AddressModel(
      id: '2',
      userId: 'user1',
      label: AddressLabel.office,
      governorate: 'Cairo',
      area: 'New Cairo',
      streetName: '90th Street',
      buildingNumber: 'Building A',
      floor: '5',
      apartmentNumber: '501',
      landmark: 'Fifth Settlement, Near AUC',
      latitude: 30.0074,
      longitude: 31.4913,
      isDefault: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];
}

final defaultAddressProvider = Provider<AddressModel?>((ref) {
  final addressesAsync = ref.watch(addressesProvider);
  return addressesAsync.when(
    data: (addresses) =>
        addresses.where((a) => a.isDefault).firstOrNull ?? addresses.firstOrNull,
    loading: () => null,
    error: (_, __) => null,
  );
});

final selectedAddressProvider =
    StateProvider<AddressModel?>((ref) {
  return ref.watch(defaultAddressProvider);
});
