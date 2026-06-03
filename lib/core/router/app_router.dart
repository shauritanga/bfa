import 'package:bfa/features/home/presentation/pages/home_page.dart';
import 'package:bfa/features/products/presentation/pages/product_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/client_shell.dart';
import '../screens/splash_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/products/presentation/pages/products_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';

import '../../features/checkout/presentation/screens/checkout_screen.dart';
import '../../features/orders/presentation/screens/orders.dart';
import '../../features/orders/presentation/screens/order_details_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/search/presentation/pages/search_page.dart';
import 'app_routes.dart';

// Global navigator keys for StatefulShellRoute
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _productsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'products');
final _cartNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'cart');
final _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    initialLocation: "/splash",

    // Redirect logic based on authentication and onboarding state
    redirect: (context, state) {
      final isAuthenticated = ref.read(isAuthenticatedProvider);
      final isLoading = ref.read(authLoadingProvider);
      final currentPath = state.uri.toString();

      // If still loading auth state, stay on splash
      if (isLoading && currentPath == "/splash") {
        return null;
      }

      // Define public routes that don't require authentication
      final publicRoutes = [
        "/splash",
        "/onboarding",
        "/login",
        "/register",
        "/forgot-password",
      ];

      final isPublicRoute = publicRoutes.contains(currentPath);

      // Simplified logic: protect authenticated routes only
      if (!isAuthenticated && !isPublicRoute) {
        return "/login";
      }

      // If user is authenticated and on auth pages, redirect to home
      if (isAuthenticated &&
          (currentPath == "/login" || currentPath == "/register")) {
        return "/home";
      }

      return null; // No redirect needed
    },

    routes: [
      // Splash Route
      GoRoute(
        path: "/splash",
        name: AppRoute.splash.name,
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding Route
      GoRoute(
        path: "/onboarding",
        name: AppRoute.onboarding.name,
        builder: (context, state) => const OnboardingPage(),
      ),

      // Authentication Routes
      GoRoute(
        path: "/login",
        name: AppRoute.login.name,
        builder: (context, state) => const LoginPage(),
      ),

      GoRoute(
        path: "/register",
        name: AppRoute.register.name,
        builder: (context, state) => const RegisterPage(),
      ),

      GoRoute(
        name: AppRoute.forgotPassword.name,
        path: "/forgot-password",
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      // Search Route
      GoRoute(
        path: "/search",
        name: AppRoute.search.name,
        builder: (context, state) {
          final query = state.uri.queryParameters['q'];
          return SearchPage(initialQuery: query);
        },
      ),

      // Main App Routes (Protected) - Stateful Shell with Bottom Navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ClientShell(navigationShell: navigationShell);
        },
        branches: [
          // Home Branch
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: "/home",
                name: AppRoute.home.name,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: HomePage()),
              ),
            ],
          ),

          // Products Branch
          StatefulShellBranch(
            navigatorKey: _productsNavigatorKey,
            routes: [
              GoRoute(
                path: "/products",
                name: AppRoute.products.name,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ProductsPage()),
                routes: [
                  // Product Details - nested route
                  GoRoute(
                    path: ":id",
                    name: AppRoute.productDetails.name,
                    builder: (context, state) {
                      final productId = state.pathParameters['id']!;
                      return ProductDetailsScreen(productId: productId);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Cart Branch
          StatefulShellBranch(
            navigatorKey: _cartNavigatorKey,
            routes: [
              GoRoute(
                path: "/cart",
                name: AppRoute.cart.name,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: CartPage()),
                routes: [
                  // Checkout - nested route
                  GoRoute(
                    path: "checkout",
                    name: AppRoute.checkout.name,
                    builder: (context, state) => const CheckoutScreen(),
                  ),
                ],
              ),
            ],
          ),
          // Profile Branch
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: "/profile",
                name: AppRoute.profile.name,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ProfilePage()),
                routes: [
                  // Orders - nested route
                  GoRoute(
                    path: "orders",
                    name: AppRoute.orders.name,
                    builder: (context, state) => const OrdersScreen(),
                    routes: [
                      // Order Details - nested route
                      GoRoute(
                        path: ":id",
                        name: AppRoute.orderDetails.name,
                        builder: (context, state) {
                          final orderId = state.pathParameters['id']!;
                          return OrderDetailsScreen(orderId: orderId);
                        },
                      ),
                    ],
                  ),
                  // Favorites/Wishlist - nested route
                  GoRoute(
                    path: "favorites",
                    name: AppRoute.favorites.name,
                    builder: (context, state) => const FavoritesScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.uri.toString()}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.goNamed(AppRoute.home.name),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
