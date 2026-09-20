import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chat/application/chat_application.dart';
import 'package:lotus_connect/features/chat/domain/usecases/reaction_message_usecase.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';
import 'package:lotus_connect/features/chat_core/domain/usecases/get_message_usecase.dart';
import 'package:lotus_connect/features/chat_core/domain/usecases/save_local_message_usecase.dart';

class ReactionMessageCommand implements ChatCommand<void> {
  ReactionMessageCommand({
    required this.messageId,
    required this.reaction,
    required this.getMessageUseCase,
    required this.saveLocalMessageUseCase,
    required this.reactionMessageUseCase,
  });

  final String messageId;
  final String reaction;
  final GetMessageUseCase getMessageUseCase;
  final SaveLocalMessageUseCase saveLocalMessageUseCase;
  final ReactionMessageUseCase reactionMessageUseCase;

  Message? _backupMessage;

  @override
  FutureResult<void> execute() async {
    final getMessageResult = await getMessageUseCase(
      GetMessageParam(messageId: messageId),
    );

    getMessageResult.fold((_) {}, (message) => _backupMessage = message);

    final result = await reactionMessageUseCase(
      ReactionMessageParam(
        messageId: messageId,
        reaction: reaction,
      ),
    );

    return await result.fold(
      (failure) {
        undo();
        return left(failure);
      },
      right,
    );
  }

  @override
  String get id => messageId;

  @override
  Future<void> undo() async {
    if (_backupMessage != null) {
      await saveLocalMessageUseCase(
        SaveLocalMessageParam(message: _backupMessage!),
      );
    }
  }
}
