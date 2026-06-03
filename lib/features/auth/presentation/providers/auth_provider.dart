import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';

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

  AuthNotifier(this._authService) : super(const AuthState(isLoading: true)) {
    _init();
  }

  void _init() async {
    try {
      // Set initial loading state
      state = state.copyWith(isLoading: true);

      // Check current auth state immediately
      final currentUser = _authService.currentUser;

      if (currentUser != null) {
        // User is already signed in, get user entity
        final userEntity = await _authService.getCurrentUserEntity();
        if (userEntity.isSuccess) {
          state = state.copyWith(
            user: userEntity.data,
            isAuthenticated: true,
            isLoading: false,
            error: null,
          );
        } else {
          state = state.copyWith(
            user: null,
            isAuthenticated: false,
            isLoading: false,
            error: userEntity.failure?.message,
          );
        }
      } else {
        // No user signed in
        state = state.copyWith(
          user: null,
          isAuthenticated: false,
          isLoading: false,
          error: null,
        );
      }
    } catch (e) {
      // Handle any unexpected errors during initialization
      state = state.copyWith(
        user: null,
        isAuthenticated: false,
        isLoading: false,
        error: 'Initialization error: ${e.toString()}',
      );
    }

    // Listen to auth state changes for future updates
    _authService.authStateChanges.listen((User? user) async {
      try {
        if (user != null) {
          // User is signed in, get user entity
          print('Auth state changed: User signed in (${user.uid})');
          final userEntity = await _authService.getCurrentUserEntity();
          if (userEntity.isSuccess) {
            print('User entity retrieved successfully');
            state = state.copyWith(
              user: userEntity.data,
              isAuthenticated: true,
              isLoading: false,
              error: null, // Clear any previous errors
            );
          } else {
            print('Failed to get user entity: ${userEntity.failure?.message}');
            print(
              'User is still authenticated in Firebase Auth, creating basic user entity',
            );

            // User is authenticated in Firebase Auth but Firestore data retrieval failed
            // This is NOT an authentication error - create a basic user entity
            final basicUserEntity = UserEntity(
              id: user.uid,
              email: user.email ?? '',
              firstName: '',
              lastName: '',
              isEmailVerified: user.emailVerified,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

            state = state.copyWith(
              user: basicUserEntity,
              isAuthenticated: true,
              isLoading: false,
              error:
                  null, // IMPORTANT: Don't show error if user is authenticated
            );

            print(
              'Successfully created basic user entity for authenticated user',
            );
          }
        } else {
          // User is signed out
          print('Auth state changed: User signed out');
          state = state.copyWith(
            user: null,
            isAuthenticated: false,
            isLoading: false,
            error: null,
          );
        }
      } catch (e) {
        print('Error in auth state listener: $e');
        print(
          'User is ${user != null ? 'authenticated' : 'not authenticated'}',
        );

        if (user == null) {
          // User is not authenticated, this is a real auth error
          state = state.copyWith(
            user: null,
            isAuthenticated: false,
            isLoading: false,
            error: 'Authentication error: ${e.toString()}',
          );
        } else {
          // User IS authenticated in Firebase Auth, but there was an error getting Firestore data
          // This is NOT an authentication error - just a data retrieval issue
          print(
            'User is authenticated but Firestore data retrieval failed. Creating basic user entity.',
          );

          final basicUserEntity = UserEntity(
            id: user.uid,
            email: user.email ?? '',
            firstName: '',
            lastName: '',
            isEmailVerified: user.emailVerified,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          state = state.copyWith(
            user: basicUserEntity,
            isAuthenticated: true,
            isLoading: false,
            error: null, // IMPORTANT: Don't show error if user is authenticated
          );

          print(
            'Successfully created basic user entity for authenticated user',
          );
        }
      }
    });
  }

  /// Sign in with email and password
  Future<Result<UserEntity>> signIn({
    required String email,
    required String password,
  }) async {
    // Clear any previous errors and set loading state
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Don't update state here for success - let the auth state listener handle it
    // This prevents race conditions between direct updates and listener updates
    if (result.isFailure) {
      // Only update state for failures, success will be handled by auth state listener
      state = state.copyWith(isLoading: false, error: result.failure?.message);
    }
    // Note: For success, the auth state listener will automatically update the state
    // when Firebase Auth state changes, including clearing any errors

    return result;
  }

  /// Create account with email and password
  Future<Result<UserEntity>> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    String? address,
  }) async {
    try {
      print('=== AUTH PROVIDER SIGNUP ===');
      print('Email: $email');
      print('First Name: $firstName');
      print('Last Name: $lastName');
      print('Phone Number: $phoneNumber');
      print('Address: $address');
      print('=== CALLING AUTH SERVICE ===');

      state = state.copyWith(isLoading: true, error: null);

      final result = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        address: address,
      );

      // Don't update state here for success - let the auth state listener handle it
      // This prevents race conditions between direct updates and listener updates
      if (result.isFailure) {
        // Only update state for failures, success will be handled by auth state listener
        state = state.copyWith(
          isLoading: false,
          error: result.failure?.message,
        );
      }
      // Note: For success, the auth state listener will automatically update the state
      // when Firebase Auth state changes

      return result;
    } catch (e) {
      // Handle any unexpected errors during registration
      final errorMessage = 'Registration error: ${e.toString()}';
      state = state.copyWith(isLoading: false, error: errorMessage);
      return Result.failure(UnknownFailure(message: errorMessage));
    }
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
      state = state.copyWith(isLoading: false, error: result.failure?.message);
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
      state = state.copyWith(isLoading: false, error: result.failure?.message);
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
      state = state.copyWith(isLoading: false, error: result.failure?.message);
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
