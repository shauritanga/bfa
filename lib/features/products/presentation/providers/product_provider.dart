import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/product_filter.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../data/repositories/product_repository_impl.dart';

/// Product state for managing product data and UI state
class ProductState {
  final List<ProductEntity> products;
  final List<ProductEntity> featuredProducts;
  final List<ProductEntity> freshProducts;
  final List<ProductEntity> searchResults;
  final ProductEntity? selectedProduct;
  final ProductFilter currentFilter;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool hasMoreProducts;
  final int currentPage;

  const ProductState({
    this.products = const [],
    this.featuredProducts = const [],
    this.freshProducts = const [],
    this.searchResults = const [],
    this.selectedProduct,
    this.currentFilter = const ProductFilter(),
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.hasMoreProducts = true,
    this.currentPage = 1,
  });

  ProductState copyWith({
    List<ProductEntity>? products,
    List<ProductEntity>? featuredProducts,
    List<ProductEntity>? freshProducts,
    List<ProductEntity>? searchResults,
    ProductEntity? selectedProduct,
    ProductFilter? currentFilter,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool? hasMoreProducts,
    int? currentPage,
  }) {
    return ProductState(
      products: products ?? this.products,
      featuredProducts: featuredProducts ?? this.featuredProducts,
      freshProducts: freshProducts ?? this.freshProducts,
      searchResults: searchResults ?? this.searchResults,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      currentFilter: currentFilter ?? this.currentFilter,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      hasMoreProducts: hasMoreProducts ?? this.hasMoreProducts,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// Product notifier for managing product state
class ProductNotifier extends StateNotifier<ProductState> {
  final ProductRepository _repository;
  final GetProductsUseCase _getProductsUseCase;
  final SearchProductsUseCase _searchProductsUseCase;
  final GetFeaturedProductsUseCase _getFeaturedProductsUseCase;
  final GetFreshProductsUseCase _getFreshProductsUseCase;

  ProductNotifier(
    this._repository,
    this._getProductsUseCase,
    this._searchProductsUseCase,
    this._getFeaturedProductsUseCase,
    this._getFreshProductsUseCase,
  ) : super(const ProductState()) {
    _loadInitialData();
  }

  /// Load initial data (featured and fresh products)
  Future<void> _loadInitialData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Load featured products
      final featuredResult = await _getFeaturedProductsUseCase();
      if (featuredResult.isSuccess) {
        state = state.copyWith(featuredProducts: featuredResult.data!);
      }

      // Load fresh products
      final freshResult = await _getFreshProductsUseCase();
      if (freshResult.isSuccess) {
        state = state.copyWith(freshProducts: freshResult.data!);
      }

      // Load initial products
      await loadProducts();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load initial data: $e',
      );
    }
  }

