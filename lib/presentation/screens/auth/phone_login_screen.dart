import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/l10n_extensions.dart';
import '../../../core/router/app_router.dart';
import 'akedly_auth_webview_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  bool get _isValidPhone {
    final phone = _phoneController.text;
    if (phone.length != AppConstants.phoneLength) return false;
    return AppConstants.validPhonePrefixes.any((p) => phone.startsWith(p));
  }

  Future<void> _startPhoneLogin() async {
    if (!_isValidPhone) {
      setState(() {
        _errorText = 'Please enter a valid Egyptian phone number';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final normalizedPhone = '+20${_phoneController.text}';
      final started = await ref
          .read(authStateProvider.notifier)
          .startAkedlyOtp(normalizedPhone);

      if (!mounted) return;

      final callback = await Navigator.of(context)
          .push<AkedlyAuthCallbackResult>(
            MaterialPageRoute(
              builder: (_) =>
                  AkedlyAuthWebViewScreen(iframeUrl: started.iframeUrl),
            ),
          );

      if (!mounted) return;

      final result = callback ?? AkedlyAuthCallbackResult.cancelled;
      final completed = await ref
          .read(authStateProvider.notifier)
          .completeAkedlySession(
            status: result.status,
            attemptId: result.attemptId ?? started.attemptId,
            transactionId: result.transactionId,
          );

      if (mounted) {
        if (!completed) {
          final authState = ref.read(authStateProvider);
          setState(() {
            _errorText = authState is AuthStateError
                ? authState.message
                : 'Unable to complete login. Please try again.';
          });
          return;
        }

        final authState = ref.read(authStateProvider);
        if (authState is AuthStateNeedsProfileCreation) {
          context.go(Routes.createProfile);
        } else if (authState is AuthStateAuthenticated) {
          context.go(Routes.home);
        }
      }
    } catch (e) {
      setState(() {
        _errorText = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showLanguagePicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final currentLocale = ref.watch(localeProvider);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(context.l10n.selectLanguage, style: AppTextStyles.h6),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.l10n.english),
                  trailing: currentLocale.languageCode == 'en'
                      ? Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    ref
                        .read(localeProvider.notifier)
                        .setLocale(const Locale('en'));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.l10n.arabic),
                  trailing: currentLocale.languageCode == 'ar'
                      ? Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    ref
                        .read(localeProvider.notifier)
                        .setLocale(const Locale('ar'));
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton.icon(
                  onPressed: _showLanguagePicker,
                  icon: const Icon(Icons.language_rounded, size: 18),
                  label: Text(context.l10n.language),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    textStyle: AppTextStyles.labelMedium,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const SizedBox(height: 48),
              // App icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppColors.softGlow(AppColors.primary),
                ),
                child: const Icon(
                  Icons.restaurant_menu_rounded,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome to SmartApp',
                style: AppTextStyles.h3.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              Text(
                'Order healthy meals tailored to your mood',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 48),
              PhoneTextField(
                controller: _phoneController,
                errorText: _errorText,
                autofocus: true,
                onChanged: (_) {
                  if (_errorText != null) {
                    setState(() => _errorText = null);
                  }
                },
              ),
              const SizedBox(height: 24),
              AppButton(
                text: 'Continue',
                onPressed: _isValidPhone ? _startPhoneLogin : null,
                isLoading: _isLoading,
                width: double.infinity,
                gradient: _isValidPhone ? AppColors.primaryGradient : null,
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  "Don't have an account? Continue to create one.",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 52),
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTextStyles.caption,
                    children: [
                      const TextSpan(text: 'By continuing, you agree to our '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
