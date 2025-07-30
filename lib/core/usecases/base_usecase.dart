import '../utils/result.dart';
import '../errors/failures.dart';
import '../repositories/base_repository.dart';

/// Base use case interface
abstract class UseCase<Type, Params> {
  /// Execute the use case
  Future<Result<Type>> call(Params params);
}

/// Use case with no parameters
abstract class NoParamsUseCase<Type> {
  /// Execute the use case
  Future<Result<Type>> call();
}

/// Synchronous use case
abstract class SyncUseCase<Type, Params> {
  /// Execute the use case synchronously
  Result<Type> call(Params params);
}

/// Synchronous use case with no parameters
abstract class NoParamsSyncUseCase<Type> {
  /// Execute the use case synchronously
  Result<Type> call();
}

/// Stream use case for real-time data
abstract class StreamUseCase<Type, Params> {
  /// Execute the use case and return a stream
  Stream<Result<Type>> call(Params params);
}

/// Stream use case with no parameters
abstract class NoParamsStreamUseCase<Type> {
  /// Execute the use case and return a stream
  Stream<Result<Type>> call();
}

/// No parameters class for use cases that don't need parameters
class NoParams {
  const NoParams();

  @override
  bool operator ==(Object other) => other is NoParams;

  @override
  int get hashCode => 0;
}

/// Base use case implementation with common functionality
abstract class BaseUseCase<Type, Params> implements UseCase<Type, Params> {
  /// Validate parameters before execution
  Result<void> validateParams(Params params) {
    return const Result.success(null);
  }

  /// Handle exceptions and convert to failures
  Result<Type> handleException(Exception exception) {
    if (exception is ArgumentError) {
      return Result.failure(
        ValidationFailure(
          message: 'Invalid parameters: ${exception.toString()}',
        ),
      );
    }
    return Result.failure(
      UnknownFailure(message: 'Unexpected error: ${exception.toString()}'),
    );
  }

  /// Execute with validation and error handling
  @override
  Future<Result<Type>> call(Params params) async {
    try {
      // Validate parameters
      final validation = validateParams(params);
      if (validation.isFailure) {
        return Result.failure(validation.failure!);
      }

      // Execute the use case
      return await execute(params);
    } on Exception catch (e) {
      return handleException(e);
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Unexpected error: ${e.toString()}'),
      );
    }
  }

  /// Abstract method to be implemented by concrete use cases
  Future<Result<Type>> execute(Params params);
}

/// Base use case for operations that don't need parameters
abstract class BaseNoParamsUseCase<Type> implements NoParamsUseCase<Type> {
  /// Handle exceptions and convert to failures
  Result<Type> handleException(Exception exception) {
    return Result.failure(
      UnknownFailure(message: 'Unexpected error: ${exception.toString()}'),
    );
  }

  /// Execute with error handling
  @override
  Future<Result<Type>> call() async {
    try {
      return await execute();
    } on Exception catch (e) {
      return handleException(e);
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Unexpected error: ${e.toString()}'),
      );
    }
  }

  /// Abstract method to be implemented by concrete use cases
  Future<Result<Type>> execute();
}

/// Use case for paginated operations
abstract class PaginatedUseCase<Type>
    implements UseCase<PaginatedResult<Type>, PaginationParams> {
  @override
  Future<Result<PaginatedResult<Type>>> call(PaginationParams params) async {
    try {
      // Validate pagination parameters
      if (params.page < 1) {
        return const Result.failure(
          ValidationFailure(message: 'Page number must be greater than 0'),
        );
      }

      if (params.limit < 1 || params.limit > 100) {
        return const Result.failure(
          ValidationFailure(message: 'Limit must be between 1 and 100'),
        );
      }

      return await executePaginated(params);
    } on Exception catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Unexpected error: ${e.toString()}'),
      );
    }
  }

  /// Abstract method for paginated execution
  Future<Result<PaginatedResult<Type>>> executePaginated(
    PaginationParams params,
  );
}

/// Parameters for paginated use cases
class PaginationParams {
  final int page;
  final int limit;
  final String? searchQuery;
  final Map<String, dynamic>? filters;
  final String? sortBy;
  final SortOrder sortOrder;

  const PaginationParams({
    this.page = 1,
    this.limit = 20,
    this.searchQuery,
    this.filters,
    this.sortBy,
    this.sortOrder = SortOrder.asc,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaginationParams &&
        other.page == page &&
        other.limit == limit &&
        other.searchQuery == searchQuery &&
        other.sortBy == sortBy &&
        other.sortOrder == sortOrder;
  }

  @override
  int get hashCode {
    return Object.hash(page, limit, searchQuery, sortBy, sortOrder);
  }

  @override
  String toString() {
    return 'PaginationParams(page: $page, limit: $limit, searchQuery: $searchQuery, sortBy: $sortBy, sortOrder: $sortOrder)';
  }
}

/// Use case composition utilities
class UseCaseComposer {
  /// Chain multiple use cases together
  static Future<Result<R>> chain<T, R>(
    Future<Result<T>> first,
    Future<Result<R>> Function(T) second,
  ) async {
    final firstResult = await first;
    if (firstResult.isSuccess) {
      return await second(firstResult.data as T);
    } else {
      return Result.failure(firstResult.failure!);
    }
  }

  /// Execute multiple use cases in parallel
  static Future<List<Result<T>>> parallel<T>(
    List<Future<Result<T>>> useCases,
  ) async {
    return await Future.wait(useCases);
  }

  /// Execute use cases with fallback
  static Future<Result<T>> withFallback<T>(
    Future<Result<T>> primary,
    Future<Result<T>> fallback,
  ) async {
    final primaryResult = await primary;
    if (primaryResult.isSuccess) {
      return primaryResult;
    }
    return await fallback;
  }
}

/// Use case metrics interface
abstract class UseCaseMetrics {
  /// Record use case execution time
  void recordExecutionTime(String useCaseName, Duration duration);

  /// Record use case success
  void recordSuccess(String useCaseName);

  /// Record use case failure
  void recordFailure(String useCaseName, Failure failure);

  /// Get use case statistics
  Map<String, dynamic> getStatistics();
}

/// Use case with metrics tracking
mixin UseCaseMetricsMixin<Type, Params> on UseCase<Type, Params> {
  UseCaseMetrics? get metrics;

  @override
  Future<Result<Type>> call(Params params) async {
    final stopwatch = Stopwatch()..start();
    final useCaseName = runtimeType.toString();

    try {
      final result = await execute(params);

      stopwatch.stop();
      metrics?.recordExecutionTime(useCaseName, stopwatch.elapsed);

      if (result.isSuccess) {
        metrics?.recordSuccess(useCaseName);
      } else {
        metrics?.recordFailure(useCaseName, result.failure!);
      }

      return result;
    } catch (e) {
      stopwatch.stop();
      final failure = UnknownFailure(message: e.toString());
      metrics?.recordFailure(useCaseName, failure);
      return Result.failure(failure);
    }
  }

  /// Abstract method to be implemented by concrete use cases
  Future<Result<Type>> execute(Params params);
}
