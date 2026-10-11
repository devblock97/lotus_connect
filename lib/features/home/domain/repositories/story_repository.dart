import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/home/domain/entities/user_story.dart';

abstract class StoryRepository {
  FutureResult<List<UserStory>> getStoriesTray();

  FutureResult<void> markStoryViewed(String storyId);

  FutureResult<void> reactToStory(String storyId, String reaction);

  FutureResult<void> replyToStory(String storyId, String message);
}
