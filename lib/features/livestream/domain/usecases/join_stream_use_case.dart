import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/livestream/domain/repositories/livestream_repository.dart';

class JoinStreamParam extends Equatable {
  const JoinStreamParam({required this.streamId});
  final String streamId;

  @override
  List<Object?> get props => [streamId];
}

class JoinStreamUseCase implements UseCase<void, JoinStreamParam> {
  const JoinStreamUseCase(LiveStreamRepository repository)
      : _repository = repository;

  final LiveStreamRepository _repository;

  @override
  FutureResult<void> call(JoinStreamParam params) async {
    return _repository.joinStream(params.streamId);
  }
}
