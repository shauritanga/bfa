import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/repositories/base_repository.dart';
import '../entities/order_entity.dart';
import '../entities/delivery_info_entity.dart';
import '../entities/payment_info_entity.dart';
import '../repositories/order_repository.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../../../payments/domain/entities/payment_response_entity.dart';

/// Use case for creating an order from cart
class CreateOrderFromCartUseCase {
  final OrderRepository _repository;

  const CreateOrderFromCartUseCase(this._repository);

  Future<Result<OrderEntity>> call({
    required String userId,
    required CartEntity cart,
    required DeliveryInfoEntity deliveryInfo,
    required PaymentInfoEntity paymentInfo,
    String? notes,
  }) async {
    // Validate inputs
    if (userId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'User ID cannot be empty'),
      );
    }

    if (cart.isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Cart cannot be empty'),
      );
    }

    if (!cart.isValidForCheckout) {
      return const Result.failure(
        ValidationFailure(message: 'Cart contains invalid items'),
      );
    }

    // Convert cart items to order item requests
    final orderItems = cart.items
        .map(
          (cartItem) => OrderItemRequest(
            productId: cartItem.productId,
            farmerId: cartItem.product.farmerId,
            quantity: cartItem.quantity,
            unitPrice: cartItem.unitPrice,
            discountPrice: cartItem.discountPrice,
            notes: cartItem.notes,
          ),
        )
        .toList();

    return await _repository.createOrder(
      userId: userId.trim(),
      items: orderItems,
      deliveryInfo: deliveryInfo,
      paymentInfo: paymentInfo,
      couponCode: cart.couponCode,
      notes: notes,
    );
  }
}

/// Use case for getting user orders
class GetUserOrdersUseCase {
  final OrderRepository _repository;

  const GetUserOrdersUseCase(this._repository);

  Future<Result<PaginatedResult<OrderEntity>>> call({
    required String userId,
    OrderStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    // Validate inputs
    if (userId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'User ID cannot be empty'),
      );
    }

    if (page < 1) {
      return const Result.failure(
        ValidationFailure(message: 'Page number must be greater than 0'),
      );
    }

    if (limit < 1 || limit > 100) {
      return const Result.failure(
        ValidationFailure(message: 'Limit must be between 1 and 100'),
      );
    }

    return await _repository.getUserOrders(
      userId: userId.trim(),
      status: status,
      page: page,
      limit: limit,
    );
  }
}

/// Use case for getting order by ID
class GetOrderByIdUseCase {
  final OrderRepository _repository;

  const GetOrderByIdUseCase(this._repository);

  Future<Result<OrderEntity>> call(String orderId) async {
    if (orderId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Order ID cannot be empty'),
      );
    }

    return await _repository.getById(orderId.trim());
  }
}

/// Use case for getting order by order number
class GetOrderByNumberUseCase {
  final OrderRepository _repository;

  const GetOrderByNumberUseCase(this._repository);

  Future<Result<OrderEntity?>> call(String orderNumber) async {
    if (orderNumber.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Order number cannot be empty'),
      );
    }

    return await _repository.getOrderByNumber(orderNumber.trim());
  }
}

/// Use case for cancelling an order
class CancelOrderUseCase {
  final OrderRepository _repository;

  const CancelOrderUseCase(this._repository);

  Future<Result<OrderEntity>> call({
    required String orderId,
    required String reason,
  }) async {
    // Validate inputs
    if (orderId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Order ID cannot be empty'),
      );
    }

    if (reason.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Cancellation reason cannot be empty'),
      );
    }

    // Check if order can be cancelled
    final orderResult = await _repository.getById(orderId.trim());
    if (orderResult.isFailure) {
      return Result.failure(orderResult.failure!);
    }

    final order = orderResult.data!;
    if (!order.canBeCancelled) {
      return const Result.failure(
        ValidationFailure(message: 'Order cannot be cancelled at this stage'),
      );
    }

    return await _repository.cancelOrder(
      orderId: orderId.trim(),
      reason: reason.trim(),
    );
  }
}

