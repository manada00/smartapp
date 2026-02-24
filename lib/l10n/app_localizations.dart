import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Smart Food'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @plans.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get plans;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @healthGoals.
  ///
  /// In en, this message translates to:
  /// **'Health Goals'**
  String get healthGoals;

  /// No description provided for @dietaryPreferences.
  ///
  /// In en, this message translates to:
  /// **'Dietary Preferences'**
  String get dietaryPreferences;

  /// No description provided for @dailyRoutine.
  ///
  /// In en, this message translates to:
  /// **'Daily Routine'**
  String get dailyRoutine;

  /// No description provided for @orderHistory.
  ///
  /// In en, this message translates to:
  /// **'Order History'**
  String get orderHistory;

  /// No description provided for @addresses.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get addresses;

  /// No description provided for @manageAddresses.
  ///
  /// In en, this message translates to:
  /// **'Manage Addresses'**
  String get manageAddresses;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @myWallet.
  ///
  /// In en, this message translates to:
  /// **'My Wallet'**
  String get myWallet;

  /// No description provided for @rewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewards;

  /// No description provided for @myPointsRewards.
  ///
  /// In en, this message translates to:
  /// **'My Points & Rewards'**
  String get myPointsRewards;

  /// No description provided for @referFriend.
  ///
  /// In en, this message translates to:
  /// **'Refer a Friend'**
  String get referFriend;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @appTheme.
  ///
  /// In en, this message translates to:
  /// **'App Theme'**
  String get appTheme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @reportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get reportIssue;

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'User Name'**
  String get userName;

  /// No description provided for @goldPoints.
  ///
  /// In en, this message translates to:
  /// **'Gold • 2,500 points'**
  String get goldPoints;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @sweetDreams.
  ///
  /// In en, this message translates to:
  /// **'Sweet dreams'**
  String get sweetDreams;

  /// No description provided for @startYourDayRight.
  ///
  /// In en, this message translates to:
  /// **'Start your day right'**
  String get startYourDayRight;

  /// No description provided for @timeToRecharge.
  ///
  /// In en, this message translates to:
  /// **'Time to recharge'**
  String get timeToRecharge;

  /// No description provided for @windDownWithSomethingGood.
  ///
  /// In en, this message translates to:
  /// **'Wind down with something good'**
  String get windDownWithSomethingGood;

  /// No description provided for @lightBiteBeforeBed.
  ///
  /// In en, this message translates to:
  /// **'A light bite before bed?'**
  String get lightBiteBeforeBed;

  /// No description provided for @setDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Set delivery address'**
  String get setDeliveryAddress;

  /// No description provided for @homeHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Household needs, from bread to everything'**
  String get homeHeroTitle;

  /// No description provided for @homeHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fast shopping experience with fresh picks and top deals.'**
  String get homeHeroSubtitle;

  /// No description provided for @quickActionReorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get quickActionReorder;

  /// No description provided for @quickActionFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get quickActionFavorites;

  /// No description provided for @quickActionSpecials.
  ///
  /// In en, this message translates to:
  /// **'Specials'**
  String get quickActionSpecials;

  /// No description provided for @howDoYouWantToFeel.
  ///
  /// In en, this message translates to:
  /// **'How do you want to feel today?'**
  String get howDoYouWantToFeel;

  /// No description provided for @howDoYouWantToFeelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a mood and we will guide your next meal.'**
  String get howDoYouWantToFeelSubtitle;

  /// No description provided for @browseByCategory.
  ///
  /// In en, this message translates to:
  /// **'Browse by Category'**
  String get browseByCategory;

  /// No description provided for @popularRightNow.
  ///
  /// In en, this message translates to:
  /// **'Popular Right Now'**
  String get popularRightNow;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @recommendedNow.
  ///
  /// In en, this message translates to:
  /// **'Recommended now'**
  String get recommendedNow;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorPrefix;

  /// No description provided for @searchForMeals.
  ///
  /// In en, this message translates to:
  /// **'Search for meals...'**
  String get searchForMeals;

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemsCount(int count);

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @highProtein.
  ///
  /// In en, this message translates to:
  /// **'High Protein'**
  String get highProtein;

  /// No description provided for @lowCarb.
  ///
  /// In en, this message translates to:
  /// **'Low Carb'**
  String get lowCarb;

  /// No description provided for @under150Egp.
  ///
  /// In en, this message translates to:
  /// **'Under 150 EGP'**
  String get under150Egp;

  /// No description provided for @quickUnder15Min.
  ///
  /// In en, this message translates to:
  /// **'Quick < 15min'**
  String get quickUnder15Min;

  /// No description provided for @perfectForYou.
  ///
  /// In en, this message translates to:
  /// **'Perfect for you'**
  String get perfectForYou;

  /// No description provided for @perfectForYouSubtitle.
  ///
  /// In en, this message translates to:
  /// **'These match exactly what your body needs'**
  String get perfectForYouSubtitle;

  /// No description provided for @alsoGreatChoices.
  ///
  /// In en, this message translates to:
  /// **'Also great choices'**
  String get alsoGreatChoices;

  /// No description provided for @alsoGreatChoicesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Solid options that support your goals'**
  String get alsoGreatChoicesSubtitle;

  /// No description provided for @maybeNotRightNow.
  ///
  /// In en, this message translates to:
  /// **'Maybe not right now'**
  String get maybeNotRightNow;

  /// No description provided for @maybeNotRightNowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'These might not be the best fit today'**
  String get maybeNotRightNowSubtitle;

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'{name} added to cart'**
  String addedToCart(Object name);

  /// No description provided for @viewCart.
  ///
  /// In en, this message translates to:
  /// **'View Cart'**
  String get viewCart;

  /// No description provided for @reviewsCount.
  ///
  /// In en, this message translates to:
  /// **'{rating} ({count} reviews)'**
  String reviewsCount(Object rating, int count);

  /// No description provided for @readyInMin.
  ///
  /// In en, this message translates to:
  /// **'Ready in {minutes} min'**
  String readyInMin(int minutes);

  /// No description provided for @bestFor.
  ///
  /// In en, this message translates to:
  /// **'Best For'**
  String get bestFor;

  /// No description provided for @portionSize.
  ///
  /// In en, this message translates to:
  /// **'Portion Size'**
  String get portionSize;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @extraCost.
  ///
  /// In en, this message translates to:
  /// **'+EGP {price}'**
  String extraCost(Object price);

  /// No description provided for @specialInstructions.
  ///
  /// In en, this message translates to:
  /// **'Special Instructions'**
  String get specialInstructions;

  /// No description provided for @specialInstructionsHint.
  ///
  /// In en, this message translates to:
  /// **'Any allergies or preferences?'**
  String get specialInstructionsHint;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @addToCartPrice.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart • EGP {price}'**
  String addToCartPrice(Object price);

  /// No description provided for @greatPickForMorning.
  ///
  /// In en, this message translates to:
  /// **'Great pick for the morning'**
  String get greatPickForMorning;

  /// No description provided for @keepsYouFullLonger.
  ///
  /// In en, this message translates to:
  /// **'Keeps you full longer'**
  String get keepsYouFullLonger;

  /// No description provided for @perfectBeforeBedtime.
  ///
  /// In en, this message translates to:
  /// **'Perfect before bedtime'**
  String get perfectBeforeBedtime;

  /// No description provided for @gentleOnYourStomach.
  ///
  /// In en, this message translates to:
  /// **'Gentle on your stomach'**
  String get gentleOnYourStomach;

  /// No description provided for @helpsYouStayFocused.
  ///
  /// In en, this message translates to:
  /// **'Helps you stay focused'**
  String get helpsYouStayFocused;

  /// No description provided for @keepsYouFull.
  ///
  /// In en, this message translates to:
  /// **'Keeps you full'**
  String get keepsYouFull;

  /// No description provided for @steadyEnergy.
  ///
  /// In en, this message translates to:
  /// **'Steady energy'**
  String get steadyEnergy;

  /// No description provided for @easyToDigest.
  ///
  /// In en, this message translates to:
  /// **'Easy to digest'**
  String get easyToDigest;

  /// No description provided for @goodBeforeSleep.
  ///
  /// In en, this message translates to:
  /// **'Good before sleep'**
  String get goodBeforeSleep;

  /// No description provided for @focusSupport.
  ///
  /// In en, this message translates to:
  /// **'Focus support'**
  String get focusSupport;

  /// No description provided for @workoutFuel.
  ///
  /// In en, this message translates to:
  /// **'Workout fuel'**
  String get workoutFuel;

  /// No description provided for @boostMyEnergy.
  ///
  /// In en, this message translates to:
  /// **'Boost my energy'**
  String get boostMyEnergy;

  /// No description provided for @needSomethingFilling.
  ///
  /// In en, this message translates to:
  /// **'I need something filling'**
  String get needSomethingFilling;

  /// No description provided for @keepItLight.
  ///
  /// In en, this message translates to:
  /// **'Keep it light for me'**
  String get keepItLight;

  /// No description provided for @refuelAfterTraining.
  ///
  /// In en, this message translates to:
  /// **'Refuel after training'**
  String get refuelAfterTraining;

  /// No description provided for @helpMeFeelCalm.
  ///
  /// In en, this message translates to:
  /// **'Help me feel calm'**
  String get helpMeFeelCalm;

  /// No description provided for @easeHeaviness.
  ///
  /// In en, this message translates to:
  /// **'Ease the heaviness'**
  String get easeHeaviness;

  /// No description provided for @helpMeWindDown.
  ///
  /// In en, this message translates to:
  /// **'Help me wind down'**
  String get helpMeWindDown;

  /// No description provided for @pickForMyKid.
  ///
  /// In en, this message translates to:
  /// **'Pick for my kid'**
  String get pickForMyKid;

  /// No description provided for @prepForFast.
  ///
  /// In en, this message translates to:
  /// **'Prep for tomorrow’s fast'**
  String get prepForFast;

  /// No description provided for @showMeGoodOptions.
  ///
  /// In en, this message translates to:
  /// **'Show me good options'**
  String get showMeGoodOptions;

  /// No description provided for @staySharp.
  ///
  /// In en, this message translates to:
  /// **'Stay sharp for the next few hours'**
  String get staySharp;

  /// No description provided for @balancedMealsSatisfy.
  ///
  /// In en, this message translates to:
  /// **'Balanced meals that satisfy longer'**
  String get balancedMealsSatisfy;

  /// No description provided for @gentleChoicesEasy.
  ///
  /// In en, this message translates to:
  /// **'Gentle choices that feel easy'**
  String get gentleChoicesEasy;

  /// No description provided for @proteinRecovery.
  ///
  /// In en, this message translates to:
  /// **'Protein-forward picks for recovery'**
  String get proteinRecovery;

  /// No description provided for @comfortSteadyEnergy.
  ///
  /// In en, this message translates to:
  /// **'Comforting meals with steady energy'**
  String get comfortSteadyEnergy;

  /// No description provided for @softerOptions.
  ///
  /// In en, this message translates to:
  /// **'Softer options to feel better soon'**
  String get softerOptions;

  /// No description provided for @lighterDinners.
  ///
  /// In en, this message translates to:
  /// **'Lighter dinners for a calmer night'**
  String get lighterDinners;

  /// No description provided for @kidsEnjoy.
  ///
  /// In en, this message translates to:
  /// **'Nutritious meals kids actually enjoy'**
  String get kidsEnjoy;

  /// No description provided for @preFastMeals.
  ///
  /// In en, this message translates to:
  /// **'Smart pre-fast meals for steady fuel'**
  String get preFastMeals;

  /// No description provided for @exploreByMood.
  ///
  /// In en, this message translates to:
  /// **'Explore all recommendations by mood'**
  String get exploreByMood;

  /// No description provided for @balancedCarbsProtein.
  ///
  /// In en, this message translates to:
  /// **'Balanced carbs + protein to avoid crashes.'**
  String get balancedCarbsProtein;

  /// No description provided for @fullnessPortion.
  ///
  /// In en, this message translates to:
  /// **'Curated for fullness and better portion control.'**
  String get fullnessPortion;

  /// No description provided for @lowerHeaviness.
  ///
  /// In en, this message translates to:
  /// **'Lower heaviness so you can stay comfortable.'**
  String get lowerHeaviness;

  /// No description provided for @recoveryFocused.
  ///
  /// In en, this message translates to:
  /// **'Recovery-focused picks chosen by nutrition rules.'**
  String get recoveryFocused;

  /// No description provided for @steadyMood.
  ///
  /// In en, this message translates to:
  /// **'Steady choices selected to keep mood balanced.'**
  String get steadyMood;

  /// No description provided for @gentlerIngredients.
  ///
  /// In en, this message translates to:
  /// **'Gentler ingredients chosen for easier digestion.'**
  String get gentlerIngredients;

  /// No description provided for @eveningFriendly.
  ///
  /// In en, this message translates to:
  /// **'Evening-friendly meals to support better rest.'**
  String get eveningFriendly;

  /// No description provided for @kidApproved.
  ///
  /// In en, this message translates to:
  /// **'Kid-approved options with balanced nutrition.'**
  String get kidApproved;

  /// No description provided for @longLastingEnergy.
  ///
  /// In en, this message translates to:
  /// **'Smart combinations for longer-lasting energy.'**
  String get longLastingEnergy;

  /// No description provided for @exploreAllPaths.
  ///
  /// In en, this message translates to:
  /// **'You can always explore all personalized paths.'**
  String get exploreAllPaths;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
