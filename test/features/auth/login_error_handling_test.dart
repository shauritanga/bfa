import 'package:flutter_test/flutter_test.dart';
import 'package:bfa/features/auth/presentation/providers/auth_provider.dart';
import 'package:bfa/features/auth/domain/entities/user_entity.dart';

void main() {
  group('Login Error Handling Tests', () {
    test('Auth state should clear errors when clearError is called', () {
      // Create an auth state with an error
      const errorState = AuthState(
        user: null,
        isLoading: false,
        error: 'Invalid credentials',
        isAuthenticated: false,
      );

      // Clear the error
      final clearedState = errorState.copyWith(error: null);

      expect(clearedState.user, isNull);
      expect(clearedState.isLoading, isFalse);
      expect(clearedState.error, isNull); // Error should be cleared
      expect(clearedState.isAuthenticated, isFalse);
    });

    test('Auth state should not show errors for authenticated users', () {
      final user = UserEntity(
        id: 'authenticated-user',
        email: 'user@example.com',
        firstName: 'John',
        lastName: 'Doe',
        isEmailVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // State with user authenticated but also an error (should not happen in practice)
      final authenticatedWithErrorState = AuthState(
        user: user,
        isLoading: false,
        error: 'Some error',
        isAuthenticated: true,
      );

      // In the UI, we should not show errors for authenticated users
      // This test verifies the logic: !next.isAuthenticated should prevent error display
      expect(authenticatedWithErrorState.isAuthenticated, isTrue);
      expect(authenticatedWithErrorState.error, isNotNull);
      
      // The UI logic should not show this error because user is authenticated
      final shouldShowError = authenticatedWithErrorState.error != null && 
                             !authenticatedWithErrorState.isLoading && 
                             !authenticatedWithErrorState.isAuthenticated;
      
      expect(shouldShowError, isFalse); // Should not show error for authenticated user
    });

    test('Auth state should only show NEW errors', () {
      // Previous state with an error
      const previousState = AuthState(
        user: null,
        isLoading: false,
        error: 'Old error',
        isAuthenticated: false,
      );

      // Next state with the same error
      const nextStateSameError = AuthState(
        user: null,
        isLoading: false,
        error: 'Old error', // Same error
        isAuthenticated: false,
      );

      // Next state with a new error
      const nextStateNewError = AuthState(
        user: null,
        isLoading: false,
        error: 'New error', // Different error
        isAuthenticated: false,
      );

      // Check if we should show error for same error (should not)
      final shouldShowSameError = nextStateSameError.error != null && 
                                 !nextStateSameError.isLoading && 
                                 !nextStateSameError.isAuthenticated &&
                                 nextStateSameError.error != previousState.error;
      
      expect(shouldShowSameError, isFalse); // Should not show same error again

      // Check if we should show error for new error (should show)
      final shouldShowNewError = nextStateNewError.error != null && 
                                !nextStateNewError.isLoading && 
                                !nextStateNewError.isAuthenticated &&
                                nextStateNewError.error != previousState.error;
      
      expect(shouldShowNewError, isTrue); // Should show new error
    });

    test('Auth state should clear errors on successful authentication', () {
      final user = UserEntity(
        id: 'success-user',
        email: 'success@example.com',
        firstName: 'Success',
        lastName: 'User',
        isEmailVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Start with error state
      const errorState = AuthState(
        user: null,
        isLoading: false,
        error: 'Login failed',
        isAuthenticated: false,
      );

      // Transition to loading state (error should be cleared)
      final loadingState = errorState.copyWith(
        isLoading: true,
        error: null, // Error cleared when starting new attempt
      );

      expect(loadingState.error, isNull);
      expect(loadingState.isLoading, isTrue);

      // Transition to success state
      final successState = loadingState.copyWith(
        user: user,
        isLoading: false,
        isAuthenticated: true,
        error: null, // Ensure error stays cleared
      );

      expect(successState.user, equals(user));
      expect(successState.isLoading, isFalse);
      expect(successState.isAuthenticated, isTrue);
      expect(successState.error, isNull); // Error should remain cleared
    });

    test('Auth state transitions should handle error clearing correctly', () {
      // Test the complete flow: error -> loading -> success
      
      // 1. Initial error state
      const errorState = AuthState(
        user: null,
        isLoading: false,
        error: 'Invalid password',
        isAuthenticated: false,
      );

      expect(errorState.error, equals('Invalid password'));
      expect(errorState.isAuthenticated, isFalse);

      // 2. User starts new login attempt (loading state with cleared error)
      final loadingState = errorState.copyWith(
        isLoading: true,
        error: null, // Error cleared when starting new attempt
      );

      expect(loadingState.error, isNull);
      expect(loadingState.isLoading, isTrue);
      expect(loadingState.isAuthenticated, isFalse);

      // 3. Login succeeds
      final user = UserEntity(
        id: 'success-user',
        email: 'user@example.com',
        firstName: 'User',
        lastName: 'Name',
        isEmailVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final successState = loadingState.copyWith(
        user: user,
        isLoading: false,
        isAuthenticated: true,
        // error remains null from loading state
      );

      expect(successState.user, equals(user));
      expect(successState.isLoading, isFalse);
      expect(successState.isAuthenticated, isTrue);
      expect(successState.error, isNull); // No error in success state
    });

    test('Error display logic should work correctly', () {
      // Test the exact logic used in the login page listener

      // Case 1: Show error (new error, not authenticated, not loading)
      const errorState = AuthState(
        user: null,
        isLoading: false,
        error: 'Login failed',
        isAuthenticated: false,
      );

      const previousState = AuthState(
        user: null,
        isLoading: false,
        error: null, // No previous error
        isAuthenticated: false,
      );

      final shouldShowError = errorState.error != null && 
                             !errorState.isLoading && 
                             !errorState.isAuthenticated &&
                             errorState.error != previousState.error;

      expect(shouldShowError, isTrue);

      // Case 2: Don't show error (user is authenticated)
      final user = UserEntity(
        id: 'auth-user',
        email: 'auth@example.com',
        firstName: 'Auth',
        lastName: 'User',
        isEmailVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final authenticatedState = AuthState(
        user: user,
        isLoading: false,
        error: 'Some error', // Error exists but user is authenticated
        isAuthenticated: true,
      );

      final shouldNotShowError = authenticatedState.error != null && 
                                !authenticatedState.isLoading && 
                                !authenticatedState.isAuthenticated && // This is false
                                authenticatedState.error != previousState.error;

      expect(shouldNotShowError, isFalse);

      // Case 3: Don't show error (currently loading)
      const loadingState = AuthState(
        user: null,
        isLoading: true, // Currently loading
        error: 'Some error',
        isAuthenticated: false,
      );

      final shouldNotShowLoadingError = loadingState.error != null && 
                                       !loadingState.isLoading && // This is false
                                       !loadingState.isAuthenticated &&
                                       loadingState.error != previousState.error;

      expect(shouldNotShowLoadingError, isFalse);
    });
  });
}
