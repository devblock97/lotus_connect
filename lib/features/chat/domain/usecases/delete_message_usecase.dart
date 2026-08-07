import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chat/domain/repositories/private_chat_repository.dart';
import 'package:lotus_connect/features/chat_core/domain/repositories/chat_core_repository.dart';

class DeleteMessageUseCase implements UseCase<void, String> {
  const DeleteMessageUseCase({
    required ChatCoreRepository chatCoreRepository,
    required PrivateChatRepository privateChatRepository,
  })  : _chatCoreRepository = chatCoreRepository,
        _privateChatRepository = privateChatRepository;

  final ChatCoreRepository _chatCoreRepository;
  final PrivateChatRepository _privateChatRepository;

  @override
  FutureResult<void> call(String messageId) async {
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );

    if (!uuidRegex.hasMatch(messageId)) {
      // Legacy optimistic message with a timestamp ID. Delete locally only.
      try {
        await _chatCoreRepository.deleteMessage(messageId);
        return const Right(null);
      } catch (e) {
        return Left(DatabaseFailure('Failed to delete message locally: $e', e));
      }
    }

    final deleteResult = await _privateChatRepository.deleteMessage(messageId);
    return deleteResult.fold(
      (failure) => Left(failure),
      (_) async {
        try {
          await _chatCoreRepository.deleteMessage(messageId);
          return const Right(null);
        } catch (e) {
          return Left(DatabaseFailure('Failed to delete message locally: $e', e));
        }
      },
    );
  }
}
