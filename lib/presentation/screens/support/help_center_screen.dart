import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../widgets/common/app_text_field.dart';

class HelpCenterScreen extends ConsumerStatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  ConsumerState<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends ConsumerState<HelpCenterScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  static const _faqCategories = [
    _FaqCategory(
      icon: Icons.local_shipping_rounded,
      title: 'Orders & Delivery',
      faqs: [
        _FaqItem(
          question: 'How do I track my order?',
          answer:
              'You can track your order in real-time by going to Orders > Active Orders and tapping on your order. You\'ll see the live location of your driver once your order is out for delivery.',
        ),
        _FaqItem(
          question: 'What are the delivery hours?',
          answer:
              'We deliver daily from 8 AM to 11 PM. Delivery times may vary during Ramadan and public holidays.',
        ),
        _FaqItem(
          question: 'Can I change my delivery address after ordering?',
          answer:
              'You can change your delivery address only if your order hasn\'t been picked up yet. Go to your order details and tap "Change Address" or contact support.',
        ),
        _FaqItem(
          question: 'What if my order is late?',
          answer:
              'If your order is significantly delayed, you\'ll receive automatic updates. For very late orders, we may provide compensation in the form of wallet credits or discount codes.',
        ),
      ],
    ),
    _FaqCategory(
      icon: Icons.credit_card_rounded,
      title: 'Payments & Refunds',
      faqs: [
        _FaqItem(
          question: 'What payment methods do you accept?',
          answer:
              'We accept Cash on Delivery (COD), credit/debit cards (Visa, Mastercard, Meeza), mobile wallets (Vodafone Cash, Orange Cash, Etisalat Cash, WE Pay, CIB Smart Wallet), Fawry, and InstaPay.',
        ),
        _FaqItem(
          question: 'How do refunds work?',
          answer:
              'Refunds are processed within 3-5 business days for card payments. For COD orders, refunds are added to your wallet balance. You can use wallet balance for future orders or request a bank transfer.',
        ),
        _FaqItem(
          question: 'Is there a minimum order amount?',
          answer:
              'Yes, the minimum order amount varies by area, typically EGP 100-150. You\'ll see the minimum for your area during checkout.',
        ),
      ],
    ),
    _FaqCategory(
      icon: Icons.calendar_today_rounded,
      title: 'Subscriptions',
      faqs: [
        _FaqItem(
          question: 'How do meal subscriptions work?',
          answer:
              'Choose a plan that fits your needs, select your meals or let our chefs choose for you, and receive fresh meals at your chosen delivery time. You can skip, swap, pause, or cancel anytime.',
        ),
        _FaqItem(
          question: 'Can I pause my subscription?',
          answer:
              'Yes! You can pause your subscription for up to 4 weeks. Go to Subscriptions > Manage Plan > Pause Subscription.',
        ),
        _FaqItem(
          question: 'How do I cancel my subscription?',
          answer:
              'You can cancel anytime before your next billing date. Go to Subscriptions > Manage Plan > Cancel Subscription. You won\'t be charged for future deliveries.',
        ),
      ],
    ),
    _FaqCategory(
      icon: Icons.person_rounded,
      title: 'Account',
      faqs: [
        _FaqItem(
          question: 'How do I change my phone number?',
          answer:
              'Go to Profile > Edit Profile > Phone Number. You\'ll need to verify your new number with an OTP.',
        ),
        _FaqItem(
          question: 'How do I delete my account?',
          answer:
              'Contact our support team to request account deletion. Please note this will delete all your data including order history and wallet balance.',
        ),
      ],
    ),
    _FaqCategory(
      icon: Icons.restaurant_menu_rounded,
      title: 'Food & Menu',
      faqs: [
        _FaqItem(
          question: 'How do functional scores work?',
          answer:
              'Each meal is rated on 8 functional scores: Energy Stability, Satiety, Insulin Impact, Digestion Ease, Focus Support, Sleep Friendly, Kid Friendly, and Workout Support. Higher scores (4-5) mean the meal excels in that area.',
        ),
        _FaqItem(
          question: 'How do you handle food allergies?',
          answer:
              'Set your allergies in Profile > Dietary Preferences. We\'ll warn you about dishes containing your allergens. Always double-check ingredients and inform us of severe allergies.',
        ),
        _FaqItem(
          question: 'Are nutritional values accurate?',
          answer:
              'Nutritional information is calculated by professional nutritionists. Values may vary slightly based on portion sizes and ingredient variations.',
        ),
      ],
    ),
  ];

  List<_FaqCategory> get _filteredCategories {
    if (_searchQuery.isEmpty) return _faqCategories;

    return _faqCategories
        .map((category) {
          final filteredFaqs = category.faqs
              .where((faq) =>
                  faq.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  faq.answer.toLowerCase().contains(_searchQuery.toLowerCase()))
              .toList();
          return _FaqCategory(
            icon: category.icon,
            title: category.title,
            faqs: filteredFaqs,
          );
        })
        .where((category) => category.faqs.isNotEmpty)
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Help Center'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: SearchTextField(
              controller: _searchController,
              hint: 'Search for help...',
              onChanged: (query) {
                setState(() => _searchQuery = query);
              },
            ),
          ),
          Expanded(
            child: _filteredCategories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No results found',
                          style: AppTextStyles.h6,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different search term',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = _filteredCategories[index];
                      return _FaqCategorySection(category: category);
                    },
                  ),
          ),
          _StillNeedHelpSection(),
        ],
      ),
    );
  }
}

class _FaqCategory {
  final IconData icon;
  final String title;
  final List<_FaqItem> faqs;

  const _FaqCategory({
    required this.icon,
    required this.title,
    required this.faqs,
  });
}

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({
    required this.question,
    required this.answer,
  });
}

class _FaqCategorySection extends StatelessWidget {
  final _FaqCategory category;

  const _FaqCategorySection({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(category.icon, color: AppColors.primary, size: 20),
          ),
          title: Text(category.title, style: AppTextStyles.labelLarge),
          children: category.faqs.map((faq) => _FaqTile(faq: faq)).toList(),
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final _FaqItem faq;

  const _FaqTile({required this.faq});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        faq.question,
        style: AppTextStyles.bodyMedium,
      ),
      childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceWarm,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            faq.answer,
            style: AppTextStyles.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _StillNeedHelpSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: SafeArea(
        child: Column(
          children: [
            Text('Still need help?', style: AppTextStyles.labelLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _HelpButton(
                    icon: Icons.chat_bubble_rounded,
                    label: 'Chat',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _HelpButton(
                    icon: Icons.phone_rounded,
                    label: 'Call',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _HelpButton(
                    icon: Icons.email_rounded,
                    label: 'Email',
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HelpButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceWarm,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
