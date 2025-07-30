import 'package:equatable/equatable.dart';
import '../../../products/domain/entities/product_entity.dart';

/// Order item entity representing a product in an order
class OrderItemEntity extends Equatable {
  final String id;
  final String orderId;
  final String productId;
  final String farmerId;
  final String farmerName;
  final ProductEntity product;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double? discountPrice;
  final double totalPrice;
  final String? notes;
  final OrderItemStatus status;
  final DateTime? harvestDate;
  final DateTime? expiryDate;
  final Map<String, dynamic> metadata;

  const OrderItemEntity({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.farmerId,
    required this.farmerName,
    required this.product,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    this.discountPrice,
    required this.totalPrice,
    this.notes,
    required this.status,
    this.harvestDate,
    this.expiryDate,
    required this.metadata,
  });

  /// Get the effective price per unit (discount price if available, otherwise unit price)
  double get effectiveUnitPrice => discountPrice ?? unitPrice;

  /// Calculate total savings if there's a discount
  double get totalSavings {
    if (discountPrice == null) return 0.0;
    return (unitPrice - discountPrice!) * quantity;
  }

  /// Check if this item has a discount
  bool get hasDiscount => discountPrice != null && discountPrice! < unitPrice;

  /// Get discount percentage
  double get discountPercentage {
    if (!hasDiscount) return 0.0;
    return ((unitPrice - discountPrice!) / unitPrice) * 100;
  }

  /// Check if item is available
  bool get isAvailable => status != OrderItemStatus.unavailable;

  /// Check if item is ready
  bool get isReady => status == OrderItemStatus.ready;

  /// Check if item is delivered
  bool get isDelivered => status == OrderItemStatus.delivered;

  /// Check if item is cancelled
  bool get isCancelled => status == OrderItemStatus.cancelled;

  /// Create from cart item
  factory OrderItemEntity.fromCartItem({
    required String id,
    required String orderId,
    required String productId,
    required String farmerId,
    required String farmerName,
    required ProductEntity product,
    required double quantity,
    required String unit,
    required double unitPrice,
    double? discountPrice,
    String? notes,
  }) {
    final effectivePrice = discountPrice ?? unitPrice;
    return OrderItemEntity(
      id: id,
      orderId: orderId,
      productId: productId,
      farmerId: farmerId,
      farmerName: farmerName,
      product: product,
      quantity: quantity,
      unit: unit,
      unitPrice: unitPrice,
      discountPrice: discountPrice,
      totalPrice: effectivePrice * quantity,
      notes: notes,
      status: OrderItemStatus.pending,
      harvestDate: product.harvestDate,
      expiryDate: product.expiryDate,
      metadata: {},
    );
  }

  /// Create a copy with updated fields
  OrderItemEntity copyWith({
    String? id,
    String? orderId,
    String? productId,
    String? farmerId,
    String? farmerName,
    ProductEntity? product,
    double? quantity,
    String? unit,
    double? unitPrice,
    double? discountPrice,
    double? totalPrice,
    String? notes,
    OrderItemStatus? status,
    DateTime? harvestDate,
    DateTime? expiryDate,
    Map<String, dynamic>? metadata,
  }) {
    return OrderItemEntity(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      discountPrice: discountPrice ?? this.discountPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      harvestDate: harvestDate ?? this.harvestDate,
      expiryDate: expiryDate ?? this.expiryDate,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'productId': productId,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'product': product.toMap(),
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'discountPrice': discountPrice,
      'totalPrice': totalPrice,
      'notes': notes,
      'status': status.name,
      'harvestDate': harvestDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Create from map (Firestore document)
  factory OrderItemEntity.fromMap(Map<String, dynamic> map) {
    return OrderItemEntity(
      id: map['id'] ?? '',
      orderId: map['orderId'] ?? '',
      productId: map['productId'] ?? '',
      farmerId: map['farmerId'] ?? '',
      farmerName: map['farmerName'] ?? '',
      product: ProductEntity.fromMap(map['product']),
      quantity: (map['quantity'] ?? 0.0).toDouble(),
      unit: map['unit'] ?? '',
      unitPrice: (map['unitPrice'] ?? 0.0).toDouble(),
      discountPrice: map['discountPrice']?.toDouble(),
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
      notes: map['notes'],
      status: OrderItemStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => OrderItemStatus.pending,
      ),
      harvestDate: map['harvestDate'] != null
          ? DateTime.parse(map['harvestDate'])
          : null,
      expiryDate: map['expiryDate'] != null
          ? DateTime.parse(map['expiryDate'])
          : null,
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [
        id,
        orderId,
        productId,
        farmerId,
        farmerName,
        product,
        quantity,
        unit,
        unitPrice,
        discountPrice,
        totalPrice,
        notes,
        status,
        harvestDate,
        expiryDate,
        metadata,
      ];

  @override
  String toString() {
    return 'OrderItemEntity(id: $id, productId: $productId, quantity: $quantity, totalPrice: $totalPrice)';
  }
}

/// Order item status enumeration
enum OrderItemStatus {
  pending,
  confirmed,
  preparing,
  ready,
  delivered,
  cancelled,
  unavailable,
}

/// Extension for order item status
extension OrderItemStatusExtension on OrderItemStatus {
  String get displayName {
    switch (this) {
      case OrderItemStatus.pending:
        return 'Pending';
      case OrderItemStatus.confirmed:
        return 'Confirmed';
      case OrderItemStatus.preparing:
        return 'Preparing';
      case OrderItemStatus.ready:
        return 'Ready';
      case OrderItemStatus.delivered:
        return 'Delivered';
      case OrderItemStatus.cancelled:
        return 'Cancelled';
      case OrderItemStatus.unavailable:
        return 'Unavailable';
    }
  }

  String get description {
    switch (this) {
      case OrderItemStatus.pending:
        return 'Item is being processed';
      case OrderItemStatus.confirmed:
        return 'Item has been confirmed';
      case OrderItemStatus.preparing:
        return 'Item is being prepared';
      case OrderItemStatus.ready:
        return 'Item is ready for pickup/delivery';
      case OrderItemStatus.delivered:
        return 'Item has been delivered';
      case OrderItemStatus.cancelled:
        return 'Item has been cancelled';
      case OrderItemStatus.unavailable:
        return 'Item is not available';
    }
  }
}
