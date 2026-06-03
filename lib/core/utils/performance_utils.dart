import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Performance monitoring utilities for the app
class PerformanceUtils {
  static const String _tag = 'PerformanceUtils';

  /// Execute a function with performance monitoring
  static Future<T> measureAsync<T>(
    String operationName,
    Future<T> Function() operation, {
    bool logResults = kDebugMode,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      final result = await operation();
      stopwatch.stop();

      if (logResults) {
        final duration = stopwatch.elapsedMilliseconds;
        developer.log(
          '✅ $operationName completed in ${duration}ms',
          name: _tag,
        );

        // Warn if operation took too long
        if (duration > 1000) {
          developer.log(
            '⚠️ $operationName took ${duration}ms - consider optimization',
            name: _tag,
          );
        }
      }

      return result;
    } catch (e) {
      stopwatch.stop();

      if (logResults) {
        developer.log(
          '❌ $operationName failed after ${stopwatch.elapsedMilliseconds}ms: $e',
          name: _tag,
        );
      }

      rethrow;
    }
  }

  /// Execute a synchronous function with performance monitoring
  static T measureSync<T>(
    String operationName,
    T Function() operation, {
    bool logResults = kDebugMode,
  }) {
    final stopwatch = Stopwatch()..start();

    try {
      final result = operation();
      stopwatch.stop();

      if (logResults) {
        final duration = stopwatch.elapsedMilliseconds;
        developer.log(
          '✅ $operationName completed in ${duration}ms',
          name: _tag,
        );

        // Warn if operation took too long on main thread
        if (duration > 16) {
          // 16ms = 60fps threshold
          developer.log(
            '⚠️ $operationName took ${duration}ms on main thread - consider async',
            name: _tag,
          );
        }
      }

      return result;
    } catch (e) {
      stopwatch.stop();

      if (logResults) {
        developer.log(
          '❌ $operationName failed after ${stopwatch.elapsedMilliseconds}ms: $e',
          name: _tag,
        );
      }

      rethrow;
    }
  }

  /// Execute operation with timeout
  static Future<T> withTimeout<T>(
    Future<T> operation,
    Duration timeout, {
    String? operationName,
  }) async {
    try {
      return await operation.timeout(timeout);
    } on TimeoutException {
      final name = operationName ?? 'Operation';
      developer.log(
        '⏰ $name timed out after ${timeout.inMilliseconds}ms',
        name: _tag,
      );
      rethrow;
    }
  }

  /// Execute operation with retry logic
  static Future<T> withRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    String? operationName,
  }) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempts++;

        if (attempts >= maxRetries) {
          final name = operationName ?? 'Operation';
          developer.log(
            '❌ $name failed after $attempts attempts: $e',
            name: _tag,
          );
          rethrow;
        }

        if (kDebugMode) {
          final name = operationName ?? 'Operation';
          developer.log(
            '🔄 $name attempt $attempts failed, retrying in ${delay.inMilliseconds}ms: $e',
            name: _tag,
          );
        }

        await Future.delayed(delay);
      }
    }

    throw StateError('Should not reach here');
  }

  /// Execute operation on background isolate
  static Future<T> runInBackground<T>(
    T Function() computation, {
    String? operationName,
  }) async {
    return await compute((_) => computation(), null);
  }

  /// Debounce function calls
  static Timer? _debounceTimer;

  static void debounce(
    Duration duration,
    VoidCallback callback, {
    String? operationName,
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(duration, () {
      if (kDebugMode && operationName != null) {
        developer.log('🎯 Executing debounced $operationName', name: _tag);
      }
      callback();
    });
  }

  /// Throttle function calls
  static DateTime? _lastThrottleTime;

  static void throttle(
    Duration duration,
    VoidCallback callback, {
    String? operationName,
  }) {
    final now = DateTime.now();

    if (_lastThrottleTime == null ||
        now.difference(_lastThrottleTime!) >= duration) {
      _lastThrottleTime = now;

      if (kDebugMode && operationName != null) {
        developer.log('🎯 Executing throttled $operationName', name: _tag);
      }

      callback();
    }
  }

  /// Log memory usage
  static void logMemoryUsage([String? context]) {
    if (!kDebugMode) return;

    // Note: This is a simplified memory check
    // For detailed memory profiling, use Flutter DevTools
    final contextStr = context != null ? ' ($context)' : '';
    developer.log(
      '📊 Memory check$contextStr - Use DevTools for detailed analysis',
      name: _tag,
    );
  }

  /// Execute operation with memory monitoring
  static Future<T> withMemoryMonitoring<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    if (kDebugMode) {
      logMemoryUsage('Before $operationName');
    }

    final result = await operation();

    if (kDebugMode) {
      logMemoryUsage('After $operationName');
    }

    return result;
  }

  /// Check if operation should be executed based on app state
  static bool shouldExecuteOperation() {
    // Add your app state checks here
    // For example, check if app is in foreground, has network, etc.
    return true;
  }

  /// Execute operation only if app is in good state
  static Future<T?> executeIfReady<T>(
    Future<T> Function() operation, {
    String? operationName,
  }) async {
    if (!shouldExecuteOperation()) {
      if (kDebugMode && operationName != null) {
        developer.log('⏸️ Skipping $operationName - app not ready', name: _tag);
      }
      return null;
    }

    return await operation();
  }

  /// Cleanup resources
  static void cleanup() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _lastThrottleTime = null;
  }
}

/// Extension to add performance monitoring to Future
extension FuturePerformance<T> on Future<T> {
  /// Add performance monitoring to any Future
  Future<T> withPerformanceMonitoring(String operationName) {
    return PerformanceUtils.measureAsync(operationName, () => this);
  }

  /// Add timeout to any Future
  Future<T> withPerformanceTimeout(Duration timeout, [String? operationName]) {
    return PerformanceUtils.withTimeout(
      this,
      timeout,
      operationName: operationName,
    );
  }

  /// Add retry logic to any Future
  Future<T> withPerformanceRetry({
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    String? operationName,
  }) {
    return PerformanceUtils.withRetry(
      () => this,
      maxRetries: maxRetries,
      delay: delay,
      operationName: operationName,
    );
  }
}
