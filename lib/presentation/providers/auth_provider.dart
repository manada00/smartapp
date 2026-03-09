import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/app_constants.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/storage/local_storage.dart';
import '../../data/models/user_model.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());
final localStorageProvider = Provider<LocalStorage>((ref) => LocalStorage());

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(ref.watch(secureStorageProvider));
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(secureStorageProvider),
    ref.watch(localStorageProvider),
    ref.watch(dioClientProvider),
  );
});

class AkedlyOtpStartResponse {
  final String iframeUrl;
  final String attemptId;

  const AkedlyOtpStartResponse({
    required this.iframeUrl,
    required this.attemptId,
  });
}

class AuthNotifier extends StateNotifier<AuthState> {
  final SecureStorage _secureStorage;
  final LocalStorage _localStorage;
  final DioClient _dioClient;

  AuthNotifier(this._secureStorage, this._localStorage, this._dioClient)
    : super(const AuthState.initial());

  Future<void> checkAuthState() async {
    state = const AuthState.loading();

    final hasSession = await _secureStorage.hasValidSession();
    final isFirstLaunch = _localStorage.isFirstLaunch;
    final isOnboardingComplete = _localStorage.isOnboardingComplete;

    if (isFirstLaunch) {
      state = const AuthState.unauthenticated(showOnboarding: true);
    } else if (!hasSession) {
      state = const AuthState.unauthenticated(showOnboarding: false);
    } else if (!isOnboardingComplete) {
      state = const AuthState.needsOnboarding();
    } else {
      state = const AuthState.authenticated();
    }
  }

  Future<void> sendOtp(String phone) async {
    state = const AuthState.loading();
    try {
      await _dioClient.post(ApiConstants.sendOtp, data: {'phone': phone});
      state = AuthState.otpSent(phone);
    } catch (e) {
      state = AuthState.error(e.toString());
      rethrow;
    }
  }

  Future<AkedlyOtpStartResponse> startAkedlyOtp(String phoneNumber) async {
    state = const AuthState.loading();
    try {
      final response = await _dioClient.post(
        ApiConstants.startOtpAttempt,
        data: {'phoneNumber': phoneNumber},
      );

      final body = response.data as Map<String, dynamic>? ?? {};
      final iframeUrl = (body['iframeUrl'] ?? '').toString().trim();
      final attemptId = (body['attemptId'] ?? '').toString().trim();

      if (body['success'] != true || iframeUrl.isEmpty || attemptId.isEmpty) {
        throw Exception(
          _extractApiErrorMessage(
            body,
            fallback: 'Unable to start OTP verification',
          ),
        );
      }

      state = const AuthState.unauthenticated(showOnboarding: false);

      return AkedlyOtpStartResponse(iframeUrl: iframeUrl, attemptId: attemptId);
    } on DioException catch (e) {
      final data = e.response?.data;
      final statusCode = e.response?.statusCode;

      final message = switch (statusCode) {
        429 => 'Too many OTP attempts. Please try again shortly.',
        _ => _extractApiErrorMessage(
          data,
          fallback: 'Unable to start OTP verification',
        ),
      };

      state = AuthState.error(message);
      rethrow;
    } catch (e) {
      final message = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : e.toString();
      state = AuthState.error(message);
      rethrow;
    }
  }

