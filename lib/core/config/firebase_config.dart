import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import '../utils/result.dart';
import '../errors/failures.dart';

/// Firebase configuration and initialization
class FirebaseConfig {
  static FirebaseConfig? _instance;
  static FirebaseConfig get instance => _instance ??= FirebaseConfig._();

  FirebaseConfig._();

  // Firebase service instances
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  FirebaseStorage? _storage;
  FirebaseMessaging? _messaging;
  FirebaseAnalytics? _analytics;
  FirebaseCrashlytics? _crashlytics;

  // Getters for Firebase services
  FirebaseAuth get auth => _auth ??= FirebaseAuth.instance;
  FirebaseFirestore get firestore => _firestore ??= FirebaseFirestore.instance;
  FirebaseStorage get storage => _storage ??= FirebaseStorage.instance;
  FirebaseMessaging get messaging => _messaging ??= FirebaseMessaging.instance;
  FirebaseAnalytics get analytics => _analytics ??= FirebaseAnalytics.instance;
  FirebaseCrashlytics get crashlytics =>
      _crashlytics ??= FirebaseCrashlytics.instance;

  /// Initialize Firebase
  static Future<Result<void>> initialize() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp();

      // Configure Firestore settings
      await _configureFirestore();

      // Configure Firebase Messaging
      await _configureMessaging();

      // Configure Crashlytics
      await _configureCrashlytics();

      // Configure Analytics
      await _configureAnalytics();

      return const Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(
        FirebaseFailure(
          message: 'Firebase initialization failed: ${e.message}',
        ),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure(
          message: 'Unexpected error during Firebase initialization: $e',
        ),
      );
    }
  }

  /// Configure Firestore settings
  static Future<void> _configureFirestore() async {
    final firestore = FirebaseFirestore.instance;

    // Enable offline persistence
    firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // Enable network for Firestore
    await firestore.enableNetwork();
  }

  /// Configure Firebase Messaging
  static Future<void> _configureMessaging() async {
    final messaging = FirebaseMessaging.instance;

    // Request permission for notifications
    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Configure foreground message handling
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Configure background message handling
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Configure message opened app handling
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  /// Configure Crashlytics
  static Future<void> _configureCrashlytics() async {
    final crashlytics = FirebaseCrashlytics.instance;

    // Enable crashlytics collection in release mode
    await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

    // Set user identifier for crash reports
    if (FirebaseAuth.instance.currentUser != null) {
      await crashlytics.setUserIdentifier(
        FirebaseAuth.instance.currentUser!.uid,
      );
    }
  }

  /// Configure Analytics
  static Future<void> _configureAnalytics() async {
    final analytics = FirebaseAnalytics.instance;

    // Enable analytics collection
    await analytics.setAnalyticsCollectionEnabled(!kDebugMode);
  }

  /// Handle foreground messages
  static void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Received foreground message: ${message.messageId}');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
    }
  }

  /// Handle background messages
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      print('Received background message: ${message.messageId}');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
    }
  }

  /// Handle message opened app
  static void _handleMessageOpenedApp(RemoteMessage message) {
    if (kDebugMode) {
      print('Message opened app: ${message.messageId}');
      print('Data: ${message.data}');
    }
  }

  /// Get FCM token
  Future<Result<String>> getFCMToken() async {
    try {
      final token = await messaging.getToken();
      if (token != null) {
        return Result.success(token);
      } else {
        return const Result.failure(
          FirebaseFailure(message: 'Failed to get FCM token'),
        );
      }
    } on FirebaseException catch (e) {
      return Result.failure(
        FirebaseFailure(message: 'Failed to get FCM token: ${e.message}'),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Unexpected error getting FCM token: $e'),
      );
    }
  }

  /// Subscribe to topic
  Future<Result<void>> subscribeToTopic(String topic) async {
    try {
      await messaging.subscribeToTopic(topic);
      return const Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(
        FirebaseFailure(message: 'Failed to subscribe to topic: ${e.message}'),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Unexpected error subscribing to topic: $e'),
      );
    }
  }

  /// Unsubscribe from topic
  Future<Result<void>> unsubscribeFromTopic(String topic) async {
    try {
      await messaging.unsubscribeFromTopic(topic);
      return const Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(
        FirebaseFailure(
          message: 'Failed to unsubscribe from topic: ${e.message}',
        ),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure(
          message: 'Unexpected error unsubscribing from topic: $e',
        ),
      );
    }
  }

  /// Log custom event to Analytics
  Future<Result<void>> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      await analytics.logEvent(name: name, parameters: parameters);
      return const Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(
        FirebaseFailure(message: 'Failed to log event: ${e.message}'),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Unexpected error logging event: $e'),
      );
    }
  }

  /// Set user properties for Analytics
  Future<Result<void>> setUserProperties({
    required Map<String, String> properties,
  }) async {
    try {
      for (final entry in properties.entries) {
        await analytics.setUserProperty(name: entry.key, value: entry.value);
      }
      return const Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(
        FirebaseFailure(message: 'Failed to set user properties: ${e.message}'),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Unexpected error setting user properties: $e'),
      );
    }
  }

  /// Record error to Crashlytics
  Future<Result<void>> recordError({
    required dynamic exception,
    StackTrace? stackTrace,
    String? reason,
    bool fatal = false,
  }) async {
    try {
      await crashlytics.recordError(
        exception,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Unexpected error recording error: $e'),
      );
    }
  }

  /// Set custom key for Crashlytics
  Future<Result<void>> setCrashlyticsCustomKey({
    required String key,
    required Object value,
  }) async {
    try {
      await crashlytics.setCustomKey(key, value);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Unexpected error setting custom key: $e'),
      );
    }
  }

  /// Check if Firebase is initialized
  static bool get isInitialized => Firebase.apps.isNotEmpty;

  /// Dispose Firebase services
  void dispose() {
    _auth = null;
    _firestore = null;
    _storage = null;
    _messaging = null;
    _analytics = null;
    _crashlytics = null;
  }
}

/// Firebase collection names
class FirebaseCollections {
  static const String users = 'users';
  static const String products = 'products';
  static const String categories = 'categories';
  static const String orders = 'orders';
  static const String carts = 'carts';
  static const String wishlists = 'wishlists';
  static const String payments = 'payments';
  static const String paymentRequests = 'payment_requests';
  static const String reviews = 'reviews';
  static const String farmers = 'farmers';
  static const String notifications = 'notifications';
  static const String analytics = 'analytics';
}

/// Firebase storage paths
class FirebaseStoragePaths {
  static const String userProfiles = 'user_profiles';
  static const String productImages = 'product_images';
  static const String categoryImages = 'category_images';
  static const String farmerProfiles = 'farmer_profiles';
  static const String reviewImages = 'review_images';
}

/// Firebase messaging topics
class FirebaseTopics {
  static const String allUsers = 'all_users';
  static const String newProducts = 'new_products';
  static const String orderUpdates = 'order_updates';
  static const String promotions = 'promotions';
  static const String farmerUpdates = 'farmer_updates';
}
