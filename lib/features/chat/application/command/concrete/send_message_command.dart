import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chat/application/command/chat_command.dart';
import 'package:lotus_connect/features/chat/data/models/file_upload_response_model.dart';
import 'package:lotus_connect/features/chat/domain/usecases/delete_local_message_usecase.dart';
import 'package:lotus_connect/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:lotus_connect/features/chat/domain/usecases/upload_file_usecase.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';
import 'package:lotus_connect/features/chat_core/domain/usecases/save_local_message_usecase.dart';

class SendMessageCommand implements ChatCommand<Message> {
  SendMessageCommand({
    required this.conversationId,
    required this.text,
    required SendMessageUseCase sendMessageUseCase,
    required UploadFileUseCase uploadFileUseCase,
    required SaveLocalMessageUseCase saveLocalMessageUseCase,
    required DeleteLocalMessageUseCase deleteLocalMessageUseCase,
    this.replyToId,
    this.medias = const [],
  })  : _sendMessageUseCase = sendMessageUseCase,
        _uploadFileUseCase = uploadFileUseCase,
        _saveLocalMessageUseCase = saveLocalMessageUseCase,
        _deleteLocalMessageUseCase = deleteLocalMessageUseCase,
        id = DateTime.now().millisecondsSinceEpoch.toString();

  final String conversationId;
  final String text;
  final String? replyToId;
  final List<XFile> medias;

  final SendMessageUseCase _sendMessageUseCase;
  final UploadFileUseCase _uploadFileUseCase;
  final SaveLocalMessageUseCase _saveLocalMessageUseCase;
  final DeleteLocalMessageUseCase _deleteLocalMessageUseCase;

  late final Message _optimisticMessage;

  Message createOptimisticMessage() {
    _optimisticMessage = Message(
      id: id,
      conversationId: conversationId,
      role: MessageRole.user,
      content: text,
      timestamp: DateTime.now(),
      replyToId: replyToId,
      status: MessageStatus.sending,
    );

    return _optimisticMessage;
  }

  @override
  FutureResult<Message> execute() async {
    try {
      var mediaModels = <MediaModel>[];

      if (medias.isNotEmpty) {
        final paths = medias.map((f) => f.path).toList();
        final uploadResult =
            await _uploadFileUseCase(UploadFileParam(paths: paths));

        final uploadFailureOrFiles = uploadResult
            .fold<Either<Failure, FileUploadResponseModel>>(left, right);

        if (uploadFailureOrFiles.isLeft()) {
          final failure = uploadFailureOrFiles.getLeft().toNullable()!;
          await undo();
          return left(failure);
        }

        final fileUrl = uploadFailureOrFiles.getRight().toNullable();
        mediaModels = (fileUrl?.files ?? [])
            .map(
              (f) => MediaModel(
                url: f.url,
                fileName: f.fileName,
                fileSize: f.fileSize,
                thumbnailUrl: f.thumbnailUrl,
                mimeType: f.mimeType,
              ),
            )
            .toList();
      }

      final sendResult = await _sendMessageUseCase(
        SendMessageParams(
          conversationId: conversationId,
          text: text,
          replyToId: replyToId,
          messageType: mediaModels.isNotEmpty ? 'image' : null,
          mediaItems: mediaModels,
        ),
      );

      return await sendResult.fold((failure) async {
        await undo();
        return left(failure);
      }, (remoteMessage) async {
        await _deleteLocalMessageUseCase(id);
        await _saveLocalMessageUseCase(
          SaveLocalMessageParam(message: remoteMessage),
        );
        return right(remoteMessage);
      });
    } on Object catch (e) {
      await undo();
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  final String id;

  @override
  Future<void> undo() async {
    await _deleteLocalMessageUseCase(id);
  }
}
