import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/entities/response_entity_base.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chat/domain/repositories/chat_repository.dart';

class DeleteRemoteMessageParam extends Equatable {
  const DeleteRemoteMessageParam({required this.messageId});

  final String messageId;

  @override
  List<Object?> get props => [messageId];
}

class DeleteRemoteMessageUseCase
    implements UseCase<ResponseEntityBase, DeleteRemoteMessageParam> {
  const DeleteRemoteMessageUseCase({required ChatRepository repository})
      : _repository = repository;

  final ChatRepository _repository;

  @override
  FutureResult<ResponseEntityBase> call(DeleteRemoteMessageParam params) async {
    return _repository.deleteMessage(params.messageId);
  }
}
