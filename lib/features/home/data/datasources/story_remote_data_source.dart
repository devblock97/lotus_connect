import 'package:lotus_connect/core/constants/api_constants.dart';
import 'package:lotus_connect/core/errors/exception.dart';
import 'package:lotus_connect/core/network/dio_client.dart';
import 'package:lotus_connect/features/home/domain/entities/user_story.dart';

abstract class StoryRemoteDataSource {
  /// Fetches the stories tray items for the home screen.
  Future<List<UserStory>> getStoriesTray();

  /// Marks a specific story as viewed.
  Future<void> markStoryViewed(String storyId);

  /// Reacts to a story with an emoji reaction (e.g. "❤️").
  Future<void> reactToStory(String storyId, String reaction);

  /// Replies to a story with a direct chat message.
  Future<void> replyToStory(String storyId, String message);
}

class StoryRemoteDataSourceImpl implements StoryRemoteDataSource {
  const StoryRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  final DioClient _dioClient;

  @override
  Future<List<UserStory>> getStoriesTray() async {
    try {
      final response = await _dioClient.get<dynamic>(ApiConstants.storiesTray);
      final data = response.data;

      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(UserStory.fromJson)
            .toList();
      }

      if (data is Map<String, dynamic>) {
        final rawItems =
            data['data'] ?? data['items'] ?? data['stories'] ?? data['tray'];
        if (rawItems is List) {
          return rawItems
              .whereType<Map<String, dynamic>>()
              .map(UserStory.fromJson)
              .toList();
        }
      }

      return <UserStory>[];
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to fetch stories tray: $e');
    }
  }

  @override
  Future<void> markStoryViewed(String storyId) async {
    try {
      await _dioClient.post<dynamic>(ApiConstants.markStoryViewed(storyId));
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to mark story as viewed: $e');
    }
  }

  @override
  Future<void> reactToStory(String storyId, String reaction) async {
    try {
      await _dioClient.post<dynamic>(
        ApiConstants.storyReactions(storyId),
        data: {'reaction': reaction},
      );
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to react to story: $e');
    }
  }

  @override
  Future<void> replyToStory(String storyId, String message) async {
    try {
      await _dioClient.post<dynamic>(
        ApiConstants.replyToStory(storyId),
        data: {'message': message},
      );
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to reply to story: $e');
    }
  }
}
