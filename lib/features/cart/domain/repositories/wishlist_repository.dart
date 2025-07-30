import '../../../../core/utils/result.dart';
import '../entities/wishlist_item_entity.dart';

/// Wishlist repository interface
abstract class WishlistRepository {
  /// Get user's wishlist
  Future<Result<WishlistEntity?>> getUserWishlist(String userId);

  /// Create a new wishlist for user
  Future<Result<WishlistEntity>> createWishlist(WishlistEntity wishlist);

  /// Update wishlist
  Future<Result<WishlistEntity>> updateWishlist(WishlistEntity wishlist);

  /// Delete wishlist
  Future<Result<void>> deleteWishlist(String wishlistId);

  /// Add item to wishlist
  Future<Result<WishlistEntity>> addItemToWishlist({
    required String userId,
    required WishlistItemEntity item,
  });

  /// Remove item from wishlist
  Future<Result<WishlistEntity>> removeItemFromWishlist({
    required String userId,
    required String productId,
  });

  /// Clear all items from wishlist
  Future<Result<WishlistEntity>> clearWishlist(String userId);

  /// Check if product is in wishlist
  Future<Result<bool>> isProductInWishlist({
    required String userId,
    required String productId,
  });

  /// Get wishlist item count for user
  Future<Result<int>> getWishlistItemCount(String userId);

  /// Toggle product in wishlist (add if not present, remove if present)
  Future<Result<WishlistEntity>> toggleProductInWishlist({
    required String userId,
    required String productId,
  });

  /// Get public wishlists (for sharing/discovery)
  Future<Result<List<WishlistEntity>>> getPublicWishlists({
    int limit = 20,
    String? searchQuery,
  });

  /// Share wishlist (make public and get shareable link)
  Future<Result<String>> shareWishlist(String wishlistId);

  /// Get wishlist by share ID
  Future<Result<WishlistEntity?>> getSharedWishlist(String shareId);

  /// Update wishlist details (name, description, privacy)
  Future<Result<WishlistEntity>> updateWishlistDetails({
    required String userId,
    String? name,
    String? description,
    bool? isPublic,
  });

  /// Move items from wishlist to cart
  Future<Result<void>> moveItemsToCart({
    required String userId,
    required List<String> productIds,
  });

  /// Get wishlist statistics
  Future<Result<WishlistStatistics>> getWishlistStatistics(String userId);
}

/// Wishlist statistics
class WishlistStatistics {
  final int totalItems;
  final int availableItems;
  final int unavailableItems;
  final int discountedItems;
  final double totalValue;
  final double potentialSavings;
  final Map<String, int> itemsByCategory;

  const WishlistStatistics({
    required this.totalItems,
    required this.availableItems,
    required this.unavailableItems,
    required this.discountedItems,
    required this.totalValue,
    required this.potentialSavings,
    required this.itemsByCategory,
  });

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'totalItems': totalItems,
      'availableItems': availableItems,
      'unavailableItems': unavailableItems,
      'discountedItems': discountedItems,
      'totalValue': totalValue,
      'potentialSavings': potentialSavings,
      'itemsByCategory': itemsByCategory,
    };
  }

  /// Create from map
  factory WishlistStatistics.fromMap(Map<String, dynamic> map) {
    return WishlistStatistics(
      totalItems: map['totalItems'] ?? 0,
      availableItems: map['availableItems'] ?? 0,
      unavailableItems: map['unavailableItems'] ?? 0,
      discountedItems: map['discountedItems'] ?? 0,
      totalValue: (map['totalValue'] ?? 0.0).toDouble(),
      potentialSavings: (map['potentialSavings'] ?? 0.0).toDouble(),
      itemsByCategory: Map<String, int>.from(map['itemsByCategory'] ?? {}),
    );
  }
}
