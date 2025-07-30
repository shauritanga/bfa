import '../../../../core/utils/result.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product_entity.dart';
import '../entities/product_filter.dart';
import '../repositories/product_repository.dart';

/// Use case for getting products with filtering and pagination
class GetProductsUseCase {
  final ProductRepository _repository;

  const GetProductsUseCase(this._repository);

  /// Execute the use case
  Future<Result<PaginatedResult<ProductEntity>>> call({
    ProductFilter? filter,
    int page = 1,
    int limit = 20,
  }) async {
    // Validate parameters
    if (page < 1) {
      return const Result.failure(
        ValidationFailure(message: 'Page number must be greater than 0'),
      );
    }

    if (limit < 1 || limit > 100) {
      return const Result.failure(
        ValidationFailure(message: 'Limit must be between 1 and 100'),
      );
    }

    // Apply default filter if none provided
    final effectiveFilter = filter ?? ProductFilter.empty();

    // Get products from repository
    return await _repository.getProducts(
      filter: effectiveFilter,
      page: page,
      limit: limit,
    );
  }
}

/// Use case for searching products
class SearchProductsUseCase {
  final ProductRepository _repository;

  const SearchProductsUseCase(this._repository);

  /// Execute the use case
  Future<Result<List<ProductEntity>>> call({
    required String query,
    int limit = 20,
  }) async {
    // Validate parameters
    if (query.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Search query cannot be empty'),
      );
    }

    if (query.trim().length < 2) {
      return const Result.failure(
        ValidationFailure(
          message: 'Search query must be at least 2 characters',
        ),
      );
    }

    if (limit < 1 || limit > 100) {
      return const Result.failure(
        ValidationFailure(message: 'Limit must be between 1 and 100'),
      );
    }

    // Search products
    return await _repository.searchProducts(query: query.trim(), limit: limit);
  }
}

/// Use case for getting featured products
class GetFeaturedProductsUseCase {
  final ProductRepository _repository;

  const GetFeaturedProductsUseCase(this._repository);

  /// Execute the use case
  Future<Result<List<ProductEntity>>> call({int limit = 10}) async {
    // Validate parameters
    if (limit < 1 || limit > 50) {
      return const Result.failure(
        ValidationFailure(message: 'Limit must be between 1 and 50'),
      );
    }

    return await _repository.getFeaturedProducts(limit: limit);
  }
}

/// Use case for getting fresh products
class GetFreshProductsUseCase {
  final ProductRepository _repository;

  const GetFreshProductsUseCase(this._repository);

  /// Execute the use case
  Future<Result<List<ProductEntity>>> call({int limit = 10}) async {
    // Validate parameters
    if (limit < 1 || limit > 50) {
      return const Result.failure(
        ValidationFailure(message: 'Limit must be between 1 and 50'),
      );
    }

    return await _repository.getFreshProducts(limit: limit);
  }
}

/// Use case for getting products by category
class GetProductsByCategoryUseCase {
  final ProductRepository _repository;

  const GetProductsByCategoryUseCase(this._repository);

  /// Execute the use case
  Future<Result<PaginatedResult<ProductEntity>>> call({
    required String categoryId,
    ProductFilter? filter,
    int page = 1,
    int limit = 20,
  }) async {
    // Validate parameters
    if (categoryId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Category ID cannot be empty'),
      );
    }

    if (page < 1) {
      return const Result.failure(
        ValidationFailure(message: 'Page number must be greater than 0'),
      );
    }

    if (limit < 1 || limit > 100) {
      return const Result.failure(
        ValidationFailure(message: 'Limit must be between 1 and 100'),
      );
    }

    return await _repository.getProductsByCategory(
      categoryId: categoryId.trim(),
      filter: filter,
      page: page,
      limit: limit,
    );
  }
}

/// Use case for getting products by farmer
class GetProductsByFarmerUseCase {
  final ProductRepository _repository;

  const GetProductsByFarmerUseCase(this._repository);

  /// Execute the use case
  Future<Result<PaginatedResult<ProductEntity>>> call({
    required String farmerId,
    ProductFilter? filter,
    int page = 1,
    int limit = 20,
  }) async {
    // Validate parameters
    if (farmerId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Farmer ID cannot be empty'),
      );
    }

    if (page < 1) {
      return const Result.failure(
        ValidationFailure(message: 'Page number must be greater than 0'),
      );
    }

    if (limit < 1 || limit > 100) {
      return const Result.failure(
        ValidationFailure(message: 'Limit must be between 1 and 100'),
      );
    }

    return await _repository.getProductsByFarmer(
      farmerId: farmerId.trim(),
      filter: filter,
      page: page,
      limit: limit,
    );
  }
}

/// Use case for getting a single product by ID
class GetProductByIdUseCase {
  final ProductRepository _repository;

  const GetProductByIdUseCase(this._repository);

  /// Execute the use case
  Future<Result<ProductEntity>> call(String productId) async {
    // Validate parameters
    if (productId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Product ID cannot be empty'),
      );
    }

    return await _repository.getById(productId.trim());
  }
}

/// Use case for getting related products
class GetRelatedProductsUseCase {
  final ProductRepository _repository;

  const GetRelatedProductsUseCase(this._repository);

  /// Execute the use case
  Future<Result<List<ProductEntity>>> call({
    required String productId,
    int limit = 10,
  }) async {
    // Validate parameters
    if (productId.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Product ID cannot be empty'),
      );
    }

    if (limit < 1 || limit > 50) {
      return const Result.failure(
        ValidationFailure(message: 'Limit must be between 1 and 50'),
      );
    }

    return await _repository.getRelatedProducts(
      productId: productId.trim(),
      limit: limit,
    );
  }
}

/// Validation failure for use case parameters
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}
