import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_stream.dart';
import 'package:lotus_connect/features/livestream/domain/repositories/livestream_repository.dart';

class GetStreamParam extends Equatable {
  const GetStreamParam({required this.streamId});
  final String streamId;

  @override
  List<Object?> get props => [streamId];
}

class GetStreamUseCase extends UseCase<LiveStream, GetStreamParam> {
  GetStreamUseCase(LiveStreamRepository repository) : _repository = repository;
  final LiveStreamRepository _repository;

  @override
  FutureResult<LiveStream> call(GetStreamParam params) async {
    return _repository.getStream(params.streamId);
  }
}
