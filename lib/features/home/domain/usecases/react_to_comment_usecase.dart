import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/home/domain/repositories/comment_repository.dart';

class ReactToCommentParams extends Equatable {
  const ReactToCommentParams({
    required this.postId,
    required this.commentId,
    this.reaction = 'like',
    this.isRemove = false,
  });

  final String postId;
  final String commentId;
  final String reaction;
  final bool isRemove;

  @override
  List<Object?> get props => [postId, commentId, reaction, isRemove];
}

class ReactToCommentUseCase implements UseCase<void, ReactToCommentParams> {
  const ReactToCommentUseCase({required CommentRepository repository})
      : _repository = repository;

  final CommentRepository _repository;

  @override
  FutureResult<void> call(ReactToCommentParams params) {
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
    if (params.isRemove) {
      return _repository.removeCommentReaction(
        postId: params.postId,
        commentId: params.commentId,
      );
    }
    return _repository.addCommentReaction(
      postId: params.postId,
      commentId: params.commentId,
      reaction: params.reaction,
    );
  }
}
