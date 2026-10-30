import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/patterns/command/chat_command.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/core/utils/utils.dart';
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
    this.existingMessage,
  })  : _sendMessageUseCase = sendMessageUseCase,
        _uploadFileUseCase = uploadFileUseCase,
        _saveLocalMessageUseCase = saveLocalMessageUseCase,
        _deleteLocalMessageUseCase = deleteLocalMessageUseCase,
        id = existingMessage?.id ??
            DateTime.now().millisecondsSinceEpoch.toString();

  final String conversationId;
  final String text;
  final String? replyToId;
  final List<XFile> medias;
  final Message? existingMessage;

  final SendMessageUseCase _sendMessageUseCase;
  final UploadFileUseCase _uploadFileUseCase;
  final SaveLocalMessageUseCase _saveLocalMessageUseCase;
  final DeleteLocalMessageUseCase _deleteLocalMessageUseCase;

  Message createOptimisticMessage() {
    if (existingMessage != null) {
      return existingMessage!.copyWith(
        status: MessageStatus.sending,
        isError: false,
      );
    }

    final localMediaModels = medias.map((f) {
      final path = f.path;
      final fileName = f.name.isNotEmpty ? f.name : path.split('/').last;
      final mime = f.mimeType ?? (isVideo(path) ? 'video/mp4' : 'image/jpeg');

      return MediaModel(
        url: path,
        fileName: fileName,
        fileSize: 0,
        mimeType: mime,
      );
    }).toList();

    return Message(
      id: id,
      conversationId: conversationId,
      role: MessageRole.user,
      content: text,
      timestamp: DateTime.now(),
      replyToId: replyToId,
      status: MessageStatus.sending,
      medias: localMediaModels,
    );
  }

  @override
  FutureResult<Message> execute() async {
    final optimistic = createOptimisticMessage();

    try {
      var mediaModels = <MediaModel>[];

      // Determine local file paths to upload (from XFile list
      // or saved local MediaModels)
      final localPathsToUpload = <String>[
        if (medias.isNotEmpty)
          ...medias.map((f) => f.path)
        else if (existingMessage != null)
          ...existingMessage!.medias
              .where((m) => !isValidUrl(m.url))
              .map((m) => m.url),
      ];

      final alreadyUploadedMedias =
          existingMessage?.medias.where((m) => isValidUrl(m.url)).toList() ??
              <MediaModel>[];

      if (localPathsToUpload.isNotEmpty) {
        final uploadResult = await _uploadFileUseCase(
          UploadFileParam(paths: localPathsToUpload),
        );

        final uploadFailureOrFiles = uploadResult
            .fold<Either<Failure, FileUploadResponseModel>>(left, right);

        if (uploadFailureOrFiles.isLeft()) {
          final failure = uploadFailureOrFiles.getLeft().toNullable()!;
          await _markAsFailed(optimistic);
          return left(failure);
        }

        final fileUrl = uploadFailureOrFiles.getRight().toNullable();
        mediaModels = [
          ...alreadyUploadedMedias,
          ...(fileUrl?.files ?? []).map(
            (f) => MediaModel(
              url: f.url,
              fileName: f.fileName,
              fileSize: f.fileSize,
              thumbnailUrl: f.thumbnailUrl,
              mimeType: f.mimeType,
            ),
          ),
        ];
      } else {
        mediaModels = alreadyUploadedMedias;
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
        await _markAsFailed(
          optimistic.copyWith(
            medias: mediaModels.isNotEmpty ? mediaModels : null,
          ),
        );
        return left(failure);
      }, (remoteMessage) async {
        await _deleteLocalMessageUseCase(id);
        await _saveLocalMessageUseCase(
          SaveLocalMessageParam(message: remoteMessage),
        );
        return right(remoteMessage);
      });
    } on Object catch (e) {
      await _markAsFailed(optimistic);
      return left(ServerFailure(e.toString()));
    }
  }

  Future<void> _markAsFailed(Message message) async {
    await _saveLocalMessageUseCase(
      SaveLocalMessageParam(
        message: message.copyWith(
          status: MessageStatus.failed,
          isError: true,
        ),
      ),
    );
  }

  @override
  final String id;

  @override
  Future<void> undo() async {
    await _deleteLocalMessageUseCase(id);
  }
}
