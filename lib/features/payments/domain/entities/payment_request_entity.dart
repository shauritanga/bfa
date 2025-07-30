import 'package:equatable/equatable.dart';

/// Payment request entity for initiating payments
class PaymentRequestEntity extends Equatable {
  final String id;
  final String orderId;
  final String userId;
  final double amount;
  final String currency;
  final PaymentMethod method;
  final PaymentProvider provider;
  final String phoneNumber;
  final String? email;
  final String? customerName;
  final String description;
  final String callbackUrl;
  final String? successUrl;
  final String? failureUrl;
  final Map<String, dynamic> metadata;
  final DateTime expiresAt;
  final DateTime createdAt;

  const PaymentRequestEntity({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.method,
    required this.provider,
    required this.phoneNumber,
    this.email,
    this.customerName,
    required this.description,
    required this.callbackUrl,
    this.successUrl,
    this.failureUrl,
    required this.metadata,
    required this.expiresAt,
    required this.createdAt,
  });

  /// Check if payment request is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Get time remaining until expiration
  Duration? get timeRemaining {
    if (isExpired) return null;
    return expiresAt.difference(DateTime.now());
  }

  /// Format phone number for payment provider
  String get formattedPhoneNumber {
    // Remove any non-digit characters
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Handle Tanzanian phone numbers
    if (cleaned.startsWith('255')) {
      return cleaned; // Already in international format
    } else if (cleaned.startsWith('0')) {
      return '255${cleaned.substring(1)}'; // Convert from local format
    } else if (cleaned.length == 9) {
      return '255$cleaned'; // Add country code
    }
    
    return cleaned;
  }

