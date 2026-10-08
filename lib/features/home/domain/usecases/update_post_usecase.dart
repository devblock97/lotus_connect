import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';
import 'package:lotus_connect/features/home/domain/entities/post_media_item.dart';
import 'package:lotus_connect/features/home/domain/repositories/feed_repository.dart';

/// Parameters for updating an existing post.
class UpdatePostParams {
  const UpdatePostParams({
    required this.postId,
    this.content,
    this.mediaItems,
    this.filePaths = const [],
    this.visibility,
  });

  final String postId;
  final String? content;
  final List<PostMediaItem>? mediaItems;
  final List<String> filePaths;
  final String? visibility;
}

/// Use case to handle post editing with automated media file uploads.
class UpdatePostUseCase implements UseCase<PostItem, UpdatePostParams> {
  const UpdatePostUseCase({required FeedRepository repository})
      : _repository = repository;

  final FeedRepository _repository;

  @override
  FutureResult<PostItem> call(UpdatePostParams params) async {
    if (params.postId.trim().isEmpty) {
      return const Left(ValidationFailure('Post ID cannot be empty.'));
    }

    final hasContent =
        params.content != null && params.content!.trim().isNotEmpty;
    final hasMedia =
        (params.mediaItems != null && params.mediaItems!.isNotEmpty) ||
            params.filePaths.isNotEmpty;

    if (!hasContent && !hasMedia) {
      return const Left(
        ValidationFailure('Post cannot be empty. Add text or media.'),
      );
    }

    var allMediaItems = <PostMediaItem>[
      if (params.mediaItems != null) ...params.mediaItems!,
    ];

    // Upload newly added local file paths if any are provided
    if (params.filePaths.isNotEmpty) {
      final uploadResult = await _repository.uploadFiles(params.filePaths);
      final uploadFailure = uploadResult.fold<Failure?>((f) => f, (_) => null);
      if (uploadFailure != null) {
        return Left(uploadFailure);
      }

      final uploadedItems = uploadResult.getOrElse((_) => <PostMediaItem>[]);
      allMediaItems = [...allMediaItems, ...uploadedItems];
    }

    return _repository.updatePost(
      postId: params.postId,
      content: params.content,
      mediaItems: allMediaItems.isNotEmpty ? allMediaItems : null,
      visibility: params.visibility,
    );
  }
}
