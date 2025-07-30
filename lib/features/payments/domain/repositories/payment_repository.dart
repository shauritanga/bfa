import '../../../../core/utils/result.dart';
import '../entities/payment_request_entity.dart';
import '../entities/payment_response_entity.dart';

/// Payment repository interface
abstract class PaymentRepository {
  /// Initiate a payment request
  Future<Result<PaymentResponseEntity>> initiatePayment({
    required PaymentRequestEntity request,
  });

  /// Check payment status
  Future<Result<PaymentResponseEntity>> checkPaymentStatus({
    required String paymentId,
  });

  /// Get payment by transaction ID
  Future<Result<PaymentResponseEntity?>> getPaymentByTransactionId({
    required String transactionId,
  });

  /// Get payment by order ID
  Future<Result<PaymentResponseEntity?>> getPaymentByOrderId({
    required String orderId,
  });

  /// Get user's payment history
  Future<Result<List<PaymentResponseEntity>>> getUserPaymentHistory({
    required String userId,
    int limit = 20,
    String? startAfter,
  });

  /// Cancel a pending payment
  Future<Result<PaymentResponseEntity>> cancelPayment({
    required String paymentId,
    required String reason,
  });

  /// Process refund
  Future<Result<PaymentResponseEntity>> processRefund({
    required String originalPaymentId,
    required double amount,
    required String reason,
  });

  /// Verify payment callback
  Future<Result<PaymentResponseEntity>> verifyPaymentCallback({
    required Map<String, dynamic> callbackData,
    required String signature,
  });

  /// Get supported payment methods
  Future<Result<List<PaymentMethodInfo>>> getSupportedPaymentMethods();

  /// Validate phone number for payment provider
  Future<Result<PaymentProviderValidation>> validatePhoneNumber({
    required String phoneNumber,
    PaymentProvider? preferredProvider,
  });

  /// Get payment fees
  Future<Result<PaymentFees>> getPaymentFees({
    required double amount,
    required PaymentMethod method,
    required PaymentProvider provider,
  });

  /// Save payment for later processing
  Future<Result<void>> savePaymentRequest({
    required PaymentRequestEntity request,
  });

  /// Update payment status
  Future<Result<PaymentResponseEntity>> updatePaymentStatus({
    required String paymentId,
    required PaymentStatus status,
    String? transactionId,
    String? failureReason,
    Map<String, dynamic>? providerData,
  });
}

/// Payment method information
class PaymentMethodInfo {
  final PaymentMethod method;
  final List<PaymentProvider> providers;
  final bool isEnabled;
  final double? minimumAmount;
  final double? maximumAmount;
  final String? description;

  const PaymentMethodInfo({
    required this.method,
    required this.providers,
    required this.isEnabled,
    this.minimumAmount,
    this.maximumAmount,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'method': method.name,
      'providers': providers.map((p) => p.name).toList(),
      'isEnabled': isEnabled,
      'minimumAmount': minimumAmount,
      'maximumAmount': maximumAmount,
      'description': description,
    };
  }

  factory PaymentMethodInfo.fromMap(Map<String, dynamic> map) {
    return PaymentMethodInfo(
      method: PaymentMethod.values.firstWhere(
        (e) => e.name == map['method'],
        orElse: () => PaymentMethod.mobileMoney,
      ),
      providers: (map['providers'] as List<dynamic>?)
          ?.map((p) => PaymentProvider.values.firstWhere(
                (e) => e.name == p,
                orElse: () => PaymentProvider.clickpesa,
              ))
          .toList() ?? [],
      isEnabled: map['isEnabled'] ?? false,
      minimumAmount: map['minimumAmount']?.toDouble(),
      maximumAmount: map['maximumAmount']?.toDouble(),
      description: map['description'],
    );
  }
}

/// Payment provider validation result
class PaymentProviderValidation {
  final bool isValid;
  final PaymentProvider? recommendedProvider;
  final List<PaymentProvider> supportedProviders;
  final String? errorMessage;

  const PaymentProviderValidation({
    required this.isValid,
    this.recommendedProvider,
    required this.supportedProviders,
    this.errorMessage,
  });

  Map<String, dynamic> toMap() {
    return {
      'isValid': isValid,
      'recommendedProvider': recommendedProvider?.name,
      'supportedProviders': supportedProviders.map((p) => p.name).toList(),
      'errorMessage': errorMessage,
    };
  }

  factory PaymentProviderValidation.fromMap(Map<String, dynamic> map) {
    return PaymentProviderValidation(
      isValid: map['isValid'] ?? false,
      recommendedProvider: map['recommendedProvider'] != null
          ? PaymentProvider.values.firstWhere(
              (e) => e.name == map['recommendedProvider'],
              orElse: () => PaymentProvider.clickpesa,
            )
          : null,
      supportedProviders: (map['supportedProviders'] as List<dynamic>?)
          ?.map((p) => PaymentProvider.values.firstWhere(
                (e) => e.name == p,
                orElse: () => PaymentProvider.clickpesa,
              ))
          .toList() ?? [],
      errorMessage: map['errorMessage'],
    );
  }
}

/// Payment fees information
class PaymentFees {
  final double transactionFee;
  final double processingFee;
  final double totalFees;
  final double netAmount;
  final String currency;
  final String feeStructure;

  const PaymentFees({
    required this.transactionFee,
    required this.processingFee,
    required this.totalFees,
    required this.netAmount,
    required this.currency,
    required this.feeStructure,
  });

  Map<String, dynamic> toMap() {
    return {
      'transactionFee': transactionFee,
      'processingFee': processingFee,
      'totalFees': totalFees,
      'netAmount': netAmount,
      'currency': currency,
      'feeStructure': feeStructure,
    };
  }

  factory PaymentFees.fromMap(Map<String, dynamic> map) {
    return PaymentFees(
      transactionFee: (map['transactionFee'] ?? 0.0).toDouble(),
      processingFee: (map['processingFee'] ?? 0.0).toDouble(),
      totalFees: (map['totalFees'] ?? 0.0).toDouble(),
      netAmount: (map['netAmount'] ?? 0.0).toDouble(),
      currency: map['currency'] ?? 'TZS',
      feeStructure: map['feeStructure'] ?? '',
    );
  }
}
