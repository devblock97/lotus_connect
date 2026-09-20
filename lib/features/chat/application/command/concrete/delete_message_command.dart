import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/core/utils/utils.dart';
import 'package:lotus_connect/features/chat/application/command/chat_command.dart';
import 'package:lotus_connect/features/chat/domain/usecases/delete_local_message_usecase.dart';
import 'package:lotus_connect/features/chat/domain/usecases/delete_remote_message_usecase.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';
import 'package:lotus_connect/features/chat_core/domain/usecases/get_message_usecase.dart';
import 'package:lotus_connect/features/chat_core/domain/usecases/save_local_message_usecase.dart';

class DeleteMessageCommand implements ChatCommand<void> {
  DeleteMessageCommand({
    required this.messageId,
    required DeleteLocalMessageUseCase deleteLocalMessageUseCase,
    required DeleteRemoteMessageUseCase deleteRemoteMessageUseCase,
    required GetMessageUseCase getMessageUseCase,
    required SaveLocalMessageUseCase saveLocalMessageUseCase,
  })  : _deleteRemoteMessageUseCase = deleteRemoteMessageUseCase,
        _deleteLocalMessageUseCase = deleteLocalMessageUseCase,
        _getMessageUseCase = getMessageUseCase,
        _saveLocalMessageUseCase = saveLocalMessageUseCase;

  final String messageId;
  final DeleteLocalMessageUseCase _deleteLocalMessageUseCase;
  final DeleteRemoteMessageUseCase _deleteRemoteMessageUseCase;
  final GetMessageUseCase _getMessageUseCase;
  final SaveLocalMessageUseCase _saveLocalMessageUseCase;

  Message? _backupMessage;

  @override
  FutureResult<void> execute() async {
    final getResult = await _getMessageUseCase(
      GetMessageParam(messageId: messageId),
    );
    getResult.fold((_) {}, (msg) => _backupMessage = msg);

    // Optimistically delete locally
    await _deleteLocalMessageUseCase(messageId);

    if (!uuidRegex.hasMatch(messageId)) {
      return right(null);
    }

    final result = await _deleteRemoteMessageUseCase(
      DeleteRemoteMessageParam(messageId: messageId),
    );

    return await result.fold(
      (failure) async {
        await undo();
        return left(failure);
      },
      (_) => right(null),
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
