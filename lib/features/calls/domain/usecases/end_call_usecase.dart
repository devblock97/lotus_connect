import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/calls/domain/repositories/calls_repository.dart';

class EndCallParams extends Equatable {
  const EndCallParams({
    required this.callId,
    required this.recipientId,
  });

  final String callId;
  final String recipientId;

  @override
  List<Object?> get props => [callId];
}

class EndCallUseCase implements UseCase<void, EndCallParams> {
  const EndCallUseCase(this._repository);

  final CallsRepository _repository;

  @override
  FutureResult<void> call(EndCallParams params) {
    return _repository.endCall(
      callId: params.callId,
      recipientId: params.recipientId,
    );
  }
}
