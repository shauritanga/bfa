import 'package:equatable/equatable.dart';
import 'cart_item_entity.dart';

/// Cart entity representing a user's shopping cart
class CartEntity extends Equatable {
  final String id;
  final String userId;
  final List<CartItemEntity> items;
  final String? couponCode;
  final double? couponDiscount;
  final double? deliveryFee;
  final String? deliveryAddress;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CartEntity({
    required this.id,
    required this.userId,
    required this.items,
    this.couponCode,
    this.couponDiscount,
    this.deliveryFee,
    this.deliveryAddress,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if cart is empty
  bool get isEmpty => items.isEmpty;

  /// Check if cart has items
  bool get isNotEmpty => items.isNotEmpty;

  /// Get total number of items in cart
  int get itemCount => items.length;

  /// Get total quantity of all items
  double get totalQuantity => items.fold(0.0, (sum, item) => sum + item.quantity);

  /// Calculate subtotal (sum of all item prices before discounts)
  double get subtotal => items.fold(0.0, (sum, item) => sum + (item.unitPrice * item.quantity));

  /// Calculate total item discounts
  double get itemDiscounts => items.fold(0.0, (sum, item) => sum + item.totalSavings);

  /// Calculate subtotal after item discounts
  double get discountedSubtotal => subtotal - itemDiscounts;

  /// Get coupon discount amount
  double get couponDiscountAmount => couponDiscount ?? 0.0;

  /// Get delivery fee amount
  double get deliveryFeeAmount => deliveryFee ?? 0.0;

  /// Calculate total before delivery
  double get totalBeforeDelivery => discountedSubtotal - couponDiscountAmount;

  /// Calculate final total
  double get total => totalBeforeDelivery + deliveryFeeAmount;

  /// Calculate total savings (item discounts + coupon discount)
  double get totalSavings => itemDiscounts + couponDiscountAmount;

  /// Check if cart has any discounts
  bool get hasDiscounts => itemDiscounts > 0 || couponDiscountAmount > 0;

  /// Check if all items are available
  bool get allItemsAvailable => items.every((item) => item.isProductAvailable);

  /// Get unavailable items
  List<CartItemEntity> get unavailableItems => 
      items.where((item) => !item.isProductAvailable).toList();

  /// Get items that exceed stock
  List<CartItemEntity> get itemsExceedingStock => 
      items.where((item) => item.exceedsStock).toList();

  /// Check if cart is valid for checkout
  bool get isValidForCheckout => 
      isNotEmpty && allItemsAvailable && itemsExceedingStock.isEmpty;

  /// Get unique farmer IDs from cart items
  List<String> get farmerIds => 
      items.map((item) => item.product.farmerId).toSet().toList();

  /// Group items by farmer
  Map<String, List<CartItemEntity>> get itemsByFarmer {
    final Map<String, List<CartItemEntity>> grouped = {};
    for (final item in items) {
      final farmerId = item.product.farmerId;
      grouped.putIfAbsent(farmerId, () => []).add(item);
    }
    return grouped;
  }

  /// Find item by product ID
  CartItemEntity? findItemByProductId(String productId) {
    try {
      return items.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
  }

  /// Check if product is in cart
  bool containsProduct(String productId) {
    return findItemByProductId(productId) != null;
  }

  /// Get quantity of specific product in cart
  double getProductQuantity(String productId) {
    final item = findItemByProductId(productId);
    return item?.quantity ?? 0.0;
  }

  /// Add item to cart
  CartEntity addItem(CartItemEntity newItem) {
    final existingItemIndex = items.indexWhere(
      (item) => item.productId == newItem.productId,
    );

    List<CartItemEntity> updatedItems;
    if (existingItemIndex != -1) {
      // Update existing item quantity
      final existingItem = items[existingItemIndex];
      final updatedItem = existingItem.copyWith(
        quantity: existingItem.quantity + newItem.quantity,
        updatedAt: DateTime.now(),
      );
      updatedItems = List.from(items);
      updatedItems[existingItemIndex] = updatedItem;
    } else {
      // Add new item
      updatedItems = [...items, newItem];
    }

    return copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    );
  }

  /// Update item quantity
  CartEntity updateItemQuantity(String productId, double quantity) {
    final updatedItems = items.map((item) {
      if (item.productId == productId) {
        return item.copyWith(
          quantity: quantity,
          updatedAt: DateTime.now(),
        );
      }
      return item;
    }).toList();

    return copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    );
  }

  /// Remove item from cart
  CartEntity removeItem(String productId) {
    final updatedItems = items.where((item) => item.productId != productId).toList();
    
    return copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    );
  }

  /// Clear all items from cart
  CartEntity clearItems() {
    return copyWith(
      items: [],
      updatedAt: DateTime.now(),
    );
  }

  /// Apply coupon
  CartEntity applyCoupon(String couponCode, double discountAmount) {
    return copyWith(
      couponCode: couponCode,
      couponDiscount: discountAmount,
      updatedAt: DateTime.now(),
    );
  }

  /// Remove coupon
  CartEntity removeCoupon() {
    return copyWith(
      couponCode: null,
      couponDiscount: null,
      updatedAt: DateTime.now(),
    );
  }

  /// Set delivery fee
  CartEntity setDeliveryFee(double fee) {
    return copyWith(
      deliveryFee: fee,
      updatedAt: DateTime.now(),
    );
  }

  /// Set delivery address
  CartEntity setDeliveryAddress(String address) {
    return copyWith(
      deliveryAddress: address,
      updatedAt: DateTime.now(),
    );
  }

  /// Create a copy with updated fields
  CartEntity copyWith({
    String? id,
    String? userId,
    List<CartItemEntity>? items,
    String? couponCode,
    double? couponDiscount,
    double? deliveryFee,
    String? deliveryAddress,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      couponCode: couponCode ?? this.couponCode,
      couponDiscount: couponDiscount ?? this.couponDiscount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
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
      'items': items.map((item) => item.toMap()).toList(),
      'couponCode': couponCode,
      'couponDiscount': couponDiscount,
      'deliveryFee': deliveryFee,
      'deliveryAddress': deliveryAddress,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from map (Firestore document)
  factory CartEntity.fromMap(Map<String, dynamic> map) {
    return CartEntity(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      items: (map['items'] as List<dynamic>?)
          ?.map((item) => CartItemEntity.fromMap(item))
          .toList() ?? [],
      couponCode: map['couponCode'],
      couponDiscount: map['couponDiscount']?.toDouble(),
      deliveryFee: map['deliveryFee']?.toDouble(),
      deliveryAddress: map['deliveryAddress'],
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  /// Create empty cart
  factory CartEntity.empty({
    required String id,
    required String userId,
  }) {
    final now = DateTime.now();
    return CartEntity(
      id: id,
      userId: userId,
      items: [],
      metadata: {},
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        items,
        couponCode,
        couponDiscount,
        deliveryFee,
        deliveryAddress,
        metadata,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'CartEntity(id: $id, userId: $userId, itemCount: $itemCount, total: $total)';
  }
}
