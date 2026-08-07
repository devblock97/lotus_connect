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
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );

    if (!uuidRegex.hasMatch(params.messageId)) {
      // Legacy optimistic message. Update locally only.
      return _updateLocally(params.messageId, params.content);
    }

    final updateResult = await _privateChatRepository.updateMessage(
      messageId: params.messageId,
      content: params.content,
    );

    return updateResult.fold(
      (failure) => Left(failure),
      (_) => _updateLocally(params.messageId, params.content),
    );
  }

  FutureResult<void> _updateLocally(String messageId, String content) async {
    try {
      final getResult = await _chatCoreRepository.getMessage(messageId);
      return await getResult.fold(
        (failure) => Left(failure),
        (msg) async {
          if (msg != null) {
            final updatedMsg = msg.copyWith(content: content);
            await _chatCoreRepository.saveMessage(updatedMsg);
          }
          return const Right(null);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to update message locally: $e', e));
    }
  }
}
