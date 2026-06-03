import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Onboarding state
class OnboardingState {
  final bool hasSeenOnboarding;
  final bool isLoading;

  const OnboardingState({
    required this.hasSeenOnboarding,
    required this.isLoading,
  });

  OnboardingState copyWith({bool? hasSeenOnboarding, bool? isLoading}) {
    return OnboardingState(
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Onboarding state provider
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  static const String _onboardingKey = 'has_seen_onboarding';

  OnboardingNotifier()
    : super(const OnboardingState(hasSeenOnboarding: false, isLoading: true)) {
    _loadOnboardingStatus();
  }

  /// Load onboarding status from shared preferences
  Future<void> _loadOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool(_onboardingKey) ?? false;

      // Check if the notifier is still mounted before updating state
      if (mounted) {
        state = state.copyWith(
          hasSeenOnboarding: hasSeenOnboarding,
          isLoading: false,
        );
      }
    } catch (e) {
      // If there's an error, assume user hasn't seen onboarding
      if (mounted) {
        state = state.copyWith(hasSeenOnboarding: false, isLoading: false);
      }
    }
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, true);

      if (mounted) {
        state = state.copyWith(hasSeenOnboarding: true);
      }
    } catch (e) {
      // Handle error silently - onboarding will show again
    }
  }

  /// Reset onboarding status (for testing/debugging)
  Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, false);

      if (mounted) {
        state = state.copyWith(hasSeenOnboarding: false);
      }
    } catch (e) {
      // Handle error silently
    }
  }
}

/// Provider for onboarding status
final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
      return OnboardingNotifier();
    });

/// Provider to check if user has completed onboarding
final hasSeenOnboardingProvider = Provider<bool>((ref) {
  return ref.watch(onboardingProvider).hasSeenOnboarding;
});

/// Provider to check if onboarding is loading
final onboardingLoadingProvider = Provider<bool>((ref) {
  return ref.watch(onboardingProvider).isLoading;
});