  /// Load products with current filter
  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        currentPage: 1,
        hasMoreProducts: true,
      );
    } else if (state.isLoading || state.isLoadingMore) {
      return; // Already loading
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final result = await _getProductsUseCase(
        filter: state.currentFilter,
        page: refresh ? 1 : state.currentPage,
        limit: 20,
      );

      if (result.isSuccess) {
        final paginatedResult = result.data!;
        final newProducts = refresh 
            ? paginatedResult.items
            : [...state.products, ...paginatedResult.items];

        state = state.copyWith(
          products: newProducts,
          isLoading: false,
          hasMoreProducts: paginatedResult.hasNextPage,
          currentPage: paginatedResult.currentPage,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.failure?.message ?? 'Failed to load products',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load products: $e',
      );
    }
  }

  /// Load more products (pagination)
  Future<void> loadMoreProducts() async {
    if (!state.hasMoreProducts || state.isLoadingMore || state.isLoading) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);

    try {
      final result = await _getProductsUseCase(
        filter: state.currentFilter,
        page: state.currentPage + 1,
        limit: 20,
      );

      if (result.isSuccess) {
        final paginatedResult = result.data!;
        state = state.copyWith(
          products: [...state.products, ...paginatedResult.items],
          isLoadingMore: false,
          hasMoreProducts: paginatedResult.hasNextPage,
          currentPage: paginatedResult.currentPage,
        );
      } else {
        state = state.copyWith(
          isLoadingMore: false,
          error: result.failure?.message ?? 'Failed to load more products',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: 'Failed to load more products: $e',
      );
    }
  }

  /// Search products
  Future<void> searchProducts(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(searchResults: []);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _searchProductsUseCase(query: query.trim());

      if (result.isSuccess) {
        state = state.copyWith(
          searchResults: result.data!,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.failure?.message ?? 'Search failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Search failed: $e',
      );
    }
  }

  /// Apply filter
  Future<void> applyFilter(ProductFilter filter) async {
    state = state.copyWith(
      currentFilter: filter,
      currentPage: 1,
      hasMoreProducts: true,
    );
    await loadProducts(refresh: true);
  }

  /// Clear filter
  Future<void> clearFilter() async {
    await applyFilter(ProductFilter.empty());
  }

  /// Select product
  Future<void> selectProduct(String productId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _repository.getById(productId);

      if (result.isSuccess) {
        state = state.copyWith(
          selectedProduct: result.data!,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.failure?.message ?? 'Failed to load product details',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load product details: $e',
      );
    }
  }

  /// Clear selected product
  void clearSelectedProduct() {
    state = state.copyWith(selectedProduct: null);
  }

  /// Refresh featured products
  Future<void> refreshFeaturedProducts() async {
    try {
      final result = await _getFeaturedProductsUseCase();
      if (result.isSuccess) {
        state = state.copyWith(featuredProducts: result.data!);
      }
    } catch (e) {
      // Silently fail for refresh operations
    }
  }

  /// Refresh fresh products
  Future<void> refreshFreshProducts() async {
    try {
      final result = await _getFreshProductsUseCase();
      if (result.isSuccess) {
        state = state.copyWith(freshProducts: result.data!);
      }
    } catch (e) {
      // Silently fail for refresh operations
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Firestore service provider
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService.instance;
});

/// Product repository provider
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return ProductRepositoryImpl(firestoreService);
});

/// Use case providers
final getProductsUseCaseProvider = Provider<GetProductsUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetProductsUseCase(repository);
});

final searchProductsUseCaseProvider = Provider<SearchProductsUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return SearchProductsUseCase(repository);
});

final getFeaturedProductsUseCaseProvider = Provider<GetFeaturedProductsUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetFeaturedProductsUseCase(repository);
});

final getFreshProductsUseCaseProvider = Provider<GetFreshProductsUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetFreshProductsUseCase(repository);
});

/// Product state provider
final productProvider = StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  final getProductsUseCase = ref.watch(getProductsUseCaseProvider);
  final searchProductsUseCase = ref.watch(searchProductsUseCaseProvider);
  final getFeaturedProductsUseCase = ref.watch(getFeaturedProductsUseCaseProvider);
  final getFreshProductsUseCase = ref.watch(getFreshProductsUseCaseProvider);

  return ProductNotifier(
    repository,
    getProductsUseCase,
    searchProductsUseCase,
    getFeaturedProductsUseCase,
    getFreshProductsUseCase,
  );
});

/// Convenience providers for specific data
final productsProvider = Provider<List<ProductEntity>>((ref) {
  return ref.watch(productProvider).products;
});

final featuredProductsProvider = Provider<List<ProductEntity>>((ref) {
  return ref.watch(productProvider).featuredProducts;
});

final freshProductsProvider = Provider<List<ProductEntity>>((ref) {
  return ref.watch(productProvider).freshProducts;
});

final searchResultsProvider = Provider<List<ProductEntity>>((ref) {
  return ref.watch(productProvider).searchResults;
});

final selectedProductProvider = Provider<ProductEntity?>((ref) {
  return ref.watch(productProvider).selectedProduct;
});

final productLoadingProvider = Provider<bool>((ref) {
  return ref.watch(productProvider).isLoading;
});

final productErrorProvider = Provider<String?>((ref) {
  return ref.watch(productProvider).error;
});
