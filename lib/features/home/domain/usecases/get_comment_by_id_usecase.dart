import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/home/data/models/comment_model.dart';
import 'package:lotus_connect/features/home/domain/repositories/comment_repository.dart';

class GetCommentByIdParams extends Equatable {
  const GetCommentByIdParams({
    required this.postId,
    required this.commentId,
  });

  final String postId;
  final String commentId;

  @override
  List<Object?> get props => [postId, commentId];
}

class GetCommentByIdUseCase
    implements UseCase<CommentModel, GetCommentByIdParams> {
  const GetCommentByIdUseCase({required CommentRepository repository})
      : _repository = repository;

  final CommentRepository _repository;

  @override
  FutureResult<CommentModel> call(GetCommentByIdParams params) {
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
    return _repository.getCommentById(
      postId: params.postId,
      commentId: params.commentId,
    );
  }
}
