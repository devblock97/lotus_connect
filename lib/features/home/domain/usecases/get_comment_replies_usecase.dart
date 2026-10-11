import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/home/data/models/comment_model.dart';
import 'package:lotus_connect/features/home/domain/repositories/comment_repository.dart';

class GetCommentRepliesParams extends Equatable {
  const GetCommentRepliesParams({
    required this.postId,
    required this.commentId,
    this.cursor,
    this.limit,
  });

  final String postId;
  final String commentId;
  final String? cursor;
  final int? limit;

  @override
  List<Object?> get props => [postId, commentId, cursor, limit];
}

class GetCommentRepliesUseCase
    implements UseCase<List<CommentModel>, GetCommentRepliesParams> {
  const GetCommentRepliesUseCase({required CommentRepository repository})
      : _repository = repository;

  final CommentRepository _repository;

  @override
  FutureResult<List<CommentModel>> call(GetCommentRepliesParams params) {
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
    return _repository.getCommentReplies(
      postId: params.postId,
      commentId: params.commentId,
      cursor: params.cursor,
      limit: params.limit,
    );
  }
}
