import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';

/// Standard Result type using `Either<Failure, T>` from fpdart.
typedef Result<T> = Either<Failure, T>;

/// Result of an operation that returns Future<Either<Failure, T>>.
typedef FutureResult<T> = Future<Either<Failure, T>>;

/// Result of an operation that streams Either<Failure, T>.
typedef StreamResult<T> = Stream<Either<Failure, T>>;
