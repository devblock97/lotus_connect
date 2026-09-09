import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chat/domain/repositories/private_chat_repository.dart';
import 'package:lotus_connect/features/chat_core/domain/repositories/chat_core_repository.dart';

class UpdateMessageParam {
  const UpdateMessageParam({required this.messageId, required this.content});

  final String messageId;
  final String content;
}

class UpdateMessageUseCase extends UseCase<void, UpdateMessageParam> {
  UpdateMessageUseCase({
    required ChatCoreRepository chatCoreRepository,
    required PrivateChatRepository privateChatRepository,
  })  : _chatCoreRepository = chatCoreRepository,
        _privateChatRepository = privateChatRepository;

  final ChatCoreRepository _chatCoreRepository;
  final PrivateChatRepository _privateChatRepository;

  @override
  FutureResult<void> call(UpdateMessageParam params) async {
    return _privateChatRepository.updateMessage(
      messageId: params.messageId,
      content: params.content,
    );
  }
}
