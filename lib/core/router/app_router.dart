import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/food_model.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/auth/phone_login_screen.dart';
import '../../presentation/screens/auth/otp_verification_screen.dart';
import '../../presentation/screens/profile_setup/profile_setup_screen.dart';
import '../../presentation/screens/profile_setup/health_goals_screen.dart';
import '../../presentation/screens/profile_setup/dietary_preferences_screen.dart';
import '../../presentation/screens/profile_setup/daily_routine_screen.dart';
import '../../presentation/screens/addresses/add_address_screen.dart';
import '../../presentation/screens/home/entry_decision_screen.dart';
import '../../presentation/screens/home/guided_mood_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/home/main_shell.dart';
import '../../presentation/screens/recommendations/recommendations_screen.dart';
import '../../presentation/screens/food_detail/food_detail_screen.dart';
import '../../presentation/screens/categories/categories_screen.dart';
import '../../presentation/screens/categories/category_detail_screen.dart';
import '../../presentation/screens/cart/cart_screen.dart';
import '../../presentation/screens/checkout/checkout_screen.dart';
import '../../presentation/screens/orders/orders_screen.dart';
import '../../presentation/screens/order_tracking/order_tracking_screen.dart';
import '../../presentation/screens/subscriptions/subscriptions_screen.dart';
import '../../presentation/screens/subscriptions/subscription_detail_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/profile/edit_profile_screen.dart';
import '../../presentation/screens/addresses/manage_addresses_screen.dart';
import '../../presentation/screens/wallet/wallet_screen.dart';
import '../../presentation/screens/rewards/rewards_screen.dart';
import '../../presentation/screens/payments/payment_methods_screen.dart';
import '../../presentation/screens/notifications/notifications_screen.dart';
import '../../presentation/screens/notifications/notification_settings_screen.dart';
import '../../presentation/screens/support/help_center_screen.dart';
import '../../presentation/screens/support/contact_support_screen.dart';
import '../../presentation/screens/referral/refer_friend_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: Routes.phoneLogin,
        builder: (context, state) => const PhoneLoginScreen(),
      ),
      GoRoute(
        path: Routes.otpVerification,
        builder: (context, state) {
          final phone = state.extra as String? ?? '';
          return OtpVerificationScreen(phoneNumber: phone);
        },
      ),
      GoRoute(
        path: Routes.profileSetup,
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: Routes.healthGoals,
        builder: (context, state) => const HealthGoalsScreen(),
      ),
      GoRoute(
        path: Routes.dietaryPreferences,
        builder: (context, state) => const DietaryPreferencesScreen(),
      ),
      GoRoute(
        path: Routes.dailyRoutine,
        builder: (context, state) => const DailyRoutineScreen(),
      ),
      GoRoute(
        path: Routes.addAddress,
        builder: (context, state) => const AddAddressScreen(),
      ),
      GoRoute(
        path: Routes.entry,
        builder: (context, state) => const EntryDecisionScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: Routes.home,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: Routes.categories,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CategoriesScreen()),
          ),
          GoRoute(
            path: Routes.orders,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: OrdersScreen()),
          ),
          GoRoute(
            path: Routes.subscriptions,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SubscriptionsScreen()),
          ),
          GoRoute(
            path: Routes.profile,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
          GoRoute(
            path: Routes.guided,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: GuidedMoodScreen()),
          ),
        ],
      ),
      GoRoute(
        path: Routes.recommendations,
        builder: (context, state) {
          final feeling = state.extra as FeelingType? ?? FeelingType.browseAll;
          return RecommendationsScreen(feeling: feeling);
        },
      ),
      GoRoute(
        path: '${Routes.foodDetail}/:id',
        builder: (context, state) {
          final foodId = state.pathParameters['id']!;
          return FoodDetailScreen(foodId: foodId);
        },
      ),
      GoRoute(
        path: '${Routes.categoryDetail}/:id',
        builder: (context, state) {
          final categoryId = state.pathParameters['id']!;
          final categoryName = state.extra as String? ?? 'Category';
          return CategoryDetailScreen(
            categoryId: categoryId,
            categoryName: categoryName,
          );
        },
      ),
      GoRoute(
        path: Routes.cart,
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: Routes.checkout,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '${Routes.orderTracking}/:id',
        builder: (context, state) {
          final orderId = state.pathParameters['id']!;
          return OrderTrackingScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '${Routes.subscriptionDetail}/:id',
        builder: (context, state) {
          final planId = state.pathParameters['id']!;
          return SubscriptionDetailScreen(planId: planId);
        },
      ),
      GoRoute(
        path: Routes.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: Routes.manageAddresses,
        builder: (context, state) => const ManageAddressesScreen(),
      ),
      GoRoute(
        path: Routes.wallet,
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        path: Routes.rewards,
        builder: (context, state) => const RewardsScreen(),
      ),
      GoRoute(
        path: Routes.paymentMethods,
        builder: (context, state) => const PaymentMethodsScreen(),
      ),
      GoRoute(
        path: Routes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: Routes.notificationSettings,
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: Routes.helpCenter,
        builder: (context, state) => const HelpCenterScreen(),
      ),
      GoRoute(
        path: Routes.contactSupport,
        builder: (context, state) => const ContactSupportScreen(),
      ),
      GoRoute(
        path: Routes.referFriend,
        builder: (context, state) => const ReferFriendScreen(),
      ),
    ],
  );
}

class Routes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const phoneLogin = '/login';
  static const otpVerification = '/otp';
  static const profileSetup = '/setup/profile';
  static const healthGoals = '/setup/goals';
  static const dietaryPreferences = '/setup/preferences';
  static const dailyRoutine = '/setup/routine';
  static const addAddress = '/setup/address';
  static const entry = '/entry';
  static const home = '/home';
  static const categories = '/categories';
  static const orders = '/orders';
  static const subscriptions = '/subscriptions';
  static const profile = '/profile';
  static const guided = '/guided';
  static const recommendations = '/recommendations';
  static const foodDetail = '/food';
  static const categoryDetail = '/category';
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const orderTracking = '/tracking';
  static const subscriptionDetail = '/subscription';
  static const editProfile = '/profile/edit';
  static const manageAddresses = '/addresses';
  static const wallet = '/wallet';
  static const rewards = '/rewards';
  static const paymentMethods = '/payment-methods';
  static const notifications = '/notifications';
  static const notificationSettings = '/notifications/settings';
  static const helpCenter = '/help';
  static const contactSupport = '/contact';
  static const referFriend = '/referral';
}
