import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../../../core/config/firebase_config.dart';
import '../../../../core/services/firestore_service.dart';
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
      print('🔄 ProductRepository: getProducts called with filter: $filter');

      // Check if we need to filter by category
      if (filter?.categoryIds.isNotEmpty == true) {
        // Use category-specific filtering
        return _getProductsWithCategoryFilter(filter!, page, limit);
      }

      // TEMPORARY FIX: Use simple query to avoid index issues
      Query query = FirebaseFirestore.instance.collection(
        FirebaseCollections.products,
      );

      // Only apply basic available filter to avoid index issues
      if (filter?.isAvailable == true || filter == null) {
        // For now, just get all products without complex filtering
        query = query.where('isAvailable', isEqualTo: true);
      }

      // Simple sorting by creation date (no index required)
      query = query.orderBy('createdAt', descending: true);

      // Apply pagination
      query = query.limit(limit);

      print('🔄 ProductRepository: Executing Firestore query...');
      final querySnapshot = await query.get();
      print(
        '✅ ProductRepository: Query executed, got ${querySnapshot.docs.length} documents',
      );

      // Debug: Check first few products for category information
      if (querySnapshot.docs.isNotEmpty) {
        for (int i = 0; i < querySnapshot.docs.length.clamp(0, 3); i++) {
          final doc = querySnapshot.docs[i];
          final data = doc.data() as Map<String, dynamic>?;
          print(
            '🔍 ProductRepository: Product ${doc.id} data: categoryId=${data?['categoryId']}, category=${data?['category']}, name=${data?['name']}',
          );
        }
      }

      final products = querySnapshot.docs
          .map(
            (doc) => ProductEntity.fromMap({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();

      print('✅ ProductRepository: Mapped ${products.length} products');

      // Simplified total count (just use current results for now)
      final totalItems = querySnapshot.docs.length;
      final totalPages = 1; // Simplified for now

      return PaginatedResult<ProductEntity>(
        items: products,
        currentPage: page,
        totalPages: totalPages,
        totalItems: totalItems,
        itemsPerPage: limit,
        hasNextPage: false, // Simplified for now
        hasPreviousPage: page > 1,
      );
    });
  }

  /// Get products with category filter - tries multiple approaches
  Future<PaginatedResult<ProductEntity>> _getProductsWithCategoryFilter(
    ProductFilter filter,
    int page,
    int limit,
  ) async {
    print(
      '🔍 ProductRepository: _getProductsWithCategoryFilter called with categories: ${filter.categoryIds}',
    );

    // Get all available products first
    Query query = FirebaseFirestore.instance.collection(
      FirebaseCollections.products,
    );

    // Apply basic filters
    query = query.where('isAvailable', isEqualTo: true);
    query = query.orderBy('createdAt', descending: true);
    query = query.limit(100); // Get more products to filter locally

    print(
      '🔍 ProductRepository: Fetching products for local category filtering...',
    );
    final querySnapshot = await query.get();
    print(
      '🔍 ProductRepository: Got ${querySnapshot.docs.length} products to filter locally',
    );

    final allProducts = querySnapshot.docs
        .map(
          (doc) => ProductEntity.fromMap({
            'id': doc.id,
            ...doc.data() as Map<String, dynamic>,
          }),
        )
        .toList();

    // Filter products locally by category
    final filteredProducts = <ProductEntity>[];
    final targetCategories = filter.categoryIds
        .map((id) => id.toLowerCase())
        .toSet();

    for (final product in allProducts) {
      final productCategoryId = product.categoryId.toLowerCase();

      // Check if product category matches any of the target categories
      // Try exact match first, then partial matches
      bool matches = false;

      for (final targetCategory in targetCategories) {
        if (productCategoryId == targetCategory ||
            productCategoryId.contains(targetCategory) ||
            targetCategory.contains(productCategoryId)) {
          matches = true;
          break;
        }
      }

      if (matches) {
        filteredProducts.add(product);
        print(
          '🔍 ProductRepository: Product "${product.name}" matches category filter (categoryId: ${product.categoryId})',
        );
      }
    }

    print(
      '🔍 ProductRepository: Category filtering complete. Found ${filteredProducts.length} matching products',
    );

    // Apply pagination to filtered results
    final startIndex = (page - 1) * limit;
    final endIndex = (startIndex + limit).clamp(0, filteredProducts.length);
    final paginatedProducts = filteredProducts.sublist(
      startIndex.clamp(0, filteredProducts.length),
      endIndex,
    );

    return PaginatedResult<ProductEntity>(
      items: paginatedProducts,
      currentPage: page,
      totalPages: (filteredProducts.length / limit).ceil(),
      totalItems: filteredProducts.length,
      itemsPerPage: limit,
      hasNextPage: endIndex < filteredProducts.length,
      hasPreviousPage: page > 1,
    );
  }

  @override
  Future<Result<List<ProductEntity>>> searchProducts({
    required String query,
    int limit = 20,
  }) async {
    return handleAsyncOperation(() async {
      print('🔍 ProductRepository: searchProducts called with query: "$query"');

      final searchTerm = query.toLowerCase().trim();
      final results = <ProductEntity>[];
      final seenIds = <String>{};

      try {
        // Get all products first (since Firestore has limited search capabilities)
        final allProductsQuery = FirebaseFirestore.instance
            .collection(FirebaseCollections.products)
            .where('isAvailable', isEqualTo: true)
            .limit(100); // Get more products to search through

        print('🔍 ProductRepository: Fetching all available products...');
        final allProductsSnapshot = await allProductsQuery.get();
        print(
          '🔍 ProductRepository: Got ${allProductsSnapshot.docs.length} products to search through',
        );

        // Create a list to store products with their relevance scores
        final scoredResults = <Map<String, dynamic>>[];

        // Filter products locally for better search results
        for (final doc in allProductsSnapshot.docs) {
          try {
            final data = doc.data();
            final productName = (data['name'] as String? ?? '').toLowerCase();
            final productDescription = (data['description'] as String? ?? '')
                .toLowerCase();
            final productTags = (data['tags'] as List<dynamic>? ?? [])
                .map((tag) => tag.toString().toLowerCase())
                .toList();

            // Calculate relevance score
            int score = 0;

            // Exact name match gets highest score
            if (productName == searchTerm) {
              score += 100;
            }
            // Name starts with search term gets high score
            else if (productName.startsWith(searchTerm)) {
              score += 80;
            }
            // Name contains search term gets medium score
            else if (productName.contains(searchTerm)) {
              score += 60;
            }

            // Tag matches
            for (final tag in productTags) {
              if (tag == searchTerm) {
                score += 50;
              } else if (tag.contains(searchTerm)) {
                score += 30;
              }
            }

            // Description contains search term gets lower score
            if (productDescription.contains(searchTerm)) {
              score += 20;
            }

            // Only include products with some relevance
            if (score > 0 && !seenIds.contains(doc.id)) {
              final product = ProductEntity.fromMap({'id': doc.id, ...data});
              scoredResults.add({'product': product, 'score': score});
              seenIds.add(doc.id);
            }
          } catch (e) {
            print(
              '⚠️ ProductRepository: Error processing product ${doc.id}: $e',
            );
            continue;
          }
        }

        // Sort by relevance score (highest first) and take the top results
        scoredResults.sort(
          (a, b) => (b['score'] as int).compareTo(a['score'] as int),
        );
        results.addAll(
          scoredResults
              .take(limit)
              .map((item) => item['product'] as ProductEntity)
              .toList(),
        );

        print(
          '✅ ProductRepository: Search completed, found ${results.length} matching products',
        );
        return results;
      } catch (e) {
        print('❌ ProductRepository: Search error: $e');
        rethrow;
      }
    });
  }

  @override
  Future<Result<List<ProductEntity>>> getFeaturedProducts({
    int limit = 10,
  }) async {
    return handleAsyncOperation(() async {
      print('🔄 ProductRepository: getFeaturedProducts called');

      // TEMPORARY FIX: Simplified query to avoid index issues
      final query = FirebaseFirestore.instance
          .collection(FirebaseCollections.products)
          .where('isFeatured', isEqualTo: true)
          .limit(limit);

      print('🔄 ProductRepository: Executing featured products query...');
      final snapshot = await query.get();
      print(
        '✅ ProductRepository: Featured products query executed, got ${snapshot.docs.length} documents',
      );

      return snapshot.docs
          .map((doc) => ProductEntity.fromMap({'id': doc.id, ...doc.data()}))
          .toList();
    });
  }

  @override
  Future<Result<List<ProductEntity>>> getFreshProducts({int limit = 10}) async {
    return handleAsyncOperation(() async {
      print('🔄 ProductRepository: getFreshProducts called');

      // TEMPORARY FIX: Simplified query to avoid index issues
      // Just get available products ordered by creation date
      final query = FirebaseFirestore.instance
          .collection(FirebaseCollections.products)
          .where('isAvailable', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      print('🔄 ProductRepository: Executing fresh products query...');
      final snapshot = await query.get();
      print(
        '✅ ProductRepository: Fresh products query executed, got ${snapshot.docs.length} documents',
      );

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
      print(
        '🔍 ProductRepository: Filtering by categories: ${filter.categoryIds}',
      );
      // Try filtering by categoryId first, if that doesn't work, we'll filter by category field
      query = query.where('categoryId', whereIn: filter.categoryIds);
    } else {
      print(
        '🔍 ProductRepository: No category filter applied (showing all products)',
      );
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
