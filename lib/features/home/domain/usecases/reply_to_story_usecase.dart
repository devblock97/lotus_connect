import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/home/domain/repositories/story_repository.dart';

class ReplyToStoryParams extends Equatable {
  const ReplyToStoryParams({required this.storyId, required this.message});

  final String storyId;
  final String message;

  @override
  List<Object?> get props => [storyId, message];
}

/// Use case to reply to a story with a direct chat message.
class ReplyToStoryUseCase implements UseCase<void, ReplyToStoryParams> {
  const ReplyToStoryUseCase({required StoryRepository repository})
      : _repository = repository;

  final StoryRepository _repository;

  @override
  FutureResult<void> call(ReplyToStoryParams params) {
    return _repository.replyToStory(params.storyId, params.message);
  }
}
