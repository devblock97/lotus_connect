import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/home/domain/repositories/comment_repository.dart';

/// Parameters for deleting a comment.
class DeleteCommentParams extends Equatable {
  const DeleteCommentParams({
    required this.postId,
    required this.commentId,
  });

  final String postId;
  final String commentId;

  @override
  List<Object?> get props => [postId, commentId];
}

/// Use case to delete a comment.
class DeleteCommentUseCase implements UseCase<bool, DeleteCommentParams> {
  const DeleteCommentUseCase({required CommentRepository repository})
      : _repository = repository;

  final CommentRepository _repository;

  @override
  FutureResult<bool> call(DeleteCommentParams params) {
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
    return _repository.deleteComment(
      postId: params.postId,
      commentId: params.commentId,
    );
  }
}
