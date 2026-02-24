import 'package:flutter/material.dart';
import 'package:smart_food/l10n/app_localizations.dart';

extension L10nBuildContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  bool get isArabic => Localizations.localeOf(this).languageCode == 'ar';

  String tr(String key) => _translateKey(l10n, key);
}

extension AppLocalizationsLegacyX on AppLocalizations {
  String tr(String key) => _translateKey(this, key);
}

String _translateKey(AppLocalizations l10n, String key) {
  switch (key) {
    case 'appName':
      return l10n.appName;
    case 'home':
      return l10n.home;
    case 'categories':
      return l10n.categories;
    case 'orders':
      return l10n.orders;
    case 'plans':
      return l10n.plans;
    case 'profile':
      return l10n.profile;
    case 'account':
      return l10n.account;
    case 'editProfile':
      return l10n.editProfile;
    case 'healthGoals':
      return l10n.healthGoals;
    case 'dietaryPreferences':
      return l10n.dietaryPreferences;
    case 'dailyRoutine':
      return l10n.dailyRoutine;
    case 'orderHistory':
      return l10n.orderHistory;
    case 'addresses':
      return l10n.addresses;
    case 'manageAddresses':
      return l10n.manageAddresses;
    case 'payments':
      return l10n.payments;
    case 'paymentMethods':
      return l10n.paymentMethods;
    case 'myWallet':
      return l10n.myWallet;
    case 'rewards':
      return l10n.rewards;
    case 'myPointsRewards':
      return l10n.myPointsRewards;
    case 'referFriend':
      return l10n.referFriend;
    case 'settings':
      return l10n.settings;
    case 'notifications':
      return l10n.notifications;
    case 'appTheme':
      return l10n.appTheme;
    case 'language':
      return l10n.language;
    case 'support':
      return l10n.support;
    case 'helpCenter':
      return l10n.helpCenter;
    case 'contactUs':
      return l10n.contactUs;
    case 'reportIssue':
      return l10n.reportIssue;
    case 'legal':
      return l10n.legal;
    case 'termsOfService':
      return l10n.termsOfService;
    case 'privacyPolicy':
      return l10n.privacyPolicy;
    case 'about':
      return l10n.about;
    case 'logOut':
      return l10n.logOut;
    case 'version':
      return l10n.version;
    case 'userName':
      return l10n.userName;
    case 'goldPoints':
      return l10n.goldPoints;
    case 'selectLanguage':
      return l10n.selectLanguage;
    case 'english':
      return l10n.english;
    case 'arabic':
      return l10n.arabic;
    default:
      return key;
  }
}

extension DynamicLocalizationX on String {
  String localize(BuildContext context) {
    if (!context.isArabic) return this;
    return _dynamicArMap[this] ?? this;
  }
}

