import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/home/domain/entities/user_story.dart';

/// Contract for the stories repository in the domain layer.
abstract class StoryRepository {
  /// Fetches the stories tray items.
  FutureResult<List<UserStory>> getStoriesTray();

  /// Marks a story as viewed.
  FutureResult<void> markStoryViewed(String storyId);

  /// Reacts to a story.
  FutureResult<void> reactToStory(String storyId, String reaction);

  /// Replies to a story.
  FutureResult<void> replyToStory(String storyId, String message);
}
