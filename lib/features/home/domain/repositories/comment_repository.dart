import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/home/data/models/comment_model.dart';

abstract class CommentRepository {
  FutureResult<List<CommentModel>> getComments({
    required String postId,
    String? cursor,
    int? limit,
    String? sort,
  });

  FutureResult<CommentModel> createComment({
    required String postId,
    required String content,
    String? parentCommentId,
    String? mediaUrl,
  });

  FutureResult<CommentModel> getCommentById({
    required String postId,
    required String commentId,
  });

  FutureResult<List<CommentModel>> getCommentReplies({
    required String postId,
    required String commentId,
    String? cursor,
    int? limit,
  });

  FutureResult<CommentModel> updateComment({
    required String postId,
    required String commentId,
    required String content,
    String? mediaUrl,
  });

  FutureResult<bool> deleteComment({
    required String postId,
    required String commentId,
  });

  FutureResult<void> addCommentReaction({
    required String postId,
    required String commentId,
    String reaction = 'like',
  });

  FutureResult<void> removeCommentReaction({
    required String postId,
    required String commentId,
  });

  FutureResult<void> pinComment({
    required String postId,
    required String commentId,
  });

  FutureResult<void> unpinComment({
    required String postId,
    required String commentId,
  });

  FutureResult<String> uploadMedia({required String filePath});
}
