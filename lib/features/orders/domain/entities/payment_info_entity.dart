import 'package:equatable/equatable.dart';

/// Payment information entity for orders
class PaymentInfoEntity extends Equatable {
  final String id;
  final PaymentMethod method;
  final PaymentProvider provider;
  final double amount;
  final String currency;
  final String? transactionId;
  final String? referenceNumber;
  final String? phoneNumber;
  final String? accountNumber;
  final String? cardLast4;
  final String? cardBrand;
  final DateTime? paidAt;
  final DateTime? expiresAt;
  final String? failureReason;
  final double? refundedAmount;
  final DateTime? refundedAt;
  final String? refundReason;
  final Map<String, dynamic> providerData;
  final Map<String, dynamic> metadata;

  const PaymentInfoEntity({
    required this.id,
    required this.method,
    required this.provider,
    required this.amount,
    required this.currency,
    this.transactionId,
    this.referenceNumber,
    this.phoneNumber,
    this.accountNumber,
    this.cardLast4,
    this.cardBrand,
    this.paidAt,
    this.expiresAt,
    this.failureReason,
    this.refundedAmount,
    this.refundedAt,
    this.refundReason,
    required this.providerData,
    required this.metadata,
  });

  /// Check if payment is completed
  bool get isCompleted => paidAt != null;

  /// Check if payment has failed
  bool get hasFailed => failureReason != null;

  /// Check if payment is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if payment is refunded
  bool get isRefunded => refundedAmount != null && refundedAmount! > 0;

  /// Check if payment is fully refunded
  bool get isFullyRefunded => refundedAmount != null && refundedAmount! >= amount;

  /// Check if payment is partially refunded
  bool get isPartiallyRefunded => 
      refundedAmount != null && refundedAmount! > 0 && refundedAmount! < amount;

  /// Get remaining refundable amount
  double get refundableAmount => amount - (refundedAmount ?? 0.0);

  /// Get payment status display text
  String get statusDisplay {
    if (isCompleted) {
      if (isFullyRefunded) return 'Refunded';
      if (isPartiallyRefunded) return 'Partially Refunded';
      return 'Paid';
    }
    if (hasFailed) return 'Failed';
    if (isExpired) return 'Expired';
    return 'Pending';
  }

  /// Get masked account information for display
  String? get maskedAccountInfo {
    switch (method) {
      case PaymentMethod.mobileMoney:
        if (phoneNumber != null && phoneNumber!.length > 4) {
          return '***${phoneNumber!.substring(phoneNumber!.length - 4)}';
        }
        return phoneNumber;
      case PaymentMethod.bankTransfer:
        if (accountNumber != null && accountNumber!.length > 4) {
          return '***${accountNumber!.substring(accountNumber!.length - 4)}';
        }
        return accountNumber;
      case PaymentMethod.card:
        if (cardLast4 != null) {
          return '**** **** **** $cardLast4';
        }
        return null;
      case PaymentMethod.cash:
        return 'Cash on Delivery';
      case PaymentMethod.wallet:
        return 'Digital Wallet';
    }
  }

