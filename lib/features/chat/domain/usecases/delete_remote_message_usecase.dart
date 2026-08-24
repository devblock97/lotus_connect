import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chat/domain/repositories/private_chat_repository.dart';

class DeleteRemoteMessageParam extends Equatable {
  const DeleteRemoteMessageParam({required this.messageId});

  final String messageId;

  @override
  List<Object?> get props => [messageId];
}

class DeleteRemoteMessageUseCase
    implements UseCase<void, DeleteRemoteMessageParam> {
  const DeleteRemoteMessageUseCase({required PrivateChatRepository repository})
      : _repository = repository;

  final PrivateChatRepository _repository;

  @override
  FutureResult<void> call(DeleteRemoteMessageParam params) async {
    return _repository.deleteMessage(params.messageId);
  }
}
