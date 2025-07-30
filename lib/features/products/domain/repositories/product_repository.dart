import '../../../../core/utils/result.dart';
import '../../../../core/repositories/base_repository.dart';
import '../entities/product_entity.dart';
import '../entities/product_filter.dart';

/// Product repository interface
abstract class ProductRepository extends BaseRepository<ProductEntity, String> {
  /// Get products with filtering and pagination
  Future<Result<PaginatedResult<ProductEntity>>> getProducts({
    ProductFilter? filter,
    int page = 1,
    int limit = 20,
  });

  /// Search products by query
  Future<Result<List<ProductEntity>>> searchProducts({
    required String query,
    int limit = 20,
  });

  /// Get featured products
  Future<Result<List<ProductEntity>>> getFeaturedProducts({
    int limit = 10,
  });

  /// Get fresh products (recently harvested)
  Future<Result<List<ProductEntity>>> getFreshProducts({
    int limit = 10,
  });

  /// Get products by category
  Future<Result<PaginatedResult<ProductEntity>>> getProductsByCategory({
    required String categoryId,
    ProductFilter? filter,
    int page = 1,
    int limit = 20,
  });

  /// Get products by farmer
  Future<Result<PaginatedResult<ProductEntity>>> getProductsByFarmer({
    required String farmerId,
    ProductFilter? filter,
    int page = 1,
    int limit = 20,
  });

  /// Get related products (similar category, farmer, or tags)
  Future<Result<List<ProductEntity>>> getRelatedProducts({
    required String productId,
    int limit = 10,
  });

  /// Get products by location (nearby)
  Future<Result<List<ProductEntity>>> getProductsByLocation({
    required double latitude,
    required double longitude,
    required double radiusKm,
    ProductFilter? filter,
    int limit = 20,
  });

  /// Get products with discounts
  Future<Result<List<ProductEntity>>> getDiscountedProducts({
    int limit = 20,
  });

  /// Get organic products
  Future<Result<List<ProductEntity>>> getOrganicProducts({
    int limit = 20,
  });

  /// Get products expiring soon
  Future<Result<List<ProductEntity>>> getExpiringSoonProducts({
    int limit = 20,
  });

  /// Update product rating
  Future<Result<void>> updateProductRating({
    required String productId,
    required double newRating,
    required int newReviewCount,
  });

  /// Update product quantity
  Future<Result<void>> updateProductQuantity({
    required String productId,
    required double newQuantity,
  });

  /// Update product availability
  Future<Result<void>> updateProductAvailability({
    required String productId,
    required bool isAvailable,
  });

  /// Get product statistics
  Future<Result<ProductStatistics>> getProductStatistics();

  /// Get trending products (most viewed/purchased)
  Future<Result<List<ProductEntity>>> getTrendingProducts({
    int limit = 10,
  });

  /// Get recently added products
  Future<Result<List<ProductEntity>>> getRecentlyAddedProducts({
    int limit = 10,
  });

  /// Get products by price range
  Future<Result<List<ProductEntity>>> getProductsByPriceRange({
    required double minPrice,
    required double maxPrice,
    int limit = 20,
  });

  /// Get products by tags
  Future<Result<List<ProductEntity>>> getProductsByTags({
    required List<String> tags,
    int limit = 20,
  });

  /// Bulk update products
  Future<Result<void>> bulkUpdateProducts({
    required List<ProductEntity> products,
  });

  /// Get product suggestions based on user preferences
  Future<Result<List<ProductEntity>>> getProductSuggestions({
    required String userId,
    int limit = 10,
  });
}

/// Product statistics data class
class ProductStatistics {
  final int totalProducts;
  final int availableProducts;
  final int featuredProducts;
  final int organicProducts;
  final double averagePrice;
  final double averageRating;
  final Map<String, int> productsByCategory;
  final Map<String, int> productsByLocation;

  const ProductStatistics({
    required this.totalProducts,
    required this.availableProducts,
    required this.featuredProducts,
    required this.organicProducts,
    required this.averagePrice,
    required this.averageRating,
    required this.productsByCategory,
    required this.productsByLocation,
  });

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'totalProducts': totalProducts,
      'availableProducts': availableProducts,
      'featuredProducts': featuredProducts,
      'organicProducts': organicProducts,
      'averagePrice': averagePrice,
      'averageRating': averageRating,
      'productsByCategory': productsByCategory,
      'productsByLocation': productsByLocation,
    };
  }

  /// Create from map
  factory ProductStatistics.fromMap(Map<String, dynamic> map) {
    return ProductStatistics(
      totalProducts: map['totalProducts'] ?? 0,
      availableProducts: map['availableProducts'] ?? 0,
      featuredProducts: map['featuredProducts'] ?? 0,
      organicProducts: map['organicProducts'] ?? 0,
      averagePrice: (map['averagePrice'] ?? 0.0).toDouble(),
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      productsByCategory: Map<String, int>.from(map['productsByCategory'] ?? {}),
      productsByLocation: Map<String, int>.from(map['productsByLocation'] ?? {}),
    );
  }
}
