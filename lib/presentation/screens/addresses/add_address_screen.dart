import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/address_model.dart';
import '../../providers/address_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

class AddAddressScreen extends ConsumerStatefulWidget {
  final AddressModel? editAddress;

  const AddAddressScreen({super.key, this.editAddress});

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _buildingController = TextEditingController();
  final _floorController = TextEditingController();
  final _apartmentController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _instructionsController = TextEditingController();

  AddressLabel _selectedLabel = AddressLabel.home;
  String? _selectedGovernorate;
  String? _selectedArea;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.editAddress != null) {
      _populateFields(widget.editAddress!);
    }
  }

  void _populateFields(AddressModel address) {
    _selectedLabel = address.label;
    _selectedGovernorate = address.governorate;
    _selectedArea = address.area;
    _streetController.text = address.streetName;
    _buildingController.text = address.buildingNumber;
    _floorController.text = address.floor ?? '';
    _apartmentController.text = address.apartmentNumber ?? '';
    _landmarkController.text = address.landmark;
    _instructionsController.text = address.deliveryInstructions ?? '';
  }

  List<String> get _areas {
    if (_selectedGovernorate == null) return [];
    return AppConstants.areasByGovernorate[_selectedGovernorate] ?? [];
  }

  Future<void> _useCurrentLocation() async {
    // TODO: Implement location detection
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Detecting your location...')),
    );
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final address = AddressModel(
        id: widget.editAddress?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'user1',
        label: _selectedLabel,
        governorate: _selectedGovernorate!,
        area: _selectedArea!,
        streetName: _streetController.text.trim(),
        buildingNumber: _buildingController.text.trim(),
        floor: _floorController.text.trim().isNotEmpty
            ? _floorController.text.trim()
            : null,
        apartmentNumber: _apartmentController.text.trim().isNotEmpty
            ? _apartmentController.text.trim()
            : null,
        landmark: _landmarkController.text.trim(),
        deliveryInstructions: _instructionsController.text.trim().isNotEmpty
            ? _instructionsController.text.trim()
            : null,
        latitude: 30.0444,
        longitude: 31.2357,
        isDefault: widget.editAddress?.isDefault ?? true,
        createdAt: widget.editAddress?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.editAddress != null) {
        await ref.read(addressesProvider.notifier).updateAddress(address);
      } else {
        await ref.read(addressesProvider.notifier).addAddress(address);
      }

      // Complete onboarding if this is the first address
      await ref.read(authStateProvider.notifier).completeOnboarding();

      if (mounted) {
        context.go(Routes.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving address: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _streetController.dispose();
    _buildingController.dispose();
    _floorController.dispose();
    _apartmentController.dispose();
    _landmarkController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.editAddress != null ? 'Edit Address' : 'Delivery Address'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: AppColors.primaryGradient,
                          boxShadow: AppColors.softGlow(AppColors.primary),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _useCurrentLocation,
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.my_location_rounded, color: AppColors.textOnPrimary),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Use Current Location',
                                    style: AppTextStyles.buttonMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Divider(color: AppColors.divider),
                      const SizedBox(height: 28),
                      Text('Address Label', style: AppTextStyles.labelMedium),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: AddressLabel.values.map((label) {
                          final isSelected = _selectedLabel == label;
                          return ChoiceChip(
                            label: Text('${label.emoji} ${label.label}'),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() => _selectedLabel = label);
                            },
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.surfaceWarm,
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected ? AppColors.primary : AppColors.divider,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Location Details', style: AppTextStyles.labelLarge),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _selectedGovernorate,
                              decoration: InputDecoration(
                                labelText: 'Governorate *',
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
                                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                                ),
                              ),
                              items: AppConstants.governorates.map((gov) {
                                return DropdownMenuItem(value: gov, child: Text(gov));
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedGovernorate = value;
                                  _selectedArea = null;
                                });
                              },
                              validator: (v) => v == null ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _selectedArea,
                              decoration: InputDecoration(
                                labelText: 'Area/District *',
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
                                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                                ),
                              ),
                              items: _areas.map((area) {
                                return DropdownMenuItem(value: area, child: Text(area));
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedArea = value);
                              },
                              validator: (v) => v == null ? 'Required' : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Address Details', style: AppTextStyles.labelLarge),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _streetController,
                              decoration: InputDecoration(
                                labelText: 'Street Name *',
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
                                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                                ),
                              ),
                              validator: (v) =>
                                  v?.trim().isEmpty == true ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _buildingController,
                              decoration: InputDecoration(
                                labelText: 'Building Number/Name *',
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
                                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                                ),
                              ),
                              validator: (v) =>
                                  v?.trim().isEmpty == true ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _floorController,
                                    decoration: InputDecoration(
                                      labelText: 'Floor',
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
                                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _apartmentController,
                                    decoration: InputDecoration(
                                      labelText: 'Apartment',
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
                                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _landmarkController,
                              decoration: InputDecoration(
                                labelText: 'Landmark *',
                                hintText: 'e.g., Next to Seoudi Market',
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
                                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                                ),
                              ),
                              validator: (v) =>
                                  v?.trim().isEmpty == true ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _instructionsController,
                              label: 'Delivery Instructions (optional)',
                              hint: 'Any special instructions for delivery',
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7A6B50).withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: AppButton(
                text: 'Save Address',
                onPressed: _saveAddress,
                isLoading: _isLoading,
                width: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
