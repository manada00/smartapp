// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'سمارت فود';

  @override
  String get home => 'الرئيسية';

  @override
  String get categories => 'التصنيفات';

  @override
  String get orders => 'الطلبات';

  @override
  String get plans => 'الخطط';

  @override
  String get profile => 'حسابي';

  @override
  String get account => 'الحساب';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get healthGoals => 'الأهداف الصحية';

  @override
  String get dietaryPreferences => 'التفضيلات الغذائية';

  @override
  String get dailyRoutine => 'الروتين اليومي';

  @override
  String get orderHistory => 'سجل الطلبات';

  @override
  String get addresses => 'العناوين';

  @override
  String get manageAddresses => 'إدارة العناوين';

  @override
  String get payments => 'الدفع';

  @override
  String get paymentMethods => 'طرق الدفع';

  @override
  String get myWallet => 'المحفظة';

  @override
  String get rewards => 'المكافآت';

  @override
  String get myPointsRewards => 'نقاطي ومكافآتي';

  @override
  String get referFriend => 'ادعُ صديقاً';

  @override
  String get settings => 'الإعدادات';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get appTheme => 'مظهر التطبيق';

  @override
  String get language => 'اللغة';

  @override
  String get support => 'الدعم';

  @override
  String get helpCenter => 'مركز المساعدة';

  @override
  String get contactUs => 'تواصل معنا';

  @override
  String get reportIssue => 'الإبلاغ عن مشكلة';

  @override
  String get legal => 'قانوني';

  @override
  String get termsOfService => 'شروط الاستخدام';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get about => 'حول التطبيق';

  @override
  String get logOut => 'تسجيل الخروج';

  @override
  String get version => 'الإصدار';

  @override
  String get userName => 'اسم المستخدم';

  @override
  String get goldPoints => 'ذهبي • ٢٥٠٠ نقطة';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get goodMorning => 'صباح الخير';

  @override
  String get goodAfternoon => 'مساء الخير';

  @override
  String get goodEvening => 'مساء الخير';

  @override
  String get sweetDreams => 'أحلام سعيدة';

  @override
  String get startYourDayRight => 'ابدأ يومك بشكل صحي';

  @override
  String get timeToRecharge => 'حان وقت استعادة النشاط';

  @override
  String get windDownWithSomethingGood => 'اختم يومك بوجبة مناسبة';

  @override
  String get lightBiteBeforeBed => 'وجبة خفيفة قبل النوم؟';

  @override
  String get setDeliveryAddress => 'حدد عنوان التوصيل';

  @override
  String get homeHeroTitle => 'كل احتياجات البيت من الخبز لكل شيء';

  @override
  String get homeHeroSubtitle => 'تجربة تسوق سريعة مع اختيارات طازجة وعروض مميزة.';

  @override
  String get quickActionReorder => 'إعادة الطلب';

  @override
  String get quickActionFavorites => 'المفضلة';

  @override
  String get quickActionSpecials => 'العروض';

  @override
  String get howDoYouWantToFeel => 'كيف تحب أن تشعر اليوم؟';

  @override
  String get howDoYouWantToFeelSubtitle => 'اختر حالتك وسنرشدك لوجبتك القادمة.';

  @override
  String get browseByCategory => 'تصفح حسب التصنيف';

  @override
  String get popularRightNow => 'الأكثر طلباً الآن';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get recommendedNow => 'موصى به الآن';

  @override
  String get errorPrefix => 'خطأ';

  @override
  String get searchForMeals => 'ابحث عن الوجبات...';

  @override
  String itemsCount(int count) {
    return '$count عنصر';
  }

  @override
  String get all => 'الكل';

  @override
  String get highProtein => 'بروتين عالي';

  @override
  String get lowCarb => 'كربوهيدرات أقل';

  @override
  String get under150Egp => 'أقل من 150 جنيه';

  @override
  String get quickUnder15Min => 'سريع أقل من 15 دقيقة';

  @override
  String get perfectForYou => 'مناسب لك جداً';

  @override
  String get perfectForYouSubtitle => 'هذه الخيارات تناسب احتياج جسمك حالياً';

  @override
  String get alsoGreatChoices => 'خيارات ممتازة أيضاً';

  @override
  String get alsoGreatChoicesSubtitle => 'اختيارات قوية تدعم أهدافك';

  @override
  String get maybeNotRightNow => 'قد لا تكون مناسبة الآن';

  @override
  String get maybeNotRightNowSubtitle => 'ربما ليست الأنسب لك اليوم';

  @override
  String addedToCart(Object name) {
    return 'تمت إضافة $name إلى السلة';
  }

  @override
  String get viewCart => 'عرض السلة';

  @override
  String reviewsCount(Object rating, int count) {
    return '$rating ($count تقييم)';
  }

  @override
  String readyInMin(int minutes) {
    return 'جاهز خلال $minutes دقيقة';
  }

  @override
  String get bestFor => 'مناسب لـ';

  @override
  String get portionSize => 'حجم الحصة';

  @override
  String get popular => 'الأكثر شيوعاً';

  @override
  String extraCost(Object price) {
    return '+$price جنيه';
  }

  @override
  String get specialInstructions => 'ملاحظات خاصة';

  @override
  String get specialInstructionsHint => 'هل لديك حساسية أو تفضيلات؟';

  @override
  String get quantity => 'الكمية';

  @override
  String addToCartPrice(Object price) {
    return 'أضف للسلة • $price جنيه';
  }

  @override
  String get greatPickForMorning => 'اختيار ممتاز للصباح';

  @override
  String get keepsYouFullLonger => 'يشعرك بالشبع لفترة أطول';

  @override
  String get perfectBeforeBedtime => 'مناسب قبل النوم';

  @override
  String get gentleOnYourStomach => 'خفيف على المعدة';

  @override
  String get helpsYouStayFocused => 'يساعدك على التركيز';

  @override
  String get keepsYouFull => 'يشعرك بالشبع';

  @override
  String get steadyEnergy => 'طاقة مستقرة';

  @override
  String get easyToDigest => 'سهل الهضم';

  @override
  String get goodBeforeSleep => 'مناسب قبل النوم';

  @override
  String get focusSupport => 'يدعم التركيز';

  @override
  String get workoutFuel => 'وقود للتمرين';

  @override
  String get boostMyEnergy => 'أريد طاقة أكثر';

  @override
  String get needSomethingFilling => 'أريد وجبة مشبعة';

  @override
  String get keepItLight => 'أريد شيئاً خفيفاً';

  @override
  String get refuelAfterTraining => 'استعادة الطاقة بعد التمرين';

  @override
  String get helpMeFeelCalm => 'أريد الشعور بالهدوء';

  @override
  String get easeHeaviness => 'تخفيف الإحساس بالثقل';

  @override
  String get helpMeWindDown => 'ساعدني على الاسترخاء';

  @override
  String get pickForMyKid => 'اختر لطفلي';

  @override
  String get prepForFast => 'استعداد لصيام الغد';

  @override
  String get showMeGoodOptions => 'اعرض خيارات مناسبة';

  @override
  String get staySharp => 'حافظ على تركيزك خلال الساعات القادمة';

  @override
  String get balancedMealsSatisfy => 'وجبات متوازنة تمنحك شبعاً أطول';

  @override
  String get gentleChoicesEasy => 'خيارات خفيفة ومريحة';

  @override
  String get proteinRecovery => 'خيارات غنية بالبروتين للتعافي';

  @override
  String get comfortSteadyEnergy => 'وجبات مريحة بطاقة مستقرة';

  @override
  String get softerOptions => 'خيارات ألطف لتشعر بتحسن سريع';

  @override
  String get lighterDinners => 'عشاء أخف لليلة أكثر هدوءاً';

  @override
  String get kidsEnjoy => 'وجبات مغذية يحبها الأطفال';

  @override
  String get preFastMeals => 'وجبات ذكية قبل الصيام لطاقة ثابتة';

  @override
  String get exploreByMood => 'استكشف التوصيات حسب حالتك';

  @override
  String get balancedCarbsProtein => 'كربوهيدرات متوازنة مع بروتين لتجنب الهبوط المفاجئ.';

  @override
  String get fullnessPortion => 'مختارة للشبع الأفضل والتحكم في الحصص.';

  @override
  String get lowerHeaviness => 'أقل ثقلاً لتشعر براحة أكبر.';

  @override
  String get recoveryFocused => 'خيارات للتعافي حسب أسس غذائية دقيقة.';

  @override
  String get steadyMood => 'خيارات مستقرة لدعم المزاج.';

  @override
  String get gentlerIngredients => 'مكونات ألطف لراحة الهضم.';

  @override
  String get eveningFriendly => 'وجبات مسائية تدعم نوماً أفضل.';

  @override
  String get kidApproved => 'خيارات مناسبة للأطفال ومغذية.';

  @override
  String get longLastingEnergy => 'تركيبات ذكية لطاقة تدوم أطول.';

  @override
  String get exploreAllPaths => 'يمكنك دائماً استكشاف كل المسارات المناسبة لك.';
}