  /// Create a copy with updated fields
  PaymentRequestEntity copyWith({
    String? id,
    String? orderId,
    String? userId,
    double? amount,
    String? currency,
    PaymentMethod? method,
    PaymentProvider? provider,
    String? phoneNumber,
    String? email,
    String? customerName,
    String? description,
    String? callbackUrl,
    String? successUrl,
    String? failureUrl,
    Map<String, dynamic>? metadata,
    DateTime? expiresAt,
    DateTime? createdAt,
  }) {
    return PaymentRequestEntity(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      method: method ?? this.method,
      provider: provider ?? this.provider,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      customerName: customerName ?? this.customerName,
      description: description ?? this.description,
      callbackUrl: callbackUrl ?? this.callbackUrl,
      successUrl: successUrl ?? this.successUrl,
      failureUrl: failureUrl ?? this.failureUrl,
      metadata: metadata ?? this.metadata,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convert to map for API requests
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'userId': userId,
      'amount': amount,
      'currency': currency,
      'method': method.name,
      'provider': provider.name,
      'phoneNumber': formattedPhoneNumber,
      'email': email,
      'customerName': customerName,
      'description': description,
      'callbackUrl': callbackUrl,
      'successUrl': successUrl,
      'failureUrl': failureUrl,
      'metadata': metadata,
      'expiresAt': expiresAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from map
  factory PaymentRequestEntity.fromMap(Map<String, dynamic> map) {
    return PaymentRequestEntity(
      id: map['id'] ?? '',
      orderId: map['orderId'] ?? '',
      userId: map['userId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      currency: map['currency'] ?? 'TZS',
      method: PaymentMethod.values.firstWhere(
        (e) => e.name == map['method'],
        orElse: () => PaymentMethod.mobileMoney,
      ),
      provider: PaymentProvider.values.firstWhere(
        (e) => e.name == map['provider'],
        orElse: () => PaymentProvider.clickpesa,
      ),
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'],
      customerName: map['customerName'],
      description: map['description'] ?? '',
      callbackUrl: map['callbackUrl'] ?? '',
      successUrl: map['successUrl'],
      failureUrl: map['failureUrl'],
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      expiresAt: DateTime.parse(map['expiresAt']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        orderId,
        userId,
        amount,
        currency,
        method,
        provider,
        phoneNumber,
        email,
        customerName,
        description,
        callbackUrl,
        successUrl,
        failureUrl,
        metadata,
        expiresAt,
        createdAt,
      ];

  @override
  String toString() {
    return 'PaymentRequestEntity(id: $id, orderId: $orderId, amount: $amount, method: $method)';
  }
}

/// Payment method enumeration
enum PaymentMethod {
  mobileMoney,
  bankTransfer,
  card,
  cash,
}

/// Payment provider enumeration
enum PaymentProvider {
  clickpesa,
  mpesa,
  tigopesa,
  airtelmoney,
  halopesa,
  bank,
}

/// Extensions for payment method
extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.mobileMoney:
        return 'Mobile Money';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.card:
        return 'Credit/Debit Card';
      case PaymentMethod.cash:
        return 'Cash on Delivery';
    }
  }

  String get description {
    switch (this) {
      case PaymentMethod.mobileMoney:
        return 'Pay using your mobile money account';
      case PaymentMethod.bankTransfer:
        return 'Transfer from your bank account';
      case PaymentMethod.card:
        return 'Pay with credit or debit card';
      case PaymentMethod.cash:
        return 'Pay cash when order is delivered';
    }
  }

  List<PaymentProvider> get supportedProviders {
    switch (this) {
      case PaymentMethod.mobileMoney:
        return [
          PaymentProvider.clickpesa,
          PaymentProvider.mpesa,
          PaymentProvider.tigopesa,
          PaymentProvider.airtelmoney,
          PaymentProvider.halopesa,
        ];
      case PaymentMethod.bankTransfer:
        return [PaymentProvider.bank];
      case PaymentMethod.card:
        return [PaymentProvider.clickpesa];
      case PaymentMethod.cash:
        return [];
    }
  }
}

/// Extensions for payment provider
extension PaymentProviderExtension on PaymentProvider {
  String get displayName {
    switch (this) {
      case PaymentProvider.clickpesa:
        return 'ClickPesa';
      case PaymentProvider.mpesa:
        return 'M-Pesa';
      case PaymentProvider.tigopesa:
        return 'Tigo Pesa';
      case PaymentProvider.airtelmoney:
        return 'Airtel Money';
      case PaymentProvider.halopesa:
        return 'Halo Pesa';
      case PaymentProvider.bank:
        return 'Bank Transfer';
    }
  }

  String get logoAsset {
    switch (this) {
      case PaymentProvider.clickpesa:
        return 'assets/images/payment/clickpesa.png';
      case PaymentProvider.mpesa:
        return 'assets/images/payment/mpesa.png';
      case PaymentProvider.tigopesa:
        return 'assets/images/payment/tigopesa.png';
      case PaymentProvider.airtelmoney:
        return 'assets/images/payment/airtel.png';
      case PaymentProvider.halopesa:
        return 'assets/images/payment/halopesa.png';
      case PaymentProvider.bank:
        return 'assets/images/payment/bank.png';
    }
  }

  /// Get the network code for mobile money providers
  String? get networkCode {
    switch (this) {
      case PaymentProvider.mpesa:
        return 'MPESA';
      case PaymentProvider.tigopesa:
        return 'TIGO';
      case PaymentProvider.airtelmoney:
        return 'AIRTEL';
      case PaymentProvider.halopesa:
        return 'HALO';
      default:
        return null;
    }
  }

  /// Check if provider supports the given phone number
  bool supportsPhoneNumber(String phoneNumber) {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    switch (this) {
      case PaymentProvider.mpesa:
        return cleaned.startsWith('25575') || cleaned.startsWith('25576') || 
               cleaned.startsWith('25577') || cleaned.startsWith('25578');
      case PaymentProvider.tigopesa:
        return cleaned.startsWith('25571') || cleaned.startsWith('25572') || 
               cleaned.startsWith('25573') || cleaned.startsWith('25574');
      case PaymentProvider.airtelmoney:
        return cleaned.startsWith('25568') || cleaned.startsWith('25569') || 
               cleaned.startsWith('25570');
      case PaymentProvider.halopesa:
        return cleaned.startsWith('25562') || cleaned.startsWith('25563');
      case PaymentProvider.clickpesa:
        return true; // ClickPesa supports all networks
      case PaymentProvider.bank:
        return true; // Bank transfers don't depend on phone numbers
    }
  }
}
