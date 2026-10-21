import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_cohost.dart';
import 'package:lotus_connect/features/livestream/domain/repositories/livestream_repository.dart';

class ResponseCohostParam extends Equatable {
  const ResponseCohostParam({
    required this.streamId,
    required this.userId,
    required this.action,
  });

  final String streamId;
  final String userId;
  final String action;

  @override
  List<Object?> get props => [streamId, userId, action];
}

class ResponseCohostUseCase
    implements UseCase<LiveCohost, ResponseCohostParam> {
  const ResponseCohostUseCase(LiveStreamRepository repository)
      : _repository = repository;
  final LiveStreamRepository _repository;

  @override
  FutureResult<LiveCohost> call(ResponseCohostParam params) async {
    return _repository.respondCohost(
      params.streamId,
      userId: params.userId,
      action: params.action,
    );
  }
}
