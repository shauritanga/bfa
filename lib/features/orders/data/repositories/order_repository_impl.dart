import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../../../core/config/firebase_config.dart';
import '../../../../core/services/firestore_service.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_item_entity.dart';
import '../../domain/entities/delivery_info_entity.dart';
import '../../domain/entities/payment_info_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../../payments/domain/entities/payment_response_entity.dart';

/// Implementation of OrderRepository using Firestore
class OrderRepositoryImpl extends BaseRepositoryImpl<OrderEntity, String>
    implements OrderRepository {
  final FirestoreService _firestoreService;
  final ProductRepository _productRepository;

  OrderRepositoryImpl(this._firestoreService, this._productRepository);

  @override
  Future<Result<List<OrderEntity>>> getAll() async {
    return handleAsyncOperation(() async {
      final result = await _firestoreService.getDocuments(
        collection: FirebaseCollections.orders,
      );

      if (result.isSuccess) {
        final orders = result.data!
            .map((doc) => OrderEntity.fromMap(doc))
            .toList();
        return orders;
      } else {
        throw Exception(result.failure?.message ?? 'Failed to get orders');
      }
    });
  }

  @override
  Future<Result<OrderEntity>> getById(String id) async {
    return handleAsyncOperation(() async {
      final result = await _firestoreService.getDocument(
        collection: FirebaseCollections.orders,
        documentId: id,
      );

      if (result.isSuccess && result.data != null) {
        return OrderEntity.fromMap(result.data!);
      } else {
        throw Exception(result.failure?.message ?? 'Order not found');
      }
    });
  }

  @override
  Future<Result<OrderEntity>> create(OrderEntity item) async {
    return handleAsyncOperation(() async {
      final result = await _firestoreService.createDocument(
        collection: FirebaseCollections.orders,
        data: item.toMap(),
        documentId: item.id,
      );

      if (result.isSuccess) {
        return item;
      } else {
        throw Exception(result.failure?.message ?? 'Failed to create order');
      }
    });
  }

  @override
  Future<Result<OrderEntity>> update(String id, OrderEntity item) async {
    return handleAsyncOperation(() async {
      final updatedItem = item.copyWith(id: id, updatedAt: DateTime.now());

      final result = await _firestoreService.updateDocument(
        collection: FirebaseCollections.orders,
        documentId: id,
        data: updatedItem.toMap(),
      );

      if (result.isSuccess) {
        return updatedItem;
      } else {
        throw Exception(result.failure?.message ?? 'Failed to update order');
      }
    });
  }

  @override
  Future<Result<void>> delete(String id) async {
    return handleAsyncOperation(() async {
      final result = await _firestoreService.deleteDocument(
        collection: FirebaseCollections.orders,
        documentId: id,
      );

      if (result.isFailure) {
        throw Exception(result.failure?.message ?? 'Failed to delete order');
      }
    });
  }

  @override
  Future<Result<OrderEntity>> createOrder({
    required String userId,
    required List<OrderItemRequest> items,
    required DeliveryInfoEntity deliveryInfo,
    required PaymentInfoEntity paymentInfo,
    String? couponCode,
    String? notes,
  }) async {
    return handleAsyncOperation(() async {
      final orderId = _generateOrderId();
      final orderNumber = _generateOrderNumber();
      final now = DateTime.now();

      // Convert order item requests to order items
      final orderItems = <OrderItemEntity>[];
      double subtotal = 0.0;

      for (final itemRequest in items) {
        // Get product details
        final productResult = await _productRepository.getById(
          itemRequest.productId,
        );
        if (productResult.isFailure) {
          throw Exception('Product ${itemRequest.productId} not found');
        }

        final product = productResult.data!;
        final effectivePrice =
            itemRequest.discountPrice ?? itemRequest.unitPrice;
        final totalPrice = effectivePrice * itemRequest.quantity;

        final orderItem = OrderItemEntity.fromCartItem(
          id: '${orderId}_${itemRequest.productId}',
          orderId: orderId,
          productId: itemRequest.productId,
          farmerId: itemRequest.farmerId,
          farmerName: product.farmerName,
          product: product,
          quantity: itemRequest.quantity,
          unit: product.unit,
          unitPrice: itemRequest.unitPrice,
          discountPrice: itemRequest.discountPrice,
          notes: itemRequest.notes,
        );

        orderItems.add(orderItem);
        subtotal += totalPrice;
      }

      // Calculate totals
      const discountAmount = 0.0; // TODO: Calculate from coupon
      final taxAmount = subtotal * 0.18; // 18% VAT
      final totalAmount =
          subtotal - discountAmount + deliveryInfo.deliveryFee + taxAmount;

      // Create order
      final order = OrderEntity(
        id: orderId,
        userId: userId,
        orderNumber: orderNumber,
        items: orderItems,
        status: OrderStatus.pending,
        paymentStatus: PaymentStatus.pending,
        deliveryInfo: deliveryInfo,
        paymentInfo: paymentInfo.copyWith(amount: totalAmount),
        subtotal: subtotal,
        discountAmount: discountAmount,
        deliveryFee: deliveryInfo.deliveryFee,
        taxAmount: taxAmount,
        totalAmount: totalAmount,
        couponCode: couponCode,
        notes: notes,
        orderDate: now,
        estimatedDeliveryDate: now.add(deliveryInfo.type.estimatedDuration),
        metadata: const {},
        createdAt: now,
        updatedAt: now,
      );

      // Save order
      final result = await create(order);
      if (result.isFailure) {
        throw Exception(result.failure?.message ?? 'Failed to create order');
      }

      return order;
    });
  }

  @override
  Future<Result<PaginatedResult<OrderEntity>>> getUserOrders({
    required String userId,
    OrderStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    return handleAsyncOperation(() async {
      Query query = FirebaseFirestore.instance
          .collection(FirebaseCollections.orders)
          .where('userId', isEqualTo: userId)
          .orderBy('orderDate', descending: true);

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      query = query.limit(limit);

      final querySnapshot = await query.get();
      final orders = querySnapshot.docs
          .map(
            (doc) => OrderEntity.fromMap({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();

      // Get total count
      Query countQuery = FirebaseFirestore.instance
          .collection(FirebaseCollections.orders)
          .where('userId', isEqualTo: userId);

      if (status != null) {
        countQuery = countQuery.where('status', isEqualTo: status.name);
      }

      final totalSnapshot = await countQuery.count().get();
      final totalItems = totalSnapshot.count ?? 0;
      final totalPages = (totalItems / limit).ceil();

      return PaginatedResult<OrderEntity>(
        items: orders,
        currentPage: page,
        totalPages: totalPages,
        totalItems: totalItems,
        itemsPerPage: limit,
        hasNextPage: page < totalPages,
        hasPreviousPage: page > 1,
      );
    });
  }

  @override
  Future<Result<OrderEntity?>> getOrderByNumber(String orderNumber) async {
    return handleAsyncOperation(() async {
      final query = FirebaseFirestore.instance
          .collection(FirebaseCollections.orders)
          .where('orderNumber', isEqualTo: orderNumber)
          .limit(1);

      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) {
        return null;
      }

      final doc = snapshot.docs.first;
      return OrderEntity.fromMap({'id': doc.id, ...doc.data()});
    });
  }

  @override
  Future<Result<OrderEntity>> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
    String? notes,
  }) async {
    return handleAsyncOperation(() async {
      final orderResult = await getById(orderId);
      if (orderResult.isFailure) {
        throw Exception('Order not found');
      }

      final order = orderResult.data!;
      final updatedOrder = order.copyWith(
        status: status,
        notes: notes,
        updatedAt: DateTime.now(),
      );

      final result = await update(orderId, updatedOrder);
      if (result.isSuccess) {
        return result.data!;
      } else {
        throw Exception(result.failure?.message ?? 'Failed to update order');
      }
    });
  }

  @override
  Future<Result<OrderEntity>> updatePaymentStatus({
    required String orderId,
    required PaymentStatus paymentStatus,
    String? transactionId,
    String? failureReason,
  }) async {
    return handleAsyncOperation(() async {
      final orderResult = await getById(orderId);
      if (orderResult.isFailure) {
        throw Exception('Order not found');
      }

      final order = orderResult.data!;
      final updatedPaymentInfo = order.paymentInfo.copyWith(
        transactionId: transactionId,
        failureReason: failureReason,
        paidAt: paymentStatus == PaymentStatus.completed
            ? DateTime.now()
            : null,
      );

      final updatedOrder = order.copyWith(
        paymentStatus: paymentStatus,
        paymentInfo: updatedPaymentInfo,
        updatedAt: DateTime.now(),
      );

      final result = await update(orderId, updatedOrder);
      if (result.isSuccess) {
        return result.data!;
      } else {
        throw Exception(result.failure?.message ?? 'Failed to update order');
      }
    });
  }

  @override
  Future<Result<OrderEntity>> cancelOrder({
    required String orderId,
    required String reason,
  }) async {
    return handleAsyncOperation(() async {
      final orderResult = await getById(orderId);
      if (orderResult.isFailure) {
        throw Exception('Order not found');
      }

      final order = orderResult.data!;
      if (!order.canBeCancelled) {
        throw Exception('Order cannot be cancelled at this stage');
      }

      final updatedOrder = order.copyWith(
        status: OrderStatus.cancelled,
        cancellationReason: reason,
        cancelledAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await update(orderId, updatedOrder);
      if (result.isSuccess) {
        return result.data!;
      } else {
        throw Exception(result.failure?.message ?? 'Failed to cancel order');
      }
    });
  }

  // Helper methods
  String _generateOrderId() {
    return 'order_${DateTime.now().millisecondsSinceEpoch}';
  }

  String _generateOrderNumber() {
    final now = DateTime.now();
    final year = now.year.toString().substring(2);
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final timestamp = now.millisecondsSinceEpoch.toString().substring(8);
    return 'FC$year$month$day$timestamp';
  }

  // Placeholder implementations for remaining methods
  @override
  Future<Result<OrderEntity>> updateDeliveryInfo({
    required String orderId,
    required DeliveryInfoEntity deliveryInfo,
  }) async {
    return handleAsyncOperation(() async {
      final orderResult = await getById(orderId);
      if (orderResult.isFailure) {
        throw Exception('Order not found');
      }

      final order = orderResult.data!;
      final updatedOrder = order.copyWith(
        deliveryInfo: deliveryInfo,
        updatedAt: DateTime.now(),
      );

      final result = await update(orderId, updatedOrder);
      if (result.isSuccess) {
        return result.data!;
      } else {
        throw Exception(result.failure?.message ?? 'Failed to update order');
      }
    });
  }

  @override
  Future<Result<OrderEntity>> assignDriver({
    required String orderId,
    required String driverId,
    required String driverName,
    required String driverPhone,
    String? vehicleInfo,
  }) async {
    return handleAsyncOperation(() async {
      final orderResult = await getById(orderId);
      if (orderResult.isFailure) {
        throw Exception('Order not found');
      }

      final order = orderResult.data!;
      final updatedDeliveryInfo = order.deliveryInfo.copyWith(
        driverId: driverId,
        driverName: driverName,
        driverPhone: driverPhone,
        vehicleInfo: vehicleInfo,
      );

      final updatedOrder = order.copyWith(
        deliveryInfo: updatedDeliveryInfo,
        updatedAt: DateTime.now(),
      );

      final result = await update(orderId, updatedOrder);
      if (result.isSuccess) {
        return result.data!;
      } else {
        throw Exception(result.failure?.message ?? 'Failed to update order');
      }
    });
  }

  @override
  Future<Result<OrderEntity>> updateDeliveryStatus({
    required String orderId,
    DateTime? estimatedArrival,
    DateTime? actualArrival,
    String? deliveryNotes,
    List<String>? deliveryPhotos,
  }) async {
    return handleAsyncOperation(() async {
      final orderResult = await getById(orderId);
      if (orderResult.isFailure) {
        throw Exception('Order not found');
      }

      final order = orderResult.data!;
      final updatedDeliveryInfo = order.deliveryInfo.copyWith(
        estimatedArrival: estimatedArrival,
        actualArrival: actualArrival,
        deliveryNotes: deliveryNotes,
        deliveryPhotos: deliveryPhotos,
      );

      final updatedOrder = order.copyWith(
        deliveryInfo: updatedDeliveryInfo,
        status: actualArrival != null ? OrderStatus.delivered : order.status,
        actualDeliveryDate: actualArrival,
        updatedAt: DateTime.now(),
      );

      final result = await update(orderId, updatedOrder);
      if (result.isSuccess) {
        return result.data!;
      } else {
        throw Exception(result.failure?.message ?? 'Failed to update order');
      }
    });
  }

  // Add placeholder implementations for remaining abstract methods
  @override
  Future<Result<List<OrderEntity>>> getOrdersByStatus({
    required OrderStatus status,
    int limit = 50,
  }) async {
    return handleAsyncOperation(() async {
      final query = FirebaseFirestore.instance
          .collection(FirebaseCollections.orders)
          .where('status', isEqualTo: status.name)
          .orderBy('orderDate', descending: true)
          .limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => OrderEntity.fromMap({'id': doc.id, ...doc.data()}))
          .toList();
    });
  }

  @override
  Future<Result<PaginatedResult<OrderEntity>>> getOrdersByFarmer({
    required String farmerId,
    OrderStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    // TODO: Implement farmer-specific order queries
    return getUserOrders(
      userId: farmerId,
      status: status,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<Result<List<OrderEntity>>> getOrdersByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? userId,
    String? farmerId,
  }) async {
    return handleAsyncOperation(() async {
      Query query = FirebaseFirestore.instance
          .collection(FirebaseCollections.orders)
          .where(
            'orderDate',
            isGreaterThanOrEqualTo: startDate.toIso8601String(),
          )
          .where('orderDate', isLessThanOrEqualTo: endDate.toIso8601String());

      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map(
            (doc) => OrderEntity.fromMap({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();
    });
  }

  @override
  Future<Result<OrderStatistics>> getOrderStatistics({
    String? userId,
    String? farmerId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return handleAsyncOperation(() async {
      // Basic implementation - in a real app, this would use aggregation queries
      final ordersResult = await getAll();
      if (ordersResult.isFailure) {
        throw Exception('Failed to get orders for statistics');
      }

      final orders = ordersResult.data!;
      final totalOrders = orders.length;
      final pendingOrders = orders
          .where((o) => o.status == OrderStatus.pending)
          .length;
      final completedOrders = orders
          .where((o) => o.status == OrderStatus.delivered)
          .length;
      final cancelledOrders = orders
          .where((o) => o.status == OrderStatus.cancelled)
          .length;
      final totalRevenue = orders.fold(
        0.0,
        (total, order) => total + order.totalAmount,
      );
      final averageOrderValue = totalOrders > 0
          ? totalRevenue / totalOrders
          : 0.0;

      return OrderStatistics(
        totalOrders: totalOrders,
        pendingOrders: pendingOrders,
        completedOrders: completedOrders,
        cancelledOrders: cancelledOrders,
        totalRevenue: totalRevenue,
        averageOrderValue: averageOrderValue,
        ordersByStatus: {},
        ordersByMonth: {},
        revenueByMonth: {},
      );
    });
  }

  @override
  Future<Result<OrderEntity>> processRefund({
    required String orderId,
    required double amount,
    required String reason,
  }) async {
    return handleAsyncOperation(() async {
      final orderResult = await getById(orderId);
      if (orderResult.isFailure) {
        throw Exception('Order not found');
      }

      final order = orderResult.data!;
      final updatedPaymentInfo = order.paymentInfo.copyWith(
        refundedAmount: (order.paymentInfo.refundedAmount ?? 0.0) + amount,
        refundedAt: DateTime.now(),
        refundReason: reason,
      );

      final updatedOrder = order.copyWith(
        paymentInfo: updatedPaymentInfo,
        paymentStatus: updatedPaymentInfo.isFullyRefunded
            ? PaymentStatus.refunded
            : PaymentStatus.partiallyRefunded,
        updatedAt: DateTime.now(),
      );

      final result = await update(orderId, updatedOrder);
      if (result.isSuccess) {
        return result.data!;
      } else {
        throw Exception(result.failure?.message ?? 'Failed to update order');
      }
    });
  }

  @override
  Future<Result<List<OrderEntity>>> getPendingOrders({
    String? farmerId,
    int limit = 50,
  }) async {
    return getOrdersByStatus(status: OrderStatus.pending, limit: limit);
  }

  @override
  Future<Result<List<OrderEntity>>> getOrdersRequiringAttention({
    String? farmerId,
    int limit = 50,
  }) async {
    return handleAsyncOperation(() async {
      // Get orders that are overdue or have issues
      final now = DateTime.now();
      final query = FirebaseFirestore.instance
          .collection(FirebaseCollections.orders)
          .where('estimatedDeliveryDate', isLessThan: now.toIso8601String())
          .where(
            'status',
            whereIn: [
              OrderStatus.confirmed.name,
              OrderStatus.preparing.name,
              OrderStatus.outForDelivery.name,
            ],
          )
          .limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => OrderEntity.fromMap({'id': doc.id, ...doc.data()}))
          .toList();
    });
  }

  @override
  Future<Result<OrderEntity>> updateOrderItemsStatus({
    required String orderId,
    required Map<String, OrderItemStatus> itemStatuses,
  }) async {
    return handleAsyncOperation(() async {
      final orderResult = await getById(orderId);
      if (orderResult.isFailure) {
        throw Exception('Order not found');
      }

      final order = orderResult.data!;
      final updatedItems = order.items.map((item) {
        final newStatus = itemStatuses[item.id];
        return newStatus != null ? item.copyWith(status: newStatus) : item;
      }).toList();

      final updatedOrder = order.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      );

      final result = await update(orderId, updatedOrder);
      if (result.isSuccess) {
        return result.data!;
      } else {
        throw Exception(result.failure?.message ?? 'Failed to update order');
      }
    });
  }

  @override
  Future<Result<OrderTrackingInfo>> getOrderTracking(String orderId) async {
    return handleAsyncOperation(() async {
      final orderResult = await getById(orderId);
      if (orderResult.isFailure) {
        throw Exception('Order not found');
      }

      final order = orderResult.data!;

      // Create tracking events based on order status
      final events = <OrderTrackingEvent>[
        OrderTrackingEvent(
          id: '${orderId}_placed',
          status: OrderStatus.pending,
          title: 'Order Placed',
          description: 'Your order has been placed successfully',
          timestamp: order.orderDate,
          metadata: {},
        ),
      ];

      if (order.status.index >= OrderStatus.confirmed.index) {
        events.add(
          OrderTrackingEvent(
            id: '${orderId}_confirmed',
            status: OrderStatus.confirmed,
            title: 'Order Confirmed',
            description: 'Your order has been confirmed by the farmer',
            timestamp: order.updatedAt,
            metadata: {},
          ),
        );
      }

      // Add more events based on status...

      return OrderTrackingInfo(
        orderId: orderId,
        currentStatus: order.status,
        events: events,
        deliveryInfo: order.deliveryInfo,
        estimatedDelivery: order.estimatedDeliveryDate,
        trackingNumber: order.orderNumber,
      );
    });
  }

  @override
  Future<Result<void>> sendOrderNotification({
    required String orderId,
    required OrderNotificationType type,
    Map<String, dynamic>? data,
  }) async {
    return handleAsyncOperation(() async {
      // Placeholder for notification sending
      // This would integrate with Firebase Cloud Messaging or other notification services
      // For now, we'll just return success without actually sending notifications
    });
  }
}
