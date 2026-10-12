/// Base exception for data sources and infrastructure layers.
abstract class AppException implements Exception {
  /// Constructor taking an optional message and cause.
  const AppException(this.message, [this.cause]);

  /// Informative message.
  final String message;

  /// Underlying cause.
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message';
}

/// Exception thrown when local database operations fail.
class LocalDatabaseException extends AppException {
  /// Creates a [LocalDatabaseException].
  const LocalDatabaseException(super.message, [super.cause]);
}

/// Exception thrown when network connectivity or API calls fail.
class NetworkException extends AppException {
  /// Creates a [NetworkException].
  const NetworkException(
    String message, {
    this.statusCode,
    Object? cause,
  }) : super(message, cause);

  /// HTTP status code if available.
  final int? statusCode;
}

/// Exception thrown when remote server returns error code or fails.
class ServerException extends AppException {
  /// Creates a [ServerException].
  const ServerException(super.message, [super.cause]);
}

class TimeoutException extends AppException {
  const TimeoutException(super.message, [super.cause]);
}

class AuthException extends AppException {
  const AuthException(super.message, [super.cause]);
}

class ValidationException extends AppException {
  const ValidationException(super.message, [super.cause]);
}

class NotFoundException extends AppException {
  const NotFoundException(super.message, [super.cause]);
}

class SignalingException extends AppException {
  const SignalingException(super.message, [super.cause]);
}
