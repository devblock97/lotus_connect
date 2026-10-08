import 'package:dio/dio.dart';
import 'package:lotus_connect/core/constants/api_constants.dart';
import 'package:lotus_connect/core/errors/exception.dart';
import 'package:lotus_connect/core/network/dio_client.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';
import 'package:lotus_connect/features/home/domain/entities/post_media_item.dart';

abstract class FeedRemoteDataSource {
  Future<List<PostItem>> getFeed();

  Future<PostItem> createPost({
    String? content,
    List<PostMediaItem>? mediaItems,
    String visibility = 'public',
  });

  Future<PostItem> updatePost({
    required String postId,
    String? content,
    List<PostMediaItem>? mediaItems,
    String? visibility,
  });

  Future<List<PostMediaItem>> uploadFiles(List<String> filePaths);

  Future<bool> deletePost(String postId);
}

class FeedRemoteDataSourceImpl implements FeedRemoteDataSource {
  const FeedRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  final DioClient _dioClient;

  @override
  Future<List<PostItem>> getFeed() async {
    try {
      final response = await _dioClient.get<dynamic>(ApiConstants.feed);
      final data = response.data;

      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(PostItem.fromJson)
            .toList();
      }

      if (data is Map<String, dynamic>) {
        final rawItems = data['data'] ?? data['items'] ?? data['feed'];
        if (rawItems is List) {
          return rawItems
              .whereType<Map<String, dynamic>>()
              .map(PostItem.fromJson)
              .toList();
        }
      }

      return <PostItem>[];
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to fetch feed: $e');
    }
  }

  @override
  Future<List<PostMediaItem>> uploadFiles(List<String> filePaths) async {
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
        final rawFiles = data['files'];
        if (rawFiles is List) {
          return rawFiles
              .whereType<Map<String, dynamic>>()
              .map(PostMediaItem.fromJson)
              .toList();
        }
        final rawUrls = data['fileUrls'];
        if (rawUrls is List) {
          return rawUrls
              .map((url) => PostMediaItem(url: url.toString()))
              .toList();
        }
      }
      return <PostMediaItem>[];
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to upload media files: $e');
    }
  }

  @override
  Future<PostItem> createPost({
    String? content,
    List<PostMediaItem>? mediaItems,
    String visibility = 'public',
  }) async {
    try {
      final payload = <String, dynamic>{
        'visibility': visibility,
      };
      if (content != null && content.isNotEmpty) {
        payload['content'] = content;
      }
      if (mediaItems != null && mediaItems.isNotEmpty) {
        payload['mediaItems'] = mediaItems.map((e) => e.toJson()).toList();
      }

      final response = await _dioClient.post<dynamic>(
        ApiConstants.posts,
        data: payload,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return PostItem.fromJson(data);
      }
      throw const ServerException('Invalid response format for created post');
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to create post: $e');
    }
  }

  @override
  Future<PostItem> updatePost({
    required String postId,
    String? content,
    List<PostMediaItem>? mediaItems,
    String? visibility,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (content != null) {
        payload['content'] = content;
      }
      if (mediaItems != null) {
        payload['mediaItems'] = mediaItems.map((e) => e.toJson()).toList();
      }
      if (visibility != null) {
        payload['visibility'] = visibility;
      }

      final response = await _dioClient.put<dynamic>(
        ApiConstants.postById(postId),
        data: payload,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return PostItem.fromJson(data);
      }
      throw const ServerException('Invalid response format for updated post');
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to update post: $e');
    }
  }

  @override
  Future<bool> deletePost(String postId) async {
    try {
      await _dioClient.delete<dynamic>(ApiConstants.postById(postId));
      return true;
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to delete post: $e');
    }
  }
}
