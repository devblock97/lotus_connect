import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/calls/domain/repositories/calls_repository.dart';

class InitiateCallParams extends Equatable {
  const InitiateCallParams({
    required this.peerId,
    required this.isVideo,
    required this.channelId,
  });

  final String peerId;
  final bool isVideo;
  final String channelId;

  @override
  List<Object?> get props => [peerId, isVideo, channelId];
}

class InitiateCallUseCase implements UseCase<void, InitiateCallParams> {
  const InitiateCallUseCase(this._repository);

  final CallsRepository _repository;

  @override
  FutureResult<void> call(InitiateCallParams params) {
    return _repository.initiateCall(
      peerId: params.peerId,
      channelId: params.channelId,
      isVideo: params.isVideo,
    );
  }
}
