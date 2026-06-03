import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/config/clickpesa_config.dart';
import 'clickpesa_api_service.dart';

/// High-level ClickPesa integration service for the checkout flow
class ClickPesaIntegrationService {
  final ClickPesaApiService _apiService;
  final ClickPesaConfig _config;

  ClickPesaIntegrationService({
    required ClickPesaApiService apiService,
    required ClickPesaConfig config,
  }) : _apiService = apiService,
       _config = config;

  /// Process mobile money payment for checkout
  Future<Result<PaymentResult>> processMobileMoneyPayment({
    required double amount,
    required String phoneNumber,
    required String orderReference,
    String currency = 'TZS',
  }) async {
    try {
      // Validate inputs
      final validationResult = _validatePaymentInputs(
        amount: amount,
        phoneNumber: phoneNumber,
        orderReference: orderReference,
      );
      if (validationResult.isFailure) {
        return Result.failure(validationResult.failure!);
      }

      // Additional validations
      if (!_apiService.isValidAmount(amount)) {
        return const Result.failure(
          ValidationFailure(
            message: 'Amount must be between TZS 1,000 and TZS 10,000,000',
          ),
        );
      }

      // Format phone number
      final formattedPhone = _apiService.formatPhoneNumber(phoneNumber);
      final amountString = amount.toStringAsFixed(0);

      print('🔄 ClickPesa Payment Request:');
      print('Amount: $amountString $currency');
      print('Order Reference: $orderReference');
      print('Phone: $formattedPhone');

      // Generate checksum for preview (without phone number)
      // Using official ClickPesa format: HMAC-SHA256 with sorted payload values
      final checksum = _apiService.generateChecksum(
        amount: amountString,
        currency: currency,
        orderReference: orderReference,
      );

      print('Using official ClickPesa checksum format: $checksum');

      // Step 1: Preview the payment request
      final previewResult = await _apiService.previewUssdPushRequest(
        amount: amountString,
        currency: currency,
        orderReference: orderReference,
        checksum: checksum,
      );

      if (previewResult.isFailure) {
        return Result.failure(previewResult.failure!);
      }

      // Check if payment methods are available
      final previewData = previewResult.data;
      final activeMethods = previewData?['activeMethods'] as List<dynamic>?;

      if (activeMethods == null || activeMethods.isEmpty) {
        return const Result.failure(
          ValidationFailure(
            message: 'No payment methods available for this transaction',
          ),
        );
      }

      // Check if any method is available
      final hasAvailableMethod = activeMethods.any((method) {
        if (method is Map<String, dynamic>) {
          return method['status'] == 'AVAILABLE';
        }
        return false;
      });

      if (!hasAvailableMethod) {
        return const Result.failure(
          ValidationFailure(
            message: 'Mobile money services are currently unavailable',
          ),
        );
      }

      // Step 2: Initiate the payment
      // Generate checksum for initiate (with phone number) - using official format
      final initiateChecksum = _apiService.generateChecksum(
        amount: amountString,
        currency: currency,
        orderReference: orderReference,
        phoneNumber: formattedPhone,
      );

      final initiateResult = await _apiService.initiateUssdPushRequest(
        amount: amountString,
        currency: currency,
        orderReference: orderReference,
        phoneNumber: formattedPhone,
        checksum: initiateChecksum,
      );

      if (initiateResult.isFailure) {
        return Result.failure(initiateResult.failure!);
      }

      final paymentData = initiateResult.data;

      // Ensure paymentData is not null
      if (paymentData == null) {
        return const Result.failure(
          ServerFailure(message: 'Invalid payment response received'),
        );
      }

      print('📦 Payment Response Data: $paymentData');

      // Safely extract fields with null checks
      final id = paymentData['id']?.toString() ?? orderReference;
      final statusString = paymentData['status']?.toString() ?? 'PENDING';
      final orderRef =
          paymentData['orderReference']?.toString() ?? orderReference;
      final channel = paymentData['channel']?.toString();
      final createdAtString = paymentData['createdAt']?.toString();

      print('🔍 Extracted fields:');
      print('ID: $id');
      print('Status: $statusString');
      print('Order Reference: $orderRef');
      print('Channel: $channel');
      print('Created At: $createdAtString');

      // Parse created date safely
      DateTime createdAt;
      try {
        createdAt = createdAtString != null
            ? DateTime.parse(createdAtString)
            : DateTime.now();
      } catch (e) {
        print('⚠️ Failed to parse createdAt: $e');
        createdAt = DateTime.now();
      }

      return Result.success(
        PaymentResult(
          id: id,
          status: PaymentStatus.fromString(statusString),
          orderReference: orderRef,
          amount: amount,
          currency: currency,
          phoneNumber: formattedPhone,
          channel: channel,
          createdAt: createdAt,
          message:
              'Payment initiated successfully. Check your phone for USSD prompt.',
        ),
      );
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Payment processing failed: $e'),
      );
    }
  }

  /// Check payment status
  Future<Result<PaymentResult>> checkPaymentStatus({
    required String orderReference,
  }) async {
    try {
      final statusResult = await _apiService.queryPaymentStatus(
        orderReference: orderReference,
      );

      if (statusResult.isFailure) {
        return Result.failure(statusResult.failure!);
      }

      final payments = statusResult.data;
      if (payments == null || payments.isEmpty) {
        return const Result.failure(
          ValidationFailure(message: 'Payment not found'),
        );
      }

      // Get the latest payment
      final latestPayment = payments.first;

      print('📦 Payment Status Data: $latestPayment');

      // Safely extract fields with null checks
      final id = latestPayment['id']?.toString() ?? '';
      final statusString = latestPayment['status']?.toString() ?? 'PENDING';
      final orderRef = latestPayment['orderReference']?.toString() ?? '';
      final collectedAmount = latestPayment['collectedAmount'];
      final amount = collectedAmount is num ? collectedAmount.toDouble() : 0.0;
      final currency = latestPayment['collectedCurrency']?.toString() ?? 'TZS';
      final phoneNumber = latestPayment['customer']?['customerPhoneNumber']
          ?.toString();
      final paymentReference = latestPayment['paymentReference']?.toString();
      final message = latestPayment['message']?.toString();
      final createdAtString = latestPayment['createdAt']?.toString();
      final updatedAtString = latestPayment['updatedAt']?.toString();

      // Parse dates safely
      DateTime createdAt;
      DateTime? updatedAt;

      try {
        createdAt = createdAtString != null
            ? DateTime.parse(createdAtString)
            : DateTime.now();
      } catch (e) {
        print('⚠️ Failed to parse createdAt: $e');
        createdAt = DateTime.now();
      }

      try {
        updatedAt = updatedAtString != null
            ? DateTime.parse(updatedAtString)
            : null;
      } catch (e) {
        print('⚠️ Failed to parse updatedAt: $e');
        updatedAt = null;
      }

      return Result.success(
        PaymentResult(
          id: id,
          status: PaymentStatus.fromString(statusString),
          orderReference: orderRef,
          amount: amount,
          currency: currency,
          phoneNumber: phoneNumber,
          paymentReference: paymentReference,
          message: message,
          createdAt: createdAt,
          updatedAt: updatedAt,
        ),
      );
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Payment status check failed: $e'),
      );
    }
  }

  /// Validate payment inputs
  Result<void> _validatePaymentInputs({
    required double amount,
    required String phoneNumber,
    required String orderReference,
  }) {
    // Validate amount
    if (!_apiService.isValidAmount(amount)) {
      return const Result.failure(
        ValidationFailure(
          message: 'Amount must be between TZS 1,000 and TZS 10,000,000',
        ),
      );
    }

    // Validate phone number
    if (!_apiService.isValidTanzanianPhoneNumber(phoneNumber)) {
      return const Result.failure(
        ValidationFailure(
          message: 'Please enter a valid Tanzanian phone number',
        ),
      );
    }

    // Validate order reference
    if (orderReference.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Order reference is required'),
      );
    }

    return const Result.success(null);
  }

  /// Get integration status
  Map<String, dynamic> getIntegrationStatus() {
    return {
      'isConfigured': true,
      'environment': _config.isProduction ? 'production' : 'sandbox',
      'baseUrl': _config.baseUrl,
      'tokenStatus': _apiService.getTokenStatus(),
    };
  }
}

