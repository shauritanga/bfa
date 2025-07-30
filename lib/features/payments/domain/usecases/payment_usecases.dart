import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../entities/payment_request_entity.dart';
import '../entities/payment_response_entity.dart';
import '../repositories/payment_repository.dart';
import '../../../orders/domain/entities/order_entity.dart';

/// Use case for initiating a payment
class InitiatePaymentUseCase {
  final PaymentRepository _repository;

  const InitiatePaymentUseCase(this._repository);

  Future<Result<PaymentResponseEntity>> call({
    required OrderEntity order,
    required PaymentMethod method,
    required PaymentProvider provider,
    required String phoneNumber,
    String? email,
    String? customerName,
  }) async {
    // Validate inputs
    if (phoneNumber.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Phone number cannot be empty'),
      );
    }

    if (order.totalAmount <= 0) {
      return const Result.failure(
        ValidationFailure(message: 'Order amount must be greater than 0'),
      );
    }

    // Validate phone number for the provider
    final validationResult = await _repository.validatePhoneNumber(
      phoneNumber: phoneNumber.trim(),
      preferredProvider: provider,
    );

    if (validationResult.isFailure) {
      return Result.failure(validationResult.failure!);
    }

    final validation = validationResult.data!;
    if (!validation.isValid) {
      return Result.failure(
        ValidationFailure(message: validation.errorMessage ?? 'Invalid phone number'),
      );
    }

    // Create payment request
    final now = DateTime.now();
    final paymentRequest = PaymentRequestEntity(
      id: _generatePaymentId(),
      orderId: order.id,
      userId: order.userId,
      amount: order.totalAmount,
      currency: 'TZS',
      method: method,
      provider: validation.recommendedProvider ?? provider,
      phoneNumber: phoneNumber.trim(),
      email: email?.trim(),
      customerName: customerName?.trim() ?? 'Customer',
      description: 'Payment for order ${order.orderNumber}',
      callbackUrl: _buildCallbackUrl(order.id),
      successUrl: _buildSuccessUrl(order.id),
      failureUrl: _buildFailureUrl(order.id),
      metadata: {
        'order_id': order.id,
        'order_number': order.orderNumber,
        'user_id': order.userId,
      },
      expiresAt: now.add(const Duration(minutes: 15)),
      createdAt: now,
    );

    return await _repository.initiatePayment(request: paymentRequest);
  }

  String _generatePaymentId() {
    return 'pay_${DateTime.now().millisecondsSinceEpoch}';
  }

  String _buildCallbackUrl(String orderId) {
    return 'https://api.freshcrops.co.tz/payments/callback/$orderId';
  }

  String _buildSuccessUrl(String orderId) {
    return 'https://app.freshcrops.co.tz/orders/$orderId/payment-success';
  }

  String _buildFailureUrl(String orderId) {
    return 'https://app.freshcrops.co.tz/orders/$orderId/payment-failed';
  }
}

/// Use case for checking payment status
class CheckPaymentStatusUseCase {
  final PaymentRepository _repository;

  const CheckPaymentStatusUseCase(this._repository);

  Future<Result<PaymentResponseEntity>> call(String paymentId) async {
    if (paymentId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Payment ID cannot be empty'),
      );
    }

    return await _repository.checkPaymentStatus(paymentId: paymentId.trim());
  }
}

/// Use case for getting payment by order ID
class GetPaymentByOrderIdUseCase {
  final PaymentRepository _repository;

  const GetPaymentByOrderIdUseCase(this._repository);

  Future<Result<PaymentResponseEntity?>> call(String orderId) async {
    if (orderId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Order ID cannot be empty'),
      );
    }

    return await _repository.getPaymentByOrderId(orderId: orderId.trim());
  }
}

/// Use case for getting user payment history
class GetUserPaymentHistoryUseCase {
  final PaymentRepository _repository;

  const GetUserPaymentHistoryUseCase(this._repository);

  Future<Result<List<PaymentResponseEntity>>> call({
    required String userId,
    int limit = 20,
    String? startAfter,
  }) async {
    if (userId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'User ID cannot be empty'),
      );
    }

    if (limit < 1 || limit > 100) {
      return const Result.failure(
        ValidationFailure(message: 'Limit must be between 1 and 100'),
      );
    }

    return await _repository.getUserPaymentHistory(
      userId: userId.trim(),
      limit: limit,
      startAfter: startAfter,
    );
  }
}

