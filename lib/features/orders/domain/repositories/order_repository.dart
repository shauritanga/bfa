import '../../../../core/utils/result.dart';
import '../../../../core/repositories/base_repository.dart';
import '../entities/order_entity.dart';
import '../entities/order_item_entity.dart';
import '../entities/delivery_info_entity.dart';
import '../entities/payment_info_entity.dart';
import '../../../payments/domain/entities/payment_response_entity.dart';

/// Order repository interface
abstract class OrderRepository extends BaseRepository<OrderEntity, String> {
  /// Create a new order
  Future<Result<OrderEntity>> createOrder({
    required String userId,
    required List<OrderItemRequest> items,
    required DeliveryInfoEntity deliveryInfo,
    required PaymentInfoEntity paymentInfo,
    String? couponCode,
    String? notes,
  });

  /// Get user's orders with pagination
  Future<Result<PaginatedResult<OrderEntity>>> getUserOrders({
    required String userId,
    OrderStatus? status,
    int page = 1,
    int limit = 20,
  });

  /// Get order by order number
  Future<Result<OrderEntity?>> getOrderByNumber(String orderNumber);

  /// Update order status
  Future<Result<OrderEntity>> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
    String? notes,
  });

  /// Update payment status
  Future<Result<OrderEntity>> updatePaymentStatus({
    required String orderId,
    required PaymentStatus paymentStatus,
    String? transactionId,
    String? failureReason,
  });

  /// Cancel order
  Future<Result<OrderEntity>> cancelOrder({
    required String orderId,
    required String reason,
  });

  /// Update delivery information
  Future<Result<OrderEntity>> updateDeliveryInfo({
    required String orderId,
    required DeliveryInfoEntity deliveryInfo,
  });

  /// Assign driver to order
  Future<Result<OrderEntity>> assignDriver({
    required String orderId,
    required String driverId,
    required String driverName,
    required String driverPhone,
    String? vehicleInfo,
  });

  /// Update delivery status
  Future<Result<OrderEntity>> updateDeliveryStatus({
    required String orderId,
    DateTime? estimatedArrival,
    DateTime? actualArrival,
    String? deliveryNotes,
    List<String>? deliveryPhotos,
  });

  /// Get orders by status
  Future<Result<List<OrderEntity>>> getOrdersByStatus({
    required OrderStatus status,
    int limit = 50,
  });

  /// Get orders by farmer
  Future<Result<PaginatedResult<OrderEntity>>> getOrdersByFarmer({
    required String farmerId,
    OrderStatus? status,
    int page = 1,
    int limit = 20,
  });

  /// Get orders by date range
  Future<Result<List<OrderEntity>>> getOrdersByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? userId,
    String? farmerId,
  });

  /// Get order statistics
  Future<Result<OrderStatistics>> getOrderStatistics({
    String? userId,
    String? farmerId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Process refund
  Future<Result<OrderEntity>> processRefund({
    required String orderId,
    required double amount,
    required String reason,
  });

  /// Get pending orders (for farmers/admin)
  Future<Result<List<OrderEntity>>> getPendingOrders({
    String? farmerId,
    int limit = 50,
  });

  /// Get orders requiring attention
  Future<Result<List<OrderEntity>>> getOrdersRequiringAttention({
    String? farmerId,
    int limit = 50,
  });

  /// Update order items status
  Future<Result<OrderEntity>> updateOrderItemsStatus({
    required String orderId,
    required Map<String, OrderItemStatus> itemStatuses,
  });

  /// Get order tracking information
  Future<Result<OrderTrackingInfo>> getOrderTracking(String orderId);

  /// Send order notification
  Future<Result<void>> sendOrderNotification({
    required String orderId,
    required OrderNotificationType type,
    Map<String, dynamic>? data,
  });
}

/// Order item request for creating orders
class OrderItemRequest {
  final String productId;
  final String farmerId;
  final double quantity;
  final double unitPrice;
  final double? discountPrice;
  final String? notes;

  const OrderItemRequest({
    required this.productId,
    required this.farmerId,
    required this.quantity,
    required this.unitPrice,
    this.discountPrice,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'farmerId': farmerId,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'discountPrice': discountPrice,
      'notes': notes,
    };
  }
}

/// Order statistics data class
class OrderStatistics {
  final int totalOrders;
  final int pendingOrders;
  final int completedOrders;
  final int cancelledOrders;
  final double totalRevenue;
  final double averageOrderValue;
  final Map<OrderStatus, int> ordersByStatus;
  final Map<String, int> ordersByMonth;
  final Map<String, double> revenueByMonth;

  const OrderStatistics({
    required this.totalOrders,
    required this.pendingOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.totalRevenue,
    required this.averageOrderValue,
    required this.ordersByStatus,
    required this.ordersByMonth,
    required this.revenueByMonth,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalOrders': totalOrders,
      'pendingOrders': pendingOrders,
      'completedOrders': completedOrders,
      'cancelledOrders': cancelledOrders,
      'totalRevenue': totalRevenue,
      'averageOrderValue': averageOrderValue,
      'ordersByStatus': ordersByStatus.map((k, v) => MapEntry(k.name, v)),
      'ordersByMonth': ordersByMonth,
      'revenueByMonth': revenueByMonth,
    };
  }
}

/// Order tracking information
class OrderTrackingInfo {
  final String orderId;
  final OrderStatus currentStatus;
  final List<OrderTrackingEvent> events;
  final DeliveryInfoEntity? deliveryInfo;
  final DateTime? estimatedDelivery;
  final String? trackingNumber;

  const OrderTrackingInfo({
    required this.orderId,
    required this.currentStatus,
    required this.events,
    this.deliveryInfo,
    this.estimatedDelivery,
    this.trackingNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'currentStatus': currentStatus.name,
      'events': events.map((e) => e.toMap()).toList(),
      'deliveryInfo': deliveryInfo?.toMap(),
      'estimatedDelivery': estimatedDelivery?.toIso8601String(),
      'trackingNumber': trackingNumber,
    };
  }
}

/// Order tracking event
class OrderTrackingEvent {
  final String id;
  final OrderStatus status;
  final String title;
  final String description;
  final DateTime timestamp;
  final String? location;
  final Map<String, dynamic> metadata;

  const OrderTrackingEvent({
    required this.id,
    required this.status,
    required this.title,
    required this.description,
    required this.timestamp,
    this.location,
    required this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'status': status.name,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'location': location,
      'metadata': metadata,
    };
  }
}

/// Order notification types
enum OrderNotificationType {
  orderPlaced,
  orderConfirmed,
  orderPreparing,
  orderReady,
  orderOutForDelivery,
  orderDelivered,
  orderCancelled,
  paymentReceived,
  paymentFailed,
  refundProcessed,
}
