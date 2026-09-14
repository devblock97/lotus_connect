import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chat/data/models/file_upload_response_model.dart';
import 'package:lotus_connect/features/chat/domain/repositories/chat_repository.dart';

class UploadFileParam extends Equatable {
  const UploadFileParam({required this.paths});

  final List<String> paths;

  @override
  List<Object?> get props => [paths];
}

class UploadFileUseCase
    implements UseCase<FileUploadResponseModel, UploadFileParam> {
  const UploadFileUseCase({required ChatRepository repository})
      : _repository = repository;

  final ChatRepository _repository;

  @override
  FutureResult<FileUploadResponseModel> call(UploadFileParam params) async {
    return _repository.uploadFiles(params.paths);
  }
}
