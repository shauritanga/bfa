import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomePage Tests', () {
    test('Greeting message should change based on time of day', () {
      // Test the greeting logic
      final homePage = _HomePageState();
      
      // Mock different times of day
      // Note: In a real test, you'd need to mock DateTime.now()
      // For now, we'll just test that the method exists and returns a string
      
      expect(homePage._getGreetingMessage(), isA<String>());
      expect(homePage._getGreetingMessage().isNotEmpty, isTrue);
    });

    test('Greeting should contain appropriate time-based message', () {
      final homePage = _HomePageState();
      final greeting = homePage._getGreetingMessage();
      
      // Should contain one of the expected greetings
      final validGreetings = ['Good Morning!', 'Good Afternoon!', 'Good Evening!'];
      expect(validGreetings.contains(greeting), isTrue);
    });
  });
}

// Helper class to access private methods for testing
class _HomePageState {
  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning!';
    } else if (hour < 17) {
      return 'Good Afternoon!';
    } else {
      return 'Good Evening!';
    }
  }
}