/// Use case for cancelling a payment
class CancelPaymentUseCase {
  final PaymentRepository _repository;

  const CancelPaymentUseCase(this._repository);

  Future<Result<PaymentResponseEntity>> call({
    required String paymentId,
    required String reason,
  }) async {
    if (paymentId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Payment ID cannot be empty'),
      );
    }

    if (reason.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Cancellation reason cannot be empty'),
      );
    }

    return await _repository.cancelPayment(
      paymentId: paymentId.trim(),
      reason: reason.trim(),
    );
  }
}

/// Use case for processing a refund
class ProcessRefundUseCase {
  final PaymentRepository _repository;

  const ProcessRefundUseCase(this._repository);

  Future<Result<PaymentResponseEntity>> call({
    required String originalPaymentId,
    required double amount,
    required String reason,
  }) async {
    if (originalPaymentId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Original payment ID cannot be empty'),
      );
    }

    if (amount <= 0) {
      return const Result.failure(
        ValidationFailure(message: 'Refund amount must be greater than 0'),
      );
    }

    if (reason.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Refund reason cannot be empty'),
      );
    }

    return await _repository.processRefund(
      originalPaymentId: originalPaymentId.trim(),
      amount: amount,
      reason: reason.trim(),
    );
  }
}

/// Use case for verifying payment callback
class VerifyPaymentCallbackUseCase {
  final PaymentRepository _repository;

  const VerifyPaymentCallbackUseCase(this._repository);

  Future<Result<PaymentResponseEntity>> call({
    required Map<String, dynamic> callbackData,
    required String signature,
  }) async {
    if (callbackData.isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Callback data cannot be empty'),
      );
    }

    if (signature.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Signature cannot be empty'),
      );
    }

    return await _repository.verifyPaymentCallback(
      callbackData: callbackData,
      signature: signature.trim(),
    );
  }
}

/// Use case for getting supported payment methods
class GetSupportedPaymentMethodsUseCase {
  final PaymentRepository _repository;

  const GetSupportedPaymentMethodsUseCase(this._repository);

  Future<Result<List<PaymentMethodInfo>>> call() async {
    return await _repository.getSupportedPaymentMethods();
  }
}

/// Use case for validating phone number
class ValidatePhoneNumberUseCase {
  final PaymentRepository _repository;

  const ValidatePhoneNumberUseCase(this._repository);

  Future<Result<PaymentProviderValidation>> call({
    required String phoneNumber,
    PaymentProvider? preferredProvider,
  }) async {
    if (phoneNumber.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Phone number cannot be empty'),
      );
    }

    return await _repository.validatePhoneNumber(
      phoneNumber: phoneNumber.trim(),
      preferredProvider: preferredProvider,
    );
  }
}

/// Use case for getting payment fees
class GetPaymentFeesUseCase {
  final PaymentRepository _repository;

  const GetPaymentFeesUseCase(this._repository);

  Future<Result<PaymentFees>> call({
    required double amount,
    required PaymentMethod method,
    required PaymentProvider provider,
  }) async {
    if (amount <= 0) {
      return const Result.failure(
        ValidationFailure(message: 'Amount must be greater than 0'),
      );
    }

    return await _repository.getPaymentFees(
      amount: amount,
      method: method,
      provider: provider,
    );
  }
}

/// Use case for updating payment status
class UpdatePaymentStatusUseCase {
  final PaymentRepository _repository;

  const UpdatePaymentStatusUseCase(this._repository);

  Future<Result<PaymentResponseEntity>> call({
    required String paymentId,
    required PaymentStatus status,
    String? transactionId,
    String? failureReason,
    Map<String, dynamic>? providerData,
  }) async {
    if (paymentId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Payment ID cannot be empty'),
      );
    }

    return await _repository.updatePaymentStatus(
      paymentId: paymentId.trim(),
      status: status,
      transactionId: transactionId?.trim(),
      failureReason: failureReason?.trim(),
      providerData: providerData,
    );
  }
}

/// Validation failure for use case parameters
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}
