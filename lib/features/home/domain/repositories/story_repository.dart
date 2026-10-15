import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/home/domain/entities/create_story_params.dart';
import 'package:lotus_connect/features/home/domain/entities/story.dart';
import 'package:lotus_connect/features/home/domain/entities/user_story.dart';

abstract class StoryRepository {
  FutureResult<List<UserStory>> getStoriesTray();

  FutureResult<void> markStoryViewed(String storyId);

  FutureResult<void> reactToStory(String storyId, String reaction);

  FutureResult<void> replyToStory(String storyId, String message);

  FutureResult<Story> createStory(CreateStoryParams params);

  FutureResult<List<String>> uploadStoryMedia(List<String> filePaths);

  FutureResult<bool> deleteStory(String storyId);
}
