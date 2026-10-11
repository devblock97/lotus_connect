import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/home/data/models/comment_model.dart';
import 'package:lotus_connect/features/home/domain/repositories/comment_repository.dart';

class CreateCommentParams extends Equatable {
  const CreateCommentParams({
    required this.postId,
    required this.content,
    this.parentCommentId,
    this.mediaUrl,
  });

  final String postId;
  final String content;
  final String? parentCommentId;
  final String? mediaUrl;

  CreateCommentParams copyWith({
    String? postId,
    String? content,
    String? parentCommentId,
    String? mediaUrl,
  }) {
    return CreateCommentParams(
      postId: postId ?? this.postId,
      content: content ?? this.content,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      mediaUrl: mediaUrl ?? this.mediaUrl,
    );
  }

  @override
  List<Object?> get props => [postId, content, parentCommentId, mediaUrl];
}

/// Use case to post a new comment or threaded reply.
class CreateCommentUseCase
    implements UseCase<CommentModel, CreateCommentParams> {
  const CreateCommentUseCase({required CommentRepository repository})
      : _repository = repository;

  final CommentRepository _repository;

  @override
  FutureResult<CommentModel> call(CreateCommentParams params) async {
    if (params.postId.trim().isEmpty) {
      return const Left(ValidationFailure('Post ID cannot be empty.'));
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

    return _repository.createComment(
      postId: params.postId,
      content: params.content.trim(),
      parentCommentId: params.parentCommentId,
      mediaUrl: effectiveMediaUrl,
    );
  }
}
