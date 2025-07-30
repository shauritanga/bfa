/// Base class for all exceptions in the application
abstract class AppException implements Exception {
  final String message;
  final int? code;

  const AppException({required this.message, this.code});

  @override
  String toString() => 'AppException: $message (Code: $code)';
}

/// Network-related exceptions
class NetworkException extends AppException {
  const NetworkException({required super.message, super.code});

  @override
  String toString() => 'NetworkException: $message (Code: $code)';
}

/// Server-related exceptions
class ServerException extends AppException {
  const ServerException({required super.message, super.code});

  @override
  String toString() => 'ServerException: $message (Code: $code)';
}

/// Authentication-related exceptions
class AuthException extends AppException {
  const AuthException({required super.message, super.code});

  @override
  String toString() => 'AuthException: $message (Code: $code)';
}

/// Validation-related exceptions
class ValidationException extends AppException {
  const ValidationException({required super.message, super.code});

  @override
  String toString() => 'ValidationException: $message (Code: $code)';
}

/// Cache-related exceptions
class CacheException extends AppException {
  const CacheException({required super.message, super.code});

  @override
  String toString() => 'CacheException: $message (Code: $code)';
}

/// Permission-related exceptions
class PermissionException extends AppException {
  const PermissionException({required super.message, super.code});

  @override
  String toString() => 'PermissionException: $message (Code: $code)';
}

/// Payment-related exceptions
class PaymentException extends AppException {
  const PaymentException({required super.message, super.code});

  @override
  String toString() => 'PaymentException: $message (Code: $code)';
}

/// Firebase-related exceptions
class CustomFirebaseException extends AppException {
  const CustomFirebaseException({required super.message, super.code});

  @override
  String toString() => 'CustomFirebaseException: $message (Code: $code)';
}

/// File operation exceptions
class FileException extends AppException {
  const FileException({required super.message, super.code});

  @override
  String toString() => 'FileException: $message (Code: $code)';
}

/// Location-related exceptions
class LocationException extends AppException {
  const LocationException({required super.message, super.code});

  @override
  String toString() => 'LocationException: $message (Code: $code)';
}

/// Timeout exceptions
class TimeoutException extends AppException {
  const TimeoutException({required super.message, super.code});

  @override
  String toString() => 'TimeoutException: $message (Code: $code)';
}

/// Format exceptions
class FormatException extends AppException {
  const FormatException({required super.message, super.code});

  @override
  String toString() => 'FormatException: $message (Code: $code)';
}
