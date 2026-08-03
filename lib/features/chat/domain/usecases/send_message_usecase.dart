import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/services/websocket/websocket_service.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chat/domain/repositories/private_chat_repository.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';
import 'package:lotus_connect/features/chat_core/domain/repositories/chat_core_repository.dart';

class SendMessageParams {
  const SendMessageParams({
    required this.conversationId,
    required this.text,
  });

  final String conversationId;
  final String text;
}

class SendMessageUseCase implements UseCase<Message, SendMessageParams> {
  const SendMessageUseCase({
    required ChatCoreRepository chatCoreRepository,
    required PrivateChatRepository privateChatRepository,
  })  : _chatCoreRepository = chatCoreRepository,
        _privateChatRepository = privateChatRepository;

  final ChatCoreRepository _chatCoreRepository;
  final PrivateChatRepository _privateChatRepository;

  @override
  FutureResult<Message> call(SendMessageParams params) async {
    final trimmedText = params.text.trim();
    if (trimmedText.isEmpty) {
      return const Left(ValidationFailure('Message content cannot be empty'));
    }

    final optimisticId = DateTime.now().millisecondsSinceEpoch.toString();
    final userMessageId = DateTime.now().millisecondsSinceEpoch.toString();
    final userMessage = Message(
      id: userMessageId,
      conversationId: params.conversationId,
      role: MessageRole.user,
      content: trimmedText,
      timestamp: DateTime.now(),
    );

    await _chatCoreRepository.saveMessage(userMessage);
    await _chatCoreRepository.saveDraftMessage(params.conversationId, '');

    final sendResult = await _privateChatRepository.sendMessage(
      conversationId: params.conversationId,
      content: trimmedText,
    );

    return sendResult.fold(
      (failure) async {
        final failedMessage = userMessage.copyWith(
          status: MessageStatus.error,
          isError: true,
        );
        await _chatCoreRepository.saveMessage(failedMessage);
        return Left(failure);
      },
      (remoteMessage) async {
        // Delete optimistic message and save the permanent
        // server-synchronized message
        await _chatCoreRepository.deleteMessage(optimisticId);
        await _chatCoreRepository.saveMessage(remoteMessage);
        return Right(remoteMessage);
      }
    );
  }
}
