/// Application route constants
class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  // Authentication Routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Main App Routes
  static const String home = '/home';
  static const String profile = '/profile';

  // Product Routes
  static const String products = '/products';
  static const String productDetails = '/products/:id';
  static const String categories = '/categories';
  static const String categoryProducts = '/categories/:id/products';

  // Shopping Routes
  static const String cart = '/cart';
  static const String wishlist = '/wishlist';
  static const String checkout = '/checkout';

  // Order Routes
  static const String orders = '/orders';
  static const String orderDetails = '/orders/:id';
  static const String orderTracking = '/orders/:id/tracking';

  // Payment Routes
  static const String payment = '/payment';
  static const String paymentSuccess = '/payment/success';
  static const String paymentFailure = '/payment/failure';

  // User Routes
  static const String editProfile = '/profile/edit';
  static const String changePassword = '/profile/change-password';
  static const String addresses = '/profile/addresses';
  static const String addAddress = '/profile/addresses/add';
  static const String editAddress = '/profile/addresses/:id/edit';

  // Farmer Routes
  static const String farmers = '/farmers';
  static const String farmerProfile = '/farmers/:id';
  static const String farmerProducts = '/farmers/:id/products';

  // Review Routes
  static const String reviews = '/reviews';
  static const String writeReview = '/products/:id/review';

  // Search Routes
  static const String search = '/search';
  static const String searchResults = '/search/results';

  // Settings Routes
  static const String settings = '/settings';
  static const String notifications = '/settings/notifications';
  static const String privacy = '/settings/privacy';
  static const String terms = '/settings/terms';
  static const String about = '/settings/about';
  static const String help = '/settings/help';

  // Error Routes
  static const String notFound = '/404';
  static const String error = '/error';

  /// Helper method to build product details route
  static String productDetailsRoute(String productId) {
    return productDetails.replaceAll(':id', productId);
  }

  /// Helper method to build category products route
  static String categoryProductsRoute(String categoryId) {
    return categoryProducts.replaceAll(':id', categoryId);
  }

  /// Helper method to build order details route
  static String orderDetailsRoute(String orderId) {
    return orderDetails.replaceAll(':id', orderId);
  }

  /// Helper method to build order tracking route
  static String orderTrackingRoute(String orderId) {
    return orderTracking.replaceAll(':id', orderId);
  }

  /// Helper method to build farmer profile route
  static String farmerProfileRoute(String farmerId) {
    return farmerProfile.replaceAll(':id', farmerId);
  }

  /// Helper method to build farmer products route
  static String farmerProductsRoute(String farmerId) {
    return farmerProducts.replaceAll(':id', farmerId);
  }

  /// Helper method to build edit address route
  static String editAddressRoute(String addressId) {
    return editAddress.replaceAll(':id', addressId);
  }

  /// Helper method to build write review route
  static String writeReviewRoute(String productId) {
    return writeReview.replaceAll(':id', productId);
  }

  /// Get all authentication routes
  static List<String> get authRoutes => [
        splash,
        login,
        register,
        forgotPassword,
      ];

  /// Get all protected routes (require authentication)
  static List<String> get protectedRoutes => [
        home,
        profile,
        products,
        cart,
        wishlist,
        checkout,
        orders,
        payment,
        editProfile,
        changePassword,
        addresses,
        addAddress,
        farmers,
        reviews,
        search,
        settings,
      ];

  /// Check if a route is protected
  static bool isProtectedRoute(String route) {
    return protectedRoutes.any((protectedRoute) {
      // Handle parameterized routes
      if (protectedRoute.contains(':')) {
        final pattern = protectedRoute.replaceAll(RegExp(r':[^/]+'), r'[^/]+');
        return RegExp('^$pattern\$').hasMatch(route);
      }
      return route == protectedRoute;
    });
  }

  /// Check if a route is an auth route
  static bool isAuthRoute(String route) {
    return authRoutes.contains(route);
  }
}
