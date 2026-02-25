import 'package:flutter/material.dart';
import 'package:smart_food/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/localization/l10n_extensions.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/storage/local_storage.dart';
import 'core/storage/secure_storage.dart';
import 'presentation/providers/locale_provider.dart';
import 'presentation/widgets/support/support_notification_listener.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize local storage
  await LocalStorage.init();

  // Initialize secure storage (Hive-based fallback for desktop)
  await SecureStorage.initIfNeeded();

  // Initialize Firebase (required for social auth)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization skipped/failed: $e');
  }

  runApp(const ProviderScope(child: SmartFoodApp()));
}

class SmartFoodApp extends ConsumerWidget {
  const SmartFoodApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.tr('appName'),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        return SupportNotificationListener(child: child);
      },
      routerConfig: AppRouter.router,
    );
  }
}
