import 'package:flutter/foundation.dart';

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

class CacheFailure extends Failure {
  const CacheFailure(super.message, [super.cause]);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, [super.cause]);
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message, [super.cause]);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, [super.cause]);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message, [super.cause]);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.cause]);
}
