import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lotus_connect/features/chat/application/chat_providers.dart';
import 'package:lotus_connect/features/chat/application/command/concrete/delete_message_command.dart';
import 'package:lotus_connect/features/chat/application/command/concrete/react_message_command.dart';
import 'package:lotus_connect/features/chat/application/command/concrete/send_message_command.dart';
import 'package:lotus_connect/features/chat/application/command/concrete/update_message_command.dart';
import 'package:lotus_connect/features/chat/domain/usecases/delete_local_message_usecase.dart';
import 'package:lotus_connect/features/chat/domain/usecases/delete_remote_message_usecase.dart';
import 'package:lotus_connect/features/chat/domain/usecases/reaction_message_usecase.dart';
import 'package:lotus_connect/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:lotus_connect/features/chat/domain/usecases/update_message_usecase.dart';
import 'package:lotus_connect/features/chat/domain/usecases/upload_file_usecase.dart';
import 'package:lotus_connect/features/chat_core/application/chat_core_providers.dart';
import 'package:lotus_connect/features/chat_core/domain/usecases/get_message_usecase.dart';
import 'package:lotus_connect/features/chat_core/domain/usecases/save_local_message_usecase.dart';

class ChatCommandFactory {
  ChatCommandFactory({
    required this.sendMessageUseCase,
    required this.uploadFileUseCase,
    required this.saveLocalMessageUseCase,
    required this.deleteLocalMessageUseCase,
    required this.deleteRemoteMessageUseCase,
    required this.getMessageUseCase,
    required this.updateMessageUseCase,
    required this.reactionMessageUseCase,
  });

  final SendMessageUseCase sendMessageUseCase;
  final UploadFileUseCase uploadFileUseCase;
  final SaveLocalMessageUseCase saveLocalMessageUseCase;
  final DeleteLocalMessageUseCase deleteLocalMessageUseCase;
  final DeleteRemoteMessageUseCase deleteRemoteMessageUseCase;
  final GetMessageUseCase getMessageUseCase;
  final UpdateMessageUseCase updateMessageUseCase;
  final ReactionMessageUseCase reactionMessageUseCase;

  SendMessageCommand createSendMessageCommand({
    required String conversationId,
    required String text,
    String? replyToId,
    List<XFile> medias = const [],
  }) {
    return SendMessageCommand(
      conversationId: conversationId,
      text: text,
      replyToId: replyToId,
      medias: medias,
      sendMessageUseCase: sendMessageUseCase,
      uploadFileUseCase: uploadFileUseCase,
      saveLocalMessageUseCase: saveLocalMessageUseCase,
      deleteLocalMessageUseCase: deleteLocalMessageUseCase,
    );
  }

  DeleteMessageCommand createDeleteMessageCommand(String messageId) {
    return DeleteMessageCommand(
      messageId: messageId,
      deleteLocalMessageUseCase: deleteLocalMessageUseCase,
      deleteRemoteMessageUseCase: deleteRemoteMessageUseCase,
      getMessageUseCase: getMessageUseCase,
      saveLocalMessageUseCase: saveLocalMessageUseCase,
    );
  }

  UpdateMessageCommand createUpdateMessageCommand(
    String messageId,
    String content,
  ) {
    return UpdateMessageCommand(
      messageId: messageId,
      content: content,
      getMessageUseCase: getMessageUseCase,
      saveLocalMessageUseCase: saveLocalMessageUseCase,
      updateMessageUseCase: updateMessageUseCase,
    );
  }

  ReactionMessageCommand createReactionMessageCommand(
    String messageId,
    String reaction,
  ) {
    return ReactionMessageCommand(
      messageId: messageId,
      reaction: reaction,
      getMessageUseCase: getMessageUseCase,
      saveLocalMessageUseCase: saveLocalMessageUseCase,
      reactionMessageUseCase: reactionMessageUseCase,
    );
  }
}

final chatCommandFactoryProvider = Provider<ChatCommandFactory>((ref) {
  return ChatCommandFactory(
    sendMessageUseCase: ref.watch(sendMessageUseCaseProvider),
    uploadFileUseCase: ref.watch(uploadFileUseCaseProvider),
    saveLocalMessageUseCase: ref.watch(saveMessageUseCaseProvider),
    deleteLocalMessageUseCase: ref.watch(deleteLocalMessageUseCaseProvider),
    deleteRemoteMessageUseCase: ref.watch(deleteRemoteMessageUseCaseProvider),
    getMessageUseCase: ref.watch(getMessageUseCaseProvider),
    updateMessageUseCase: ref.watch(updateMessageUseCaseProvider),
    reactionMessageUseCase: ref.watch(reactionMessageUseCaseProvider),
  );
});