const Map<String, String> _dynamicArMap = {
  'Daily Meals': 'وجبات يومية',
  'Smart Salads': 'سلطات ذكية',
  'Functional Snacks': 'سناكس وظيفية',
  'Gym Performance': 'أداء رياضي',
  'Kids Meals': 'وجبات الأطفال',
  'Digestive Comfort': 'راحة الهضم',
  'Night & Calm': 'ليل وهدوء',
  'Meal Bundles': 'باقات الوجبات',
  'Energy Boosting Meals': 'وجبات تعزيز الطاقة',
  'Filling & Satisfying': 'مشبعة ومُرضية',
  'Light & Fresh': 'خفيفة وطازجة',
  'Post-Workout Recovery': 'تعافي بعد التمرين',
  'Comfort & Calm': 'راحة وهدوء',
  'Gentle on Digestion': 'لطيف على الهضم',
  'Sleep-Friendly Options': 'خيارات مناسبة للنوم',
  'Kid-Approved Meals': 'وجبات يحبها الأطفال',
  'Suhoor Sustaining Meals': 'وجبات سحور مشبعة',
  'All Meals': 'كل الوجبات',
  'Balanced meals for everyday nutrition': 'وجبات متوازنة لتغذية يومية',
  'Fresh and nutritious salads': 'سلطات طازجة ومغذية',
  'Healthy snacks to fuel your day': 'وجبات خفيفة صحية تمنحك طاقة',
  'High-protein meals for athletes': 'وجبات عالية البروتين للرياضيين',
  'Nutritious and fun meals for kids': 'وجبات مغذية وممتعة للأطفال',
  'Easy to digest, gentle meals': 'وجبات خفيفة وسهلة الهضم',
  'Light meals for better sleep': 'وجبات خفيفة لنوم أفضل',
  'Value bundles for the whole day': 'باقات اقتصادية لليوم بالكامل',
  'Grilled Salmon Power Bowl': 'باول سلمون مشوي للطاقة',
  'Mediterranean Chicken Salad': 'سلطة الدجاج المتوسطية',
  'Energy Boost Smoothie Bowl': 'باول سموثي تعزيز الطاقة',
  'Protein Packed Omelette': 'أومليت غني بالبروتين',
  'Calming Chamomile Porridge': 'شوفان البابونج المهدئ',
  'Wild-caught salmon fillet served with quinoa, roasted vegetables, and a lemon tahini dressing. Perfect for sustained energy and muscle recovery.':
      'فيليه سلمون بري مع كينوا وخضار مشوية وصلصة طحينة بالليمون. مثالي للطاقة المستمرة وتعافي العضلات.',
  'Grilled chicken breast with mixed greens, cherry tomatoes, cucumber, feta cheese, and olive oil dressing.':
      'صدر دجاج مشوي مع خضار ورقية وطماطم شيري وخيار وجبن فيتا وتتبيلة زيت الزيتون.',
  'Acai, banana, and berry smoothie topped with granola, chia seeds, and fresh fruits.':
      'سموثي أساي بالموز والتوت مع جرانولا وبذور الشيا وفواكه طازجة.',
  'Three-egg omelette with spinach, mushrooms, cheese, and turkey bacon. Served with whole grain toast.':
      'أومليت من ثلاث بيضات مع سبانخ وفطر وجبن وتركى بيكون. يقدم مع خبز حبوب كاملة.',
  'Warm oatmeal infused with chamomile, honey, and topped with bananas and walnuts. Perfect before bedtime.':
      'شوفان دافئ بنكهة البابونج والعسل مع شرائح موز وجوز. مثالي قبل النوم.',
  'Regular': 'عادي',
  'Large': 'كبير',
  'Extra Protein': 'بروتين إضافي',
  'Modifications': 'تعديلات',
  'Carb Options': 'خيارات الكربوهيدرات',
  'Extra Salmon (+50g)': 'سلمون إضافي (+50جم)',
  'Add Grilled Chicken': 'إضافة دجاج مشوي',
  'Add 2 Boiled Eggs': 'إضافة 2 بيضة مسلوقة',
  'No Sauce': 'بدون صوص',
  'Sauce on Side': 'الصوص على الجانب',
  'Extra Vegetables': 'خضار إضافية',
  'Quinoa (default)': 'كينوا (افتراضي)',
  'Brown Rice': 'أرز بني',
  'No Carbs': 'بدون كربوهيدرات',
  'Customizations': 'التخصيصات',
  'What this meal does for you': 'ما تقدمه لك هذه الوجبة',
  'Gentle on insulin': 'لطيف على الإنسولين',
  'Kid friendly': 'مناسب للأطفال',
  'Post-Workout': 'بعد التمرين',
  'High Energy': 'طاقة عالية',
  'Weight Loss': 'إنقاص الوزن',
  'Light Meal': 'وجبة خفيفة',
  'Digestion': 'الهضم',
  'Morning Energy': 'طاقة الصباح',
  'Pre-Workout': 'قبل التمرين',
  'Kids': 'الأطفال',
  'Breakfast': 'الفطور',
  'Muscle Building': 'بناء العضلات',
  'Sleep': 'النوم',
  'Relaxation': 'الاسترخاء',
  'High Protein': 'بروتين عالي',
  'Omega-3 Rich': 'غني بالأوميغا 3',
  'Gluten-Free Option': 'خيار خالٍ من الجلوتين',
  'Low Carb': 'قليل الكربوهيدرات',
  'Keto-Friendly': 'مناسب للكيتو',
  'Vegan': 'نباتي',
  'High Fiber': 'ألياف عالية',
  'Antioxidant Rich': 'غني بمضادات الأكسدة',
  'Vegetarian': 'نباتي (مع ألبان/بيض)',
  'Sleep Support': 'دعم النوم',
};
