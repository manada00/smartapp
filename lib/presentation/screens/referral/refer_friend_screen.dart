import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../widgets/common/app_button.dart';

class ReferFriendScreen extends ConsumerWidget {
  const ReferFriendScreen({super.key});

  void _copyCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Code copied to clipboard!')));
  }

  void _shareViaWhatsApp(String code) async {
    final message = Uri.encodeComponent(
      'Use my code $code to get EGP 50 off your first Smart Food order! 🍽️\n\n'
      'Smart Food helps you eat for how you feel - get personalized meal recommendations based on your energy, mood, and fitness goals.\n\n'
      'Download now: https://smartfood.app/download',
    );
    final url = Uri.parse('https://wa.me/?text=$message');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _shareViaSms(String code) async {
    final message = Uri.encodeComponent(
      'Use my code $code for EGP 50 off at Smart Food! Download: https://smartfood.app',
    );
    final url = Uri.parse('sms:?body=$message');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _shareGeneral(String code) {
    SharePlus.instance.share(
      ShareParams(
        text:
            'Use my code $code to get EGP 50 off your first Smart Food order! 🍽️\n\n'
            'Smart Food helps you eat for how you feel - get personalized meal recommendations.\n\n'
            'Download: https://smartfood.app/download',
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const referralCode = 'AHMED50';
    const friendsJoined = 3;
    const totalEarned = 150.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Refer a Friend')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppColors.elevatedShadow,
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.textOnPrimary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.card_giftcard_rounded,
                      size: 48,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Give EGP 50, Get EGP 50',
                    style: AppTextStyles.h4.copyWith(
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Share your code with friends. When they order,\nyou both get EGP 50!',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textOnPrimary.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                children: [
                  Text(
                    'Your Referral Code',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWarm,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          referralCode,
                          style: AppTextStyles.h3.copyWith(
                            letterSpacing: 4,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(
                            Icons.copy_rounded,
                            color: AppColors.primary,
                          ),
                          onPressed: () => _copyCode(context, referralCode),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    text: 'Copy Code',
                    onPressed: () => _copyCode(context, referralCode),
                    width: double.infinity,
                    icon: const Icon(
                      Icons.copy_rounded,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Share via', style: AppTextStyles.labelMedium),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ShareButton(
                  icon: Icons.chat_rounded,
                  label: 'WhatsApp',
                  color: const Color(0xFF25D366),
                  onTap: () => _shareViaWhatsApp(referralCode),
                ),
                _ShareButton(
                  icon: Icons.sms_rounded,
                  label: 'SMS',
                  color: AppColors.info,
                  onTap: () => _shareViaSms(referralCode),
                ),
                _ShareButton(
                  icon: Icons.share_rounded,
                  label: 'More',
                  color: AppColors.textSecondary,
                  onTap: () => _shareGeneral(referralCode),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                children: [
                  Text('Your Referral Stats', style: AppTextStyles.h6),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          value: '$friendsJoined',
                          label: 'Friends Joined',
                          icon: Icons.people_rounded,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          value: 'EGP ${totalEarned.toStringAsFixed(0)}',
                          label: 'Total Earned',
                          icon: Icons.wallet_rounded,
                        ),
                      ),
                    ],
                  ),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How it works', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 12),
                  _HowItWorksStep(
                    number: '1',
                    text: 'Share your unique code with friends',
                  ),
                  _HowItWorksStep(
                    number: '2',
                    text: 'They get EGP 50 off their first order',
                  ),
                  _HowItWorksStep(
                    number: '3',
                    text: 'You get EGP 50 added to your wallet',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWarm,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.h5),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _HowItWorksStep extends StatelessWidget {
  final String number;
  final String text;

  const _HowItWorksStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textOnPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTextStyles.bodySmall)),
        ],
      ),
    );
  }
}
