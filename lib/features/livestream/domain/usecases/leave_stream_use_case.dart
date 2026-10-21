import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/livestream/domain/repositories/livestream_repository.dart';

class LeaveStreamParam extends Equatable {
  const LeaveStreamParam({required this.streamId});

  final String streamId;

  @override
  List<Object?> get props => [streamId];
}

class LeaveStreamUseCase implements UseCase<void, LeaveStreamParam> {
  const LeaveStreamUseCase(LiveStreamRepository repository)
      : _repository = repository;
  final LiveStreamRepository _repository;

  @override
  FutureResult<void> call(LeaveStreamParam params) async {
    return _repository.leaveStream(params.streamId);
  }
}
