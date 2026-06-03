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

  // Prevent concurrent auth operations that can cause PigeonUserDetails errors
  bool _isAuthOperationInProgress = false;

  // Retry mechanism for PigeonUserDetails errors
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(milliseconds: 500);

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Retry mechanism for operations that might encounter PigeonUserDetails errors
  Future<T> _retryOnPigeonError<T>(Future<T> Function() operation) async {
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        return await operation();
      } catch (e) {
        if (e.toString().contains('PigeonUserDetails') &&
            attempt < _maxRetries) {
          print('PigeonUserDetails error on attempt $attempt, retrying...');
          await Future.delayed(_retryDelay);
          continue;
        }
        rethrow; // Re-throw if not a PigeonUserDetails error or max retries reached
      }
    }
    throw Exception('Max retries reached for PigeonUserDetails error');
  }

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
      print('Starting sign in process for email: $email');

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('Firebase Auth sign in successful');

      if (credential.user != null) {
        print('User credential received, getting user entity...');
        final userEntity = await _getUserEntity(credential.user!);
        print('User entity created successfully');
        return Result.success(userEntity);
      } else {
        print('ERROR: No user returned from Firebase Auth');
        return const Result.failure(
          AuthFailure(message: 'Sign in failed: No user returned'),
        );
      }
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Exception: ${e.code} - ${e.message}');
      return Result.failure(AuthFailure(message: _getAuthErrorMessage(e)));
    } catch (e) {
      print('Unexpected error during sign in: $e');
      print('Error type: ${e.runtimeType}');

      // Handle specific PigeonUserDetails error
      if (e.toString().contains('PigeonUserDetails')) {
        print('Detected PigeonUserDetails error - attempting recovery');
        return Result.failure(
          AuthFailure(
            message: 'Authentication service error. Please try again.',
          ),
        );
      }

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
    String? address,
  }) async {
    // Prevent concurrent auth operations
    if (_isAuthOperationInProgress) {
      return const Result.failure(
        AuthFailure(
          message:
              'Another authentication operation is in progress. Please wait.',
        ),
      );
    }

    _isAuthOperationInProgress = true;

    try {
      print('Starting user registration for email: $email');

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('Firebase Auth registration successful');

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
          address: address != null && address.isNotEmpty
              ? Address(
                  street: address,
                  city: '', // Will be filled later when user updates profile
                  region: '',
                  postalCode: '',
                  country: 'Tanzania',
                )
              : null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        try {
          await _createUserDocument(userEntity);
          print('User document created successfully');

          // Verify the document was actually saved
          await _verifyUserDocumentCreated(userEntity.id);
        } catch (e) {
          print('Failed to create user document: $e');
          // Continue with the process even if Firestore fails
          // The user account is still created in Firebase Auth
        }

        // Send email verification
        try {
          await sendEmailVerification();
          print('Email verification sent successfully');
        } catch (e) {
          print('Failed to send email verification: $e');
          // Continue with the process even if email verification fails
        }

        return Result.success(userEntity);
      } else {
        return const Result.failure(
          AuthFailure(message: 'Account creation failed: No user returned'),
        );
      }
    } on FirebaseAuthException catch (e) {
      print(
        'Firebase Auth Exception during registration: ${e.code} - ${e.message}',
      );
      return Result.failure(AuthFailure(message: _getAuthErrorMessage(e)));
    } catch (e) {
      print('Unexpected error during account creation: $e');
      print('Error type: ${e.runtimeType}');

      // Handle specific PigeonUserDetails error
      if (e.toString().contains('PigeonUserDetails')) {
        print(
          'Detected PigeonUserDetails error during registration - attempting recovery',
        );
        return Result.failure(
          AuthFailure(message: 'Registration service error. Please try again.'),
        );
      }

      return Result.failure(
        UnknownFailure(message: 'Unexpected error during account creation: $e'),
      );
    } finally {
      // Always reset the operation flag
      _isAuthOperationInProgress = false;
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
      print('Getting user entity for user: ${user.uid}');

      final doc = await _firestore
          .collection(FirebaseCollections.users)
          .doc(user.uid)
          .get();

      if (doc.exists) {
        print('User document found, parsing data...');
        final data = doc.data()!;
        print('User document data: $data');

        try {
          final userEntity = UserEntity.fromMap(data);
          print('User entity created successfully from Firestore data');
          return userEntity;
        } catch (e) {
          print('Error parsing user entity from Firestore data: $e');
          print('Attempting to preserve existing Firestore data...');

          // Try to preserve as much existing Firestore data as possible
          // instead of completely falling back to Firebase Auth data
          try {
            final displayNameParts = _parseDisplayName(user.displayName);
            return UserEntity(
              id: user.uid,
              email: user.email ?? data['email'] ?? '',
              // Preserve existing firstName/lastName from Firestore if available
              firstName:
                  data['firstName'] ?? displayNameParts['firstName'] ?? '',
              lastName: data['lastName'] ?? displayNameParts['lastName'] ?? '',
              // Preserve existing phoneNumber from Firestore if available
              phoneNumber: data['phoneNumber'] ?? user.phoneNumber,
              profileImageUrl: data['profileImageUrl'] ?? user.photoURL,
              isEmailVerified: user.emailVerified,
              // Preserve existing address from Firestore if available
              address: data['address'] != null
                  ? Address.fromMap(data['address'] as Map<String, dynamic>)
                  : null,
              createdAt: data['createdAt'] != null
                  ? DateTime.parse(data['createdAt'])
                  : DateTime.now(),
              updatedAt: DateTime.now(), // Always update the timestamp
            );
          } catch (fallbackError) {
            print('Fallback parsing also failed: $fallbackError');
            // Last resort: create minimal user entity
            return UserEntity(
              id: user.uid,
              email: user.email ?? '',
              firstName: '',
              lastName: '',
              isEmailVerified: user.emailVerified,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
          }
        }
      } else {
        // Create user document if it doesn't exist
        final displayNameParts = _parseDisplayName(user.displayName);
        final userEntity = UserEntity(
          id: user.uid,
          email: user.email ?? '',
          firstName: displayNameParts['firstName'] ?? '',
          lastName: displayNameParts['lastName'] ?? '',
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
      print('Error in _getUserEntity: $e');
      print('Error type: ${e.runtimeType}');

      // Handle specific PigeonUserDetails error
      if (e.toString().contains('PigeonUserDetails')) {
        print('Detected PigeonUserDetails error in _getUserEntity');
        print(
          'Attempting to retrieve user document directly from Firestore...',
        );

        // Try to get the user document directly, bypassing the problematic code
        try {
          final doc = await _firestore
              .collection(FirebaseCollections.users)
              .doc(user.uid)
              .get();

          if (doc.exists) {
            final data = doc.data()!;
            print('Retrieved user document data directly: $data');

            // Try to create user entity from the raw Firestore data
            return UserEntity(
              id: user.uid,
              email: data['email'] ?? user.email ?? '',
              firstName: data['firstName'] ?? '',
              lastName: data['lastName'] ?? '',
              phoneNumber: data['phoneNumber'],
              profileImageUrl: data['profileImageUrl'] ?? user.photoURL,
              isEmailVerified: user.emailVerified,
              address: data['address'] != null
                  ? Address.fromMap(data['address'] as Map<String, dynamic>)
                  : null,
              createdAt: data['createdAt'] != null
                  ? DateTime.parse(data['createdAt'])
                  : DateTime.now(),
              updatedAt: DateTime.now(),
            );
          }
        } catch (directRetrievalError) {
          print(
            'Direct Firestore retrieval also failed: $directRetrievalError',
          );
        }
      }

      // Last resort: Return basic user entity from Firebase Auth data
      print('Creating fallback user entity from Firebase Auth data');
      final displayNameParts = _parseDisplayName(user.displayName);
      return UserEntity(
        id: user.uid,
        email: user.email ?? '',
        firstName: displayNameParts['firstName'] ?? '',
        lastName: displayNameParts['lastName'] ?? '',
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
    try {
      final userData = userEntity.toMap();

      // Debug: Log the data being saved
      print('=== CREATING USER DOCUMENT ===');
      print('User ID: ${userEntity.id}');
      print('User data being saved:');
      userData.forEach((key, value) {
        print('  $key: $value (${value.runtimeType})');
      });

      await _firestore
          .collection(FirebaseCollections.users)
          .doc(userEntity.id)
          .set(userData);

      print('✅ User document created successfully for user: ${userEntity.id}');
      print('=== USER DOCUMENT CREATION COMPLETE ===');
    } catch (e) {
      print('❌ Error creating user document: $e');
      print('Error type: ${e.runtimeType}');
      print('Stack trace: ${StackTrace.current}');
      rethrow; // Re-throw to maintain error handling flow
    }
  }

  /// Verify that user document was created successfully
  Future<void> _verifyUserDocumentCreated(String userId) async {
    try {
      print('=== VERIFYING USER DOCUMENT ===');
      print('Checking document for user: $userId');

      final doc = await _firestore
          .collection(FirebaseCollections.users)
          .doc(userId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        print('✅ User document exists in Firestore');
        print('Document data:');
        data?.forEach((key, value) {
          print('  $key: $value');
        });

        // Check if critical fields are present
        final missingFields = <String>[];
        if (data?['firstName'] == null || data?['firstName'] == '') {
          missingFields.add('firstName');
        }
        if (data?['lastName'] == null || data?['lastName'] == '') {
          missingFields.add('lastName');
        }
        if (data?['email'] == null || data?['email'] == '') {
          missingFields.add('email');
        }

        if (missingFields.isNotEmpty) {
          print(
            '⚠️  WARNING: Critical fields are missing or empty: $missingFields',
          );
        } else {
          print('✅ All critical fields are present and non-empty');
        }

        // Check optional fields
        final optionalFields = ['phoneNumber', 'address'];
        for (final field in optionalFields) {
          if (data?[field] != null) {
            print('✅ Optional field $field is present: ${data?[field]}');
          } else {
            print('ℹ️  Optional field $field is null (this is okay)');
          }
        }
      } else {
        print('❌ ERROR: User document was not created in Firestore!');
        throw Exception(
          'User document verification failed: Document does not exist',
        );
      }

      print('=== USER DOCUMENT VERIFICATION COMPLETE ===');
    } catch (e) {
      print('Error verifying user document: $e');
    }
  }

  /// Parse display name safely to avoid type casting errors
  Map<String, String> _parseDisplayName(String? displayName) {
    if (displayName == null || displayName.isEmpty) {
      return {'firstName': '', 'lastName': ''};
    }

    try {
      final parts = displayName.trim().split(' ');
      if (parts.isEmpty) {
        return {'firstName': '', 'lastName': ''};
      }

      final firstName = parts.first;
      final lastName = parts.length > 1 ? parts.skip(1).join(' ') : '';

      return {'firstName': firstName, 'lastName': lastName};
    } catch (e) {
      // If any error occurs during parsing, return empty strings
      return {'firstName': '', 'lastName': ''};
    }
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
