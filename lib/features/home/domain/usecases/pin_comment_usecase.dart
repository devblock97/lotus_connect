import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/home/domain/repositories/comment_repository.dart';

class PinCommentParams extends Equatable {
  const PinCommentParams({
    required this.postId,
    required this.commentId,
    this.isPinned = true,
  });

  final String postId;
  final String commentId;
  final bool isPinned;

  @override
  List<Object?> get props => [postId, commentId, isPinned];
}

class PinCommentUseCase implements UseCase<void, PinCommentParams> {
  const PinCommentUseCase({required CommentRepository repository})
      : _repository = repository;

  final CommentRepository _repository;

  @override
  FutureResult<void> call(PinCommentParams params) {
    if (params.postId.trim().isEmpty) {
      return Future.value(
        const Left(ValidationFailure('Post ID cannot be empty.')),
      );
    }
    if (params.commentId.trim().isEmpty) {
      return Future.value(
        const Left(ValidationFailure('Comment ID cannot be empty.')),
      );
    }
    if (params.isPinned) {
      return _repository.pinComment(
        postId: params.postId,
        commentId: params.commentId,
      );
    }
    return _repository.unpinComment(
      postId: params.postId,
      commentId: params.commentId,
    );
  }
}