  Future<bool> completeAkedlySession({
    required String status,
    String? attemptId,
    String? transactionId,
  }) async {
    state = const AuthState.loading();

    final normalizedStatus = status.toLowerCase();
    if (normalizedStatus != 'success') {
      state = AuthState.error('OTP verification failed. Please try again.');
      return false;
    }

    if ((attemptId == null || attemptId.isEmpty) &&
        (transactionId == null || transactionId.isEmpty)) {
      state = AuthState.error('Missing OTP verification reference.');
      return false;
    }

    final timeoutAt = DateTime.now().add(const Duration(seconds: 30));

    while (DateTime.now().isBefore(timeoutAt)) {
      try {
        final response = await _dioClient.get(
          ApiConstants.otpSession,
          queryParameters: {
            if (attemptId != null && attemptId.isNotEmpty)
              'attemptId': attemptId,
            if (transactionId != null && transactionId.isNotEmpty)
              'transactionId': transactionId,
          },
        );

        final body = response.data as Map<String, dynamic>? ?? {};
        if (body['pending'] == true) {
          await Future<void>.delayed(const Duration(seconds: 2));
          continue;
        }

        if (body['failed'] == true) {
          state = AuthState.error(
            _extractApiErrorMessage(body, fallback: 'OTP verification failed'),
          );
          return false;
        }

        if (body['success'] != true) {
          final message = _extractApiErrorMessage(
            body,
            fallback: 'OTP verification did not complete',
          );
          state = AuthState.error(message);
          return false;
        }

        final data = body['data'] as Map<String, dynamic>?;
        if (data == null) {
          state = const AuthState.error('Missing login session data.');
          return false;
        }

        final accessToken = (data['accessToken'] ?? '').toString();
        final refreshToken = (data['refreshToken'] ?? '').toString();
        final user = data['user'] as Map<String, dynamic>? ?? {};

        if (accessToken.isEmpty || refreshToken.isEmpty || user['id'] == null) {
          state = const AuthState.error('Invalid login session payload.');
          return false;
        }

        await _secureStorage.setAccessToken(accessToken);
        await _secureStorage.setRefreshToken(refreshToken);
        await _secureStorage.setUserId(user['id'].toString());
        await _localStorage.setFirstLaunchComplete();

        final isNewUser = data['isNewUser'] == true;
        if (isNewUser) {
          state = const AuthState.needsOnboarding();
        } else {
          await _localStorage.setOnboardingComplete();
          state = const AuthState.authenticated();
        }

        return true;
      } on DioException catch (e) {
        final statusCode = e.response?.statusCode;
        if (statusCode == 202) {
          await Future<void>.delayed(const Duration(seconds: 2));
          continue;
        }

        final message = switch (statusCode) {
          429 => 'Too many verification requests. Please try again shortly.',
          _ => _extractApiErrorMessage(
            e.response?.data,
            fallback: 'Unable to complete OTP verification',
          ),
        };

        state = AuthState.error(message);
        return false;
      } catch (e) {
        state = AuthState.error(e.toString());
        return false;
      }
    }

    state = const AuthState.error('Verification timed out. Please try again.');
    return false;
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    state = const AuthState.loading();
    try {
      bool isNewUser = true;
      try {
        final response = await _dioClient.post(
          ApiConstants.verifyOtp,
          data: {'phone': phone, 'otp': otp},
        );

        if (response.data['success'] == true) {
          final data = response.data['data'];
          await _secureStorage.setAccessToken(data['accessToken']);
          await _secureStorage.setRefreshToken(data['refreshToken']);
          await _secureStorage.setUserId(data['user']['id']);
          isNewUser = data['isNewUser'] ?? true;
        } else {
          state = AuthState.error(response.data['message'] ?? 'Invalid OTP');
          return false;
        }
      } on DioException catch (e) {
        state = AuthState.error(
          e.response?.data?['message'] ?? 'Invalid or expired OTP',
        );
        return false;
      } catch (e) {
        state = AuthState.error(e.toString());
        return false;
      }

      await _localStorage.setFirstLaunchComplete();

      if (isNewUser) {
        state = const AuthState.needsOnboarding();
      } else {
        await _localStorage.setOnboardingComplete();
        state = const AuthState.authenticated();
      }
      return true;
    } catch (e) {
      state = AuthState.error(e.toString());
      return false;
    }
  }

