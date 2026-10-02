import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/home/domain/repositories/story_repository.dart';

class ReactToStoryParams extends Equatable {
  const ReactToStoryParams({required this.storyId, required this.reaction});

  final String storyId;
  final String reaction;

  @override
  List<Object?> get props => [storyId, reaction];
}

/// Use case to react to a story.
class ReactToStoryUseCase implements UseCase<void, ReactToStoryParams> {
  const ReactToStoryUseCase({required StoryRepository repository})
      : _repository = repository;

  final StoryRepository _repository;

  @override
  FutureResult<void> call(ReactToStoryParams params) {
    return _repository.reactToStory(params.storyId, params.reaction);
  }
}
