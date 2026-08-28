import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chat/domain/repositories/private_chat_repository.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';

class SendMessageParams {
  const SendMessageParams({
    required this.conversationId,
    required this.text,
    this.replyToId,
    this.thumbnailUrl,
    this.mediaUrl,
    this.fileName,
    this.messageType,
    this.mimeType,
  });

  final String conversationId;
  final String text;
  final String? replyToId;
  final String? thumbnailUrl;
  final String? mediaUrl;
  final String? fileName;
  final String? messageType;
  final String? mimeType;
}

class SendMessageUseCase implements UseCase<Message, SendMessageParams> {
  const SendMessageUseCase({
    required PrivateChatRepository privateChatRepository,
  }) : _privateChatRepository = privateChatRepository;

  final PrivateChatRepository _privateChatRepository;

  @override
  FutureResult<Message> call(SendMessageParams params) async {
    return _privateChatRepository.sendMessage(
      conversationId: params.conversationId,
      content: params.text,
      replyToId: params.replyToId,
      messageType: params.messageType,
      mediaUrl: params.mediaUrl,
      thumbnailUrl: params.thumbnailUrl,
      fileName: params.fileName,
      mimeType: params.mimeType,
    );
  }
}
