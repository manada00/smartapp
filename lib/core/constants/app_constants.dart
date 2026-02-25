class AppConstants {
  AppConstants._();

  static const String appName = 'Smart Food';
  static const String appTagline = 'Eat for how you feel';
  static const String currency = 'EGP';
  static const String countryCode = '+20';
  static const String countryFlag = '🇪🇬';

  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration otpResendDuration = Duration(seconds: 45);
  static const Duration otpTimeout = Duration(minutes: 5);
  static const Duration fawryTimeout = Duration(hours: 24);

  static const int otpLength = 6;
  static const int minOrderAmount = 100;
  static const int maxCodAmount = 2000;

  static const List<String> validPhonePrefixes = ['10', '11', '12', '15'];
  static const int phoneLength = 10;

  static const List<String> governorates = ['Cairo', 'Giza', 'Alexandria'];

  static const Map<String, List<String>> areasByGovernorate = {
    'Cairo': [
      'Maadi',
      'Heliopolis',
      'Nasr City',
      'New Cairo',
      'Zamalek',
      'Downtown',
      'Mohandessin',
      'Dokki',
      'Shubra',
      'Ain Shams',
      'El Rehab',
      'Madinet Nasr',
      'Abbasiya',
      'El Marg',
      'El Matariya',
    ],
    'Giza': [
      '6th of October',
      'Sheikh Zayed',
      'Haram',
      'Faisal',
      'Dokki',
      'Mohandessin',
      'Agouza',
      'Imbaba',
      'El Omraniya',
      'Hadayek El Ahram',
    ],
    'Alexandria': [
      'Smouha',
      'Sidi Gaber',
      'Stanley',
      'Miami',
      'Mandara',
      'Gleem',
      'San Stefano',
      'Roushdy',
      'Sporting',
      'Camp Shezar',
    ],
  };
}

class ApiConstants {
  ApiConstants._();

  static const String _apiHost = String.fromEnvironment(
    'API_HOST',
    defaultValue: 'localhost',
  );
  static const String _apiPort = String.fromEnvironment(
    'API_PORT',
    defaultValue: '4000',
  );

  static const String baseUrl = 'http://$_apiHost:$_apiPort/api/v1';
  static const String socketUrl = 'http://$_apiHost:$_apiPort';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Auth endpoints
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String socialLogin = '/auth/social';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';

  // User endpoints
  static const String profile = '/user/profile';
  static const String healthGoals = '/user/health-goals';
  static const String dietaryPreferences = '/user/dietary-preferences';
  static const String dailyRoutine = '/user/daily-routine';

  // Address endpoints
  static const String addresses = '/user/addresses';

  // Food endpoints
  static const String categories = '/food/categories';
  static const String foods = '/food';
  static const String homeConfig = '/food/home-config';
  static const String supportConfig = '/food/support-config';
  static const String recommendations = '/food/recommendations';
  static const String search = '/food/search';

  // Support endpoints
  static const String supportTickets = '/user/support/tickets';

  // Cart endpoints
  static const String cart = '/cart';
  static const String applyCoupon = '/cart/coupon';

  // Order endpoints
  static const String orders = '/orders';
  static const String activeOrders = '/orders/active';
  static const String orderTracking = '/orders/tracking';

  // Payment endpoints
  static const String paymentMethods = '/payments/methods';
  static const String initiatePayment = '/payments/initiate';
  static const String verifyPayment = '/payments/verify';

  // Subscription endpoints
  static const String subscriptions = '/subscriptions';
  static const String subscriptionPlans = '/subscriptions/plans';

  // Wallet endpoints
  static const String wallet = '/wallet';
  static const String walletTransactions = '/wallet/transactions';

  // Rewards endpoints
  static const String rewards = '/rewards';
  static const String redeemReward = '/rewards/redeem';
  static const String referral = '/rewards/referral';
}

class StorageKeys {
  StorageKeys._();

  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String isFirstLaunch = 'is_first_launch';
  static const String isOnboardingComplete = 'is_onboarding_complete';
  static const String userProfile = 'user_profile';
  static const String cartItems = 'cart_items';
  static const String recentSearches = 'recent_searches';
  static const String selectedAddress = 'selected_address';
  static const String themeMode = 'theme_mode';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String appLanguage = 'app_language';
}
