import '../../../../core/utils/result.dart';
import '../entities/cart_entity.dart';
import '../entities/cart_item_entity.dart';

/// Cart repository interface
abstract class CartRepository {
  /// Get user's cart
  Future<Result<CartEntity?>> getUserCart(String userId);

  /// Create a new cart for user
  Future<Result<CartEntity>> createCart(CartEntity cart);

  /// Update cart
  Future<Result<CartEntity>> updateCart(CartEntity cart);

  /// Delete cart
  Future<Result<void>> deleteCart(String cartId);

  /// Add item to cart
  Future<Result<CartEntity>> addItemToCart({
    required String userId,
    required CartItemEntity item,
  });

  /// Update item quantity in cart
  Future<Result<CartEntity>> updateItemQuantity({
    required String userId,
    required String productId,
    required double quantity,
  });

  /// Remove item from cart
  Future<Result<CartEntity>> removeItemFromCart({
    required String userId,
    required String productId,
  });

  /// Clear all items from cart
  Future<Result<CartEntity>> clearCart(String userId);

  /// Apply coupon to cart
  Future<Result<CartEntity>> applyCoupon({
    required String userId,
    required String couponCode,
    required double discountAmount,
  });

  /// Remove coupon from cart
  Future<Result<CartEntity>> removeCoupon(String userId);

  /// Set delivery fee
  Future<Result<CartEntity>> setDeliveryFee({
    required String userId,
    required double deliveryFee,
  });

  /// Set delivery address
  Future<Result<CartEntity>> setDeliveryAddress({
    required String userId,
    required String address,
  });

  /// Get cart item count for user
  Future<Result<int>> getCartItemCount(String userId);

  /// Get cart total for user
  Future<Result<double>> getCartTotal(String userId);

  /// Validate cart items (check availability and stock)
  Future<Result<CartValidationResult>> validateCart(String userId);

  /// Merge guest cart with user cart (for when user logs in)
  Future<Result<CartEntity>> mergeGuestCart({
    required String userId,
    required CartEntity guestCart,
  });

  /// Get abandoned carts (for marketing/recovery)
  Future<Result<List<CartEntity>>> getAbandonedCarts({
    required Duration abandonedAfter,
    int limit = 50,
  });

  /// Save cart for later (convert to wishlist or saved items)
  Future<Result<void>> saveCartForLater(String userId);
}

/// Cart validation result
class CartValidationResult {
  final bool isValid;
  final List<CartItemEntity> unavailableItems;
  final List<CartItemEntity> itemsExceedingStock;
  final List<CartItemEntity> priceChangedItems;
  final String? message;

  const CartValidationResult({
    required this.isValid,
    required this.unavailableItems,
    required this.itemsExceedingStock,
    required this.priceChangedItems,
    this.message,
  });

  /// Check if there are any issues
  bool get hasIssues => 
      unavailableItems.isNotEmpty || 
      itemsExceedingStock.isNotEmpty || 
      priceChangedItems.isNotEmpty;

  /// Get total number of issues
  int get issueCount => 
      unavailableItems.length + 
      itemsExceedingStock.length + 
      priceChangedItems.length;

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'isValid': isValid,
      'unavailableItems': unavailableItems.map((item) => item.toMap()).toList(),
      'itemsExceedingStock': itemsExceedingStock.map((item) => item.toMap()).toList(),
      'priceChangedItems': priceChangedItems.map((item) => item.toMap()).toList(),
      'message': message,
    };
  }

  /// Create from map
  factory CartValidationResult.fromMap(Map<String, dynamic> map) {
    return CartValidationResult(
      isValid: map['isValid'] ?? false,
      unavailableItems: (map['unavailableItems'] as List<dynamic>?)
          ?.map((item) => CartItemEntity.fromMap(item))
          .toList() ?? [],
      itemsExceedingStock: (map['itemsExceedingStock'] as List<dynamic>?)
          ?.map((item) => CartItemEntity.fromMap(item))
          .toList() ?? [],
      priceChangedItems: (map['priceChangedItems'] as List<dynamic>?)
          ?.map((item) => CartItemEntity.fromMap(item))
          .toList() ?? [],
      message: map['message'],
    );
  }
}
