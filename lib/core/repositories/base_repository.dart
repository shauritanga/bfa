import '../utils/result.dart';
import '../errors/failures.dart';
import '../errors/exceptions.dart';

/// Base repository interface with common CRUD operations
abstract class BaseRepository<T, ID> {
  /// Get all items
  Future<Result<List<T>>> getAll();

  /// Get item by ID
  Future<Result<T>> getById(ID id);

  /// Create a new item
  Future<Result<T>> create(T item);

  /// Update an existing item
  Future<Result<T>> update(ID id, T item);

  /// Delete an item by ID
  Future<Result<void>> delete(ID id);

  /// Check if item exists
  Future<Result<bool>> exists(ID id);
}

/// Repository with pagination support
abstract class PaginatedRepository<T, ID> extends BaseRepository<T, ID> {
  /// Get items with pagination
  Future<Result<PaginatedResult<T>>> getPaginated({
    int page = 1,
    int limit = 20,
    String? searchQuery,
    Map<String, dynamic>? filters,
    String? sortBy,
    SortOrder sortOrder = SortOrder.asc,
  });

  /// Search items
  Future<Result<List<T>>> search(String query);
}

/// Repository with caching support
abstract class CachedRepository<T, ID> extends BaseRepository<T, ID> {
  /// Get item from cache first, then from remote if not found
  Future<Result<T>> getCached(ID id);

  /// Get all items from cache first, then from remote if not found
  Future<Result<List<T>>> getAllCached();

  /// Clear cache
  Future<Result<void>> clearCache();

  /// Refresh cache
  Future<Result<void>> refreshCache();
}

/// Repository with offline support
abstract class OfflineRepository<T, ID> extends BaseRepository<T, ID> {
  /// Sync local data with remote
  Future<Result<void>> sync();

  /// Get pending sync operations
  Future<Result<List<SyncOperation<T>>>> getPendingSyncOperations();

  /// Mark item for sync
  Future<Result<void>> markForSync(ID id, SyncOperationType type);
}

/// Paginated result wrapper
class PaginatedResult<T> {
  final List<T> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const PaginatedResult({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  /// Create empty paginated result
  factory PaginatedResult.empty() {
    return const PaginatedResult(
      items: [],
      currentPage: 1,
      totalPages: 0,
      totalItems: 0,
      itemsPerPage: 20,
      hasNextPage: false,
      hasPreviousPage: false,
    );
  }

  /// Create paginated result from data
  factory PaginatedResult.fromData({
    required List<T> items,
    required int currentPage,
    required int totalItems,
    required int itemsPerPage,
  }) {
    final totalPages = (totalItems / itemsPerPage).ceil();
    return PaginatedResult(
      items: items,
      currentPage: currentPage,
      totalPages: totalPages,
      totalItems: totalItems,
      itemsPerPage: itemsPerPage,
      hasNextPage: currentPage < totalPages,
      hasPreviousPage: currentPage > 1,
    );
  }

  @override
  String toString() {
    return 'PaginatedResult(items: ${items.length}, currentPage: $currentPage, totalPages: $totalPages, totalItems: $totalItems)';
  }
}

/// Sort order enum
enum SortOrder { asc, desc }

/// Sync operation for offline support
class SyncOperation<T> {
  final String id;
  final T? data;
  final SyncOperationType type;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const SyncOperation({
    required this.id,
    required this.type,
    required this.timestamp,
    this.data,
    this.metadata,
  });

  @override
  String toString() {
    return 'SyncOperation(id: $id, type: $type, timestamp: $timestamp)';
  }
}

/// Sync operation types
enum SyncOperationType { create, update, delete }

/// Repository exception handler mixin
mixin RepositoryExceptionHandler {
  /// Handle repository exceptions and convert to failures
  Result<T> handleException<T>(Exception exception) {
    if (exception is NetworkException) {
      return Result.failure(NetworkFailure(message: exception.message));
    } else if (exception is ServerException) {
      return Result.failure(ServerFailure(message: exception.message));
    } else if (exception is AuthException) {
      return Result.failure(AuthFailure(message: exception.message));
    } else if (exception is ValidationException) {
      return Result.failure(ValidationFailure(message: exception.message));
    } else if (exception is CacheException) {
      return Result.failure(CacheFailure(message: exception.message));
    } else {
      return Result.failure(UnknownFailure(message: exception.toString()));
    }
  }

  /// Handle async repository operations
  Future<Result<T>> handleAsyncOperation<T>(
    Future<T> Function() operation,
  ) async {
    try {
      final result = await operation();
      return Result.success(result);
    } on Exception catch (e) {
      return handleException<T>(e);
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }
}

/// Repository with batch operations
abstract class BatchRepository<T, ID> extends BaseRepository<T, ID> {
  /// Create multiple items
  Future<Result<List<T>>> createBatch(List<T> items);

  /// Update multiple items
  Future<Result<List<T>>> updateBatch(Map<ID, T> items);

  /// Delete multiple items
  Future<Result<void>> deleteBatch(List<ID> ids);
}

/// Repository with real-time updates
abstract class RealtimeRepository<T, ID> extends BaseRepository<T, ID> {
  /// Subscribe to real-time updates
  Stream<Result<T>> subscribeToItem(ID id);

  /// Subscribe to real-time updates for all items
  Stream<Result<List<T>>> subscribeToAll();

  /// Subscribe to real-time updates with filters
  Stream<Result<List<T>>> subscribeWithFilters(Map<String, dynamic> filters);
}

/// Repository factory interface
abstract class RepositoryFactory {
  /// Create repository instance
  T create<T extends BaseRepository>();

  /// Register repository implementation
  void register<T extends BaseRepository>(T Function() factory);
}

/// Base repository implementation with common functionality
abstract class BaseRepositoryImpl<T, ID>
    with RepositoryExceptionHandler
    implements BaseRepository<T, ID> {
  @override
  Future<Result<bool>> exists(ID id) async {
    return handleAsyncOperation(() async {
      final result = await getById(id);
      return result.isSuccess;
    });
  }
}

/// Repository with validation
mixin RepositoryValidation<T> {
  /// Validate item before operations
  Result<void> validateItem(T item);

  /// Validate ID
  Result<void> validateId(dynamic id);

  /// Validate operation parameters
  Result<void> validateParameters(Map<String, dynamic> parameters);
}

/// Repository metrics interface
abstract class RepositoryMetrics {
  /// Record operation duration
  void recordOperationDuration(String operation, Duration duration);

  /// Record operation success
  void recordOperationSuccess(String operation);

  /// Record operation failure
  void recordOperationFailure(String operation, String error);

  /// Get operation statistics
  Map<String, dynamic> getStatistics();
}
