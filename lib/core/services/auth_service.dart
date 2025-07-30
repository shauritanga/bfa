import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/firebase_config.dart';
import '../utils/result.dart';
import '../errors/failures.dart';
import '../../features/auth/domain/entities/user_entity.dart';

/// Authentication service for Firebase Auth
class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();

  AuthService._();

  final FirebaseAuth _auth = FirebaseConfig.instance.auth;
  final FirebaseFirestore _firestore = FirebaseConfig.instance.firestore;

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is signed in
  bool get isSignedIn => currentUser != null;

  /// Get current user ID
  String? get currentUserId => currentUser?.uid;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get current user entity
  Future<Result<UserEntity>> getCurrentUserEntity() async {
    try {
      final user = currentUser;
      if (user != null) {
        final userEntity = await _getUserEntity(user);
        return Result.success(userEntity);
      } else {
        return const Result.failure(AuthFailure(message: 'No user signed in'));
      }
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Failed to get current user: $e'),
      );
    }
  }

  /// Sign in with email and password
  Future<Result<UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final userEntity = await _getUserEntity(credential.user!);
        return Result.success(userEntity);
      } else {
        return const Result.failure(
          AuthFailure(message: 'Sign in failed: No user returned'),
        );
      }
    } on FirebaseAuthException catch (e) {
      return Result.failure(AuthFailure(message: _getAuthErrorMessage(e)));
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Unexpected error during sign in: $e'),
      );
    }
  }

  /// Create user with email and password
  Future<Result<UserEntity>> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName('$firstName $lastName');

        // Create user document in Firestore
        final userEntity = UserEntity(
          id: credential.user!.uid,
          email: email,
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
          profileImageUrl: null,
          isEmailVerified: credential.user!.emailVerified,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _createUserDocument(userEntity);

        // Send email verification
        await sendEmailVerification();

        return Result.success(userEntity);
      } else {
        return const Result.failure(
          AuthFailure(message: 'Account creation failed: No user returned'),
        );
      }
    } on FirebaseAuthException catch (e) {
      return Result.failure(AuthFailure(message: _getAuthErrorMessage(e)));
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Unexpected error during account creation: $e'),
      );
    }
  }

  /// Sign out
  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
      return const Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.failure(
        AuthFailure(message: 'Sign out failed: ${e.message}'),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Unexpected error during sign out: $e'),
      );
    }
  }

  /// Send password reset email
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return const Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.failure(AuthFailure(message: _getAuthErrorMessage(e)));
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Unexpected error sending password reset: $e'),
      );
    }
  }

  /// Send email verification
  Future<Result<void>> sendEmailVerification() async {
    try {
      final user = currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return const Result.success(null);
      } else {
        return const Result.failure(
          AuthFailure(message: 'No user signed in or email already verified'),
        );
      }
    } on FirebaseAuthException catch (e) {
      return Result.failure(
        AuthFailure(message: 'Failed to send verification email: ${e.message}'),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure(
          message: 'Unexpected error sending verification email: $e',
        ),
      );
    }
  }

  /// Reload current user
  Future<Result<void>> reloadUser() async {
    try {
      final user = currentUser;
      if (user != null) {
        await user.reload();
        return const Result.success(null);
      } else {
        return const Result.failure(AuthFailure(message: 'No user signed in'));
      }
    } on FirebaseAuthException catch (e) {
      return Result.failure(
        AuthFailure(message: 'Failed to reload user: ${e.message}'),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Unexpected error reloading user: $e'),
      );
    }
  }

  /// Update user profile
  Future<Result<void>> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);
        return const Result.success(null);
      } else {
        return const Result.failure(AuthFailure(message: 'No user signed in'));
      }
    } on FirebaseAuthException catch (e) {
      return Result.failure(
        AuthFailure(message: 'Failed to update profile: ${e.message}'),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Unexpected error updating profile: $e'),
      );
    }
  }

  /// Change password
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = currentUser;
      if (user != null && user.email != null) {
        // Re-authenticate user
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);

        // Update password
        await user.updatePassword(newPassword);
        return const Result.success(null);
      } else {
        return const Result.failure(
          AuthFailure(message: 'No user signed in or email not available'),
        );
      }
    } on FirebaseAuthException catch (e) {
      return Result.failure(AuthFailure(message: _getAuthErrorMessage(e)));
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Unexpected error changing password: $e'),
      );
    }
  }

  /// Delete user account
  Future<Result<void>> deleteAccount(String password) async {
    try {
      final user = currentUser;
      if (user != null && user.email != null) {
        // Re-authenticate user
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);

        // Delete user document from Firestore
        await _firestore
            .collection(FirebaseCollections.users)
            .doc(user.uid)
            .delete();

        // Delete user account
        await user.delete();
        return const Result.success(null);
      } else {
        return const Result.failure(
          AuthFailure(message: 'No user signed in or email not available'),
        );
      }
    } on FirebaseAuthException catch (e) {
      return Result.failure(AuthFailure(message: _getAuthErrorMessage(e)));
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Unexpected error deleting account: $e'),
      );
    }
  }

  /// Get user entity from Firebase user
  Future<UserEntity> _getUserEntity(User user) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.users)
          .doc(user.uid)
          .get();

      if (doc.exists) {
        return UserEntity.fromMap(doc.data()!);
      } else {
        // Create user document if it doesn't exist
        final userEntity = UserEntity(
          id: user.uid,
          email: user.email ?? '',
          firstName: user.displayName?.split(' ').first ?? '',
          lastName: user.displayName?.split(' ').skip(1).join(' ') ?? '',
          phoneNumber: user.phoneNumber,
          profileImageUrl: user.photoURL,
          isEmailVerified: user.emailVerified,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _createUserDocument(userEntity);
        return userEntity;
      }
    } catch (e) {
      // Return basic user entity if Firestore fails
      return UserEntity(
        id: user.uid,
        email: user.email ?? '',
        firstName: user.displayName?.split(' ').first ?? '',
        lastName: user.displayName?.split(' ').skip(1).join(' ') ?? '',
        phoneNumber: user.phoneNumber,
        profileImageUrl: user.photoURL,
        isEmailVerified: user.emailVerified,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  /// Create user document in Firestore
  Future<void> _createUserDocument(UserEntity userEntity) async {
    await _firestore
        .collection(FirebaseCollections.users)
        .doc(userEntity.id)
        .set(userEntity.toMap());
  }

  /// Get user-friendly error message from FirebaseAuthException
  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'requires-recent-login':
        return 'Please sign in again to complete this action.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}
