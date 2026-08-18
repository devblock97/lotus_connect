import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/calls/domain/repositories/calls_repository.dart';

class AcceptCallParams extends Equatable {
  const AcceptCallParams({
    required this.callId,
    required this.recipientId,
  });

  final String callId;
  final String recipientId;

  @override
  List<Object?> get props => [callId];
}

class AcceptCallUseCase implements UseCase<void, AcceptCallParams> {
  const AcceptCallUseCase(this._repository);

  final CallsRepository _repository;

  @override
  FutureResult<void> call(AcceptCallParams params) {
    return _repository.acceptCall(
      callId: params.callId,
      recipientId: params.recipientId,
    );
  }
}
