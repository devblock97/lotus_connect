import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_stream.dart';
import 'package:lotus_connect/features/livestream/domain/repositories/livestream_repository.dart';

class UpstreamParam extends Equatable {
  const UpstreamParam({
    required this.streamId,
    this.title,
    this.description,
    this.thumbnailUrl,
    this.privacy,
  });

  final String streamId;
  final String? title;
  final String? description;
  final String? thumbnailUrl;
  final String? privacy;
  @override
  List<Object?> get props => [
        streamId,
        title,
        description,
        thumbnailUrl,
        privacy,
      ];
}

class UpstreamUseCase implements UseCase<LiveStream, UpstreamParam> {
  UpstreamUseCase(LiveStreamRepository repository) : _repository = repository;
  final LiveStreamRepository _repository;

  @override
  FutureResult<LiveStream> call(UpstreamParam params) async {
    return _repository.updateStream(
      params.streamId,
      title: params.title,
      description: params.description,
      thumbnailUrl: params.thumbnailUrl,
      privacy: params.privacy,
    );
  }
}
