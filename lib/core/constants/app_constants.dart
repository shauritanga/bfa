/// App-wide constants for the Best Farmers application
class AppConstants {
  // App Information
  static const String appName = 'Best Farmers';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Connecting you with the best farmers';

  // API Configuration
  static const String baseUrl = 'https://api.bestfarmers.com';
  static const String clickPesaBaseUrl = 'https://api.clickpesa.com';
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 15);

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String farmersCollection = 'farmers';
  static const String ordersCollection = 'orders';
  static const String categoriesCollection = 'categories';
  static const String reviewsCollection = 'reviews';
  static const String cartItemsCollection = 'cart_items';

  // Storage Paths
  static const String productImagesPath = 'product_images';
  static const String userAvatarsPath = 'user_avatars';
  static const String farmerImagesPath = 'farmer_images';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;

  // Cache Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String cartDataKey = 'cart_data';
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String themePreferenceKey = 'theme_preference';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 500;

  // Image Constraints
  static const double maxImageSizeMB = 5.0;
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1080;
  static const List<String> allowedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;

  // Grid Layout
  static const int mobileGridColumns = 2;
  static const int tabletGridColumns = 3;
  static const int desktopGridColumns = 4;

  // Breakpoints for responsive design
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  // Error Messages
  static const String networkErrorMessage =
      'Please check your internet connection';
  static const String serverErrorMessage =
      'Something went wrong. Please try again';
  static const String authErrorMessage =
      'Authentication failed. Please login again';
  static const String validationErrorMessage =
      'Please check your input and try again';

  // Success Messages
  static const String loginSuccessMessage = 'Welcome back!';
  static const String registerSuccessMessage = 'Account created successfully';
  static const String orderSuccessMessage = 'Order placed successfully';
  static const String paymentSuccessMessage = 'Payment completed successfully';

  // Product Categories
  static const List<String> defaultCategories = [
    'Vegetables',
    'Fruits',
    'Grains',
    'Legumes',
    'Herbs',
    'Spices',
    'Roots & Tubers',
    'Leafy Greens',
  ];

  // Payment Methods
  static const List<String> supportedPaymentMethods = [
    'M-Pesa',
    'Tigo Pesa',
    'Airtel Money',
    'Halopesa',
  ];

  // Order Status
  static const String orderStatusPending = 'pending';
  static const String orderStatusConfirmed = 'confirmed';
  static const String orderStatusPreparing = 'preparing';
  static const String orderStatusShipped = 'shipped';
  static const String orderStatusDelivered = 'delivered';
  static const String orderStatusCancelled = 'cancelled';

  // Rating Constants
  static const double minRating = 1.0;
  static const double maxRating = 5.0;
  static const double defaultRating = 0.0;

  // Search
  static const int minSearchLength = 2;
  static const int maxSearchHistory = 10;
  static const Duration searchDebounceDelay = Duration(milliseconds: 500);
}
