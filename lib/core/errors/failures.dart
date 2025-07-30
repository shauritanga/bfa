import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

/// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message, super.code});
}

/// Authentication-related failures
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});
}

/// Validation-related failures
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code});
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});
}

/// Permission-related failures
class PermissionFailure extends Failure {
  const PermissionFailure({required super.message, super.code});
}

/// Payment-related failures
class PaymentFailure extends Failure {
  const PaymentFailure({required super.message, super.code});
}

/// Firebase-related failures
class FirebaseFailure extends Failure {
  const FirebaseFailure({required super.message, super.code});
}

/// Unknown/Unexpected failures
class UnknownFailure extends Failure {
  const UnknownFailure({required super.message, super.code});
}

/// File operation failures
class FileFailure extends Failure {
  const FileFailure({required super.message, super.code});
}

/// Location-related failures
class LocationFailure extends Failure {
  const LocationFailure({required super.message, super.code});
}
