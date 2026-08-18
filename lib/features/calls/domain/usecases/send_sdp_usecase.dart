import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/calls/domain/repositories/calls_repository.dart';

class SendSdpParam extends Equatable {
  const SendSdpParam({
    required this.recipientId,
    required this.sdpType,
    required this.sdpDescription,
  });

  final String recipientId;
  final String sdpType;
  final String sdpDescription;

  @override
  List<Object?> get props => [
        recipientId,
        sdpType,
        sdpDescription,
      ];
}

class SendSdpUseSase implements UseCase<void, SendSdpParam> {
  SendSdpUseSase({required CallsRepository repository})
      : _repository = repository;

  final CallsRepository _repository;

  @override
  FutureResult<void> call(SendSdpParam params) async {
    return _repository.sendSdp(
      recipientId: params.recipientId,
      sdpType: params.sdpType,
      sdpDescription: params.sdpDescription,
    );
  }
}
