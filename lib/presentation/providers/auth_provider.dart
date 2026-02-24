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
