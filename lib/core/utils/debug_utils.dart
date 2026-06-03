import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Debug utilities for development and testing
class DebugUtils {
  DebugUtils._();

  /// Reset onboarding status (only works in debug mode)
  static Future<void> resetOnboarding() async {
    if (kDebugMode) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('has_seen_onboarding', false);
        print('DEBUG: Onboarding status reset to false');
      } catch (e) {
        print('DEBUG: Failed to reset onboarding: $e');
      }
    }
  }

  /// Set onboarding as completed (only works in debug mode)
  static Future<void> completeOnboarding() async {
    if (kDebugMode) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('has_seen_onboarding', true);
        print('DEBUG: Onboarding status set to true');
      } catch (e) {
        print('DEBUG: Failed to complete onboarding: $e');
      }
    }
  }

  /// Check current onboarding status (only works in debug mode)
  static Future<void> checkOnboardingStatus() async {
    if (kDebugMode) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
        print('DEBUG: Current onboarding status: $hasSeenOnboarding');
      } catch (e) {
        print('DEBUG: Failed to check onboarding status: $e');
      }
    }
  }

  /// Clear all SharedPreferences (only works in debug mode)
  static Future<void> clearAllPreferences() async {
    if (kDebugMode) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        print('DEBUG: All SharedPreferences cleared');
      } catch (e) {
        print('DEBUG: Failed to clear preferences: $e');
      }
    }
  }

  /// Print all SharedPreferences keys and values (only works in debug mode)
  static Future<void> printAllPreferences() async {
    if (kDebugMode) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final keys = prefs.getKeys();
        print('DEBUG: SharedPreferences contents:');
        for (final key in keys) {
          final value = prefs.get(key);
          print('  $key: $value');
        }
        if (keys.isEmpty) {
          print('  (empty)');
        }
      } catch (e) {
        print('DEBUG: Failed to print preferences: $e');
      }
    }
  }
}
