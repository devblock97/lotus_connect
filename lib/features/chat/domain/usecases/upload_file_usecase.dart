import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chat/domain/repositories/private_chat_repository.dart';

class UploadFileParam extends Equatable {
  const UploadFileParam({required this.path});

  final String path;

  @override
  List<Object?> get props => [path];
}

class UploadFileUseCase implements UseCase<String, UploadFileParam> {
  const UploadFileUseCase({required PrivateChatRepository repository})
      : _repository = repository;

  final PrivateChatRepository _repository;

  @override
  FutureResult<String> call(UploadFileParam params) async {
    return _repository.uploadFiles(params.path);
  }
}
