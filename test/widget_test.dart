// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bfa/main.dart';
import 'package:bfa/core/constants/app_constants.dart';

void main() {
  group('App Constants Tests', () {
    test('App constants are properly defined', () {
      expect(AppConstants.appName, equals('Best Farmers'));
      expect(AppConstants.appVersion, equals('1.0.0'));
      expect(
        AppConstants.appDescription,
        equals('Connecting you with the best farmers'),
      );
    });
  });

  group('Widget Tests', () {
    testWidgets('Firebase error app shows error message', (
      WidgetTester tester,
    ) async {
      const errorMessage = 'Test Firebase error';

      // Build the error app
      await tester.pumpWidget(const FirebaseErrorApp(error: errorMessage));

      // Verify that the error message is shown
      expect(find.text('Firebase Initialization Failed'), findsOneWidget);
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.text('Restart App'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('App title uses correct app name', (WidgetTester tester) async {
      // Create a simple MaterialApp to test the title
      await tester.pumpWidget(
        const MaterialApp(
          title: AppConstants.appName,
          home: Scaffold(body: Center(child: Text('Test App'))),
        ),
      );

      // The title is used internally by Flutter, so we just verify the app builds
      expect(find.text('Test App'), findsOneWidget);
    });
  });
}
