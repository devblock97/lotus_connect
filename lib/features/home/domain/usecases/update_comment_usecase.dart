import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/home/data/models/comment_model.dart';
import 'package:lotus_connect/features/home/domain/repositories/comment_repository.dart';

class UpdateCommentParams extends Equatable {
  const UpdateCommentParams({
    required this.postId,
    required this.commentId,
    required this.content,
    this.mediaUrl,
  });

  final String postId;
  final String commentId;
  final String content;
  final String? mediaUrl;

  UpdateCommentParams copyWith({
    String? postId,
    String? commentId,
    String? content,
    String? mediaUrl,
  }) {
    return UpdateCommentParams(
      postId: postId ?? this.postId,
      commentId: commentId ?? this.commentId,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
    );
  }

  @override
  List<Object?> get props => [postId, commentId, content, mediaUrl];
}

class UpdateCommentUseCase
    implements UseCase<CommentModel, UpdateCommentParams> {
  const UpdateCommentUseCase({required CommentRepository repository})
      : _repository = repository;

  final CommentRepository _repository;

  @override
  FutureResult<CommentModel> call(UpdateCommentParams params) async {
    if (params.postId.trim().isEmpty) {
      return const Left(ValidationFailure('Post ID cannot be empty.'));
    }
    if (params.commentId.trim().isEmpty) {
      return const Left(ValidationFailure('Comment ID cannot be empty.'));
    }
    if (params.content.trim().isEmpty &&
        (params.mediaUrl == null || params.mediaUrl!.trim().isEmpty)) {
      return const Left(
        ValidationFailure('Comment content or media cannot be empty.'),
      );
    }

    var effectiveMediaUrl = params.mediaUrl;
    if (effectiveMediaUrl != null &&
        effectiveMediaUrl.trim().isNotEmpty &&
        !effectiveMediaUrl.startsWith('http://') &&
        !effectiveMediaUrl.startsWith('https://') &&
        !effectiveMediaUrl.startsWith('data:')) {
      final cleanPath = effectiveMediaUrl.startsWith('file://')
          ? effectiveMediaUrl.replaceFirst('file://', '')
          : effectiveMediaUrl;
      final uploadResult = await _repository.uploadMedia(
        filePath: cleanPath.trim(),
      );
      final uploadFailure = uploadResult.fold<Failure?>((f) => f, (_) => null);
      if (uploadFailure != null) {
        return Left(uploadFailure);
      }
      effectiveMediaUrl = uploadResult.getOrElse((_) => effectiveMediaUrl!);
    }

    return _repository.updateComment(
      postId: params.postId,
      commentId: params.commentId,
      content: params.content.trim(),
      mediaUrl: effectiveMediaUrl,
    );
  }
}
