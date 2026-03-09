import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

class CreateProfileScreen extends ConsumerStatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  ConsumerState<CreateProfileScreen> createState() =>
      _CreateProfileScreenState();
}

class _CreateProfileScreenState extends ConsumerState<CreateProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;
  String? _errorText;

  bool get _canSubmit =>
      _firstNameController.text.trim().isNotEmpty &&
      _lastNameController.text.trim().isNotEmpty;

  Future<void> _submit() async {
    if (!_canSubmit) {
      setState(() => _errorText = 'First and last name are required');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final deliveryAddressText = _addressController.text.trim();

    final success = await ref
        .read(authStateProvider.notifier)
        .createAccountFromOtp(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          email: _emailController.text,
          deliveryAddress: deliveryAddressText.isEmpty
              ? null
              : {
                  'governorate': 'Cairo',
                  'area': 'Cairo',
                  'streetName': deliveryAddressText,
                  'buildingNumber': 'N/A',
                  'landmark': 'N/A',
                  'label': 'home',
                },
        );

    if (!mounted) return;

    if (!success) {
      final state = ref.read(authStateProvider);
      setState(() {
        _errorText = state is AuthStateError
            ? state.message
            : 'Unable to create account';
        _isLoading = false;
      });
      return;
    }

    context.go(Routes.home);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pending = ref.watch(authStateProvider);
    final pendingContext = ref
        .read(authStateProvider.notifier)
        .pendingProfileContext;
    final isAllowed =
        pending is AuthStateNeedsProfileCreation || pendingContext != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Create Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Almost there', style: AppTextStyles.h4),
              const SizedBox(height: 8),
              Text(
                'Complete your account to start ordering.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (pendingContext != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Verified phone: ${pendingContext.phoneNumber}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              AppTextField(
                controller: _firstNameController,
                label: 'First Name',
                hint: 'Enter first name',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _lastNameController,
                label: 'Last Name',
                hint: 'Enter last name',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _emailController,
                label: 'Email (optional)',
                hint: 'Enter email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _addressController,
                label: 'Delivery Address (optional)',
                hint: 'Enter delivery address',
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorText!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              AppButton(
                text: 'Create My Account',
                onPressed: (!isAllowed || _isLoading || !_canSubmit)
                    ? null
                    : _submit,
                isLoading: _isLoading,
                width: double.infinity,
                gradient: AppColors.primaryGradient,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
