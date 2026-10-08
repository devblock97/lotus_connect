import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/home/domain/repositories/feed_repository.dart';

/// Parameters for deleting a post.
class DeletePostParams {
  const DeletePostParams(this.postId);
  final String postId;
}

/// Use case to delete a post.
class DeletePostUseCase implements UseCase<bool, DeletePostParams> {
  const DeletePostUseCase({required FeedRepository repository})
      : _repository = repository;

  final FeedRepository _repository;

  @override
  FutureResult<bool> call(DeletePostParams params) {
    if (params.postId.trim().isEmpty) {
      return Future.value(
        const Left(ValidationFailure('Post ID cannot be empty.')),
      );
    }
    return _repository.deletePost(params.postId);
  }
}
