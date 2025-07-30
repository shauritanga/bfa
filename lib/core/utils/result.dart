import '../errors/failures.dart';

/// A generic result type for handling success and failure states
sealed class Result<T> {
  const Result();

  /// Create a success result
  const factory Result.success(T data) = Success<T>;

  /// Create a failure result
  const factory Result.failure(Failure failure) = ResultFailure<T>;

  /// Check if the result is a success
  bool get isSuccess => this is Success<T>;

  /// Check if the result is a failure
  bool get isFailure => this is ResultFailure<T>;

  /// Get the data if success, null otherwise
  T? get data => switch (this) {
    Success<T>(data: final data) => data,
    ResultFailure<T>() => null,
  };

  /// Get the failure if failure, null otherwise
  Failure? get failure => switch (this) {
    Success<T>() => null,
    ResultFailure<T>(failure: final failure) => failure,
  };

  /// Transform the success data
  Result<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success<T>(data: final data) => Result.success(transform(data)),
      ResultFailure<T>(failure: final failure) => Result.failure(failure),
    };
  }

  /// Transform the failure
  Result<T> mapFailure(Failure Function(Failure failure) transform) {
    return switch (this) {
      Success<T>(data: final data) => Result.success(data),
      ResultFailure<T>(failure: final failure) => Result.failure(
        transform(failure),
      ),
    };
  }

  /// Execute a function if success
  Result<T> onSuccess(void Function(T data) action) {
    if (this is Success<T>) {
      action((this as Success<T>).data);
    }
    return this;
  }

  /// Execute a function if failure
  Result<T> onFailure(void Function(Failure failure) action) {
    if (this is ResultFailure<T>) {
      action((this as ResultFailure<T>).failure);
    }
    return this;
  }

  /// Fold the result into a single value
  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T data) onSuccess,
  ) {
    return switch (this) {
      Success<T>(data: final data) => onSuccess(data),
      ResultFailure<T>(failure: final failure) => onFailure(failure),
    };
  }

  /// Chain multiple operations that return Result
  Result<R> flatMap<R>(Result<R> Function(T data) transform) {
    return switch (this) {
      Success<T>(data: final data) => transform(data),
      ResultFailure<T>(failure: final failure) => Result.failure(failure),
    };
  }

  /// Provide a default value if failure
  T getOrElse(T defaultValue) {
    return switch (this) {
      Success<T>(data: final data) => data,
      ResultFailure<T>() => defaultValue,
    };
  }

  /// Get data or throw the failure
  T getOrThrow() {
    return switch (this) {
      Success<T>(data: final data) => data,
      ResultFailure<T>(failure: final failure) => throw Exception(
        failure.message,
      ),
    };
  }
}

/// Success result containing data
final class Success<T> extends Result<T> {
  @override
  final T data;

  const Success(this.data);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Success<T> && other.data == data);
  }

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Success(data: $data)';
}

/// Failure result containing error information
final class ResultFailure<T> extends Result<T> {
  @override
  final Failure failure;

  const ResultFailure(this.failure);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ResultFailure<T> && other.failure == failure);
  }

  @override
  int get hashCode => failure.hashCode;

  @override
  String toString() => 'ResultFailure(failure: $failure)';
}

/// Extension methods for Future<Result<T>>
extension FutureResultExtension<T> on Future<Result<T>> {
  /// Transform the success data asynchronously
  Future<Result<R>> mapAsync<R>(Future<R> Function(T data) transform) async {
    final result = await this;
    return switch (result) {
      Success<T>(data: final data) => Result.success(await transform(data)),
      ResultFailure<T>(failure: final failure) => Result.failure(failure),
    };
  }

  /// Chain multiple async operations that return Result
  Future<Result<R>> flatMapAsync<R>(
    Future<Result<R>> Function(T data) transform,
  ) async {
    final result = await this;
    return switch (result) {
      Success<T>(data: final data) => await transform(data),
      ResultFailure<T>(failure: final failure) => Result.failure(failure),
    };
  }

  /// Execute an async function if success
  Future<Result<T>> onSuccessAsync(Future<void> Function(T data) action) async {
    final result = await this;
    if (result is Success<T>) {
      await action(result.data);
    }
    return result;
  }

  /// Execute an async function if failure
  Future<Result<T>> onFailureAsync(
    Future<void> Function(Failure failure) action,
  ) async {
    final result = await this;
    if (result is ResultFailure<T>) {
      await action(result.failure);
    }
    return result;
  }
}

/// Utility functions for working with multiple Results
class ResultUtils {
  ResultUtils._();

  /// Combine multiple Results into a single Result containing a list
  static Result<List<T>> combine<T>(List<Result<T>> results) {
    final List<T> successData = [];

    for (final result in results) {
      switch (result) {
        case Success<T>(data: final data):
          successData.add(data);
        case ResultFailure<T>(failure: final failure):
          return Result.failure(failure);
      }
    }

    return Result.success(successData);
  }

  /// Get all successful results, ignoring failures
  static List<T> collectSuccesses<T>(List<Result<T>> results) {
    return results
        .where((result) => result.isSuccess)
        .map((result) => result.data!)
        .toList();
  }

  /// Get all failures, ignoring successes
  static List<Failure> collectFailures<T>(List<Result<T>> results) {
    return results
        .where((result) => result.isFailure)
        .map((result) => result.failure!)
        .toList();
  }

  /// Check if all results are successful
  static bool allSuccessful<T>(List<Result<T>> results) {
    return results.every((result) => result.isSuccess);
  }

  /// Check if any result is successful
  static bool anySuccessful<T>(List<Result<T>> results) {
    return results.any((result) => result.isSuccess);
  }
}
