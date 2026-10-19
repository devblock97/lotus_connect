import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_stream.dart';
import 'package:lotus_connect/features/livestream/domain/repositories/livestream_repository.dart';

/// Parameters for starting a live stream.
class StartStreamParam extends Equatable {
  const StartStreamParam({required this.streamId});

  final String streamId;

  @override
  List<Object?> get props => [streamId];
}

typedef StartStreamParams = StartStreamParam;

/// Use case responsible for transitioning a stream to active/live broadcasting status.
class StartStreamUseCase implements UseCase<LiveStream, StartStreamParam> {
  const StartStreamUseCase(this._repository);

  final LiveStreamRepository _repository;

  @override
  FutureResult<LiveStream> call(StartStreamParam params) async {
    final trimmedStreamId = params.streamId.trim();
    if (trimmedStreamId.isEmpty) {
      return const Left(ValidationFailure('Stream ID cannot be empty'));
    }

    return _repository.startStream(trimmedStreamId);
  }
}
