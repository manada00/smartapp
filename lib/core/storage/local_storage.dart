import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

class LocalStorage {
  static const String _settingsBox = 'settings';
  static const String _cacheBox = 'cache';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_settingsBox);
    await Hive.openBox(_cacheBox);
  }

  Box get _settings => Hive.box(_settingsBox);
  Box get _cache => Hive.box(_cacheBox);

  // First Launch
  bool get isFirstLaunch =>
      _settings.get(StorageKeys.isFirstLaunch, defaultValue: true);

  Future<void> setFirstLaunchComplete() async {
    await _settings.put(StorageKeys.isFirstLaunch, false);
  }

  // Onboarding
  bool get isOnboardingComplete =>
      _settings.get(StorageKeys.isOnboardingComplete, defaultValue: false);

  Future<void> setOnboardingComplete() async {
    await _settings.put(StorageKeys.isOnboardingComplete, true);
  }

  // Theme
  String get themeMode =>
      _settings.get(StorageKeys.themeMode, defaultValue: 'system');

  Future<void> setThemeMode(String mode) async {
    await _settings.put(StorageKeys.themeMode, mode);
  }

  // Language
  String get appLanguage =>
      _settings.get(StorageKeys.appLanguage, defaultValue: 'en');

  Future<void> setAppLanguage(String languageCode) async {
    await _settings.put(StorageKeys.appLanguage, languageCode);
  }

  // Notifications
  bool get notificationsEnabled =>
      _settings.get(StorageKeys.notificationsEnabled, defaultValue: true);

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _settings.put(StorageKeys.notificationsEnabled, enabled);
  }

  // Recent Searches
  List<String> get recentSearches {
    final searches = _cache.get(StorageKeys.recentSearches);
    if (searches == null) return [];
    return List<String>.from(searches);
  }

  Future<void> addRecentSearch(String query) async {
    final searches = recentSearches;
    searches.remove(query);
    searches.insert(0, query);
    if (searches.length > 10) {
      searches.removeLast();
    }
    await _cache.put(StorageKeys.recentSearches, searches);
  }

  Future<void> clearRecentSearches() async {
    await _cache.delete(StorageKeys.recentSearches);
  }

  // Selected Address ID
  String? get selectedAddressId => _settings.get(StorageKeys.selectedAddress);

  Future<void> setSelectedAddressId(String? id) async {
    if (id == null) {
      await _settings.delete(StorageKeys.selectedAddress);
    } else {
      await _settings.put(StorageKeys.selectedAddress, id);
    }
  }

  // Generic cache methods
  Future<void> cacheData(String key, dynamic data) async {
    await _cache.put(key, data);
  }

  T? getCachedData<T>(String key) {
    return _cache.get(key) as T?;
  }

  Future<void> clearCache() async {
    await _cache.clear();
  }

  Future<void> clearAll() async {
    await _settings.clear();
    await _cache.clear();
  }
}
