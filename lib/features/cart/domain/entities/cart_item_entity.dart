import 'package:equatable/equatable.dart';
import '../../../products/domain/entities/product_entity.dart';

/// Cart item entity representing a product in the shopping cart
class CartItemEntity extends Equatable {
  final String id;
  final String productId;
  final String userId;
  final ProductEntity product;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double? discountPrice;
  final String? notes;
  final DateTime addedAt;
  final DateTime updatedAt;

  const CartItemEntity({
    required this.id,
    required this.productId,
    required this.userId,
    required this.product,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    this.discountPrice,
    this.notes,
    required this.addedAt,
    required this.updatedAt,
  });

  /// Get the effective price per unit (discount price if available, otherwise unit price)
  double get effectiveUnitPrice => discountPrice ?? unitPrice;

  /// Calculate total price for this cart item
  double get totalPrice => effectiveUnitPrice * quantity;

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

  /// Check if the product is still available
  bool get isProductAvailable => product.isAvailable && product.quantity >= quantity;

  /// Check if the requested quantity exceeds available stock
  bool get exceedsStock => quantity > product.quantity;

  /// Get maximum available quantity
  double get maxAvailableQuantity => product.quantity;

  /// Create a copy with updated fields
  CartItemEntity copyWith({
    String? id,
    String? productId,
    String? userId,
    ProductEntity? product,
    double? quantity,
    String? unit,
    double? unitPrice,
    double? discountPrice,
    String? notes,
    DateTime? addedAt,
    DateTime? updatedAt,
  }) {
    return CartItemEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      userId: userId ?? this.userId,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      discountPrice: discountPrice ?? this.discountPrice,
      notes: notes ?? this.notes,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'userId': userId,
      'product': product.toMap(),
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'discountPrice': discountPrice,
      'notes': notes,
      'addedAt': addedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from map (Firestore document)
  factory CartItemEntity.fromMap(Map<String, dynamic> map) {
    return CartItemEntity(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      userId: map['userId'] ?? '',
      product: ProductEntity.fromMap(map['product']),
      quantity: (map['quantity'] ?? 0.0).toDouble(),
      unit: map['unit'] ?? '',
      unitPrice: (map['unitPrice'] ?? 0.0).toDouble(),
      discountPrice: map['discountPrice']?.toDouble(),
      notes: map['notes'],
      addedAt: DateTime.parse(map['addedAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  /// Create from product
  factory CartItemEntity.fromProduct({
    required String id,
    required String userId,
    required ProductEntity product,
    required double quantity,
    String? notes,
  }) {
    final now = DateTime.now();
    return CartItemEntity(
      id: id,
      productId: product.id,
      userId: userId,
      product: product,
      quantity: quantity,
      unit: product.unit,
      unitPrice: product.price,
      discountPrice: product.discountPrice,
      notes: notes,
      addedAt: now,
      updatedAt: now,
    );
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        userId,
        product,
        quantity,
        unit,
        unitPrice,
        discountPrice,
        notes,
        addedAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'CartItemEntity(id: $id, productId: $productId, quantity: $quantity, totalPrice: $totalPrice)';
  }
}
