import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_stream.dart';
import 'package:lotus_connect/features/livestream/domain/repositories/livestream_repository.dart';

class EndStreamParam extends Equatable {
  const EndStreamParam({required this.streamId, this.recordingUrl});

  final String streamId;
  final String? recordingUrl;

  @override
  List<Object?> get props => [
        streamId,
        recordingUrl,
      ];
}

class EndStreamUseCase implements UseCase<LiveStream, EndStreamParam> {
  const EndStreamUseCase(LiveStreamRepository repository)
      : _repository = repository;

  final LiveStreamRepository _repository;

  @override
  FutureResult<LiveStream> call(EndStreamParam params) async {
    return _repository.endStream(
      params.streamId,
      recordingUrl: params.recordingUrl,
    );
  }
}