  /// Create a copy with updated fields
  PaymentInfoEntity copyWith({
    String? id,
    PaymentMethod? method,
    PaymentProvider? provider,
    double? amount,
    String? currency,
    String? transactionId,
    String? referenceNumber,
    String? phoneNumber,
    String? accountNumber,
    String? cardLast4,
    String? cardBrand,
    DateTime? paidAt,
    DateTime? expiresAt,
    String? failureReason,
    double? refundedAmount,
    DateTime? refundedAt,
    String? refundReason,
    Map<String, dynamic>? providerData,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentInfoEntity(
      id: id ?? this.id,
      method: method ?? this.method,
      provider: provider ?? this.provider,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      transactionId: transactionId ?? this.transactionId,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      accountNumber: accountNumber ?? this.accountNumber,
      cardLast4: cardLast4 ?? this.cardLast4,
      cardBrand: cardBrand ?? this.cardBrand,
      paidAt: paidAt ?? this.paidAt,
      expiresAt: expiresAt ?? this.expiresAt,
      failureReason: failureReason ?? this.failureReason,
      refundedAmount: refundedAmount ?? this.refundedAmount,
      refundedAt: refundedAt ?? this.refundedAt,
      refundReason: refundReason ?? this.refundReason,
      providerData: providerData ?? this.providerData,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'method': method.name,
      'provider': provider.name,
      'amount': amount,
      'currency': currency,
      'transactionId': transactionId,
      'referenceNumber': referenceNumber,
      'phoneNumber': phoneNumber,
      'accountNumber': accountNumber,
      'cardLast4': cardLast4,
      'cardBrand': cardBrand,
      'paidAt': paidAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'failureReason': failureReason,
      'refundedAmount': refundedAmount,
      'refundedAt': refundedAt?.toIso8601String(),
      'refundReason': refundReason,
      'providerData': providerData,
      'metadata': metadata,
    };
  }

  /// Create from map (Firestore document)
  factory PaymentInfoEntity.fromMap(Map<String, dynamic> map) {
    return PaymentInfoEntity(
      id: map['id'] ?? '',
      method: PaymentMethod.values.firstWhere(
        (e) => e.name == map['method'],
        orElse: () => PaymentMethod.mobileMoney,
      ),
      provider: PaymentProvider.values.firstWhere(
        (e) => e.name == map['provider'],
        orElse: () => PaymentProvider.clickpesa,
      ),
      amount: (map['amount'] ?? 0.0).toDouble(),
      currency: map['currency'] ?? 'TZS',
      transactionId: map['transactionId'],
      referenceNumber: map['referenceNumber'],
      phoneNumber: map['phoneNumber'],
      accountNumber: map['accountNumber'],
      cardLast4: map['cardLast4'],
      cardBrand: map['cardBrand'],
      paidAt: map['paidAt'] != null ? DateTime.parse(map['paidAt']) : null,
      expiresAt: map['expiresAt'] != null ? DateTime.parse(map['expiresAt']) : null,
      failureReason: map['failureReason'],
      refundedAmount: map['refundedAmount']?.toDouble(),
      refundedAt: map['refundedAt'] != null ? DateTime.parse(map['refundedAt']) : null,
      refundReason: map['refundReason'],
      providerData: Map<String, dynamic>.from(map['providerData'] ?? {}),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [
        id,
        method,
        provider,
        amount,
        currency,
        transactionId,
        referenceNumber,
        phoneNumber,
        accountNumber,
        cardLast4,
        cardBrand,
        paidAt,
        expiresAt,
        failureReason,
        refundedAmount,
        refundedAt,
        refundReason,
        providerData,
        metadata,
      ];

  @override
  String toString() {
    return 'PaymentInfoEntity(id: $id, method: $method, amount: $amount, status: $statusDisplay)';
  }
}

/// Payment method enumeration
enum PaymentMethod {
  mobileMoney,
  bankTransfer,
  card,
  cash,
  wallet,
}

/// Payment provider enumeration
enum PaymentProvider {
  clickpesa,
  mpesa,
  tigopesa,
  airtelmoney,
  halopesa,
  bank,
  visa,
  mastercard,
  cash,
}

/// Extension for payment method
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
      case PaymentMethod.wallet:
        return 'Digital Wallet';
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
      case PaymentMethod.wallet:
        return 'Pay from your digital wallet';
    }
  }
}

/// Extension for payment provider
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
      case PaymentProvider.visa:
        return 'Visa';
      case PaymentProvider.mastercard:
        return 'Mastercard';
      case PaymentProvider.cash:
        return 'Cash';
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
      case PaymentProvider.visa:
        return 'assets/images/payment/visa.png';
      case PaymentProvider.mastercard:
        return 'assets/images/payment/mastercard.png';
      case PaymentProvider.cash:
        return 'assets/images/payment/cash.png';
    }
  }
}
