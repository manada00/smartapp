import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;
  String? _errorText;
  int _resendSeconds = AppConstants.otpResendDuration.inSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendSeconds = AppConstants.otpResendDuration.inSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _verifyOtp(String otp) async {
    if (otp.length != AppConstants.otpLength) return;

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final success = await ref
          .read(authStateProvider.notifier)
          .verifyOtp(widget.phoneNumber, otp);

      if (mounted) {
        if (success) {
          final authState = ref.read(authStateProvider);
          if (authState is AuthStateNeedsOnboarding) {
            context.go(Routes.profileSetup);
          } else if (authState is AuthStateAuthenticated) {
            context.go(Routes.home);
          }
        } else {
          final authState = ref.read(authStateProvider);
          setState(() {
            _errorText = authState is AuthStateError
                ? authState.message
                : 'Invalid OTP. Please try again.';
            _otpController.clear();
          });
          _focusNode.requestFocus();
        }
      }
    } catch (e) {
      setState(() {
        _errorText = 'Invalid OTP. Please try again.';
        _otpController.clear();
      });
      _focusNode.requestFocus();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendOtp({bool viaWhatsApp = false}) async {
    if (_resendSeconds > 0) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(authStateProvider.notifier).sendOtp(widget.phoneNumber);
      _startResendTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              viaWhatsApp
                  ? 'OTP sent via WhatsApp'
                  : 'OTP resent successfully',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to resend OTP: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String get _formattedTimer {
    final minutes = (_resendSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_resendSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 54,
      height: 60,
      textStyle: AppTextStyles.h4,
      decoration: BoxDecoration(
        color: AppColors.surfaceWarm,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.transparent),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.primary, width: 2),
        color: AppColors.primarySurface,
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.error),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Verify Your Number',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    '${AppConstants.countryCode} ${widget.phoneNumber}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      'Edit',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'We sent you a 6-digit code. Enter it below.',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 40),
              Center(
                child: Pinput(
                  controller: _otpController,
                  focusNode: _focusNode,
                  length: AppConstants.otpLength,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  errorPinTheme: errorPinTheme,
                  errorText: _errorText,
                  errorTextStyle: AppTextStyles.caption.copyWith(
                    color: AppColors.error,
                  ),
                  onCompleted: _verifyOtp,
                  autofocus: true,
                  separatorBuilder: (index) => const SizedBox(width: 10),
                ),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    _errorText!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 36),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                  ),
                )
              else if (_resendSeconds > 0)
                Center(
                  child: Text(
                    'Resend code in $_formattedTimer',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppTextButton(
                      text: 'Resend via SMS',
                      onPressed: () => _resendOtp(),
                    ),
                    const SizedBox(width: 16),
                    AppTextButton(
                      text: 'Resend via WhatsApp',
                      onPressed: () => _resendOtp(viaWhatsApp: true),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
