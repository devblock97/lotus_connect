import 'package:flutter/foundation.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';

/// Base interface for asynchronous use cases returning [FutureResult].
abstract class UseCase<T, Params> {
  /// Executes the usecase with given [params].
  FutureResult<T> call(Params params);
}

/// Interface for synchronous use cases returning [Result].
abstract class SyncUseCase<T, Params> {
  /// Executes the usecase synchronously with given [params].
  Result<T> call(Params params);
}

/// Interface for streaming use cases returning [StreamResult].
abstract class StreamUseCase<T, Params> {
  /// Executes the streaming usecase with given [params].
  StreamResult<T> call(Params params);
}

/// Class used when a UseCase does not require any parameters.
@immutable
class NoParams {
  /// Creates a [NoParams] instance.
  const NoParams();

  @override
  bool operator ==(Object other) => identical(this, other) || other is NoParams;

  @override
  int get hashCode => 0;
}
