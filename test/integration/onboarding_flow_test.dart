import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bfa/features/onboarding/presentation/providers/onboarding_provider.dart';

void main() {
  group('Onboarding Flow Integration Tests', () {
    setUp(() {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Onboarding flow should work correctly', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Initially, user should not have seen onboarding
      // Wait for loading to complete
      await tester.pump(const Duration(milliseconds: 200));
      
      expect(container.read(onboardingLoadingProvider), isFalse);
      expect(container.read(hasSeenOnboardingProvider), isFalse);

      // Complete onboarding
      await container.read(onboardingProvider.notifier).completeOnboarding();
      await tester.pump();

      // User should now have seen onboarding
      expect(container.read(hasSeenOnboardingProvider), isTrue);
      expect(container.read(onboardingLoadingProvider), isFalse);

      // Verify persistence - create new container
      final newContainer = ProviderContainer();
      addTearDown(newContainer.dispose);

      // Wait for new container to load
      await tester.pump(const Duration(milliseconds: 200));

      // Should remember that onboarding was completed
      expect(newContainer.read(hasSeenOnboardingProvider), isTrue);
      expect(newContainer.read(onboardingLoadingProvider), isFalse);
    });

    testWidgets('Reset onboarding should work correctly', (WidgetTester tester) async {
      // Start with onboarding completed
      SharedPreferences.setMockInitialValues({
        'has_seen_onboarding': true,
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Wait for loading to complete
      await tester.pump(const Duration(milliseconds: 200));

      // Should start with onboarding completed
      expect(container.read(hasSeenOnboardingProvider), isTrue);

      // Reset onboarding
      await container.read(onboardingProvider.notifier).resetOnboarding();
      await tester.pump();

      // Should now show onboarding again
      expect(container.read(hasSeenOnboardingProvider), isFalse);
    });

    testWidgets('Loading state should be handled correctly', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Initially should be loading
      expect(container.read(onboardingLoadingProvider), isTrue);

      // Wait for loading to complete
      await tester.pump(const Duration(milliseconds: 200));

      // Should no longer be loading
      expect(container.read(onboardingLoadingProvider), isFalse);
    });

    testWidgets('Multiple state changes should work correctly', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Wait for initial loading
      await tester.pump(const Duration(milliseconds: 200));

      // Initially false
      expect(container.read(hasSeenOnboardingProvider), isFalse);

      // Complete onboarding
      await container.read(onboardingProvider.notifier).completeOnboarding();
      await tester.pump();
      expect(container.read(hasSeenOnboardingProvider), isTrue);

      // Reset onboarding
      await container.read(onboardingProvider.notifier).resetOnboarding();
      await tester.pump();
      expect(container.read(hasSeenOnboardingProvider), isFalse);

      // Complete again
      await container.read(onboardingProvider.notifier).completeOnboarding();
      await tester.pump();
      expect(container.read(hasSeenOnboardingProvider), isTrue);
    });

    testWidgets('State should persist across app restarts', (WidgetTester tester) async {
      // Simulate first app launch
      final firstContainer = ProviderContainer();
      addTearDown(firstContainer.dispose);

      await tester.pump(const Duration(milliseconds: 200));
      
      // Complete onboarding
      await firstContainer.read(onboardingProvider.notifier).completeOnboarding();
      await tester.pump();

      expect(firstContainer.read(hasSeenOnboardingProvider), isTrue);

      // Dispose first container (simulate app close)
      firstContainer.dispose();

      // Simulate app restart with new container
      final secondContainer = ProviderContainer();
      addTearDown(secondContainer.dispose);

      await tester.pump(const Duration(milliseconds: 200));

      // Should remember onboarding completion
      expect(secondContainer.read(hasSeenOnboardingProvider), isTrue);
      expect(secondContainer.read(onboardingLoadingProvider), isFalse);
    });
  });
}
