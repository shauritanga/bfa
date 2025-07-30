import 'package:equatable/equatable.dart';

/// Product filter criteria for searching and filtering products
class ProductFilter extends Equatable {
  final String? searchQuery;
  final List<String> categoryIds;
  final List<String> farmerIds;
  final double? minPrice;
  final double? maxPrice;
  final bool? isOrganic;
  final bool? isFeatured;
  final bool? isAvailable;
  final bool? isFresh;
  final List<String> tags;
  final String? location;
  final double? maxDistance; // in kilometers
  final DateTime? harvestDateFrom;
  final DateTime? harvestDateTo;
  final ProductSortBy sortBy;
  final ProductSortOrder sortOrder;

  const ProductFilter({
    this.searchQuery,
    this.categoryIds = const [],
    this.farmerIds = const [],
    this.minPrice,
    this.maxPrice,
    this.isOrganic,
    this.isFeatured,
    this.isAvailable,
    this.isFresh,
    this.tags = const [],
    this.location,
    this.maxDistance,
    this.harvestDateFrom,
    this.harvestDateTo,
    this.sortBy = ProductSortBy.name,
    this.sortOrder = ProductSortOrder.ascending,
  });

  /// Create empty filter
  factory ProductFilter.empty() {
    return const ProductFilter();
  }

  /// Create filter for featured products
  factory ProductFilter.featured() {
    return const ProductFilter(
      isFeatured: true,
      isAvailable: true,
      sortBy: ProductSortBy.rating,
      sortOrder: ProductSortOrder.descending,
    );
  }

  /// Create filter for fresh products
  factory ProductFilter.fresh() {
    return const ProductFilter(
      isFresh: true,
      isAvailable: true,
      sortBy: ProductSortBy.harvestDate,
      sortOrder: ProductSortOrder.descending,
    );
  }

  /// Create filter for organic products
  factory ProductFilter.organic() {
    return const ProductFilter(
      isOrganic: true,
      isAvailable: true,
      sortBy: ProductSortBy.name,
      sortOrder: ProductSortOrder.ascending,
    );
  }

  /// Create filter for price range
  factory ProductFilter.priceRange({
    required double minPrice,
    required double maxPrice,
  }) {
    return ProductFilter(
      minPrice: minPrice,
      maxPrice: maxPrice,
      isAvailable: true,
      sortBy: ProductSortBy.price,
      sortOrder: ProductSortOrder.ascending,
    );
  }

  /// Check if filter has any active criteria
  bool get hasActiveFilters {
    return searchQuery != null ||
        categoryIds.isNotEmpty ||
        farmerIds.isNotEmpty ||
        minPrice != null ||
        maxPrice != null ||
        isOrganic != null ||
        isFeatured != null ||
        isAvailable != null ||
        isFresh != null ||
        tags.isNotEmpty ||
        location != null ||
        maxDistance != null ||
        harvestDateFrom != null ||
        harvestDateTo != null;
  }

