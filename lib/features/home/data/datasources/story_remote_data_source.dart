import 'package:dio/dio.dart';
import 'package:lotus_connect/core/constants/api_constants.dart';
import 'package:lotus_connect/core/errors/exception.dart';
import 'package:lotus_connect/core/network/dio_client.dart';
import 'package:lotus_connect/features/home/domain/entities/story.dart';
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

  /// Creates a new story.
  Future<Story> createStory({
    required String mediaType,
    required String mediaUrl,
    String? thumbnailUrl,
    String? caption,
    double duration = 5.0,
    String visibility = 'public',
    String? backgroundColor,
    Map<String, dynamic>? metadata,
  });

  /// Uploads media files for stories and returns remote file URLs.
  Future<List<String>> uploadFiles(List<String> filePaths);

  /// Deletes a story by ID.
  Future<bool> deleteStory(String storyId);
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

  @override
  Future<Story> createStory({
    required String mediaType,
    required String mediaUrl,
    String? thumbnailUrl,
    String? caption,
    double duration = 5.0,
    String visibility = 'public',
    String? backgroundColor,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final payload = <String, dynamic>{
        'mediaType': mediaType,
        'mediaUrl': mediaUrl,
        'duration': duration,
        'visibility': visibility,
      };
      if (thumbnailUrl != null) payload['thumbnailUrl'] = thumbnailUrl;
      if (caption != null && caption.isNotEmpty) payload['caption'] = caption;
      if (backgroundColor != null && backgroundColor.isNotEmpty) {
        payload['backgroundColor'] = backgroundColor;
      }
      if (metadata != null && metadata.isNotEmpty) {
        payload['metadata'] = metadata;
      }

      final response = await _dioClient.post<dynamic>(
        ApiConstants.stories,
        data: payload,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final storyData = data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : data;
        return Story.fromJson(storyData);
      }
      throw const ServerException('Invalid response format for created story');
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to create story: $e');
    }
  }

  @override
  Future<List<String>> uploadFiles(List<String> filePaths) async {
    try {
      final multipartFiles = await Future.wait(
        filePaths.map((path) async {
          final fileName = path.split('/').last;
          return MultipartFile.fromFile(path, filename: fileName);
        }),
      );

      final formData = FormData.fromMap({
        'files': multipartFiles,
      });

      final response = await _dioClient.post<dynamic>(
        ApiConstants.uploadMultiple,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final rawUrls = data['fileUrls'];
        if (rawUrls is List) {
          return rawUrls.map((e) => e.toString()).toList();
        }
        final rawFiles = data['files'];
        if (rawFiles is List) {
          return rawFiles
              .whereType<Map<String, dynamic>>()
              .map((m) => m['url']?.toString() ?? '')
              .where((u) => u.isNotEmpty)
              .toList();
        }
      }
      if (data is List) {
        return data.map((e) => e.toString()).toList();
      }
      return <String>[];
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to upload story media: $e');
    }
  }

  @override
  Future<bool> deleteStory(String storyId) async {
    try {
      await _dioClient.delete<dynamic>('${ApiConstants.stories}/$storyId');
      return true;
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to delete story: $e');
    }
  }
}
