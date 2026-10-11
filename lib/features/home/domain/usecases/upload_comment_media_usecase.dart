import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/home/domain/repositories/comment_repository.dart';

class UploadCommentMediaUseCase implements UseCase<String, String> {
  const UploadCommentMediaUseCase({required CommentRepository repository})
      : _repository = repository;

  final CommentRepository _repository;

  @override
  FutureResult<String> call(String filePath) {
    if (filePath.trim().isEmpty) {
      return Future.value(
        const Left(ValidationFailure('File path cannot be empty.')),
      );
    }
    return _repository.uploadMedia(filePath: filePath.trim());
  }
}
