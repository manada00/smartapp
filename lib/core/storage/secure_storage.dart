import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

abstract class SecureStorage {
  factory SecureStorage() {
    if (!kIsWeb && (Platform.isMacOS || Platform.isLinux || Platform.isWindows)) {
      return _HiveSecureStorage();
    }
    return _KeychainSecureStorage();
  }

  static Future<void> initIfNeeded() async {
    if (!kIsWeb && (Platform.isMacOS || Platform.isLinux || Platform.isWindows)) {
      await _HiveSecureStorage.init();
    }
  }

  Future<void> setAccessToken(String token);
  Future<String?> getAccessToken();
  Future<void> setRefreshToken(String token);
  Future<String?> getRefreshToken();
  Future<void> setUserId(String userId);
  Future<String?> getUserId();
  Future<void> clearTokens();
  Future<void> clearAll();
  Future<bool> hasValidSession();
}

class _KeychainSecureStorage implements SecureStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  @override
  Future<void> setAccessToken(String token) async {
    await _storage.write(key: StorageKeys.accessToken, value: token);
  }

  @override
  Future<String?> getAccessToken() async {
    return _storage.read(key: StorageKeys.accessToken);
  }

  @override
  Future<void> setRefreshToken(String token) async {
    await _storage.write(key: StorageKeys.refreshToken, value: token);
  }

  @override
  Future<String?> getRefreshToken() async {
    return _storage.read(key: StorageKeys.refreshToken);
  }

  @override
  Future<void> setUserId(String userId) async {
    await _storage.write(key: StorageKeys.userId, value: userId);
  }

  @override
  Future<String?> getUserId() async {
    return _storage.read(key: StorageKeys.userId);
  }

  @override
  Future<void> clearTokens() async {
    await _storage.delete(key: StorageKeys.accessToken);
    await _storage.delete(key: StorageKeys.refreshToken);
  }

  @override
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  @override
  Future<bool> hasValidSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}

class _HiveSecureStorage implements SecureStorage {
  static const String _boxName = 'secure_storage';

  Box get _box => Hive.box(_boxName);

  static Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
  }

  @override
  Future<void> setAccessToken(String token) async {
    await _box.put(StorageKeys.accessToken, token);
  }

  @override
  Future<String?> getAccessToken() async {
    return _box.get(StorageKeys.accessToken) as String?;
  }

  @override
  Future<void> setRefreshToken(String token) async {
    await _box.put(StorageKeys.refreshToken, token);
  }

  @override
  Future<String?> getRefreshToken() async {
    return _box.get(StorageKeys.refreshToken) as String?;
  }

  @override
  Future<void> setUserId(String userId) async {
    await _box.put(StorageKeys.userId, userId);
  }

  @override
  Future<String?> getUserId() async {
    return _box.get(StorageKeys.userId) as String?;
  }

  @override
  Future<void> clearTokens() async {
    await _box.delete(StorageKeys.accessToken);
    await _box.delete(StorageKeys.refreshToken);
  }

  @override
  Future<void> clearAll() async {
    await _box.clear();
  }

  @override
  Future<bool> hasValidSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
