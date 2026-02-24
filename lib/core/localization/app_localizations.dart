import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('ar')];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const Map<String, Map<String, String>> _values = {
    'en': {
      'appName': 'Smart Food',
      'home': 'Home',
      'categories': 'Categories',
      'orders': 'Orders',
      'plans': 'Plans',
      'profile': 'Profile',
      'account': 'Account',
      'editProfile': 'Edit Profile',
      'healthGoals': 'Health Goals',
      'dietaryPreferences': 'Dietary Preferences',
      'dailyRoutine': 'Daily Routine',
      'orderHistory': 'Order History',
      'addresses': 'Addresses',
      'manageAddresses': 'Manage Addresses',
      'payments': 'Payments',
      'paymentMethods': 'Payment Methods',
      'myWallet': 'My Wallet',
      'rewards': 'Rewards',
      'myPointsRewards': 'My Points & Rewards',
      'referFriend': 'Refer a Friend',
      'settings': 'Settings',
      'notifications': 'Notifications',
      'appTheme': 'App Theme',
      'language': 'Language',
      'support': 'Support',
      'helpCenter': 'Help Center',
      'contactUs': 'Contact Us',
      'reportIssue': 'Report Issue',
      'legal': 'Legal',
      'termsOfService': 'Terms of Service',
      'privacyPolicy': 'Privacy Policy',
      'about': 'About',
      'logOut': 'Log Out',
      'version': 'Version',
      'userName': 'User Name',
      'goldPoints': 'Gold • 2,500 points',
      'selectLanguage': 'Select Language',
      'english': 'English',
      'arabic': 'العربية',
    },
    'ar': {
      'appName': 'سمارت فود',
      'home': 'الرئيسية',
      'categories': 'التصنيفات',
      'orders': 'الطلبات',
      'plans': 'الخطط',
      'profile': 'حسابي',
      'account': 'الحساب',
      'editProfile': 'تعديل الملف الشخصي',
      'healthGoals': 'الأهداف الصحية',
      'dietaryPreferences': 'التفضيلات الغذائية',
      'dailyRoutine': 'الروتين اليومي',
      'orderHistory': 'سجل الطلبات',
      'addresses': 'العناوين',
      'manageAddresses': 'إدارة العناوين',
      'payments': 'الدفع',
      'paymentMethods': 'طرق الدفع',
      'myWallet': 'المحفظة',
      'rewards': 'المكافآت',
      'myPointsRewards': 'نقاطي ومكافآتي',
      'referFriend': 'ادعُ صديقاً',
      'settings': 'الإعدادات',
      'notifications': 'الإشعارات',
      'appTheme': 'مظهر التطبيق',
      'language': 'اللغة',
      'support': 'الدعم',
      'helpCenter': 'مركز المساعدة',
      'contactUs': 'تواصل معنا',
      'reportIssue': 'الإبلاغ عن مشكلة',
      'legal': 'قانوني',
      'termsOfService': 'شروط الاستخدام',
      'privacyPolicy': 'سياسة الخصوصية',
      'about': 'حول التطبيق',
      'logOut': 'تسجيل الخروج',
      'version': 'الإصدار',
      'userName': 'اسم المستخدم',
      'goldPoints': 'ذهبي • ٢٥٠٠ نقطة',
      'selectLanguage': 'اختر اللغة',
      'english': 'English',
      'arabic': 'العربية',
    },
  };

  String tr(String key) {
    final code = locale.languageCode;
    return _values[code]?[key] ?? _values['en']![key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
