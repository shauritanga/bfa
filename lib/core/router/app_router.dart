import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/products/presentation/pages/products_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../constants/app_routes.dart';

/// Router configuration for the app
class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  /// Create the router configuration
  static GoRouter createRouter(Ref ref) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      debugLogDiagnostics: true,
      initialLocation: AppRoutes.splash,

      // Redirect logic based on authentication state
      redirect: (context, state) {
        final isAuthenticated = ref.read(isAuthenticatedProvider);
        final isLoading = ref.read(authLoadingProvider);

        // If still loading auth state, stay on splash
        if (isLoading && state.uri.toString() == AppRoutes.splash) {
          return null;
        }

        // Define public routes that don't require authentication
        final publicRoutes = [
          AppRoutes.splash,
          AppRoutes.login,
          AppRoutes.register,
          AppRoutes.forgotPassword,
        ];

        final isPublicRoute = publicRoutes.contains(state.uri.toString());

        // If user is not authenticated and trying to access protected route
        if (!isAuthenticated && !isPublicRoute) {
          return AppRoutes.login;
        }

        // If user is authenticated and on auth pages, redirect to home
        if (isAuthenticated &&
            isPublicRoute &&
            state.uri.toString() != AppRoutes.splash) {
          return AppRoutes.home;
        }

        return null; // No redirect needed
      },

      routes: [
        // Splash Route
        GoRoute(
          path: AppRoutes.splash,
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),

        // Authentication Routes
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),

        GoRoute(
          path: AppRoutes.register,
          name: 'register',
          builder: (context, state) => const RegisterPage(),
        ),

        GoRoute(
          path: AppRoutes.forgotPassword,
          name: 'forgot-password',
          builder: (context, state) => const ForgotPasswordPage(),
        ),

        // Main App Routes (Protected)
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),

        GoRoute(
          path: AppRoutes.profile,
          name: 'profile',
          builder: (context, state) => const ProfilePage(),
        ),

        // Products Routes
        GoRoute(
          path: AppRoutes.products,
          name: 'products',
          builder: (context, state) => const ProductsPage(),
        ),

        GoRoute(
          path: AppRoutes.productDetails,
          name: 'product-details',
          builder: (context, state) {
            final productId = state.pathParameters['id']!;
            return ProductDetailsPlaceholder(productId: productId);
          },
        ),

        GoRoute(
          path: AppRoutes.categoryProducts,
          name: 'category-products',
          builder: (context, state) {
            final categoryId = state.pathParameters['id']!;
            return ProductsPage(categoryId: categoryId);
          },
        ),

        // Cart Route
        GoRoute(
          path: AppRoutes.cart,
          name: 'cart',
          builder: (context, state) => const CartPage(),
        ),

        // TODO: Add more routes as features are implemented

        // GoRoute(
        //   path: AppRoutes.orders,
        //   name: 'orders',
        //   builder: (context, state) => const OrdersPage(),
        // ),
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
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  return AppRouter.createRouter(ref);
});

// Temporary placeholder widgets - these will be replaced with actual implementations
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag),
            onPressed: () => context.push('/products'),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => context.push('/cart'),
          ),
        ],
      ),
      body: const Center(child: Text('Welcome to FreshCrops!')),
    );
  }
}

class ProductDetailsPlaceholder extends StatelessWidget {
  final String productId;

  const ProductDetailsPlaceholder({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 64),
            const SizedBox(height: 16),
            const Text('Product Details Page'),
            Text('Product ID: $productId'),
            const SizedBox(height: 16),
            const Text('Coming Soon!'),
          ],
        ),
      ),
    );
  }
}
