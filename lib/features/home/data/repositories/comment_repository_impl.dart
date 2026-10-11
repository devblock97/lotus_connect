import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/logging/app_logger.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/home/data/datasources/comment_remote_data_source.dart';
import 'package:lotus_connect/features/home/data/models/comment_model.dart';
import 'package:lotus_connect/features/home/domain/repositories/comment_repository.dart';

/// Implementation of [CommentRepository] coordinating remote data sources.
class CommentRepositoryImpl implements CommentRepository {
  const CommentRepositoryImpl({
    required CommentRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final CommentRemoteDataSource _remoteDataSource;

  @override
  FutureResult<List<CommentModel>> getComments({
    required String postId,
    String? cursor,
    int? limit,
    String? sort,
  }) async {
    try {
      final comments = await _remoteDataSource.getComments(
        postId: postId,
        cursor: cursor,
        limit: limit,
        sort: sort,
      );
      return Right(comments);
    } on Object catch (e) {
      AppLogger.error('CommentRepositoryImpl.getComments error: $e');
      return Left(ServerFailure('Failed to load comments: $e'));
    }
  }

  @override
  FutureResult<CommentModel> createComment({
    required String postId,
    required String content,
    String? parentCommentId,
    String? mediaUrl,
  }) async {
    try {
      final comment = await _remoteDataSource.createComment(
        postId: postId,
        content: content,
        parentCommentId: parentCommentId,
        mediaUrl: mediaUrl,
      );
      return Right(comment);
    } on Object catch (e) {
      AppLogger.error('CommentRepositoryImpl.createComment error: $e');
      return Left(ServerFailure('Failed to post comment: $e'));
    }
  }

  @override
  FutureResult<CommentModel> getCommentById({
    required String postId,
    required String commentId,
  }) async {
    try {
      final comment = await _remoteDataSource.getCommentById(
        postId: postId,
        commentId: commentId,
      );
      return Right(comment);
    } on Object catch (e) {
      AppLogger.error('CommentRepositoryImpl.getCommentById error: $e');
      return Left(ServerFailure('Failed to load comment: $e'));
    }
  }

  @override
  FutureResult<List<CommentModel>> getCommentReplies({
    required String postId,
    required String commentId,
    String? cursor,
    int? limit,
  }) async {
    try {
      final replies = await _remoteDataSource.getCommentReplies(
        postId: postId,
        commentId: commentId,
        cursor: cursor,
        limit: limit,
      );
      return Right(replies);
    } on Object catch (e) {
      AppLogger.error('CommentRepositoryImpl.getCommentReplies error: $e');
      return Left(ServerFailure('Failed to load replies: $e'));
    }
  }

  @override
  FutureResult<CommentModel> updateComment({
    required String postId,
    required String commentId,
    required String content,
    String? mediaUrl,
  }) async {
    try {
      final updated = await _remoteDataSource.updateComment(
        postId: postId,
        commentId: commentId,
        content: content,
        mediaUrl: mediaUrl,
      );
      return Right(updated);
    } on Object catch (e) {
      AppLogger.error('CommentRepositoryImpl.updateComment error: $e');
      return Left(ServerFailure('Failed to update comment: $e'));
    }
  }

  @override
  FutureResult<bool> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      final success = await _remoteDataSource.deleteComment(
        postId: postId,
        commentId: commentId,
      );
      return Right(success);
    } on Object catch (e) {
      AppLogger.error('CommentRepositoryImpl.deleteComment error: $e');
      return Left(ServerFailure('Failed to delete comment: $e'));
    }
  }

  @override
  FutureResult<void> addCommentReaction({
    required String postId,
    required String commentId,
    String reaction = 'like',
  }) async {
    try {
      await _remoteDataSource.addCommentReaction(
        postId: postId,
        commentId: commentId,
        reaction: reaction,
      );
      return const Right(null);
    } on Object catch (e) {
      AppLogger.error('CommentRepositoryImpl.addCommentReaction error: $e');
      return Left(ServerFailure('Failed to react to comment: $e'));
    }
  }

  @override
  FutureResult<void> removeCommentReaction({
    required String postId,
    required String commentId,
  }) async {
    try {
      await _remoteDataSource.removeCommentReaction(
        postId: postId,
        commentId: commentId,
      );
      return const Right(null);
    } on Object catch (e) {
      AppLogger.error('CommentRepositoryImpl.removeCommentReaction error: $e');
      return Left(ServerFailure('Failed to remove comment reaction: $e'));
    }
  }

  @override
  FutureResult<void> pinComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      await _remoteDataSource.pinComment(
        postId: postId,
        commentId: commentId,
      );
      return const Right(null);
    } on Object catch (e) {
      AppLogger.error('CommentRepositoryImpl.pinComment error: $e');
      return Left(ServerFailure('Failed to pin comment: $e'));
    }
  }

  @override
  FutureResult<void> unpinComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      await _remoteDataSource.unpinComment(
        postId: postId,
        commentId: commentId,
      );
      return const Right(null);
    } on Object catch (e) {
      AppLogger.error('CommentRepositoryImpl.unpinComment error: $e');
      return Left(ServerFailure('Failed to unpin comment: $e'));
    }
  }

  @override
  FutureResult<String> uploadMedia({required String filePath}) async {
    try {
      final remoteUrl = await _remoteDataSource.uploadMedia(filePath: filePath);
      return Right(remoteUrl);
    } on Object catch (e) {
      AppLogger.error('CommentRepositoryImpl.uploadMedia error: $e');
      return Left(ServerFailure('Failed to upload comment media: $e'));
    }
  }
}
