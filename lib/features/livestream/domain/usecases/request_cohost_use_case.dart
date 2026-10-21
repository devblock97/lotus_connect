import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_cohost.dart';
import 'package:lotus_connect/features/livestream/domain/repositories/livestream_repository.dart';

class RequestCohostParam extends Equatable {
  const RequestCohostParam({required this.streamId});

  final String streamId;

  @override
  List<Object?> get props => [streamId];
}

class RequestCohostUseCase implements UseCase<LiveCohost, RequestCohostParam> {
  const RequestCohostUseCase(LiveStreamRepository repository)
      : _repository = repository;
  final LiveStreamRepository _repository;

  @override
  FutureResult<LiveCohost> call(RequestCohostParam params) async {
    return _repository.requestCohost(params.streamId);
  }
}
