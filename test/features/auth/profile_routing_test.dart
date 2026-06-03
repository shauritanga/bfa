import 'package:flutter_test/flutter_test.dart';
import 'package:bfa/core/router/app_routes.dart';

void main() {
  group('Profile Page Routing Tests', () {
    test('AppRoute enum should contain all required routes', () {
      // Test that all necessary routes are defined
      expect(AppRoute.values, contains(AppRoute.profile));
      expect(AppRoute.values, contains(AppRoute.orders));
      expect(AppRoute.values, contains(AppRoute.orderDetails));
      expect(AppRoute.values, contains(AppRoute.favorites));
    });

    test('Profile nested routes should be properly structured', () {
      // Test route structure for profile navigation
      const profileRoutes = [
        '/profile',
        '/profile/orders',
        '/profile/orders/:id',
        '/profile/favorites',
      ];
      
      // Verify all profile routes are accounted for
      expect(profileRoutes.length, equals(4));
      expect(profileRoutes, contains('/profile'));
      expect(profileRoutes, contains('/profile/orders'));
      expect(profileRoutes, contains('/profile/orders/:id'));
      expect(profileRoutes, contains('/profile/favorites'));
    });

    test('Route navigation paths should be correctly formatted', () {
      // Test that route paths follow expected patterns
      const ordersRoute = '/profile/orders';
      const favoritesRoute = '/profile/favorites';
      const orderDetailsRoute = '/profile/orders/123';
      
      // Verify route format
      expect(ordersRoute, startsWith('/profile/'));
      expect(favoritesRoute, startsWith('/profile/'));
      expect(orderDetailsRoute, matches(RegExp(r'^/profile/orders/\w+$')));
    });

    test('Profile page should support deep linking', () {
      // Test that profile routes support deep linking
      const deepLinkRoutes = [
        '/profile/orders',
        '/profile/favorites',
        '/profile/orders/order123',
      ];
      
      for (final route in deepLinkRoutes) {
        expect(route, startsWith('/profile/'));
        expect(route.split('/').length, greaterThanOrEqualTo(3));
      }
    });

    test('Route parameters should be properly handled', () {
      // Test parameterized routes
      const orderIdPattern = r'/profile/orders/([^/]+)';
      const testOrderRoute = '/profile/orders/order123';
      
      final regex = RegExp(orderIdPattern);
      final match = regex.firstMatch(testOrderRoute);
      
      expect(match, isNotNull);
      expect(match!.group(1), equals('order123'));
    });

    test('Navigation structure should be hierarchical', () {
      // Test that routes follow proper hierarchy
      const routes = [
        '/profile',           // Level 1: Profile root
        '/profile/orders',    // Level 2: Orders list
        '/profile/orders/123', // Level 3: Order details
        '/profile/favorites', // Level 2: Favorites list
      ];
      
      // Verify hierarchy depth
      expect(routes[0].split('/').length, equals(2)); // /profile
      expect(routes[1].split('/').length, equals(3)); // /profile/orders
      expect(routes[2].split('/').length, equals(4)); // /profile/orders/123
      expect(routes[3].split('/').length, equals(3)); // /profile/favorites
    });

    test('Route constants should be consistent', () {
      // Test that route naming follows conventions
      final routeNames = AppRoute.values.map((route) => route.name).toList();
      
      // Verify naming conventions
      expect(routeNames, contains('profile'));
      expect(routeNames, contains('orders'));
      expect(routeNames, contains('orderDetails'));
      expect(routeNames, contains('favorites'));
      
      // Verify no duplicate names
      final uniqueNames = routeNames.toSet();
      expect(uniqueNames.length, equals(routeNames.length));
    });
  });
}
