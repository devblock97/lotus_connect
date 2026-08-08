import 'package:flutter/foundation.dart';

/// Base Failure class for Clean Architecture domain error handling.
@immutable
abstract class Failure {
  /// Constructor taking an optional human-readable message and error cause.
  const Failure(this.message, [this.cause]);

  /// Error message explaining the failure.
  final String message;

  /// Underlying error cause or stack trace reference.
  final Object? cause;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          cause == other.cause;

  @override
  int get hashCode => message.hashCode ^ cause.hashCode;

  @override
  String toString() => '$runtimeType: $message';
}

/// Represents network connectivity or HTTP protocol failures.
class NetworkFailure extends Failure {
  /// Creates a [NetworkFailure].
  const NetworkFailure(super.message, [super.cause]);
}

/// Represents operation timeout failures.
class TimeoutFailure extends Failure {
  /// Creates a [TimeoutFailure].
  const TimeoutFailure(super.message, [super.cause]);
}

/// Represents remote API error responses (4xx, 5xx).
class ApiFailure extends Failure {
  /// Creates an [ApiFailure].
  const ApiFailure(
    String message, {
    this.statusCode,
    Object? cause,
  }) : super(message, cause);

  /// Optional HTTP status code.
  final int? statusCode;
}

/// Represents caching layer failures.
class CacheFailure extends Failure {
  /// Creates a [CacheFailure].
  const CacheFailure(super.message, [super.cause]);
}

/// Represents SQLite / Drift local database failures.
class DatabaseFailure extends Failure {
  /// Creates a [DatabaseFailure].
  const DatabaseFailure(super.message, [super.cause]);
}

/// Represents authentication or authorization failures.
class AuthenticationFailure extends Failure {
  /// Creates an [AuthenticationFailure].
  const AuthenticationFailure(super.message, [super.cause]);
}

/// Represents input validation or domain invariant failures.
class ValidationFailure extends Failure {
  /// Creates a [ValidationFailure].
  const ValidationFailure(super.message, [super.cause]);
}

/// Represents unexpected or unhandled errors.
class UnknownFailure extends Failure {
  /// Creates an [UnknownFailure].
  const UnknownFailure(super.message, [super.cause]);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.cause]);
}
