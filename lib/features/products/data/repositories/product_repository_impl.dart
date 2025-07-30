import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../../../core/config/firebase_config.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/product_filter.dart';
import '../../domain/repositories/product_repository.dart';

/// Implementation of ProductRepository using Firestore
class ProductRepositoryImpl extends BaseRepositoryImpl<ProductEntity, String>
    implements ProductRepository {
  final FirestoreService _firestoreService;

  ProductRepositoryImpl(this._firestoreService);

  @override
  Future<Result<List<ProductEntity>>> getAll() async {
    return handleAsyncOperation(() async {
      final result = await _firestoreService.getDocuments(
        collection: FirebaseCollections.products,
      );

      if (result.isSuccess) {
        final products = result.data!
            .map((doc) => ProductEntity.fromMap(doc))
            .toList();
        return products;
      } else {
        throw Exception(result.failure?.message ?? 'Failed to get products');
      }
    });
  }

  @override
  Future<Result<ProductEntity>> getById(String id) async {
    return handleAsyncOperation(() async {
      final result = await _firestoreService.getDocument(
        collection: FirebaseCollections.products,
        documentId: id,
      );

      if (result.isSuccess && result.data != null) {
        return ProductEntity.fromMap(result.data!);
      } else {
        throw Exception(result.failure?.message ?? 'Product not found');
      }
    });
  }

  @override
  Future<Result<ProductEntity>> create(ProductEntity item) async {
    return handleAsyncOperation(() async {
      final result = await _firestoreService.createDocument(
        collection: FirebaseCollections.products,
        data: item.toMap(),
        documentId: item.id,
      );

      if (result.isSuccess) {
        return item;
      } else {
        throw Exception(result.failure?.message ?? 'Failed to create product');
      }
    });
  }

  @override
  Future<Result<ProductEntity>> update(String id, ProductEntity item) async {
    return handleAsyncOperation(() async {
      final updatedItem = item.copyWith(id: id, updatedAt: DateTime.now());

      final result = await _firestoreService.updateDocument(
        collection: FirebaseCollections.products,
        documentId: id,
        data: updatedItem.toMap(),
      );

      if (result.isSuccess) {
        return updatedItem;
      } else {
        throw Exception(result.failure?.message ?? 'Failed to update product');
      }
    });
  }

  @override
  Future<Result<void>> delete(String id) async {
    return handleAsyncOperation(() async {
      final result = await _firestoreService.deleteDocument(
        collection: FirebaseCollections.products,
        documentId: id,
      );

      if (result.isFailure) {
        throw Exception(result.failure?.message ?? 'Failed to delete product');
      }
    });
  }

  @override
  Future<Result<PaginatedResult<ProductEntity>>> getProducts({
    ProductFilter? filter,
    int page = 1,
    int limit = 20,
  }) async {
    return handleAsyncOperation(() async {
      Query query = FirebaseFirestore.instance.collection(
        FirebaseCollections.products,
      );

      // Apply filters
      if (filter != null) {
        query = _applyFilters(query, filter);
      }

      // Apply sorting
      if (filter?.sortBy != null) {
        query = _applySorting(query, filter!.sortBy, filter.sortOrder);
      }

      // Apply pagination
      query = query.limit(limit);
      // Note: Firestore doesn't support offset, so we'll use cursor-based pagination
      // For now, we'll just limit the results

      final querySnapshot = await query.get();
      final products = querySnapshot.docs
          .map(
            (doc) => ProductEntity.fromMap({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();

      // Get total count for pagination
      final totalCountQuery = FirebaseFirestore.instance.collection(
        FirebaseCollections.products,
      );
      final totalSnapshot =
          await (filter != null
                  ? _applyFilters(totalCountQuery, filter)
                  : totalCountQuery)
              .count()
              .get();
      final totalItems = totalSnapshot.count ?? 0;

      final totalPages = (totalItems / limit).ceil();

      return PaginatedResult<ProductEntity>(
        items: products,
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
  Future<Result<List<ProductEntity>>> searchProducts({
    required String query,
    int limit = 20,
  }) async {
    return handleAsyncOperation(() async {
      // Firestore doesn't support full-text search, so we'll use array-contains
      // for tags and where clauses for name matching
      final results = <ProductEntity>[];

      // Search by name (case-insensitive)
      final nameQuery = FirebaseFirestore.instance
          .collection(FirebaseCollections.products)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '${query}z')
          .limit(limit);

      final nameSnapshot = await nameQuery.get();
      results.addAll(
        nameSnapshot.docs.map(
          (doc) => ProductEntity.fromMap({'id': doc.id, ...doc.data()}),
        ),
      );

      // Search by tags
      final tagQuery = FirebaseFirestore.instance
          .collection(FirebaseCollections.products)
          .where('tags', arrayContains: query.toLowerCase())
          .limit(limit);

      final tagSnapshot = await tagQuery.get();
      final tagResults = tagSnapshot.docs.map(
        (doc) => ProductEntity.fromMap({'id': doc.id, ...doc.data()}),
      );

      // Merge results and remove duplicates
      for (final product in tagResults) {
        if (!results.any((p) => p.id == product.id)) {
          results.add(product);
        }
      }

      return results.take(limit).toList();
    });
  }

  @override
  Future<Result<List<ProductEntity>>> getFeaturedProducts({
    int limit = 10,
  }) async {
    return handleAsyncOperation(() async {
      final query = FirebaseFirestore.instance
          .collection(FirebaseCollections.products)
          .where('isFeatured', isEqualTo: true)
          .where('isAvailable', isEqualTo: true)
          .orderBy('rating', descending: true)
          .limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ProductEntity.fromMap({'id': doc.id, ...doc.data()}))
          .toList();
    });
  }

  @override
  Future<Result<List<ProductEntity>>> getFreshProducts({int limit = 10}) async {
    return handleAsyncOperation(() async {
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));

      final query = FirebaseFirestore.instance
          .collection(FirebaseCollections.products)
          .where('isAvailable', isEqualTo: true)
          .where(
            'harvestDate',
            isGreaterThanOrEqualTo: threeDaysAgo.toIso8601String(),
          )
          .orderBy('harvestDate', descending: true)
          .limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ProductEntity.fromMap({'id': doc.id, ...doc.data()}))
          .toList();
    });
  }

  @override
  Future<Result<PaginatedResult<ProductEntity>>> getProductsByCategory({
    required String categoryId,
    ProductFilter? filter,
    int page = 1,
    int limit = 20,
  }) async {
    return handleAsyncOperation(() async {
      Query query = FirebaseFirestore.instance
          .collection(FirebaseCollections.products)
          .where('categoryId', isEqualTo: categoryId);

      // Apply additional filters
      if (filter != null) {
        query = _applyFilters(query, filter);
      }

      // Apply sorting
      if (filter?.sortBy != null) {
        query = _applySorting(query, filter!.sortBy, filter.sortOrder);
      }

      // Apply pagination
      query = query.limit(limit);
      // Note: Firestore doesn't support offset, so we'll use cursor-based pagination
      // For now, we'll just limit the results

      final querySnapshot = await query.get();
      final products = querySnapshot.docs
          .map(
            (doc) => ProductEntity.fromMap({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();

      // Get total count
      final totalCountQuery = FirebaseFirestore.instance
          .collection(FirebaseCollections.products)
          .where('categoryId', isEqualTo: categoryId);
      final totalSnapshot =
          await (filter != null
                  ? _applyFilters(totalCountQuery, filter)
                  : totalCountQuery)
              .count()
              .get();
      final totalItems = totalSnapshot.count ?? 0;

      final totalPages = (totalItems / limit).ceil();

      return PaginatedResult<ProductEntity>(
        items: products,
        currentPage: page,
        totalPages: totalPages,
        totalItems: totalItems,
        itemsPerPage: limit,
        hasNextPage: page < totalPages,
        hasPreviousPage: page > 1,
      );
    });
  }

  /// Apply filters to Firestore query
  Query _applyFilters(Query query, ProductFilter filter) {
    if (filter.isAvailable != null) {
      query = query.where('isAvailable', isEqualTo: filter.isAvailable);
    }

    if (filter.isOrganic != null) {
      query = query.where('isOrganic', isEqualTo: filter.isOrganic);
    }

    if (filter.isFeatured != null) {
      query = query.where('isFeatured', isEqualTo: filter.isFeatured);
    }

    if (filter.minPrice != null) {
      query = query.where('price', isGreaterThanOrEqualTo: filter.minPrice);
    }

    if (filter.maxPrice != null) {
      query = query.where('price', isLessThanOrEqualTo: filter.maxPrice);
    }

    if (filter.categoryIds.isNotEmpty) {
      query = query.where('categoryId', whereIn: filter.categoryIds);
    }

    if (filter.farmerIds.isNotEmpty) {
      query = query.where('farmerId', whereIn: filter.farmerIds);
    }

    return query;
  }

  /// Apply sorting to Firestore query
  Query _applySorting(
    Query query,
    ProductSortBy sortBy,
    ProductSortOrder sortOrder,
  ) {
    final descending = sortOrder == ProductSortOrder.descending;

    switch (sortBy) {
      case ProductSortBy.name:
        return query.orderBy('name', descending: descending);
      case ProductSortBy.price:
        return query.orderBy('price', descending: descending);
      case ProductSortBy.rating:
        return query.orderBy('rating', descending: descending);
      case ProductSortBy.harvestDate:
        return query.orderBy('harvestDate', descending: descending);
      case ProductSortBy.createdAt:
        return query.orderBy('createdAt', descending: descending);
      case ProductSortBy.popularity:
        return query.orderBy('reviewCount', descending: descending);
      case ProductSortBy.distance:
        // Distance sorting would require additional logic with location
        return query.orderBy('createdAt', descending: descending);
    }
  }

  // Implement remaining methods with basic implementations
  @override
  Future<Result<PaginatedResult<ProductEntity>>> getProductsByFarmer({
    required String farmerId,
    ProductFilter? filter,
    int page = 1,
    int limit = 20,
  }) async {
    // Similar implementation to getProductsByCategory but filter by farmerId
    return getProducts(
      filter:
          filter?.copyWith(farmerIds: [farmerId]) ??
          ProductFilter(farmerIds: [farmerId]),
      page: page,
      limit: limit,
    );
  }

  @override
  Future<Result<List<ProductEntity>>> getRelatedProducts({
    required String productId,
    int limit = 10,
  }) async {
    // Basic implementation - get products from same category
    final productResult = await getById(productId);
    if (productResult.isFailure) return Result.failure(productResult.failure!);

    final product = productResult.data!;
    return getProducts(
      filter: ProductFilter(
        categoryIds: [product.categoryId],
        isAvailable: true,
      ),
      limit: limit + 1, // Get one extra to exclude the current product
    ).then((result) {
      if (result.isSuccess) {
        final relatedProducts = result.data!.items
            .where((p) => p.id != productId)
            .take(limit)
            .toList();
        return Result.success(relatedProducts);
      }
      return Result.failure(result.failure!);
    });
  }

  // Add placeholder implementations for remaining methods
  @override
  Future<Result<List<ProductEntity>>> getProductsByLocation({
    required double latitude,
    required double longitude,
    required double radiusKm,
    ProductFilter? filter,
    int limit = 20,
  }) async {
    // TODO: Implement geolocation-based search
    return getProducts(filter: filter, limit: limit).then(
      (result) => result.isSuccess
          ? Result.success(result.data!.items)
          : Result.failure(result.failure!),
    );
  }

  @override
  Future<Result<List<ProductEntity>>> getDiscountedProducts({
    int limit = 20,
  }) async {
    return handleAsyncOperation(() async {
      final query = FirebaseFirestore.instance
          .collection(FirebaseCollections.products)
          .where('discountPrice', isNotEqualTo: null)
          .where('isAvailable', isEqualTo: true)
          .orderBy('discountPrice')
          .limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ProductEntity.fromMap({'id': doc.id, ...doc.data()}))
          .toList();
    });
  }

  @override
  Future<Result<List<ProductEntity>>> getOrganicProducts({
    int limit = 20,
  }) async {
    return getProducts(filter: ProductFilter.organic(), limit: limit).then(
      (result) => result.isSuccess
          ? Result.success(result.data!.items)
          : Result.failure(result.failure!),
    );
  }

  @override
  Future<Result<List<ProductEntity>>> getExpiringSoonProducts({
    int limit = 20,
  }) async {
    return handleAsyncOperation(() async {
      final twoDaysFromNow = DateTime.now().add(const Duration(days: 2));

      final query = FirebaseFirestore.instance
          .collection(FirebaseCollections.products)
          .where('isAvailable', isEqualTo: true)
          .where(
            'expiryDate',
            isLessThanOrEqualTo: twoDaysFromNow.toIso8601String(),
          )
          .where('expiryDate', isGreaterThan: DateTime.now().toIso8601String())
          .orderBy('expiryDate')
          .limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ProductEntity.fromMap({'id': doc.id, ...doc.data()}))
          .toList();
    });
  }

  @override
  Future<Result<void>> updateProductRating({
    required String productId,
    required double newRating,
    required int newReviewCount,
  }) async {
    return handleAsyncOperation(() async {
      final result = await _firestoreService.updateDocument(
        collection: FirebaseCollections.products,
        documentId: productId,
        data: {
          'rating': newRating,
          'reviewCount': newReviewCount,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      if (result.isFailure) {
        throw Exception(
          result.failure?.message ?? 'Failed to update product rating',
        );
      }
    });
  }

  @override
  Future<Result<void>> updateProductQuantity({
    required String productId,
    required double newQuantity,
  }) async {
    return handleAsyncOperation(() async {
      final result = await _firestoreService.updateDocument(
        collection: FirebaseCollections.products,
        documentId: productId,
        data: {
          'quantity': newQuantity,
          'isAvailable': newQuantity > 0,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      if (result.isFailure) {
        throw Exception(
          result.failure?.message ?? 'Failed to update product quantity',
        );
      }
    });
  }

  @override
  Future<Result<void>> updateProductAvailability({
    required String productId,
    required bool isAvailable,
  }) async {
    return handleAsyncOperation(() async {
      final result = await _firestoreService.updateDocument(
        collection: FirebaseCollections.products,
        documentId: productId,
        data: {
          'isAvailable': isAvailable,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      if (result.isFailure) {
        throw Exception(
          result.failure?.message ?? 'Failed to update product availability',
        );
      }
    });
  }

  @override
  Future<Result<ProductStatistics>> getProductStatistics() async {
    return handleAsyncOperation(() async {
      // This would require multiple queries to get statistics
      // For now, return basic statistics
      final allProductsResult = await getAll();
      if (allProductsResult.isFailure) {
        throw Exception('Failed to get product statistics');
      }

      final products = allProductsResult.data!;
      final totalProducts = products.length;
      final availableProducts = products.where((p) => p.isAvailable).length;
      final featuredProducts = products.where((p) => p.isFeatured).length;
      final organicProducts = products.where((p) => p.isOrganic).length;

      final averagePrice = products.isNotEmpty
          ? products.map((p) => p.price).reduce((a, b) => a + b) /
                products.length
          : 0.0;

      final averageRating = products.isNotEmpty
          ? products.map((p) => p.rating).reduce((a, b) => a + b) /
                products.length
          : 0.0;

      return ProductStatistics(
        totalProducts: totalProducts,
        availableProducts: availableProducts,
        featuredProducts: featuredProducts,
        organicProducts: organicProducts,
        averagePrice: averagePrice,
        averageRating: averageRating,
        productsByCategory: {},
        productsByLocation: {},
      );
    });
  }

  @override
  Future<Result<List<ProductEntity>>> getTrendingProducts({
    int limit = 10,
  }) async {
    return getProducts(
      filter: const ProductFilter(
        isAvailable: true,
        sortBy: ProductSortBy.popularity,
        sortOrder: ProductSortOrder.descending,
      ),
      limit: limit,
    ).then(
      (result) => result.isSuccess
          ? Result.success(result.data!.items)
          : Result.failure(result.failure!),
    );
  }

  @override
  Future<Result<List<ProductEntity>>> getRecentlyAddedProducts({
    int limit = 10,
  }) async {
    return getProducts(
      filter: const ProductFilter(
        isAvailable: true,
        sortBy: ProductSortBy.createdAt,
        sortOrder: ProductSortOrder.descending,
      ),
      limit: limit,
    ).then(
      (result) => result.isSuccess
          ? Result.success(result.data!.items)
          : Result.failure(result.failure!),
    );
  }

  @override
  Future<Result<List<ProductEntity>>> getProductsByPriceRange({
    required double minPrice,
    required double maxPrice,
    int limit = 20,
  }) async {
    return getProducts(
      filter: ProductFilter.priceRange(minPrice: minPrice, maxPrice: maxPrice),
      limit: limit,
    ).then(
      (result) => result.isSuccess
          ? Result.success(result.data!.items)
          : Result.failure(result.failure!),
    );
  }

  @override
  Future<Result<List<ProductEntity>>> getProductsByTags({
    required List<String> tags,
    int limit = 20,
  }) async {
    return getProducts(
      filter: ProductFilter(tags: tags, isAvailable: true),
      limit: limit,
    ).then(
      (result) => result.isSuccess
          ? Result.success(result.data!.items)
          : Result.failure(result.failure!),
    );
  }

  @override
  Future<Result<void>> bulkUpdateProducts({
    required List<ProductEntity> products,
  }) async {
    return handleAsyncOperation(() async {
      // For now, update products one by one
      // In a real implementation, you would use Firestore batch operations
      for (final product in products) {
        final result = await _firestoreService.updateDocument(
          collection: FirebaseCollections.products,
          documentId: product.id,
          data: product.toMap(),
        );
        if (result.isFailure) {
          throw Exception(
            result.failure?.message ?? 'Failed to bulk update products',
          );
        }
      }
    });
  }

  @override
  Future<Result<List<ProductEntity>>> getProductSuggestions({
    required String userId,
    int limit = 10,
  }) async {
    // Basic implementation - return featured products
    // In a real app, this would use user preferences and purchase history
    return getFeaturedProducts(limit: limit);
  }
}
