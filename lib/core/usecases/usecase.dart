import 'package:flutter/foundation.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';

/// Base interface for asynchronous use cases returning [FutureResult].
abstract class UseCase<Type, Params> {
  /// Executes the usecase with given [params].
  FutureResult<Type> call(Params params);
}

/// Interface for synchronous use cases returning [Result].
abstract class SyncUseCase<Type, Params> {
  /// Executes the usecase synchronously with given [params].
  Result<Type> call(Params params);
}

/// Interface for streaming use cases returning [StreamResult].
abstract class StreamUseCase<Type, Params> {
  /// Executes the streaming usecase with given [params].
  StreamResult<Type> call(Params params);
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
