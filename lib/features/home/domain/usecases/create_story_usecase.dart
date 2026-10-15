import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/home/domain/entities/create_story_params.dart';
import 'package:lotus_connect/features/home/domain/entities/story.dart';
import 'package:lotus_connect/features/home/domain/repositories/story_repository.dart';

class CreateStoryUseCase implements UseCase<Story, CreateStoryParams> {
  const CreateStoryUseCase({required StoryRepository repository})
      : _repository = repository;

  final StoryRepository _repository;

  @override
  FutureResult<Story> call(CreateStoryParams params) async {
    if (!params.isValid) {
      return const Left(
        ValidationFailure('Story must have an image, video, or text content.'),
      );
    }

    var finalMediaUrl = params.mediaUrl;
    final finalThumbnailUrl = params.thumbnailUrl;

    // Upload local file if provided
    if (params.filePath != null && params.filePath!.trim().isNotEmpty) {
      final uploadResult =
          await _repository.uploadStoryMedia([params.filePath!]);
      final uploadFailure = uploadResult.fold<Failure?>((f) => f, (_) => null);

      if (uploadFailure != null) {
        return Left(uploadFailure);
      }

      final urls = uploadResult.getOrElse((_) => <String>[]);
      if (urls.isNotEmpty) {
        finalMediaUrl = urls.first;
      }
    }

    // Default to empty string for text-only stories if no media was uploaded
    finalMediaUrl ??= '';

    return _repository.createStory(
      params.copyWith(
        mediaUrl: finalMediaUrl,
        thumbnailUrl: finalThumbnailUrl,
      ),
    );
  }
}
