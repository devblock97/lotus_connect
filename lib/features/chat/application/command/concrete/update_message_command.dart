import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/entities/response_entity_base.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/core/utils/utils.dart';
import 'package:lotus_connect/features/chat/application/command/chat_command.dart';
import 'package:lotus_connect/features/chat/domain/usecases/update_message_usecase.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';
import 'package:lotus_connect/features/chat_core/domain/usecases/get_message_usecase.dart';
import 'package:lotus_connect/features/chat_core/domain/usecases/save_local_message_usecase.dart';

class UpdateMessageCommand implements ChatCommand<ResponseEntityBase> {
  UpdateMessageCommand({
    required this.messageId,
    required this.content,
    required GetMessageUseCase getMessageUseCase,
    required SaveLocalMessageUseCase saveLocalMessageUseCase,
    required UpdateMessageUseCase updateMessageUseCase,
  })  : _getMessageUseCase = getMessageUseCase,
        _saveLocalMessageUseCase = saveLocalMessageUseCase,
        _updateMessageUseCase = updateMessageUseCase;

  final String messageId;
  final String content;
  final SaveLocalMessageUseCase _saveLocalMessageUseCase;
  final GetMessageUseCase _getMessageUseCase;
  final UpdateMessageUseCase _updateMessageUseCase;

  Message? _backupMessage;

  @override
  FutureResult<ResponseEntityBase> execute() async {
    if (!uuidRegex.hasMatch(messageId)) {
      final getMessageResult = await _getMessageUseCase(
        GetMessageParam(messageId: messageId),
      );
      await getMessageResult.fold((error) {}, (message) async {
        if (message != null) {
          _backupMessage = message as Message?;
          final updateMessage = message.copyWith(content: content);
          await _saveLocalMessageUseCase(
            SaveLocalMessageParam(message: updateMessage),
          );
        }
      });
    }

    final updateMessageResult = await _updateMessageUseCase(
      UpdateMessageParam(messageId: messageId, content: content),
    );

    return await updateMessageResult.fold(
      (failure) {
        undo();
        return left(failure);
      },
      (message) async {
        final getMessageResult = await _getMessageUseCase(
          GetMessageParam(messageId: messageId),
        );
        await getMessageResult.fold((error) {}, (message) async {
          if (message != null) {
            final updateMessage = message.copyWith(content: content);
            await _saveLocalMessageUseCase(
              SaveLocalMessageParam(message: updateMessage),
            );
          }
        });
        return right(message);
      },
    );
  }

  @override
  String get id => messageId;

  @override
  Future<void> undo() async {
    if (_backupMessage != null) {
      await _saveLocalMessageUseCase(
        SaveLocalMessageParam(message: _backupMessage!),
      );
    }
  }
}
