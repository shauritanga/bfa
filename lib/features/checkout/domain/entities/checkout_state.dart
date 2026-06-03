import 'package:equatable/equatable.dart';
import 'delivery_address.dart';
import 'payment_method.dart';

/// Checkout step enum
enum CheckoutStep {
  delivery,
  payment,
  review,
  confirmation,
}

/// Checkout state entity
class CheckoutStateEntity extends Equatable {
  final CheckoutStep currentStep;
  final DeliveryAddress? deliveryAddress;
  final CheckoutPaymentMethod? paymentMethod;
  final String? orderId;
  final bool isProcessing;
  final String? error;
  final Map<String, dynamic> metadata;

  const CheckoutStateEntity({
    this.currentStep = CheckoutStep.delivery,
    this.deliveryAddress,
    this.paymentMethod,
    this.orderId,
    this.isProcessing = false,
    this.error,
    this.metadata = const {},
  });

  /// Create from map
  factory CheckoutStateEntity.fromMap(Map<String, dynamic> map) {
    return CheckoutStateEntity(
      currentStep: CheckoutStep.values[map['currentStep'] ?? 0],
      deliveryAddress: map['deliveryAddress'] != null
          ? DeliveryAddress.fromMap(map['deliveryAddress'])
          : null,
      paymentMethod: map['paymentMethod'] != null
          ? CheckoutPaymentMethod.fromMap(map['paymentMethod'])
          : null,
      orderId: map['orderId'],
      isProcessing: map['isProcessing'] ?? false,
      error: map['error'],
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'currentStep': currentStep.index,
      'deliveryAddress': deliveryAddress?.toMap(),
      'paymentMethod': paymentMethod?.toMap(),
      'orderId': orderId,
      'isProcessing': isProcessing,
      'error': error,
      'metadata': metadata,
    };
  }

  /// Create copy with updated fields
  CheckoutStateEntity copyWith({
    CheckoutStep? currentStep,
    DeliveryAddress? deliveryAddress,
    CheckoutPaymentMethod? paymentMethod,
    String? orderId,
    bool? isProcessing,
    String? error,
    Map<String, dynamic>? metadata,
  }) {
    return CheckoutStateEntity(
      currentStep: currentStep ?? this.currentStep,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      orderId: orderId ?? this.orderId,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error ?? this.error,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Clear error
  CheckoutStateEntity clearError() {
    return copyWith(error: null);
  }

  /// Check if can proceed to next step
  bool get canProceedToNext {
    switch (currentStep) {
      case CheckoutStep.delivery:
        return deliveryAddress?.isComplete == true;
      case CheckoutStep.payment:
        return paymentMethod?.isComplete == true;
      case CheckoutStep.review:
        return deliveryAddress?.isComplete == true && 
               paymentMethod?.isComplete == true;
      case CheckoutStep.confirmation:
        return false; // Final step
    }
  }

  /// Check if can go back to previous step
  bool get canGoBack {
    return currentStep != CheckoutStep.delivery && !isProcessing;
  }

  /// Get step index
  int get stepIndex => currentStep.index;

  /// Get step title
  String get stepTitle {
    switch (currentStep) {
      case CheckoutStep.delivery:
        return 'Delivery';
      case CheckoutStep.payment:
        return 'Payment';
      case CheckoutStep.review:
        return 'Review';
      case CheckoutStep.confirmation:
        return 'Confirmation';
    }
  }

  /// Get step description
  String get stepDescription {
    switch (currentStep) {
      case CheckoutStep.delivery:
        return 'Add your delivery address';
      case CheckoutStep.payment:
        return 'Choose a payment method';
      case CheckoutStep.review:
        return 'Review your order';
      case CheckoutStep.confirmation:
        return 'Order confirmed';
    }
  }

  /// Check if checkout is complete
  bool get isComplete => currentStep == CheckoutStep.confirmation && orderId != null;

  @override
  List<Object?> get props => [
        currentStep,
        deliveryAddress,
        paymentMethod,
        orderId,
        isProcessing,
        error,
        metadata,
      ];

  @override
  String toString() {
    return 'CheckoutStateEntity(currentStep: $currentStep, orderId: $orderId)';
  }
}
