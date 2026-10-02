import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/home/domain/entities/user_story.dart';
import 'package:lotus_connect/features/home/domain/repositories/story_repository.dart';

/// Use case to fetch the stories tray items for the home screen.
class GetStoriesTrayUseCase implements UseCase<List<UserStory>, NoParams> {
  const GetStoriesTrayUseCase({required StoryRepository repository})
      : _repository = repository;

  final StoryRepository _repository;

  @override
  FutureResult<List<UserStory>> call(NoParams params) {
    return _repository.getStoriesTray();
  }
}