  Future<void> socialLogin(SocialProvider provider) async {
    state = const AuthState.loading();
    try {
      final idToken = await _getSocialFirebaseIdToken(provider);
      if (idToken == null || idToken.isEmpty) {
        throw Exception('Unable to get social auth token.');
      }

      final response = await _dioClient.post(
        ApiConstants.socialLogin,
        data: {'provider': provider.name, 'idToken': idToken},
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Social login failed');
      }

      final data = response.data['data'] as Map<String, dynamic>;
      final user = data['user'] as Map<String, dynamic>;

      await _secureStorage.setAccessToken(data['accessToken'] as String);
      await _secureStorage.setRefreshToken(data['refreshToken'] as String);
      await _secureStorage.setUserId(user['id'] as String);
      await _localStorage.setFirstLaunchComplete();

      final isNewUser = data['isNewUser'] == true;
      if (isNewUser) {
        state = const AuthState.needsOnboarding();
      } else {
        await _localStorage.setOnboardingComplete();
        state = const AuthState.authenticated();
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<String?> _getSocialFirebaseIdToken(SocialProvider provider) async {
    switch (provider) {
      case SocialProvider.google:
        return _googleSignIn();
      case SocialProvider.apple:
        throw Exception('Apple login is not configured yet.');
    }
  }

  Future<String?> _googleSignIn() async {
    final googleUser = await GoogleSignIn(scopes: ['email']).signIn();
    if (googleUser == null) {
      throw Exception('Google sign-in cancelled');
    }

    final googleAuth = await googleUser.authentication;
    if (googleAuth.idToken == null || googleAuth.idToken!.isEmpty) {
      throw Exception('Google sign-in failed to return ID token.');
    }

    return googleAuth.idToken;
  }

  Future<void> completeOnboarding() async {
    await _localStorage.setOnboardingComplete();
    state = const AuthState.authenticated();
  }

  Future<void> logout() async {
    await _secureStorage.clearAll();
    state = const AuthState.unauthenticated(showOnboarding: false);
  }

  String _extractApiErrorMessage(
    dynamic responseData, {
    required String fallback,
  }) {
    if (responseData is Map<String, dynamic>) {
      final code = (responseData['code'] ?? '').toString().toUpperCase();
      if (code == 'INVALID_SIGNATURE') {
        return 'Verification signature invalid. Please retry in a moment.';
      }
      if (code.contains('RATE_LIMIT')) {
        return 'Too many attempts. Please try again shortly.';
      }

      final message = responseData['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }

    return fallback;
  }
}

sealed class AuthState {
  const AuthState();

  const factory AuthState.initial() = AuthStateInitial;
  const factory AuthState.loading() = AuthStateLoading;
  const factory AuthState.authenticated() = AuthStateAuthenticated;
  const factory AuthState.unauthenticated({required bool showOnboarding}) =
      AuthStateUnauthenticated;
  const factory AuthState.needsOnboarding() = AuthStateNeedsOnboarding;
  const factory AuthState.otpSent(String phone) = AuthStateOtpSent;
  const factory AuthState.error(String message) = AuthStateError;
}

class AuthStateInitial extends AuthState {
  const AuthStateInitial();
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

class AuthStateAuthenticated extends AuthState {
  const AuthStateAuthenticated();
}

class AuthStateUnauthenticated extends AuthState {
  final bool showOnboarding;
  const AuthStateUnauthenticated({required this.showOnboarding});
}

class AuthStateNeedsOnboarding extends AuthState {
  const AuthStateNeedsOnboarding();
}

class AuthStateOtpSent extends AuthState {
  final String phone;
  const AuthStateOtpSent(this.phone);
}

class AuthStateError extends AuthState {
  final String message;
  const AuthStateError(this.message);
}

enum SocialProvider { google, apple }

final userProvider = StateNotifierProvider<UserNotifier, UserModel?>((ref) {
  return UserNotifier();
});

final userProfileProvider = FutureProvider<UserModel?>((ref) async {
  final dio = ref.watch(dioClientProvider);
  final localStorage = ref.watch(localStorageProvider);

  try {
    final response = await dio.get(ApiConstants.profile);
    final body = response.data as Map<String, dynamic>? ?? {};
    final data = body['data'] as Map<String, dynamic>? ?? {};
    final normalized = _normalizeUserProfilePayload(data);
    await localStorage.cacheData(StorageKeys.cachedUserProfile, normalized);
    return UserModel.fromJson(normalized);
  } on DioException {
    final cached = localStorage.getCachedData<dynamic>(
      StorageKeys.cachedUserProfile,
    );
    if (cached is Map) {
      return UserModel.fromJson(Map<String, dynamic>.from(cached));
    }
    rethrow;
  }
});

class UserNotifier extends StateNotifier<UserModel?> {
  UserNotifier() : super(null);

  void setUser(UserModel user) {
    state = user;
  }

  void updateProfile({
    String? name,
    String? email,
    String? profileImage,
    DateTime? dateOfBirth,
    String? gender,
  }) {
    if (state == null) return;
    state = state!.copyWith(
      name: name,
      email: email,
      profileImage: profileImage,
      dateOfBirth: dateOfBirth,
      gender: gender,
    );
  }

  void updateHealthGoals(List<String> goals) {
    if (state == null) return;
    state = state!.copyWith(healthGoals: goals);
  }

  void updateDietaryPreferences(DietaryPreferences preferences) {
    if (state == null) return;
    state = state!.copyWith(dietaryPreferences: preferences);
  }

  void updateDailyRoutine(DailyRoutine routine) {
    if (state == null) return;
    state = state!.copyWith(dailyRoutine: routine);
  }

  void clearUser() {
    state = null;
  }
}

Map<String, dynamic> _normalizeUserProfilePayload(Map<String, dynamic> data) {
  final nowIso = DateTime.now().toIso8601String();
  final id = (data['id'] ?? data['_id'] ?? '').toString();
  final phone = (data['phone'] ?? data['phoneNumber'] ?? '').toString();

  return {
    'id': id,
    'phone': phone,
    'name': data['name'],
    'email': data['email'],
    'profileImage': data['profileImage'],
    'dateOfBirth': data['dateOfBirth'],
    'gender': data['gender'],
    'healthGoals': data['healthGoals'] ?? const <String>[],
    'dietaryPreferences': data['dietaryPreferences'],
    'dailyRoutine': data['dailyRoutine'],
    'loyaltyInfo': data['loyaltyInfo'],
    'isOnboardingComplete': data['isOnboardingComplete'] == true,
    'createdAt': (data['createdAt'] ?? nowIso).toString(),
    'updatedAt': (data['updatedAt'] ?? nowIso).toString(),
  };
}
