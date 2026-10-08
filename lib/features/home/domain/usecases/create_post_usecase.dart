import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/home/domain/entities/create_post_params.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';
import 'package:lotus_connect/features/home/domain/entities/post_media_item.dart';
import 'package:lotus_connect/features/home/domain/repositories/feed_repository.dart';

/// Use case to handle post creation with automated media file uploads.
class CreatePostUseCase implements UseCase<PostItem, CreatePostParams> {
  const CreatePostUseCase({required FeedRepository repository})
      : _repository = repository;

  final FeedRepository _repository;

  @override
  FutureResult<PostItem> call(CreatePostParams params) async {
    if (!params.isValid) {
      return const Left(
        ValidationFailure('Post cannot be empty. Add text or media.'),
      );
    }

    var allMediaItems = <PostMediaItem>[
      if (params.mediaItems != null) ...params.mediaItems!,
    ];

    // Upload local file paths if any are provided
    if (params.filePaths.isNotEmpty) {
      final uploadResult = await _repository.uploadFiles(params.filePaths);
      final uploadFailure = uploadResult.fold<Failure?>((f) => f, (_) => null);
      if (uploadFailure != null) {
        return Left(uploadFailure);
      }

      final uploadedItems = uploadResult.getOrElse((_) => <PostMediaItem>[]);
      allMediaItems = [...allMediaItems, ...uploadedItems];
    }

    return _repository.createPost(
      content: params.formattedContent,
      mediaItems: allMediaItems.isNotEmpty ? allMediaItems : null,
      visibility: params.visibility,
    );
  }
}
