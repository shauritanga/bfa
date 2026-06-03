import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/delivery_address.dart';
import '../../domain/entities/payment_method.dart';
import '../../../orders/domain/entities/delivery_info_entity.dart';
import '../../../orders/domain/entities/payment_info_entity.dart';

/// Checkout state
class CheckoutState {
  final int currentStep;
  final DeliveryAddress? deliveryAddress;
  final CheckoutPaymentMethod? paymentMethod;
  final bool isLoading;
  final String? error;
  final bool isAddressValid;
  final bool isPaymentValid;

  const CheckoutState({
    this.currentStep = 0,
    this.deliveryAddress,
    this.paymentMethod,
    this.isLoading = false,
    this.error,
    this.isAddressValid = false,
    this.isPaymentValid = false,
  });

  CheckoutState copyWith({
    int? currentStep,
    DeliveryAddress? deliveryAddress,
    CheckoutPaymentMethod? paymentMethod,
    bool? isLoading,
    String? error,
    bool? isAddressValid,
    bool? isPaymentValid,
  }) {
    return CheckoutState(
      currentStep: currentStep ?? this.currentStep,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAddressValid: isAddressValid ?? this.isAddressValid,
      isPaymentValid: isPaymentValid ?? this.isPaymentValid,
    );
  }

  bool get canProceedToPayment => isAddressValid;
  bool get canProceedToReview => isAddressValid && isPaymentValid;
  bool get canPlaceOrder => isAddressValid && isPaymentValid;
}

/// Checkout notifier
class CheckoutNotifier extends StateNotifier<CheckoutState> {
  CheckoutNotifier() : super(const CheckoutState());

  /// Move to next step
  void nextStep() {
    if (state.currentStep < 3) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  /// Move to previous step
  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  /// Go to specific step
  void goToStep(int step) {
    if (step >= 0 && step <= 3) {
      state = state.copyWith(currentStep: step);
    }
  }

  /// Set delivery address
  void setDeliveryAddress(DeliveryAddress address) {
    final isValid = _validateAddress(address);
    state = state.copyWith(deliveryAddress: address, isAddressValid: isValid);
  }

  /// Set payment method
  void setPaymentMethod(CheckoutPaymentMethod method) {
    final isValid = _validatePaymentMethod(method);
    state = state.copyWith(paymentMethod: method, isPaymentValid: isValid);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Set loading state
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  /// Set error
  void setError(String error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  /// Reset checkout state
  void reset() {
    state = const CheckoutState();
  }

  /// Validate address
  bool _validateAddress(DeliveryAddress address) {
    return address.recipientName.isNotEmpty &&
        address.phoneNumber.isNotEmpty &&
        address.address.isNotEmpty &&
        address.city.isNotEmpty &&
        address.region.isNotEmpty;
  }

  /// Validate payment method
  bool _validatePaymentMethod(CheckoutPaymentMethod method) {
    switch (method.type) {
      case PaymentMethodType.mobileMoney:
        return method.phoneNumber?.isNotEmpty == true;
      case PaymentMethodType.cashOnDelivery:
        return true;
      case PaymentMethodType.bankTransfer:
        return method.accountNumber?.isNotEmpty == true;
    }
  }

  /// Convert to delivery info entity
  DeliveryInfoEntity? toDeliveryInfo() {
    if (state.deliveryAddress == null) return null;

    final address = state.deliveryAddress!;
    return DeliveryInfoEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: DeliveryType.delivery,
      recipientName: address.recipientName,
      recipientPhone: address.phoneNumber,
      address: address.address,
      addressLine2: address.addressLine2,
      city: address.city,
      region: address.region,
      postalCode: address.postalCode,
      latitude: address.latitude,
      longitude: address.longitude,
      landmark: address.landmark,
      specialInstructions: address.specialInstructions,
      deliveryFee: 5000.0, // TZS 5,000 standard delivery fee
      metadata: const {},
    );
  }

  /// Convert to payment info entity
  PaymentInfoEntity? toPaymentInfo(double amount) {
    if (state.paymentMethod == null) return null;

    final method = state.paymentMethod!;
    return PaymentInfoEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      method: _convertPaymentMethod(method.type),
      provider: _convertPaymentProvider(method.provider),
      amount: amount,
      currency: 'TZS',
      phoneNumber: method.phoneNumber,
      accountNumber: method.accountNumber,
      providerData: const {},
      metadata: const {},
    );
  }

  PaymentMethod _convertPaymentMethod(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.mobileMoney:
        return PaymentMethod.mobileMoney;
      case PaymentMethodType.cashOnDelivery:
        return PaymentMethod.cash;
      case PaymentMethodType.bankTransfer:
        return PaymentMethod.bankTransfer;
    }
  }

  PaymentProvider _convertPaymentProvider(PaymentProviderType? provider) {
    switch (provider) {
      case PaymentProviderType.mpesa:
        return PaymentProvider.mpesa;
      case PaymentProviderType.tigoPesa:
        return PaymentProvider.tigopesa;
      case PaymentProviderType.airltelMoney:
        return PaymentProvider.airtelmoney;
      case PaymentProviderType.halopesa:
        return PaymentProvider.halopesa;
      case null:
        return PaymentProvider.mpesa; // Default
    }
  }
}

/// Checkout provider
final checkoutProvider = StateNotifierProvider<CheckoutNotifier, CheckoutState>(
  (ref) {
    return CheckoutNotifier();
  },
);
