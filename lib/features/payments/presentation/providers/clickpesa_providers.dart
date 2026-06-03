import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../../core/config/clickpesa_config.dart';
import '../../data/services/clickpesa_api_service.dart';
import '../../data/services/clickpesa_integration_service.dart';

/// HTTP client provider
final httpClientProvider = Provider<http.Client>((ref) {
  return http.Client();
});

/// ClickPesa configuration provider
final clickPesaConfigProvider = Provider<ClickPesaConfig>((ref) {
  // Use sandbox for development, production for live
  //return ClickPesaConfig.sandbox();

  //For production, use your actual ClickPesa credentials:
  return ClickPesaConfig.production(
    clientId: 'IDme5ATc4Z2PpipLTBO0KyK1spdDIlhd',
    apiKey: 'SK0CzsS0PstDFaMbvxDsHKsRka3uK0s6aFrB1NYwOM',
    checksumKey: 'CHKrHaWbkvbcLnQGGTpbvJ2JGit0yT5rFwA',
  );

  // Or if you have sandbox credentials that work:
  // return ClickPesaConfig.sandbox(
  //   clientId: 'your_sandbox_client_id',
  //   apiKey: 'your_sandbox_api_key',
  // );
});

/// ClickPesa API service provider
final clickPesaApiServiceProvider = Provider<ClickPesaApiService>((ref) {
  final config = ref.watch(clickPesaConfigProvider);
  final httpClient = ref.watch(httpClientProvider);

  return ClickPesaApiService(
    baseUrl: config.baseUrl,
    clientId: config.clientId,
    apiKey: config.apiKey,
    checksumKey: config.checksumKey,
    httpClient: httpClient,
  );
});

/// ClickPesa integration service provider
final clickPesaIntegrationServiceProvider =
    Provider<ClickPesaIntegrationService>((ref) {
      final apiService = ref.watch(clickPesaApiServiceProvider);
      final config = ref.watch(clickPesaConfigProvider);

      return ClickPesaIntegrationService(
        apiService: apiService,
        config: config,
      );
    });

/// ClickPesa status provider
final clickPesaStatusProvider = Provider<Map<String, dynamic>>((ref) {
  final integrationService = ref.watch(clickPesaIntegrationServiceProvider);
  return integrationService.getIntegrationStatus();
});

/// Payment status provider for a specific order
final paymentStatusProvider = FutureProvider.family<PaymentResult?, String>((
  ref,
  orderReference,
) async {
  final integrationService = ref.watch(clickPesaIntegrationServiceProvider);

  final result = await integrationService.checkPaymentStatus(
    orderReference: orderReference,
  );

  return result.isSuccess ? result.data : null;
});

/// Provider to initiate mobile money payment
final mobileMoneyPaymentProvider =
    FutureProvider.family<PaymentResult?, MobileMoneyPaymentRequest>((
      ref,
      request,
    ) async {
      final integrationService = ref.watch(clickPesaIntegrationServiceProvider);

      final result = await integrationService.processMobileMoneyPayment(
        amount: request.amount,
        phoneNumber: request.phoneNumber,
        orderReference: request.orderReference,
        currency: request.currency,
      );

      return result.isSuccess ? result.data : null;
    });

/// Mobile money payment request model
class MobileMoneyPaymentRequest {
  final double amount;
  final String phoneNumber;
  final String orderReference;
  final String currency;

  const MobileMoneyPaymentRequest({
    required this.amount,
    required this.phoneNumber,
    required this.orderReference,
    this.currency = 'TZS',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MobileMoneyPaymentRequest &&
          runtimeType == other.runtimeType &&
          amount == other.amount &&
          phoneNumber == other.phoneNumber &&
          orderReference == other.orderReference &&
          currency == other.currency;

  @override
  int get hashCode =>
      amount.hashCode ^
      phoneNumber.hashCode ^
      orderReference.hashCode ^
      currency.hashCode;
}

/// ClickPesa environment provider
final clickPesaEnvironmentProvider = Provider<String>((ref) {
  final config = ref.watch(clickPesaConfigProvider);
  return config.isProduction ? 'production' : 'sandbox';
});

/// Provider to check if ClickPesa is properly configured
final clickPesaConfigurationStatusProvider = Provider<bool>((ref) {
  final config = ref.watch(clickPesaConfigProvider);

  // Check if credentials are properly set
  final hasClientId =
      config.clientId.isNotEmpty &&
      config.clientId != 'your_clickpesa_client_id_here';
  final hasApiKey =
      config.apiKey.isNotEmpty &&
      config.apiKey != 'your_clickpesa_api_key_here';

  return hasClientId && hasApiKey;
});

/// Provider for ClickPesa integration health check
final clickPesaHealthCheckProvider = FutureProvider<bool>((ref) async {
  try {
    final apiService = ref.watch(clickPesaApiServiceProvider);
    final tokenResult = await apiService.generateToken();
    return tokenResult.isSuccess;
  } catch (e) {
    return false;
  }
});

/// Provider for supported payment methods
final supportedPaymentMethodsProvider = Provider<List<String>>((ref) {
  return ['MPESA', 'TIGO_PESA', 'AIRTEL_MONEY', 'HALO_PESA'];
});

/// Provider to validate phone number
final phoneNumberValidationProvider = Provider.family<bool, String>((
  ref,
  phoneNumber,
) {
  final apiService = ref.watch(clickPesaApiServiceProvider);
  return apiService.isValidTanzanianPhoneNumber(phoneNumber);
});

/// Provider to format phone number
final phoneNumberFormatterProvider = Provider.family<String, String>((
  ref,
  phoneNumber,
) {
  final apiService = ref.watch(clickPesaApiServiceProvider);
  return apiService.formatPhoneNumber(phoneNumber);
});

/// Provider to validate payment amount
final paymentAmountValidationProvider = Provider.family<bool, double>((
  ref,
  amount,
) {
  final apiService = ref.watch(clickPesaApiServiceProvider);
  return apiService.isValidAmount(amount);
});

/// Provider for minimum and maximum payment amounts
final paymentLimitsProvider = Provider<Map<String, double>>((ref) {
  return {
    'minimum': 1000.0, // TZS 1,000
    'maximum': 10000000.0, // TZS 10,000,000
  };
});

/// Provider to clear ClickPesa token cache
final clearTokenCacheProvider = Provider<VoidCallback>((ref) {
  return () {
    final apiService = ref.read(clickPesaApiServiceProvider);
    apiService.clearTokenCache();
  };
});

/// Provider for ClickPesa token status
final tokenStatusProvider = Provider<Map<String, dynamic>>((ref) {
  final apiService = ref.watch(clickPesaApiServiceProvider);
  return apiService.getTokenStatus();
});

/// Provider for ClickPesa configuration summary
final configurationSummaryProvider = Provider<Map<String, dynamic>>((ref) {
  final config = ref.watch(clickPesaConfigProvider);
  final isConfigured = ref.watch(clickPesaConfigurationStatusProvider);
  final environment = ref.watch(clickPesaEnvironmentProvider);
  final tokenStatus = ref.watch(tokenStatusProvider);

  return {
    'isConfigured': isConfigured,
    'environment': environment,
    'baseUrl': config.baseUrl,
    'hasValidCredentials': isConfigured,
    'tokenStatus': tokenStatus,
    'supportedMethods': ref.watch(supportedPaymentMethodsProvider),
    'paymentLimits': ref.watch(paymentLimitsProvider),
  };
});
