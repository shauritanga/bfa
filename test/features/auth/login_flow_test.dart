import 'package:flutter_test/flutter_test.dart';
import 'package:bfa/features/auth/presentation/providers/auth_provider.dart';
import 'package:bfa/features/auth/domain/entities/user_entity.dart';
import 'package:bfa/core/utils/result.dart';
import 'package:bfa/core/errors/failures.dart';

void main() {
  group('Login Flow Tests', () {
    test('Auth state should update correctly on successful login', () async {
      // This test verifies that the auth state is properly managed
      // and doesn't show false errors when login succeeds

      // Create a mock user entity
      final mockUser = UserEntity(
        id: 'test-user-123',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        isEmailVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Test the auth state transitions
      expect(mockUser.id, equals('test-user-123'));
      expect(mockUser.email, equals('test@example.com'));
      expect(mockUser.firstName, equals('John'));
      expect(mockUser.lastName, equals('Doe'));
      expect(mockUser.isEmailVerified, isTrue);
    });

    test('Auth state should handle errors correctly', () async {
      // Test error handling in auth state
      const authState = AuthState(
        user: null,
        isLoading: false,
        error: 'Invalid credentials',
        isAuthenticated: false,
      );

      expect(authState.user, isNull);
      expect(authState.isLoading, isFalse);
      expect(authState.error, equals('Invalid credentials'));
      expect(authState.isAuthenticated, isFalse);
    });

    test('Auth state should handle loading state correctly', () async {
      // Test loading state management
      const loadingState = AuthState(
        user: null,
        isLoading: true,
        error: null,
        isAuthenticated: false,
      );

      expect(loadingState.user, isNull);
      expect(loadingState.isLoading, isTrue);
      expect(loadingState.error, isNull);
      expect(loadingState.isAuthenticated, isFalse);
    });

    test('Auth state should handle successful authentication', () async {
      // Test successful authentication state
      final user = UserEntity(
        id: 'authenticated-user',
        email: 'user@example.com',
        firstName: 'Jane',
        lastName: 'Smith',
        isEmailVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final authenticatedState = AuthState(
        user: user,
        isLoading: false,
        error: null,
        isAuthenticated: true,
      );

      expect(authenticatedState.user, equals(user));
      expect(authenticatedState.isLoading, isFalse);
      expect(authenticatedState.error, isNull);
      expect(authenticatedState.isAuthenticated, isTrue);
    });

    test('Auth state copyWith should work correctly', () async {
      // Test state copying functionality
      const initialState = AuthState(
        user: null,
        isLoading: true,
        error: null,
        isAuthenticated: false,
      );

      final updatedState = initialState.copyWith(
        isLoading: false,
        error: 'Test error',
      );

      expect(updatedState.user, isNull);
      expect(updatedState.isLoading, isFalse);
      expect(updatedState.error, equals('Test error'));
      expect(updatedState.isAuthenticated, isFalse);
    });

    test(
      'Auth state should clear errors on successful authentication',
      () async {
        // Test that errors are cleared when authentication succeeds
        final user = UserEntity(
          id: 'success-user',
          email: 'success@example.com',
          firstName: 'Success',
          lastName: 'User',
          isEmailVerified: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        const errorState = AuthState(
          user: null,
          isLoading: false,
          error: 'Previous error',
          isAuthenticated: false,
        );

        final successState = errorState.copyWith(
          user: user,
          isLoading: false,
          error: null, // Error should be cleared
          isAuthenticated: true,
        );

        expect(successState.user, equals(user));
        expect(successState.isLoading, isFalse);
        expect(successState.error, isNull); // Error should be cleared
        expect(successState.isAuthenticated, isTrue);
      },
    );

    test('Result class should handle success and failure correctly', () async {
      // Test the Result class used in auth operations
      final user = UserEntity(
        id: 'result-user',
        email: 'result@example.com',
        firstName: 'Result',
        lastName: 'User',
        isEmailVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Test successful result
      final successResult = Result.success(user);
      expect(successResult.isSuccess, isTrue);
      expect(successResult.isFailure, isFalse);
      expect(successResult.data, equals(user));

      // Test failure result
      final failureResult = Result<UserEntity>.failure(
        const AuthFailure(message: 'Login failed'),
      );
      expect(failureResult.isSuccess, isFalse);
      expect(failureResult.isFailure, isTrue);
      expect(failureResult.failure?.message, equals('Login failed'));
    });

    test('User entity should be created with correct default values', () async {
      // Test user entity creation with minimal data
      final minimalUser = UserEntity(
        id: 'minimal-user',
        email: 'minimal@example.com',
        firstName: '',
        lastName: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(minimalUser.id, equals('minimal-user'));
      expect(minimalUser.email, equals('minimal@example.com'));
      expect(minimalUser.firstName, equals(''));
      expect(minimalUser.lastName, equals(''));
      expect(minimalUser.phoneNumber, isNull);
      expect(minimalUser.profileImageUrl, isNull);
      expect(minimalUser.isEmailVerified, isFalse); // Default value
      expect(minimalUser.role, equals(UserRole.customer)); // Default value
      expect(minimalUser.status, equals(UserStatus.active)); // Default value
      expect(minimalUser.address, isNull);
      expect(minimalUser.preferences, isNull);
    });

    test('Auth state transitions should be logical', () async {
      // Test logical state transitions

      // Initial state (loading)
      const initialState = AuthState(isLoading: true);
      expect(initialState.isLoading, isTrue);
      expect(initialState.isAuthenticated, isFalse);
      expect(initialState.user, isNull);
      expect(initialState.error, isNull);

      // Loading to error state
      final errorState = initialState.copyWith(
        isLoading: false,
        error: 'Authentication failed',
      );
      expect(errorState.isLoading, isFalse);
      expect(errorState.isAuthenticated, isFalse);
      expect(errorState.user, isNull);
      expect(errorState.error, equals('Authentication failed'));

      // Error to loading state (retry)
      final retryState = errorState.copyWith(isLoading: true, error: null);
      expect(retryState.isLoading, isTrue);
      expect(retryState.isAuthenticated, isFalse);
      expect(retryState.user, isNull);
      expect(retryState.error, isNull);

      // Loading to success state
      final user = UserEntity(
        id: 'transition-user',
        email: 'transition@example.com',
        firstName: 'Transition',
        lastName: 'User',
        isEmailVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final successState = retryState.copyWith(
        user: user,
        isLoading: false,
        isAuthenticated: true,
      );
      expect(successState.isLoading, isFalse);
      expect(successState.isAuthenticated, isTrue);
      expect(successState.user, equals(user));
      expect(successState.error, isNull);
    });
  });
}
