import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';

/// ClickPesa API service following official documentation
/// https://docs.clickpesa.com/
class ClickPesaApiService {
  final String _baseUrl;
  final String _clientId;
  final String _apiKey;
  final String _checksumKey;
  final http.Client _httpClient;

  // Cache token and expiry
  String? _cachedToken;
  DateTime? _tokenExpiry;

  ClickPesaApiService({
    required String baseUrl,
    required String clientId,
    required String apiKey,
    required String checksumKey,
    http.Client? httpClient,
  }) : _baseUrl = baseUrl,
       _clientId = clientId,
       _apiKey = apiKey,
       _checksumKey = checksumKey,
       _httpClient = httpClient ?? http.Client();

  /// Generate JWT authorization token (valid for 1 hour)
  /// POST /third-parties/generate-token
  Future<Result<String>> generateToken() async {
    // Return cached token if still valid
    if (_cachedToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return Result.success(_cachedToken!);
    }

    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/third-parties/generate-token'),
        headers: {
          'client-id': _clientId,
          'api-key': _apiKey,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          _cachedToken = data['token'] as String;
          // Token expires in 1 hour, cache for 55 minutes to be safe
          _tokenExpiry = DateTime.now().add(const Duration(minutes: 55));
          return Result.success(_cachedToken!);
        } else {
          return Result.failure(
            ServerFailure(
              message:
                  'Token generation failed: ${data['message'] ?? 'Unknown error'}',
              code: response.statusCode,
            ),
          );
        }
      } else {
        return Result.failure(
          ServerFailure(
            message: 'Failed to generate token: ${response.statusCode}',
            code: response.statusCode,
          ),
        );
      }
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Token generation failed: $e'),
      );
    }
  }

  /// Preview USSD-PUSH request to validate payment details
  /// POST /third-parties/payments/preview-ussd-push-request
  Future<Result<Map<String, dynamic>>> previewUssdPushRequest({
    required String amount,
    required String currency,
    required String orderReference,
    required String checksum,
  }) async {
    try {
      final tokenResult = await generateToken();
      if (tokenResult.isFailure) {
        return Result.failure(tokenResult.failure!);
      }

      final requestBody = {
        'amount': amount,
        'currency': currency,
        'orderReference': orderReference,
        'checksum': checksum,
      };

      print('🔄 ClickPesa Preview Request:');
      print('URL: $_baseUrl/third-parties/payments/preview-ussd-push-request');
      print('Body: ${jsonEncode(requestBody)}');

      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/third-parties/payments/preview-ussd-push-request'),
        headers: {
          'Authorization': tokenResult.data!,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('📥 ClickPesa Preview Response:');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print('✅ Preview Success: $data');
        return Result.success(data);
      } else {
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;

          // Handle message as either String or List<dynamic>
          String errorMessage = 'Preview request failed';
          final messageField = errorData['message'];
          if (messageField is String) {
            errorMessage = messageField;
          } else if (messageField is List) {
            errorMessage = messageField.join(', ');
          }

          print('❌ ClickPesa Preview Error: $errorMessage');
          return Result.failure(
            ServerFailure(message: errorMessage, code: response.statusCode),
          );
        } catch (e) {
          print('❌ ClickPesa Preview Parse Error: $e');
          return Result.failure(
            ServerFailure(
              message:
                  'Preview request failed with status ${response.statusCode}',
              code: response.statusCode,
            ),
          );
        }
      }
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Preview request failed: $e'),
      );
    }
  }

  /// Initiate USSD-PUSH request for mobile money payment
  /// POST /third-parties/payments/initiate-ussd-push-request
  Future<Result<Map<String, dynamic>>> initiateUssdPushRequest({
    required String amount,
    required String currency,
    required String orderReference,
    required String phoneNumber,
    required String checksum,
  }) async {
    try {
      final tokenResult = await generateToken();
      if (tokenResult.isFailure) {
        return Result.failure(tokenResult.failure!);
      }

      final requestBody = {
        'amount': amount,
        'currency': currency,
        'orderReference': orderReference,
        'phoneNumber': phoneNumber,
        'checksum': checksum,
      };

      print('🔄 ClickPesa Initiate Request:');
      print('URL: $_baseUrl/third-parties/payments/initiate-ussd-push-request');
      print('Body: ${jsonEncode(requestBody)}');

      final response = await _httpClient.post(
        Uri.parse(
          '$_baseUrl/third-parties/payments/initiate-ussd-push-request',
        ),
        headers: {
          'Authorization': tokenResult.data!,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('📥 ClickPesa Initiate Response:');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print('✅ Initiate Success: $data');
        return Result.success(data);
      } else {
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          return Result.failure(
            ServerFailure(
              message: errorData['message'] ?? 'Payment initiation failed',
              code: response.statusCode,
            ),
          );
        } catch (e) {
          return Result.failure(
            ServerFailure(
              message:
                  'Payment initiation failed with status ${response.statusCode}',
              code: response.statusCode,
            ),
          );
        }
      }
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Payment initiation failed: $e'),
      );
    }
  }

  /// Query payment status using order reference
  /// GET /third-parties/payments/{orderReference}
  Future<Result<List<Map<String, dynamic>>>> queryPaymentStatus({
    required String orderReference,
  }) async {
    try {
      final tokenResult = await generateToken();
      if (tokenResult.isFailure) {
        return Result.failure(tokenResult.failure!);
      }

      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/third-parties/payments/$orderReference'),
        headers: {
          'Authorization': tokenResult.data!,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        return Result.success(
          data.map((item) => item as Map<String, dynamic>).toList(),
        );
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        return Result.failure(
          ServerFailure(
            message: errorData['message'] ?? 'Payment status query failed',
            code: response.statusCode,
          ),
        );
      }
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Payment status query failed: $e'),
      );
    }
  }

  /// Generate checksum for request validation
  String generateChecksum({
    required String amount,
    required String currency,
    required String orderReference,
    String? phoneNumber,
  }) {
    // Use the official ClickPesa checksum format from documentation
    // Create payload map
    final Map<String, String> payload = {
      'amount': amount,
      'currency': currency,
      'orderReference': orderReference,
    };

    // Add phone number for initiate requests
    if (phoneNumber != null) {
      payload['phoneNumber'] = phoneNumber;
    }

    print('🔐 Official ClickPesa Checksum generation:');
    print('Payload: $payload');

    // Sort keys alphabetically
    final sortedKeys = payload.keys.toList()..sort();
    print('Sorted keys: $sortedKeys');

    // Join only the values in sorted key order
    final payloadString = sortedKeys.map((key) => payload[key]).join('');
    print('Payload string: $payloadString');
    print('Checksum key: $_checksumKey');

    // Generate HMAC-SHA256 hash using checksum key as the secret
    final key = utf8.encode(_checksumKey);
    final bytes = utf8.encode(payloadString);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    final checksum = digest.toString();

    print('Generated HMAC-SHA256 checksum: $checksum');
    return checksum;
  }

  /// Alternative checksum generation method
  String generateChecksumAlternative({
    required String amount,
    required String currency,
    required String orderReference,
    String? phoneNumber,
  }) {
    // Some ClickPesa implementations use different formats
    String data;

    if (phoneNumber != null) {
      // For initiate: try without API key
      data = '$amount$currency$orderReference$phoneNumber';
    } else {
      // For preview: try without API key
      data = '$amount$currency$orderReference';
    }

    print('🔐 Alternative Checksum generation:');
    print('Data to hash (no API key): $data');

    // Generate SHA-256 hash
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    final checksum = digest.toString().toUpperCase();

    print('Alternative checksum: $checksum');
    return checksum;
  }

  /// Try MD5 checksum (some APIs use MD5 instead of SHA-256)
  String generateChecksumMD5({
    required String amount,
    required String currency,
    required String orderReference,
    String? phoneNumber,
  }) {
    String data;

    if (phoneNumber != null) {
      data = '$amount$currency$orderReference$phoneNumber$_apiKey';
    } else {
      data = '$amount$currency$orderReference$_apiKey';
    }

    print('🔐 MD5 Checksum generation:');
    print('Data to hash: $data');

    // Generate MD5 hash
    final bytes = utf8.encode(data);
    final digest = md5.convert(bytes);
    final checksum = digest.toString().toUpperCase();

    print('MD5 checksum: $checksum');
    return checksum;
  }

  /// Validate phone number format for Tanzania
  bool isValidTanzanianPhoneNumber(String phoneNumber) {
    // Remove any spaces or special characters
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // Check for valid Tanzania phone number formats
    final patterns = [
      RegExp(r'^\+255[67]\d{8}$'), // +255 followed by 6 or 7 and 8 digits
      RegExp(r'^255[67]\d{8}$'), // 255 followed by 6 or 7 and 8 digits
      RegExp(r'^0[67]\d{8}$'), // 0 followed by 6 or 7 and 8 digits
    ];

    return patterns.any((pattern) => pattern.hasMatch(cleanNumber));
  }

  /// Format phone number for ClickPesa (without + sign)
  String formatPhoneNumber(String phoneNumber) {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    if (cleanNumber.startsWith('+255')) {
      // Remove the + sign for ClickPesa
      return cleanNumber.substring(1);
    } else if (cleanNumber.startsWith('255')) {
      return cleanNumber;
    } else if (cleanNumber.startsWith('0')) {
      return '255${cleanNumber.substring(1)}';
    } else {
      return '255$cleanNumber';
    }
  }

  /// Validate amount for ClickPesa
  bool isValidAmount(double amount) {
    // ClickPesa minimum and maximum amounts in TZS
    const minAmount = 1000.0; // TZS 1,000
    const maxAmount = 10000000.0; // TZS 10,000,000

    return amount >= minAmount && amount <= maxAmount;
  }

  /// Clear cached token (useful for testing or logout)
  void clearTokenCache() {
    _cachedToken = null;
    _tokenExpiry = null;
  }

  /// Get current token status
  Map<String, dynamic> getTokenStatus() {
    return {
      'hasToken': _cachedToken != null,
      'isExpired':
          _tokenExpiry != null && DateTime.now().isAfter(_tokenExpiry!),
      'expiresAt': _tokenExpiry?.toIso8601String(),
    };
  }
}
