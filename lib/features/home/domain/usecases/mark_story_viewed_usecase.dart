import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/home/domain/repositories/story_repository.dart';

/// Use case to mark a story as viewed.
class MarkStoryViewedUseCase implements UseCase<void, String> {
  const MarkStoryViewedUseCase({required StoryRepository repository})
      : _repository = repository;

  final StoryRepository _repository;

  @override
  FutureResult<void> call(String storyId) {
    return _repository.markStoryViewed(storyId);
  }
}
