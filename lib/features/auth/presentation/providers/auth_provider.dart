import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/utils/result.dart';

/// Authentication state
class AuthState {
  final UserEntity? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    UserEntity? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

/// Authentication provider
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState()) {
    _init();
  }

  void _init() {
    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) async {
      if (user != null) {
        // User is signed in, get user entity
        final userEntity = await _authService.getCurrentUserEntity();
        if (userEntity.isSuccess) {
          state = state.copyWith(
            user: userEntity.data,
            isAuthenticated: true,
            error: null,
          );
        } else {
          state = state.copyWith(
            user: null,
            isAuthenticated: false,
            error: userEntity.failure?.message,
          );
        }
      } else {
        // User is signed out
        state = state.copyWith(
          user: null,
          isAuthenticated: false,
          error: null,
        );
      }
    });
  }

  /// Sign in with email and password
  Future<Result<UserEntity>> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (result.isSuccess) {
      state = state.copyWith(
        user: result.data,
        isAuthenticated: true,
        isLoading: false,
        error: null,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.failure?.message,
      );
    }

    return result;
  }

  /// Create account with email and password
  Future<Result<UserEntity>> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authService.createUserWithEmailAndPassword(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
    );

    if (result.isSuccess) {
      state = state.copyWith(
        user: result.data,
        isAuthenticated: true,
        isLoading: false,
        error: null,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.failure?.message,
      );
    }

    return result;
  }

  /// Sign out
  Future<Result<void>> signOut() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authService.signOut();

    if (result.isSuccess) {
      state = state.copyWith(
        user: null,
        isAuthenticated: false,
        isLoading: false,
        error: null,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.failure?.message,
      );
    }

    return result;
  }

  /// Send password reset email
  Future<Result<void>> sendPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authService.sendPasswordResetEmail(email);

    state = state.copyWith(
      isLoading: false,
      error: result.isFailure ? result.failure?.message : null,
    );

    return result;
  }

  /// Send email verification
  Future<Result<void>> sendEmailVerification() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authService.sendEmailVerification();

    state = state.copyWith(
      isLoading: false,
      error: result.isFailure ? result.failure?.message : null,
    );

    return result;
  }

  /// Update user profile
  Future<Result<void>> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authService.updateProfile(
      displayName: displayName,
      photoURL: photoURL,
    );

    if (result.isSuccess && state.user != null) {
      // Refresh user data
      final userResult = await _authService.getCurrentUserEntity();
      if (userResult.isSuccess) {
        state = state.copyWith(
          user: userResult.data,
          isLoading: false,
          error: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: userResult.failure?.message,
        );
      }
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.failure?.message,
      );
    }

    return result;
  }

  /// Change password
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    state = state.copyWith(
      isLoading: false,
      error: result.isFailure ? result.failure?.message : null,
    );

    return result;
  }

  /// Delete account
  Future<Result<void>> deleteAccount(String password) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authService.deleteAccount(password);

    if (result.isSuccess) {
      state = state.copyWith(
        user: null,
        isAuthenticated: false,
        isLoading: false,
        error: null,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.failure?.message,
      );
    }

    return result;
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService.instance;
});

/// Auth state provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

/// Current user provider
final currentUserProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authProvider).user;
});

/// Authentication status provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

/// Loading state provider
final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

/// Error state provider
final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});
