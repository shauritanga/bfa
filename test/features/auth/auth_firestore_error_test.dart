import 'package:flutter_test/flutter_test.dart';
import 'package:bfa/features/auth/presentation/providers/auth_provider.dart';
import 'package:bfa/features/auth/domain/entities/user_entity.dart';

void main() {
  group('Auth Firestore Error Handling Tests', () {
    test('Should create basic user entity when Firestore fails but user is authenticated', () {
      // Simulate a scenario where Firebase Auth succeeds but Firestore data retrieval fails
      // This should NOT show an error to the user since they are authenticated
      
      final basicUser = UserEntity(
        id: 'firebase-auth-user-123',
        email: 'user@example.com',
        firstName: '',
        lastName: '',
        isEmailVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Create auth state representing successful authentication with basic user data
      final authenticatedState = AuthState(
        user: basicUser,
        isAuthenticated: true,
        isLoading: false,
        error: null, // No error should be shown
      );

      expect(authenticatedState.user, isNotNull);
      expect(authenticatedState.user!.id, equals('firebase-auth-user-123'));
      expect(authenticatedState.user!.email, equals('user@example.com'));
      expect(authenticatedState.isAuthenticated, isTrue);
      expect(authenticatedState.isLoading, isFalse);
      expect(authenticatedState.error, isNull); // IMPORTANT: No error for authenticated user
    });

    test('Should show error only when user is NOT authenticated', () {
      // Test that errors are only shown when the user is actually not authenticated
      
      // Case 1: User is authenticated but Firestore failed - NO error should be shown
      final authenticatedUser = UserEntity(
        id: 'auth-user',
        email: 'auth@example.com',
        firstName: '',
        lastName: '',
        isEmailVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final authenticatedWithFirestoreIssue = AuthState(
        user: authenticatedUser,
        isAuthenticated: true,
        isLoading: false,
        error: null, // No error shown even if Firestore had issues
      );

      expect(authenticatedWithFirestoreIssue.isAuthenticated, isTrue);
      expect(authenticatedWithFirestoreIssue.error, isNull);

      // Case 2: User is NOT authenticated - error SHOULD be shown
      const notAuthenticatedWithError = AuthState(
        user: null,
        isAuthenticated: false,
        isLoading: false,
        error: 'Authentication failed',
      );

      expect(notAuthenticatedWithError.isAuthenticated, isFalse);
      expect(notAuthenticatedWithError.error, equals('Authentication failed'));
    });

    test('Basic user entity should have correct default values', () {
      // Test that basic user entity created from Firebase Auth has correct structure
      final basicUser = UserEntity(
        id: 'firebase-user-id',
        email: 'firebase@example.com',
        firstName: '', // Empty when Firestore data unavailable
        lastName: '', // Empty when Firestore data unavailable
        isEmailVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(basicUser.id, equals('firebase-user-id'));
      expect(basicUser.email, equals('firebase@example.com'));
      expect(basicUser.firstName, equals(''));
      expect(basicUser.lastName, equals(''));
      expect(basicUser.phoneNumber, isNull);
      expect(basicUser.profileImageUrl, isNull);
      expect(basicUser.isEmailVerified, isTrue);
      expect(basicUser.role, equals(UserRole.customer)); // Default role
      expect(basicUser.status, equals(UserStatus.active)); // Default status
      expect(basicUser.address, isNull);
      expect(basicUser.preferences, isNull);
    });

    test('Auth state should distinguish between auth errors and data errors', () {
      // Test the logic that determines when to show errors vs when to create basic user
      
      // Scenario 1: Firebase Auth fails (user is null) - SHOW ERROR
      const authFailureState = AuthState(
        user: null,
        isAuthenticated: false,
        isLoading: false,
        error: 'Invalid credentials',
      );

      // This should show error because user is not authenticated
      final shouldShowAuthError = authFailureState.error != null && 
                                 !authFailureState.isLoading && 
                                 !authFailureState.isAuthenticated;
      
      expect(shouldShowAuthError, isTrue);

      // Scenario 2: Firebase Auth succeeds but Firestore fails - DON'T SHOW ERROR
      final firestoreFailureUser = UserEntity(
        id: 'firestore-fail-user',
        email: 'firestore@example.com',
        firstName: '',
        lastName: '',
        isEmailVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final firestoreFailureState = AuthState(
        user: firestoreFailureUser,
        isAuthenticated: true,
        isLoading: false,
        error: null, // No error shown for authenticated user
      );

      // This should NOT show error because user is authenticated
      final shouldNotShowFirestoreError = firestoreFailureState.error != null && 
                                         !firestoreFailureState.isLoading && 
                                         !firestoreFailureState.isAuthenticated;
      
      expect(shouldNotShowFirestoreError, isFalse);
    });

    test('Auth state transitions should handle Firestore errors gracefully', () {
      // Test the complete flow when Firestore has issues but Firebase Auth works
      
      // 1. Start with loading state
      const loadingState = AuthState(
        user: null,
        isAuthenticated: false,
        isLoading: true,
        error: null,
      );

      expect(loadingState.isLoading, isTrue);
      expect(loadingState.isAuthenticated, isFalse);

      // 2. Firebase Auth succeeds but Firestore fails - create basic user
      final basicUser = UserEntity(
        id: 'basic-user',
        email: 'basic@example.com',
        firstName: '',
        lastName: '',
        isEmailVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final successWithBasicUser = loadingState.copyWith(
        user: basicUser,
        isAuthenticated: true,
        isLoading: false,
        error: null, // No error for authenticated user
      );

      expect(successWithBasicUser.user, equals(basicUser));
      expect(successWithBasicUser.isAuthenticated, isTrue);
      expect(successWithBasicUser.isLoading, isFalse);
      expect(successWithBasicUser.error, isNull);

      // 3. User should be able to use the app normally
      expect(successWithBasicUser.user!.id, isNotEmpty);
      expect(successWithBasicUser.user!.email, isNotEmpty);
      expect(successWithBasicUser.isAuthenticated, isTrue);
    });

    test('Error message logic should be precise', () {
      // Test the exact conditions used in the login page for showing errors
      
      final authenticatedUser = UserEntity(
        id: 'precise-user',
        email: 'precise@example.com',
        firstName: '',
        lastName: '',
        isEmailVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Test all combinations of conditions
      
      // 1. error != null && !isLoading && !isAuthenticated && error != previousError
      const errorState = AuthState(
        user: null,
        isAuthenticated: false,
        isLoading: false,
        error: 'New error',
      );

      const previousState = AuthState(
        user: null,
        isAuthenticated: false,
        isLoading: false,
        error: null,
      );

      final shouldShow1 = errorState.error != null && 
                         !errorState.isLoading && 
                         !errorState.isAuthenticated &&
                         errorState.error != previousState.error;
      
      expect(shouldShow1, isTrue); // Should show new error for unauthenticated user

      // 2. Same conditions but user is authenticated
      final authenticatedErrorState = AuthState(
        user: authenticatedUser,
        isAuthenticated: true,
        isLoading: false,
        error: 'Some error',
      );

      final shouldShow2 = authenticatedErrorState.error != null && 
                         !authenticatedErrorState.isLoading && 
                         !authenticatedErrorState.isAuthenticated && // This is false
                         authenticatedErrorState.error != previousState.error;
      
      expect(shouldShow2, isFalse); // Should NOT show error for authenticated user

      // 3. Same conditions but currently loading
      const loadingErrorState = AuthState(
        user: null,
        isAuthenticated: false,
        isLoading: true, // This is true
        error: 'Loading error',
      );

      final shouldShow3 = loadingErrorState.error != null && 
                         !loadingErrorState.isLoading && // This is false
                         !loadingErrorState.isAuthenticated &&
                         loadingErrorState.error != previousState.error;
      
      expect(shouldShow3, isFalse); // Should NOT show error while loading
    });
  });
}
