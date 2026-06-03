/// ClickPesa configuration for the application
class ClickPesaConfig {
  // Environment-specific URLs (based on official documentation)
  static const String productionBaseUrl = 'https://api.clickpesa.com';
  static const String sandboxBaseUrl =
      'https://api.clickpesa.com'; // Same URL, different credentials

  // Production configuration (these are your actual ClickPesa credentials)
  static const String defaultApiKey =
      'SK0CzsS0PstDFaMbvxDsHKsRka3uK0s6aFrB1NYwOM';
  static const String defaultClientId = 'IDme5ATc4Z2PpipLTBO0KyK1spdDIlhd';
  static const String defaultChecksumKey =
      'CHKrHaWbkvbcLnQGGTpbvJ2JGit0yT5rFwA';

  // Note: ClickPesa uses Client ID + API Key (not secret key)
  // The secret key field is kept for backward compatibility but not used

  // Payment configuration
  static const String currency = 'TZS';
  static const double minimumAmount = 1000.0; // TZS 1,000
  static const double maximumAmount = 10000000.0; // TZS 10,000,000

  // Timeout settings
  static const Duration paymentTimeout = Duration(minutes: 15);
  static const Duration requestTimeout = Duration(seconds: 30);

  // Callback URLs (should be configured per environment)
  static const String callbackBaseUrl = 'https://api.freshcrops.co.tz';
  static const String successBaseUrl = 'https://app.freshcrops.co.tz';

  final String baseUrl;
  final String clientId;
  final String apiKey;
  final String checksumKey;
  final bool isProduction;

  const ClickPesaConfig({
    required this.baseUrl,
    required this.clientId,
    required this.apiKey,
    required this.checksumKey,
    required this.isProduction,
  });

  /// Create sandbox configuration
  factory ClickPesaConfig.sandbox({
    String? clientId,
    String? apiKey,
    String? checksumKey,
  }) {
    return ClickPesaConfig(
      baseUrl: sandboxBaseUrl,
      clientId: clientId ?? defaultClientId,
      apiKey: apiKey ?? defaultApiKey,
      checksumKey: checksumKey ?? defaultChecksumKey,
      isProduction: false,
    );
  }

  /// Create production configuration
  factory ClickPesaConfig.production({
    required String clientId,
    required String apiKey,
    required String checksumKey,
  }) {
    return ClickPesaConfig(
      baseUrl: productionBaseUrl,
      clientId: clientId,
      apiKey: apiKey,
      checksumKey: checksumKey,
      isProduction: true,
    );
  }

  /// Get callback URL for order
  String getCallbackUrl(String orderId) {
    return '$callbackBaseUrl/payments/callback/$orderId';
  }

  /// Get success URL for order
  String getSuccessUrl(String orderId) {
    return '$successBaseUrl/orders/$orderId/payment-success';
  }

  /// Get failure URL for order
  String getFailureUrl(String orderId) {
    return '$successBaseUrl/orders/$orderId/payment-failed';
  }

  /// Validate amount
  bool isValidAmount(double amount) {
    return amount >= minimumAmount && amount <= maximumAmount;
  }

  /// Get environment name
  String get environmentName => isProduction ? 'production' : 'sandbox';

  @override
  String toString() {
    return 'ClickPesaConfig(environment: $environmentName, baseUrl: $baseUrl)';
  }
}

/// ClickPesa payment method configuration
class ClickPesaPaymentMethods {
  // Supported mobile money providers
  static const List<String> supportedProviders = [
    'MPESA',
    'TIGO_PESA',
    'AIRTEL_MONEY',
    'HALO_PESA',
  ];

  // Provider configurations
  static const Map<String, Map<String, dynamic>> providerConfig = {
    'MPESA': {
      'name': 'M-Pesa',
      'code': 'MPESA',
      'minAmount': 1000.0,
      'maxAmount': 10000000.0,
      'fee': 0.0, // Fee handled by ClickPesa
    },
    'TIGO_PESA': {
      'name': 'Tigo Pesa',
      'code': 'TIGO_PESA',
      'minAmount': 1000.0,
      'maxAmount': 5000000.0,
      'fee': 0.0,
    },
    'AIRTEL_MONEY': {
      'name': 'Airtel Money',
      'code': 'AIRTEL_MONEY',
      'minAmount': 1000.0,
      'maxAmount': 5000000.0,
      'fee': 0.0,
    },
    'HALO_PESA': {
      'name': 'HaloPesa',
      'code': 'HALO_PESA',
      'minAmount': 1000.0,
      'maxAmount': 3000000.0,
      'fee': 0.0,
    },
  };

  /// Get provider configuration
  static Map<String, dynamic>? getProviderConfig(String provider) {
    return providerConfig[provider.toUpperCase()];
  }

  /// Check if provider is supported
  static bool isProviderSupported(String provider) {
    return supportedProviders.contains(provider.toUpperCase());
  }

  /// Get provider display name
  static String getProviderDisplayName(String provider) {
    final config = getProviderConfig(provider);
    return config?['name'] ?? provider;
  }

  /// Validate amount for provider
  static bool isValidAmountForProvider(String provider, double amount) {
    final config = getProviderConfig(provider);
    if (config == null) return false;

    final minAmount = config['minAmount'] as double;
    final maxAmount = config['maxAmount'] as double;

    return amount >= minAmount && amount <= maxAmount;
  }
}

/// ClickPesa integration status
enum ClickPesaIntegrationStatus { notConfigured, configured, testing, live }

/// ClickPesa integration info
class ClickPesaIntegrationInfo {
  final ClickPesaIntegrationStatus status;
  final String message;
  final DateTime lastChecked;

  const ClickPesaIntegrationInfo({
    required this.status,
    required this.message,
    required this.lastChecked,
  });

  /// Check if integration is ready
  bool get isReady =>
      status == ClickPesaIntegrationStatus.configured ||
      status == ClickPesaIntegrationStatus.testing ||
      status == ClickPesaIntegrationStatus.live;

  /// Check if in production
  bool get isLive => status == ClickPesaIntegrationStatus.live;

  factory ClickPesaIntegrationInfo.notConfigured() {
    return ClickPesaIntegrationInfo(
      status: ClickPesaIntegrationStatus.notConfigured,
      message: 'ClickPesa API keys not configured',
      lastChecked: DateTime.now(),
    );
  }

  factory ClickPesaIntegrationInfo.configured() {
    return ClickPesaIntegrationInfo(
      status: ClickPesaIntegrationStatus.configured,
      message: 'ClickPesa integration configured and ready',
      lastChecked: DateTime.now(),
    );
  }

  factory ClickPesaIntegrationInfo.testing() {
    return ClickPesaIntegrationInfo(
      status: ClickPesaIntegrationStatus.testing,
      message: 'ClickPesa integration in testing mode',
      lastChecked: DateTime.now(),
    );
  }

  factory ClickPesaIntegrationInfo.live() {
    return ClickPesaIntegrationInfo(
      status: ClickPesaIntegrationStatus.live,
      message: 'ClickPesa integration live and operational',
      lastChecked: DateTime.now(),
    );
  }
}
