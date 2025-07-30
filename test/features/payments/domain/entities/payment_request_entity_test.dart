import 'package:flutter_test/flutter_test.dart';
import 'package:bfa/features/payments/domain/entities/payment_request_entity.dart';

void main() {
  group('PaymentRequestEntity', () {
    late PaymentRequestEntity testPaymentRequest;

    setUp(() {
      testPaymentRequest = PaymentRequestEntity(
        id: 'pay_123',
        orderId: 'order_123',
        userId: 'user_123',
        amount: 50000.0,
        currency: 'TZS',
        method: PaymentMethod.mobileMoney,
        provider: PaymentProvider.mpesa,
        phoneNumber: '0754123456',
        email: 'test@example.com',
        customerName: 'Test Customer',
        description: 'Test payment',
        callbackUrl: 'https://api.example.com/callback',
        successUrl: 'https://app.example.com/success',
        failureUrl: 'https://app.example.com/failure',
        metadata: {'test': 'data'},
        expiresAt: DateTime.now().add(const Duration(minutes: 15)),
        createdAt: DateTime.now(),
      );
    });

    test('should format phone number correctly', () {
      // Test local format
      final localRequest = testPaymentRequest.copyWith(phoneNumber: '0754123456');
      expect(localRequest.formattedPhoneNumber, '255754123456');

      // Test international format
      final intlRequest = testPaymentRequest.copyWith(phoneNumber: '255754123456');
      expect(intlRequest.formattedPhoneNumber, '255754123456');

      // Test 9-digit format
      final nineDigitRequest = testPaymentRequest.copyWith(phoneNumber: '754123456');
      expect(nineDigitRequest.formattedPhoneNumber, '255754123456');
    });

    test('should check expiration correctly', () {
      // Not expired
      final futureRequest = testPaymentRequest.copyWith(
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
      );
      expect(futureRequest.isExpired, false);
      expect(futureRequest.timeRemaining, isNotNull);

      // Expired
      final expiredRequest = testPaymentRequest.copyWith(
        expiresAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );
      expect(expiredRequest.isExpired, true);
      expect(expiredRequest.timeRemaining, isNull);
    });

    test('should convert to and from map correctly', () {
      final map = testPaymentRequest.toMap();
      final fromMap = PaymentRequestEntity.fromMap(map);

      expect(fromMap.id, testPaymentRequest.id);
      expect(fromMap.orderId, testPaymentRequest.orderId);
      expect(fromMap.amount, testPaymentRequest.amount);
      expect(fromMap.method, testPaymentRequest.method);
      expect(fromMap.provider, testPaymentRequest.provider);
      expect(fromMap.formattedPhoneNumber, testPaymentRequest.formattedPhoneNumber);
    });

    test('should create copy with updated fields', () {
      final updated = testPaymentRequest.copyWith(
        amount: 75000.0,
        method: PaymentMethod.card,
      );

      expect(updated.amount, 75000.0);
      expect(updated.method, PaymentMethod.card);
      expect(updated.id, testPaymentRequest.id); // Unchanged
      expect(updated.orderId, testPaymentRequest.orderId); // Unchanged
    });
  });

  group('PaymentMethod', () {
    test('should have correct display names', () {
      expect(PaymentMethod.mobileMoney.displayName, 'Mobile Money');
      expect(PaymentMethod.bankTransfer.displayName, 'Bank Transfer');
      expect(PaymentMethod.card.displayName, 'Credit/Debit Card');
      expect(PaymentMethod.cash.displayName, 'Cash on Delivery');
    });

    test('should have correct supported providers', () {
      expect(PaymentMethod.mobileMoney.supportedProviders, contains(PaymentProvider.mpesa));
      expect(PaymentMethod.mobileMoney.supportedProviders, contains(PaymentProvider.tigopesa));
      expect(PaymentMethod.mobileMoney.supportedProviders, contains(PaymentProvider.airtelmoney));
      
      expect(PaymentMethod.bankTransfer.supportedProviders, contains(PaymentProvider.bank));
      expect(PaymentMethod.card.supportedProviders, contains(PaymentProvider.clickpesa));
      expect(PaymentMethod.cash.supportedProviders, isEmpty);
    });
  });

  group('PaymentProvider', () {
    test('should have correct display names', () {
      expect(PaymentProvider.clickpesa.displayName, 'ClickPesa');
      expect(PaymentProvider.mpesa.displayName, 'M-Pesa');
      expect(PaymentProvider.tigopesa.displayName, 'Tigo Pesa');
      expect(PaymentProvider.airtelmoney.displayName, 'Airtel Money');
      expect(PaymentProvider.halopesa.displayName, 'Halo Pesa');
    });

    test('should have correct network codes', () {
      expect(PaymentProvider.mpesa.networkCode, 'MPESA');
      expect(PaymentProvider.tigopesa.networkCode, 'TIGO');
      expect(PaymentProvider.airtelmoney.networkCode, 'AIRTEL');
      expect(PaymentProvider.halopesa.networkCode, 'HALO');
      expect(PaymentProvider.clickpesa.networkCode, isNull);
    });

    test('should validate phone numbers correctly', () {
      // M-Pesa numbers
      expect(PaymentProvider.mpesa.supportsPhoneNumber('255754123456'), true);
      expect(PaymentProvider.mpesa.supportsPhoneNumber('255755123456'), true);
      expect(PaymentProvider.mpesa.supportsPhoneNumber('255756123456'), true);
      expect(PaymentProvider.mpesa.supportsPhoneNumber('255757123456'), true);
      expect(PaymentProvider.mpesa.supportsPhoneNumber('255758123456'), true);

      // Tigo Pesa numbers
      expect(PaymentProvider.tigopesa.supportsPhoneNumber('255711123456'), true);
      expect(PaymentProvider.tigopesa.supportsPhoneNumber('255712123456'), true);
      expect(PaymentProvider.tigopesa.supportsPhoneNumber('255713123456'), true);
      expect(PaymentProvider.tigopesa.supportsPhoneNumber('255714123456'), true);

      // Airtel Money numbers
      expect(PaymentProvider.airtelmoney.supportsPhoneNumber('255688123456'), true);
      expect(PaymentProvider.airtelmoney.supportsPhoneNumber('255689123456'), true);
      expect(PaymentProvider.airtelmoney.supportsPhoneNumber('255690123456'), true);

      // Halo Pesa numbers
      expect(PaymentProvider.halopesa.supportsPhoneNumber('255622123456'), true);
      expect(PaymentProvider.halopesa.supportsPhoneNumber('255623123456'), true);

      // ClickPesa supports all
      expect(PaymentProvider.clickpesa.supportsPhoneNumber('255754123456'), true);
      expect(PaymentProvider.clickpesa.supportsPhoneNumber('255711123456'), true);
      expect(PaymentProvider.clickpesa.supportsPhoneNumber('255688123456'), true);

      // Invalid numbers
      expect(PaymentProvider.mpesa.supportsPhoneNumber('255711123456'), false); // Tigo number
      expect(PaymentProvider.tigopesa.supportsPhoneNumber('255754123456'), false); // M-Pesa number
    });
  });
}
