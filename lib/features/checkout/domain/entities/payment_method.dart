import 'package:equatable/equatable.dart';

/// Payment method types for checkout
enum PaymentMethodType {
  mobileMoney,
  cashOnDelivery,
  bankTransfer,
}

/// Payment provider types
enum PaymentProviderType {
  mpesa,
  tigoPesa,
  airltelMoney,
  halopesa,
}

/// Payment method entity for checkout
class CheckoutPaymentMethod extends Equatable {
  final PaymentMethodType type;
  final PaymentProviderType? provider;
  final String? phoneNumber;
  final String? accountNumber;
  final String? accountName;
  final bool isDefault;

  const CheckoutPaymentMethod({
    required this.type,
    this.provider,
    this.phoneNumber,
    this.accountNumber,
    this.accountName,
    this.isDefault = false,
  });

  /// Create mobile money payment method
  factory CheckoutPaymentMethod.mobileMoney({
    required PaymentProviderType provider,
    required String phoneNumber,
    bool isDefault = false,
  }) {
    return CheckoutPaymentMethod(
      type: PaymentMethodType.mobileMoney,
      provider: provider,
      phoneNumber: phoneNumber,
      isDefault: isDefault,
    );
  }

  /// Create cash on delivery payment method
  factory CheckoutPaymentMethod.cashOnDelivery({bool isDefault = false}) {
    return CheckoutPaymentMethod(
      type: PaymentMethodType.cashOnDelivery,
      isDefault: isDefault,
    );
  }

  /// Create bank transfer payment method
  factory CheckoutPaymentMethod.bankTransfer({
    required String accountNumber,
    required String accountName,
    bool isDefault = false,
  }) {
    return CheckoutPaymentMethod(
      type: PaymentMethodType.bankTransfer,
      accountNumber: accountNumber,
      accountName: accountName,
      isDefault: isDefault,
    );
  }

  /// Create from map
  factory CheckoutPaymentMethod.fromMap(Map<String, dynamic> map) {
    return CheckoutPaymentMethod(
      type: PaymentMethodType.values[map['type']],
      provider: map['provider'] != null 
          ? PaymentProviderType.values[map['provider']]
          : null,
      phoneNumber: map['phoneNumber'],
      accountNumber: map['accountNumber'],
      accountName: map['accountName'],
      isDefault: map['isDefault'] ?? false,
    );
  }

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'type': type.index,
      'provider': provider?.index,
      'phoneNumber': phoneNumber,
      'accountNumber': accountNumber,
      'accountName': accountName,
      'isDefault': isDefault,
    };
  }

  /// Create copy with updated fields
  CheckoutPaymentMethod copyWith({
    PaymentMethodType? type,
    PaymentProviderType? provider,
    String? phoneNumber,
    String? accountNumber,
    String? accountName,
    bool? isDefault,
  }) {
    return CheckoutPaymentMethod(
      type: type ?? this.type,
      provider: provider ?? this.provider,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      accountNumber: accountNumber ?? this.accountNumber,
      accountName: accountName ?? this.accountName,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  /// Get display name for payment method
  String get displayName {
    switch (type) {
      case PaymentMethodType.mobileMoney:
        return '$providerDisplayName - ${phoneNumber ?? 'Mobile Money'}';
      case PaymentMethodType.cashOnDelivery:
        return 'Cash on Delivery';
      case PaymentMethodType.bankTransfer:
        return 'Bank Transfer - ${accountName ?? 'Bank Account'}';
    }
  }

  /// Get provider display name
  String get providerDisplayName {
    switch (provider) {
      case PaymentProviderType.mpesa:
        return 'M-Pesa';
      case PaymentProviderType.tigoPesa:
        return 'Tigo Pesa';
      case PaymentProviderType.airltelMoney:
        return 'Airtel Money';
      case PaymentProviderType.halopesa:
        return 'HaloPesa';
      case null:
        return 'Mobile Money';
    }
  }

  /// Get icon name for payment method
  String get iconName {
    switch (type) {
      case PaymentMethodType.mobileMoney:
        return 'mobile_money';
      case PaymentMethodType.cashOnDelivery:
        return 'cash';
      case PaymentMethodType.bankTransfer:
        return 'bank';
    }
  }

  /// Get provider icon name
  String get providerIconName {
    switch (provider) {
      case PaymentProviderType.mpesa:
        return 'mpesa';
      case PaymentProviderType.tigoPesa:
        return 'tigo_pesa';
      case PaymentProviderType.airltelMoney:
        return 'airtel_money';
      case PaymentProviderType.halopesa:
        return 'halopesa';
      case null:
        return 'mobile_money';
    }
  }

  /// Check if payment method is complete
  bool get isComplete {
    switch (type) {
      case PaymentMethodType.mobileMoney:
        return phoneNumber?.isNotEmpty == true && provider != null;
      case PaymentMethodType.cashOnDelivery:
        return true;
      case PaymentMethodType.bankTransfer:
        return accountNumber?.isNotEmpty == true && 
               accountName?.isNotEmpty == true;
    }
  }

  @override
  List<Object?> get props => [
        type,
        provider,
        phoneNumber,
        accountNumber,
        accountName,
        isDefault,
      ];

  @override
  String toString() {
    return 'CheckoutPaymentMethod(type: $type, displayName: $displayName)';
  }
}
