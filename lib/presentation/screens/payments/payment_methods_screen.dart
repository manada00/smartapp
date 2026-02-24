import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../widgets/common/app_button.dart';

class PaymentMethodsScreen extends ConsumerStatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  ConsumerState<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends ConsumerState<PaymentMethodsScreen> {
  final List<_SavedCard> _savedCards = [
    _SavedCard(
      id: '1',
      type: CardType.visa,
      lastFour: '4242',
      expiry: '12/25',
      isDefault: true,
    ),
    _SavedCard(
      id: '2',
      type: CardType.mastercard,
      lastFour: '8888',
      expiry: '06/26',
      isDefault: false,
    ),
  ];

  final List<_LinkedWallet> _linkedWallets = [
    _LinkedWallet(
      id: '1',
      provider: 'Vodafone Cash',
      phone: '010********78',
    ),
  ];

  void _showAddCardDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _AddCardSheet(),
    );
  }

  void _showLinkWalletDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _LinkWalletSheet(),
    );
  }

  void _setDefaultCard(String cardId) {
    setState(() {
      for (var card in _savedCards) {
        card.isDefault = card.id == cardId;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Default card updated')),
    );
  }

  void _removeCard(String cardId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Card?'),
        content: const Text('Are you sure you want to remove this card?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _savedCards.removeWhere((c) => c.id == cardId);
              });
              Navigator.pop(context);
            },
            child: const Text('Remove', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _removeWallet(String walletId) {
    setState(() {
      _linkedWallets.removeWhere((w) => w.id == walletId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Payment Methods'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Saved Cards', style: AppTextStyles.h6),
          const SizedBox(height: 16),
          if (_savedCards.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                children: [
                  const Icon(Icons.credit_card_off_rounded, size: 48, color: AppColors.textHint),
                  const SizedBox(height: 12),
                  Text('No saved cards', style: AppTextStyles.bodyMedium),
                ],
              ),
            )
          else
            ...(_savedCards.map((card) => _CardTile(
                  card: card,
                  onSetDefault: () => _setDefaultCard(card.id),
                  onRemove: () => _removeCard(card.id),
                ))),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _showAddCardDialog,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add New Card'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              side: BorderSide(color: AppColors.divider),
            ),
          ),
          const SizedBox(height: 32),
          Text('Linked Wallets', style: AppTextStyles.h6),
          const SizedBox(height: 16),
          if (_linkedWallets.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                children: [
                  const Icon(Icons.account_balance_wallet_rounded,
                      size: 48, color: AppColors.textHint),
                  const SizedBox(height: 12),
                  Text('No linked wallets', style: AppTextStyles.bodyMedium),
                ],
              ),
            )
          else
            ...(_linkedWallets.map((wallet) => _WalletTile(
                  wallet: wallet,
                  onRemove: () => _removeWallet(wallet.id),
                ))),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _showLinkWalletDialog,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Link Mobile Wallet'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              side: BorderSide(color: AppColors.divider),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedCard {
  final String id;
  final CardType type;
  final String lastFour;
  final String expiry;
  bool isDefault;

  _SavedCard({
    required this.id,
    required this.type,
    required this.lastFour,
    required this.expiry,
    this.isDefault = false,
  });
}

enum CardType { visa, mastercard, meeza }

class _LinkedWallet {
  final String id;
  final String provider;
  final String phone;

  _LinkedWallet({
    required this.id,
    required this.provider,
    required this.phone,
  });
}

class _CardTile extends StatelessWidget {
  final _SavedCard card;
  final VoidCallback onSetDefault;
  final VoidCallback onRemove;

  const _CardTile({
    required this.card,
    required this.onSetDefault,
    required this.onRemove,
  });

  IconData get _cardIcon {
    switch (card.type) {
      case CardType.visa:
        return Icons.credit_card_rounded;
      case CardType.mastercard:
        return Icons.credit_card_rounded;
      case CardType.meeza:
        return Icons.credit_card_rounded;
    }
  }

  String get _cardTypeName {
    switch (card.type) {
      case CardType.visa:
        return 'Visa';
      case CardType.mastercard:
        return 'Mastercard';
      case CardType.meeza:
        return 'Meeza';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: card.isDefault
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(_cardIcon, size: 32, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$_cardTypeName •••• ${card.lastFour}',
                          style: AppTextStyles.labelLarge,
                        ),
                        if (card.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Default',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textOnPrimary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      'Expires ${card.expiry}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: AppColors.divider),
          Row(
            children: [
              if (!card.isDefault)
                Expanded(
                  child: TextButton(
                    onPressed: onSetDefault,
                    child: const Text('Set as Default'),
                  ),
                ),
              Expanded(
                child: TextButton(
                  onPressed: onRemove,
                  child: const Text(
                    'Remove',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WalletTile extends StatelessWidget {
  final _LinkedWallet wallet;
  final VoidCallback onRemove;

  const _WalletTile({
    required this.wallet,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.phone_android_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(wallet.provider, style: AppTextStyles.labelLarge),
                Text(wallet.phone, style: AppTextStyles.caption),
              ],
            ),
          ),
          TextButton(
            onPressed: onRemove,
            child: const Text(
              'Remove',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddCardSheet extends StatefulWidget {
  const _AddCardSheet();

  @override
  State<_AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends State<_AddCardSheet> {
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();
  bool _saveCard = true;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  InputDecoration _warmInputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Add New Card', style: AppTextStyles.h5),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _cardNumberController,
              decoration: _warmInputDecoration('Card Number', hint: '1234 5678 9012 3456'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _expiryController,
                    decoration: _warmInputDecoration('Expiry', hint: 'MM/YY'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _cvvController,
                    decoration: _warmInputDecoration('CVV', hint: '123'),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: _warmInputDecoration('Cardholder Name'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              value: _saveCard,
              onChanged: (v) => setState(() => _saveCard = v ?? true),
              title: const Text('Save for future payments'),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.lock_rounded, size: 16, color: AppColors.textHint),
                const SizedBox(width: 8),
                Text(
                  'Secured by Paymob',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Add Card',
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Card added successfully')),
                );
              },
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkWalletSheet extends StatefulWidget {
  const _LinkWalletSheet();

  @override
  State<_LinkWalletSheet> createState() => _LinkWalletSheetState();
}

class _LinkWalletSheetState extends State<_LinkWalletSheet> {
  String? _selectedProvider;
  final _phoneController = TextEditingController();

  static const _providers = [
    'Vodafone Cash',
    'Orange Cash',
    'Etisalat Cash',
    'WE Pay',
    'CIB Smart Wallet',
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Link Mobile Wallet', style: AppTextStyles.h5),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _selectedProvider,
            decoration: InputDecoration(
              labelText: 'Wallet Provider',
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
            items: _providers.map((p) {
              return DropdownMenuItem(value: p, child: Text(p));
            }).toList(),
            onChanged: (v) => setState(() => _selectedProvider = v),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              prefixText: '+20 ',
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
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),
          AppButton(
            text: 'Link Wallet',
            onPressed: _selectedProvider != null
                ? () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Wallet linked successfully')),
                    );
                  }
                : null,
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}