/// Payment result model
class PaymentResult {
  final String id;
  final PaymentStatus status;
  final String orderReference;
  final double amount;
  final String currency;
  final String? phoneNumber;
  final String? channel;
  final String? paymentReference;
  final String? message;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PaymentResult({
    required this.id,
    required this.status,
    required this.orderReference,
    required this.amount,
    required this.currency,
    this.phoneNumber,
    this.channel,
    this.paymentReference,
    this.message,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.name,
      'orderReference': orderReference,
      'amount': amount,
      'currency': currency,
      'phoneNumber': phoneNumber,
      'channel': channel,
      'paymentReference': paymentReference,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

/// Payment status enum
enum PaymentStatus {
  processing,
  success,
  failed,
  cancelled,
  pending;

  static PaymentStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'PROCESSING':
        return PaymentStatus.processing;
      case 'SUCCESS':
        return PaymentStatus.success;
      case 'FAILED':
        return PaymentStatus.failed;
      case 'CANCELLED':
        return PaymentStatus.cancelled;
      case 'PENDING':
        return PaymentStatus.pending;
      default:
        return PaymentStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case PaymentStatus.processing:
        return 'Processing';
      case PaymentStatus.success:
        return 'Success';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.cancelled:
        return 'Cancelled';
      case PaymentStatus.pending:
        return 'Pending';
    }
  }

  bool get isCompleted => this == PaymentStatus.success;
  bool get isFailed =>
      this == PaymentStatus.failed || this == PaymentStatus.cancelled;
  bool get isPending =>
      this == PaymentStatus.processing || this == PaymentStatus.pending;
}
