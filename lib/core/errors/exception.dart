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

/// Exception thrown when AI provider encounters an error.
class AiProviderException extends AppException {
  /// Creates an [AiProviderException].
  const AiProviderException(super.message, [super.cause]);
}

/// Exception thrown when remote server returns error code or fails.
class ServerException extends AppException {
  /// Creates a [ServerException].
  const ServerException(super.message, [super.cause]);
}
