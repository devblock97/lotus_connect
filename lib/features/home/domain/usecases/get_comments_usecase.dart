import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/home/data/models/comment_model.dart';
import 'package:lotus_connect/features/home/domain/repositories/comment_repository.dart';

class GetCommentsParams extends Equatable {
  const GetCommentsParams({
    required this.postId,
    this.cursor,
    this.limit,
    this.sort,
  });

  final String postId;
  final String? cursor;
  final int? limit;
  final String? sort;

  @override
  List<Object?> get props => [postId, cursor, limit, sort];
}

class GetCommentsUseCase
    implements UseCase<List<CommentModel>, GetCommentsParams> {
  const GetCommentsUseCase({required CommentRepository repository})
      : _repository = repository;

  final CommentRepository _repository;

  @override
  FutureResult<List<CommentModel>> call(GetCommentsParams params) {
    if (params.postId.trim().isEmpty) {
      return Future.value(
        const Left(ValidationFailure('Post ID cannot be empty.')),
      );
    }
    return _repository.getComments(
      postId: params.postId,
      cursor: params.cursor,
      limit: params.limit,
      sort: params.sort,
    );
  }
}
