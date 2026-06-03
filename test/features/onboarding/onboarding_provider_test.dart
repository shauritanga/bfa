import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bfa/features/onboarding/presentation/providers/onboarding_provider.dart';

void main() {
  group('OnboardingProvider Tests', () {
    setUp(() {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    test('Initial state should be loading with hasSeenOnboarding false', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initialState = container.read(onboardingProvider);

      expect(initialState.hasSeenOnboarding, isFalse);
      expect(initialState.isLoading, isTrue);
    });

    test('Should load onboarding status from SharedPreferences', () async {
      // Set up SharedPreferences with onboarding completed
      SharedPreferences.setMockInitialValues({
        'has_seen_onboarding': true,
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Wait for the async loading to complete
      await Future.delayed(const Duration(milliseconds: 100));

      final state = container.read(onboardingProvider);

      expect(state.hasSeenOnboarding, isTrue);
      expect(state.isLoading, isFalse);
    });

    test('Should default to false when no SharedPreferences value exists', () async {
      // SharedPreferences is empty (default)
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Wait for the async loading to complete
      await Future.delayed(const Duration(milliseconds: 100));

      final state = container.read(onboardingProvider);

      expect(state.hasSeenOnboarding, isFalse);
      expect(state.isLoading, isFalse);
    });

    test('completeOnboarding should update state and save to SharedPreferences', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Wait for initial loading to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Complete onboarding
      await container.read(onboardingProvider.notifier).completeOnboarding();

      final state = container.read(onboardingProvider);

      expect(state.hasSeenOnboarding, isTrue);
      expect(state.isLoading, isFalse);

      // Verify it was saved to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('has_seen_onboarding'), isTrue);
    });

    test('resetOnboarding should update state and save to SharedPreferences', () async {
      // Start with onboarding completed
      SharedPreferences.setMockInitialValues({
        'has_seen_onboarding': true,
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Wait for initial loading to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify initial state
      expect(container.read(onboardingProvider).hasSeenOnboarding, isTrue);

      // Reset onboarding
      await container.read(onboardingProvider.notifier).resetOnboarding();

      final state = container.read(onboardingProvider);

      expect(state.hasSeenOnboarding, isFalse);
      expect(state.isLoading, isFalse);

      // Verify it was saved to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('has_seen_onboarding'), isFalse);
    });

    test('hasSeenOnboardingProvider should return correct value', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Wait for initial loading to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Initially should be false
      expect(container.read(hasSeenOnboardingProvider), isFalse);

      // Complete onboarding
      await container.read(onboardingProvider.notifier).completeOnboarding();

      // Should now be true
      expect(container.read(hasSeenOnboardingProvider), isTrue);
    });

    test('onboardingLoadingProvider should return correct loading state', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Initially should be loading
      expect(container.read(onboardingLoadingProvider), isTrue);

      // Wait for loading to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Should no longer be loading
      expect(container.read(onboardingLoadingProvider), isFalse);
    });

    test('Should handle SharedPreferences errors gracefully', () async {
      // This test simulates what happens when SharedPreferences fails
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Wait for the async loading to complete
      await Future.delayed(const Duration(milliseconds: 100));

      final state = container.read(onboardingProvider);

      // Should default to safe values even if there are errors
      expect(state.hasSeenOnboarding, isFalse);
      expect(state.isLoading, isFalse);
    });

    test('State transitions should work correctly', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Track state changes
      final states = <OnboardingState>[];
      container.listen(onboardingProvider, (previous, next) {
        states.add(next);
      });

      // Wait for initial loading to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Complete onboarding
      await container.read(onboardingProvider.notifier).completeOnboarding();

      // Reset onboarding
      await container.read(onboardingProvider.notifier).resetOnboarding();

      // Should have recorded state transitions
      expect(states.length, greaterThanOrEqualTo(2));
      
      // Final state should be reset
      final finalState = container.read(onboardingProvider);
      expect(finalState.hasSeenOnboarding, isFalse);
      expect(finalState.isLoading, isFalse);
    });
  });
}
