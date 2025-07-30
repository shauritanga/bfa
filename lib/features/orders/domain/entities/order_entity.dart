import 'package:equatable/equatable.dart';
import 'order_item_entity.dart';
import 'delivery_info_entity.dart';
import 'payment_info_entity.dart';
import '../../../payments/domain/entities/payment_response_entity.dart';

/// Order entity representing a customer order
class OrderEntity extends Equatable {
  final String id;
  final String userId;
  final String orderNumber;
  final List<OrderItemEntity> items;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final DeliveryInfoEntity deliveryInfo;
  final PaymentInfoEntity paymentInfo;
  final double subtotal;
  final double discountAmount;
  final double deliveryFee;
  final double taxAmount;
  final double totalAmount;
  final String? couponCode;
  final String? notes;
  final String? cancellationReason;
  final DateTime orderDate;
  final DateTime? estimatedDeliveryDate;
  final DateTime? actualDeliveryDate;
  final DateTime? cancelledAt;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderEntity({
    required this.id,
    required this.userId,
    required this.orderNumber,
    required this.items,
    required this.status,
    required this.paymentStatus,
    required this.deliveryInfo,
    required this.paymentInfo,
    required this.subtotal,
    required this.discountAmount,
    required this.deliveryFee,
    required this.taxAmount,
    required this.totalAmount,
    this.couponCode,
    this.notes,
    this.cancellationReason,
    required this.orderDate,
    this.estimatedDeliveryDate,
    this.actualDeliveryDate,
    this.cancelledAt,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get total number of items in order
  int get itemCount => items.length;

  /// Get total quantity of all items
  double get totalQuantity =>
      items.fold(0.0, (sum, item) => sum + item.quantity);

  /// Check if order can be cancelled
  bool get canBeCancelled {
    return status == OrderStatus.pending ||
        status == OrderStatus.confirmed ||
        status == OrderStatus.preparing;
  }

  /// Check if order can be modified
  bool get canBeModified {
    return status == OrderStatus.pending;
  }

  /// Check if order is completed
  bool get isCompleted {
    return status == OrderStatus.delivered;
  }

  /// Check if order is cancelled
  bool get isCancelled {
    return status == OrderStatus.cancelled;
  }

  /// Check if payment is completed
  bool get isPaymentCompleted {
    return paymentStatus == PaymentStatus.completed;
  }

  /// Check if order is refundable
  bool get isRefundable {
    return isPaymentCompleted &&
        (status == OrderStatus.cancelled ||
            (isCompleted &&
                DateTime.now().difference(actualDeliveryDate!).inDays <= 7));
  }

  /// Get unique farmer IDs from order items
  List<String> get farmerIds =>
      items.map((item) => item.farmerId).toSet().toList();

  /// Group items by farmer
  Map<String, List<OrderItemEntity>> get itemsByFarmer {
    final Map<String, List<OrderItemEntity>> grouped = {};
    for (final item in items) {
      grouped.putIfAbsent(item.farmerId, () => []).add(item);
    }
    return grouped;
  }

  /// Get order progress percentage (0-100)
  int get progressPercentage {
    switch (status) {
      case OrderStatus.pending:
        return 10;
      case OrderStatus.confirmed:
        return 25;
      case OrderStatus.preparing:
        return 50;
      case OrderStatus.readyForPickup:
        return 75;
      case OrderStatus.outForDelivery:
        return 90;
      case OrderStatus.delivered:
        return 100;
      case OrderStatus.cancelled:
        return 0;
    }
  }

  /// Get estimated delivery time remaining
  Duration? get estimatedTimeRemaining {
    if (estimatedDeliveryDate == null || isCompleted || isCancelled) {
      return null;
    }
    final now = DateTime.now();
    if (estimatedDeliveryDate!.isBefore(now)) {
      return null; // Overdue
    }
    return estimatedDeliveryDate!.difference(now);
  }

  /// Create a copy with updated fields
  OrderEntity copyWith({
    String? id,
    String? userId,
    String? orderNumber,
    List<OrderItemEntity>? items,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    DeliveryInfoEntity? deliveryInfo,
    PaymentInfoEntity? paymentInfo,
    double? subtotal,
    double? discountAmount,
    double? deliveryFee,
    double? taxAmount,
    double? totalAmount,
    String? couponCode,
    String? notes,
    String? cancellationReason,
    DateTime? orderDate,
    DateTime? estimatedDeliveryDate,
    DateTime? actualDeliveryDate,
    DateTime? cancelledAt,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      orderNumber: orderNumber ?? this.orderNumber,
      items: items ?? this.items,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      deliveryInfo: deliveryInfo ?? this.deliveryInfo,
      paymentInfo: paymentInfo ?? this.paymentInfo,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      couponCode: couponCode ?? this.couponCode,
      notes: notes ?? this.notes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      orderDate: orderDate ?? this.orderDate,
      estimatedDeliveryDate:
          estimatedDeliveryDate ?? this.estimatedDeliveryDate,
      actualDeliveryDate: actualDeliveryDate ?? this.actualDeliveryDate,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'orderNumber': orderNumber,
      'items': items.map((item) => item.toMap()).toList(),
      'status': status.name,
      'paymentStatus': paymentStatus.name,
      'deliveryInfo': deliveryInfo.toMap(),
      'paymentInfo': paymentInfo.toMap(),
      'subtotal': subtotal,
      'discountAmount': discountAmount,
      'deliveryFee': deliveryFee,
      'taxAmount': taxAmount,
      'totalAmount': totalAmount,
      'couponCode': couponCode,
      'notes': notes,
      'cancellationReason': cancellationReason,
      'orderDate': orderDate.toIso8601String(),
      'estimatedDeliveryDate': estimatedDeliveryDate?.toIso8601String(),
      'actualDeliveryDate': actualDeliveryDate?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from map (Firestore document)
  factory OrderEntity.fromMap(Map<String, dynamic> map) {
    return OrderEntity(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      orderNumber: map['orderNumber'] ?? '',
      items:
          (map['items'] as List<dynamic>?)
              ?.map((item) => OrderItemEntity.fromMap(item))
              .toList() ??
          [],
      status: OrderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == map['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      deliveryInfo: DeliveryInfoEntity.fromMap(map['deliveryInfo']),
      paymentInfo: PaymentInfoEntity.fromMap(map['paymentInfo']),
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
      discountAmount: (map['discountAmount'] ?? 0.0).toDouble(),
      deliveryFee: (map['deliveryFee'] ?? 0.0).toDouble(),
      taxAmount: (map['taxAmount'] ?? 0.0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      couponCode: map['couponCode'],
      notes: map['notes'],
      cancellationReason: map['cancellationReason'],
      orderDate: DateTime.parse(map['orderDate']),
      estimatedDeliveryDate: map['estimatedDeliveryDate'] != null
          ? DateTime.parse(map['estimatedDeliveryDate'])
          : null,
      actualDeliveryDate: map['actualDeliveryDate'] != null
          ? DateTime.parse(map['actualDeliveryDate'])
          : null,
      cancelledAt: map['cancelledAt'] != null
          ? DateTime.parse(map['cancelledAt'])
          : null,
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    orderNumber,
    items,
    status,
    paymentStatus,
    deliveryInfo,
    paymentInfo,
    subtotal,
    discountAmount,
    deliveryFee,
    taxAmount,
    totalAmount,
    couponCode,
    notes,
    cancellationReason,
    orderDate,
    estimatedDeliveryDate,
    actualDeliveryDate,
    cancelledAt,
    metadata,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'OrderEntity(id: $id, orderNumber: $orderNumber, status: $status, totalAmount: $totalAmount)';
  }
}

/// Order status enumeration
enum OrderStatus {
  pending,
  confirmed,
  preparing,
  readyForPickup,
  outForDelivery,
  delivered,
  cancelled,
}

/// Extensions for order status
extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.readyForPickup:
        return 'Ready for Pickup';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get description {
    switch (this) {
      case OrderStatus.pending:
        return 'Your order is being reviewed';
      case OrderStatus.confirmed:
        return 'Your order has been confirmed';
      case OrderStatus.preparing:
        return 'Your order is being prepared';
      case OrderStatus.readyForPickup:
        return 'Your order is ready for pickup';
      case OrderStatus.outForDelivery:
        return 'Your order is on the way';
      case OrderStatus.delivered:
        return 'Your order has been delivered';
      case OrderStatus.cancelled:
        return 'Your order has been cancelled';
    }
  }
}