  /// Create a copy with updated fields
  ProductFilter copyWith({
    String? searchQuery,
    List<String>? categoryIds,
    List<String>? farmerIds,
    double? minPrice,
    double? maxPrice,
    bool? isOrganic,
    bool? isFeatured,
    bool? isAvailable,
    bool? isFresh,
    List<String>? tags,
    String? location,
    double? maxDistance,
    DateTime? harvestDateFrom,
    DateTime? harvestDateTo,
    ProductSortBy? sortBy,
    ProductSortOrder? sortOrder,
  }) {
    return ProductFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      categoryIds: categoryIds ?? this.categoryIds,
      farmerIds: farmerIds ?? this.farmerIds,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      isOrganic: isOrganic ?? this.isOrganic,
      isFeatured: isFeatured ?? this.isFeatured,
      isAvailable: isAvailable ?? this.isAvailable,
      isFresh: isFresh ?? this.isFresh,
      tags: tags ?? this.tags,
      location: location ?? this.location,
      maxDistance: maxDistance ?? this.maxDistance,
      harvestDateFrom: harvestDateFrom ?? this.harvestDateFrom,
      harvestDateTo: harvestDateTo ?? this.harvestDateTo,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  /// Clear all filters
  ProductFilter clear() {
    return ProductFilter.empty();
  }

  /// Convert to map for API/storage
  Map<String, dynamic> toMap() {
    return {
      'searchQuery': searchQuery,
      'categoryIds': categoryIds,
      'farmerIds': farmerIds,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'isOrganic': isOrganic,
      'isFeatured': isFeatured,
      'isAvailable': isAvailable,
      'isFresh': isFresh,
      'tags': tags,
      'location': location,
      'maxDistance': maxDistance,
      'harvestDateFrom': harvestDateFrom?.toIso8601String(),
      'harvestDateTo': harvestDateTo?.toIso8601String(),
      'sortBy': sortBy.name,
      'sortOrder': sortOrder.name,
    };
  }

  /// Create from map
  factory ProductFilter.fromMap(Map<String, dynamic> map) {
    return ProductFilter(
      searchQuery: map['searchQuery'],
      categoryIds: List<String>.from(map['categoryIds'] ?? []),
      farmerIds: List<String>.from(map['farmerIds'] ?? []),
      minPrice: map['minPrice']?.toDouble(),
      maxPrice: map['maxPrice']?.toDouble(),
      isOrganic: map['isOrganic'],
      isFeatured: map['isFeatured'],
      isAvailable: map['isAvailable'],
      isFresh: map['isFresh'],
      tags: List<String>.from(map['tags'] ?? []),
      location: map['location'],
      maxDistance: map['maxDistance']?.toDouble(),
      harvestDateFrom: map['harvestDateFrom'] != null
          ? DateTime.parse(map['harvestDateFrom'])
          : null,
      harvestDateTo: map['harvestDateTo'] != null
          ? DateTime.parse(map['harvestDateTo'])
          : null,
      sortBy: ProductSortBy.values.firstWhere(
        (e) => e.name == map['sortBy'],
        orElse: () => ProductSortBy.name,
      ),
      sortOrder: ProductSortOrder.values.firstWhere(
        (e) => e.name == map['sortOrder'],
        orElse: () => ProductSortOrder.ascending,
      ),
    );
  }

  @override
  List<Object?> get props => [
    searchQuery,
    categoryIds,
    farmerIds,
    minPrice,
    maxPrice,
    isOrganic,
    isFeatured,
    isAvailable,
    isFresh,
    tags,
    location,
    maxDistance,
    harvestDateFrom,
    harvestDateTo,
    sortBy,
    sortOrder,
  ];

  @override
  String toString() {
    return 'ProductFilter(searchQuery: $searchQuery, categoryIds: $categoryIds, sortBy: $sortBy)';
  }
}

/// Product sorting options
enum ProductSortBy {
  name,
  price,
  rating,
  harvestDate,
  createdAt,
  popularity,
  distance,
}

/// Sort order for products
enum ProductSortOrder { ascending, descending }

/// Extension for ProductSortBy
extension ProductSortByExtension on ProductSortBy {
  String get displayName {
    switch (this) {
      case ProductSortBy.name:
        return 'Name';
      case ProductSortBy.price:
        return 'Price';
      case ProductSortBy.rating:
        return 'Rating';
      case ProductSortBy.harvestDate:
        return 'Harvest Date';
      case ProductSortBy.createdAt:
        return 'Date Added';
      case ProductSortBy.popularity:
        return 'Popularity';
      case ProductSortBy.distance:
        return 'Distance';
    }
  }
}

/// Extension for ProductSortOrder
extension ProductSortOrderExtension on ProductSortOrder {
  String get displayName {
    switch (this) {
      case ProductSortOrder.ascending:
        return 'Ascending';
      case ProductSortOrder.descending:
        return 'Descending';
    }
  }
}
