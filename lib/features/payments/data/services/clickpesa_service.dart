import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/payment_request_entity.dart';
import '../../domain/entities/payment_response_entity.dart';

/// ClickPesa API service for payment processing
class ClickPesaService {
  final String _baseUrl;
  final String _apiKey;
  final String _secretKey;
  final http.Client _httpClient;

  ClickPesaService({
    required String baseUrl,
    required String apiKey,
    required String secretKey,
    http.Client? httpClient,
  }) : _baseUrl = baseUrl,
       _apiKey = apiKey,
       _secretKey = secretKey,
       _httpClient = httpClient ?? http.Client();

  /// Initiate mobile money payment
  Future<Result<PaymentResponseEntity>> initiateMobileMoneyPayment({
    required PaymentRequestEntity request,
  }) async {
    try {
      final endpoint = '$_baseUrl/v1/payments/mobile-money';
      final payload = _buildMobileMoneyPayload(request);
      final signature = _generateSignature(payload);

      final response = await _httpClient.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'X-Signature': signature,
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;

        return Result.success(
          PaymentResponseEntity.fromClickPesaResponse(
            id: request.id,
            requestId: request.id,
            orderId: request.orderId,
            apiResponse: responseData,
          ),
        );
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        return Result.failure(
          ServerFailure(
            message: errorData['message'] ?? 'Payment initiation failed',
            code: response.statusCode,
          ),
        );
      }
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to initiate payment: $e'),
      );
    }
  }

  /// Check payment status
  Future<Result<PaymentResponseEntity>> checkPaymentStatus({
    required String paymentId,
  }) async {
    try {
      final endpoint = '$_baseUrl/v1/payments/$paymentId/status';

      final response = await _httpClient.get(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;

        return Result.success(
          PaymentResponseEntity.fromClickPesaResponse(
            id: paymentId,
            requestId: paymentId,
            orderId: responseData['order_id'] ?? '',
            apiResponse: responseData,
          ),
        );
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        return Result.failure(
          ServerFailure(
            message: errorData['message'] ?? 'Failed to check payment status',
            code: response.statusCode,
          ),
        );
      }
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to check payment status: $e'),
      );
    }
  }

  /// Verify payment callback
  Future<Result<PaymentResponseEntity>> verifyCallback({
    required Map<String, dynamic> callbackData,
    required String receivedSignature,
  }) async {
    try {
      // Verify signature
      final expectedSignature = _generateCallbackSignature(callbackData);
      if (expectedSignature != receivedSignature) {
        return const Result.failure(
          ValidationFailure(message: 'Invalid callback signature'),
        );
      }

      // Parse callback data
      final paymentResponse = PaymentResponseEntity.fromClickPesaResponse(
        id: callbackData['payment_id'] ?? '',
        requestId: callbackData['request_id'] ?? '',
        orderId: callbackData['order_id'] ?? '',
        apiResponse: callbackData,
      );

      return Result.success(paymentResponse);
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to verify callback: $e'),
      );
    }
  }

  /// Cancel payment
  Future<Result<PaymentResponseEntity>> cancelPayment({
    required String paymentId,
    required String reason,
  }) async {
    try {
      final endpoint = '$_baseUrl/v1/payments/$paymentId/cancel';
      final payload = {
        'reason': reason,
        'timestamp': DateTime.now().toIso8601String(),
      };
      final signature = _generateSignature(payload);

      final response = await _httpClient.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'X-Signature': signature,
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;

        return Result.success(
          PaymentResponseEntity.fromClickPesaResponse(
            id: paymentId,
            requestId: paymentId,
            orderId: responseData['order_id'] ?? '',
            apiResponse: responseData,
          ),
        );
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        return Result.failure(
          ServerFailure(
            message: errorData['message'] ?? 'Failed to cancel payment',
            code: response.statusCode,
          ),
        );
      }
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to cancel payment: $e'),
      );
    }
  }

  /// Process refund
  Future<Result<PaymentResponseEntity>> processRefund({
    required String originalPaymentId,
    required double amount,
    required String reason,
  }) async {
    try {
      final endpoint = '$_baseUrl/v1/payments/$originalPaymentId/refund';
      final payload = {
        'amount': amount,
        'reason': reason,
        'timestamp': DateTime.now().toIso8601String(),
      };
      final signature = _generateSignature(payload);

      final response = await _httpClient.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'X-Signature': signature,
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;

        return Result.success(
          PaymentResponseEntity.fromClickPesaResponse(
            id: '${originalPaymentId}_refund',
            requestId: originalPaymentId,
            orderId: responseData['order_id'] ?? '',
            apiResponse: responseData,
          ),
        );
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        return Result.failure(
          ServerFailure(
            message: errorData['message'] ?? 'Failed to process refund',
            code: response.statusCode,
          ),
        );
      }
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to process refund: $e'),
      );
    }
  }

  /// Build mobile money payment payload
  Map<String, dynamic> _buildMobileMoneyPayload(PaymentRequestEntity request) {
    return {
      'amount': request.amount,
      'currency': request.currency,
      'phone_number': request.formattedPhoneNumber,
      'network': request.provider.networkCode,
      'reference': request.id,
      'order_id': request.orderId,
      'description': request.description,
      'callback_url': request.callbackUrl,
      'success_url': request.successUrl,
      'failure_url': request.failureUrl,
      'customer_name': request.customerName,
      'customer_email': request.email,
      'metadata': request.metadata,
      'timestamp': request.createdAt.toIso8601String(),
    };
  }

  /// Generate HMAC signature for request
  String _generateSignature(Map<String, dynamic> payload) {
    final sortedKeys = payload.keys.toList()..sort();
    final queryString = sortedKeys
        .map((key) => '$key=${payload[key]}')
        .join('&');

    final hmac = Hmac(sha256, utf8.encode(_secretKey));
    final digest = hmac.convert(utf8.encode(queryString));
    return digest.toString();
  }

  /// Generate signature for callback verification
  String _generateCallbackSignature(Map<String, dynamic> callbackData) {
    // Remove signature from callback data if present
    final data = Map<String, dynamic>.from(callbackData);
    data.remove('signature');

    return _generateSignature(data);
  }

  /// Dispose resources
  void dispose() {
    _httpClient.close();
  }
}

/// ClickPesa configuration
class ClickPesaConfig {
  static const String sandboxBaseUrl = 'https://api.clickpesa.com/sandbox';
  static const String productionBaseUrl = 'https://api.clickpesa.com';

  final String baseUrl;
  final String apiKey;
  final String secretKey;
  final bool isProduction;

  const ClickPesaConfig({
    required this.baseUrl,
    required this.apiKey,
    required this.secretKey,
    required this.isProduction,
  });

  factory ClickPesaConfig.sandbox({
    required String apiKey,
    required String secretKey,
  }) {
    return ClickPesaConfig(
      baseUrl: sandboxBaseUrl,
      apiKey: apiKey,
      secretKey: secretKey,
      isProduction: false,
    );
  }

  factory ClickPesaConfig.production({
    required String apiKey,
    required String secretKey,
  }) {
    return ClickPesaConfig(
      baseUrl: productionBaseUrl,
      apiKey: apiKey,
      secretKey: secretKey,
      isProduction: true,
    );
  }
}