/// Use case for updating order status
class UpdateOrderStatusUseCase {
  final OrderRepository _repository;

  const UpdateOrderStatusUseCase(this._repository);

  Future<Result<OrderEntity>> call({
    required String orderId,
    required OrderStatus status,
    String? notes,
  }) async {
    if (orderId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Order ID cannot be empty'),
      );
    }

    return await _repository.updateOrderStatus(
      orderId: orderId.trim(),
      status: status,
      notes: notes?.trim(),
    );
  }
}

/// Use case for updating payment status
class UpdatePaymentStatusUseCase {
  final OrderRepository _repository;

  const UpdatePaymentStatusUseCase(this._repository);

  Future<Result<OrderEntity>> call({
    required String orderId,
    required PaymentStatus paymentStatus,
    String? transactionId,
    String? failureReason,
  }) async {
    if (orderId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Order ID cannot be empty'),
      );
    }

    return await _repository.updatePaymentStatus(
      orderId: orderId.trim(),
      paymentStatus: paymentStatus,
      transactionId: transactionId?.trim(),
      failureReason: failureReason?.trim(),
    );
  }
}

/// Use case for getting order tracking information
class GetOrderTrackingUseCase {
  final OrderRepository _repository;

  const GetOrderTrackingUseCase(this._repository);

  Future<Result<OrderTrackingInfo>> call(String orderId) async {
    if (orderId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Order ID cannot be empty'),
      );
    }

    return await _repository.getOrderTracking(orderId.trim());
  }
}

/// Use case for processing refund
class ProcessRefundUseCase {
  final OrderRepository _repository;

  const ProcessRefundUseCase(this._repository);

  Future<Result<OrderEntity>> call({
    required String orderId,
    required double amount,
    required String reason,
  }) async {
    // Validate inputs
    if (orderId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Order ID cannot be empty'),
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

    // Check if order is refundable
    final orderResult = await _repository.getById(orderId.trim());
    if (orderResult.isFailure) {
      return Result.failure(orderResult.failure!);
    }

    final order = orderResult.data!;
    if (!order.isRefundable) {
      return const Result.failure(
        ValidationFailure(message: 'Order is not eligible for refund'),
      );
    }

    if (amount > order.paymentInfo.refundableAmount) {
      return const Result.failure(
        ValidationFailure(message: 'Refund amount exceeds refundable amount'),
      );
    }

    return await _repository.processRefund(
      orderId: orderId.trim(),
      amount: amount,
      reason: reason.trim(),
    );
  }
}

/// Use case for getting order statistics
class GetOrderStatisticsUseCase {
  final OrderRepository _repository;

  const GetOrderStatisticsUseCase(this._repository);

  Future<Result<OrderStatistics>> call({
    String? userId,
    String? farmerId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Validate date range
    if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
      return const Result.failure(
        ValidationFailure(message: 'Start date cannot be after end date'),
      );
    }

    return await _repository.getOrderStatistics(
      userId: userId?.trim(),
      farmerId: farmerId?.trim(),
      startDate: startDate,
      endDate: endDate,
    );
  }
}

/// Use case for assigning driver to order
class AssignDriverUseCase {
  final OrderRepository _repository;

  const AssignDriverUseCase(this._repository);

  Future<Result<OrderEntity>> call({
    required String orderId,
    required String driverId,
    required String driverName,
    required String driverPhone,
    String? vehicleInfo,
  }) async {
    // Validate inputs
    if (orderId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Order ID cannot be empty'),
      );
    }

    if (driverId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Driver ID cannot be empty'),
      );
    }

    if (driverName.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Driver name cannot be empty'),
      );
    }

    if (driverPhone.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Driver phone cannot be empty'),
      );
    }

    return await _repository.assignDriver(
      orderId: orderId.trim(),
      driverId: driverId.trim(),
      driverName: driverName.trim(),
      driverPhone: driverPhone.trim(),
      vehicleInfo: vehicleInfo?.trim(),
    );
  }
}

/// Validation failure for use case parameters
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}
