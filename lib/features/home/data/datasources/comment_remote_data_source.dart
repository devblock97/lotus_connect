import 'package:dio/dio.dart';
import 'package:lotus_connect/core/constants/api_constants.dart';
import 'package:lotus_connect/core/errors/exception.dart';
import 'package:lotus_connect/core/network/dio_client.dart';
import 'package:lotus_connect/features/home/data/models/comment_model.dart';

abstract class CommentRemoteDataSource {
  Future<List<CommentModel>> getComments({
    required String postId,
    String? cursor,
    int? limit,
    String? sort,
  });

  Future<CommentModel> createComment({
    required String postId,
    required String content,
    String? parentCommentId,
    String? mediaUrl,
  });

  Future<CommentModel> getCommentById({
    required String postId,
    required String commentId,
  });

  Future<List<CommentModel>> getCommentReplies({
    required String postId,
    required String commentId,
    String? cursor,
    int? limit,
  });

  Future<CommentModel> updateComment({
    required String postId,
    required String commentId,
    required String content,
    String? mediaUrl,
  });

  Future<bool> deleteComment({
    required String postId,
    required String commentId,
  });

  Future<void> addCommentReaction({
    required String postId,
    required String commentId,
    String reaction = 'like',
  });

  Future<void> removeCommentReaction({
    required String postId,
    required String commentId,
  });

  Future<void> pinComment({
    required String postId,
    required String commentId,
  });

  Future<void> unpinComment({
    required String postId,
    required String commentId,
  });

  Future<String> uploadMedia({required String filePath});
}

class CommentRemoteDataSourceImpl implements CommentRemoteDataSource {
  const CommentRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  final DioClient _dioClient;

  @override
  Future<List<CommentModel>> getComments({
    required String postId,
    String? cursor,
    int? limit,
    String? sort,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (cursor != null && cursor.isNotEmpty) queryParams['cursor'] = cursor;
      if (limit != null) queryParams['limit'] = limit;
      if (sort != null && sort.isNotEmpty) queryParams['sort'] = sort;

      final response = await _dioClient.get<dynamic>(
        ApiConstants.postComments(postId),
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final data = response.data;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(CommentModel.fromJson)
            .toList();
      }

      if (data is Map<String, dynamic>) {
        final rawItems = data['data'] ?? data['items'] ?? data['comments'];
        if (rawItems is List) {
          return rawItems
              .whereType<Map<String, dynamic>>()
              .map(CommentModel.fromJson)
              .toList();
        }
      }

      return <CommentModel>[];
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to fetch comments: $e');
    }
  }

  @override
  Future<CommentModel> createComment({
    required String postId,
    required String content,
    String? parentCommentId,
    String? mediaUrl,
  }) async {
    try {
      final payload = <String, dynamic>{
        'content': content,
      };
      if (parentCommentId != null && parentCommentId.isNotEmpty) {
        payload['parentCommentId'] = parentCommentId;
        payload['parent_comment_id'] = parentCommentId;
      }
      if (mediaUrl != null && mediaUrl.isNotEmpty) {
        payload['mediaUrl'] = mediaUrl;
        payload['media_url'] = mediaUrl;
      }

      final response = await _dioClient.post<dynamic>(
        ApiConstants.postComments(postId),
        data: payload,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final commentData = data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : data;
        return CommentModel.fromJson(commentData);
      }

      throw const ServerException(
        'Invalid response format for created comment',
      );
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to create comment: $e');
    }
  }

  @override
  Future<CommentModel> getCommentById({
    required String postId,
    required String commentId,
  }) async {
    try {
      final response = await _dioClient.get<dynamic>(
        ApiConstants.postCommentById(postId, commentId),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final commentData = data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : data;
        return CommentModel.fromJson(commentData);
      }

      throw const ServerException('Invalid response format for comment');
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to fetch comment: $e');
    }
  }

  @override
  Future<List<CommentModel>> getCommentReplies({
    required String postId,
    required String commentId,
    String? cursor,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (cursor != null && cursor.isNotEmpty) queryParams['cursor'] = cursor;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _dioClient.get<dynamic>(
        ApiConstants.postCommentReplies(postId, commentId),
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final data = response.data;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(CommentModel.fromJson)
            .toList();
      }

      if (data is Map<String, dynamic>) {
        final rawItems = data['data'] ?? data['items'] ?? data['replies'];
        if (rawItems is List) {
          return rawItems
              .whereType<Map<String, dynamic>>()
              .map(CommentModel.fromJson)
              .toList();
        }
      }

      return <CommentModel>[];
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to fetch comment replies: $e');
    }
  }

  @override
  Future<CommentModel> updateComment({
    required String postId,
    required String commentId,
    required String content,
    String? mediaUrl,
  }) async {
    try {
      final payload = <String, dynamic>{
        'content': content,
      };
      if (mediaUrl != null) {
        payload['mediaUrl'] = mediaUrl;
        payload['media_url'] = mediaUrl;
      }

      final response = await _dioClient.put<dynamic>(
        ApiConstants.postCommentById(postId, commentId),
        data: payload,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final commentData = data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : data;
        return CommentModel.fromJson(commentData);
      }

      throw const ServerException(
        'Invalid response format for updated comment',
      );
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to update comment: $e');
    }
  }

  @override
  Future<bool> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      await _dioClient.delete<dynamic>(
        ApiConstants.postCommentById(postId, commentId),
      );
      return true;
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to delete comment: $e');
    }
  }

  @override
  Future<void> addCommentReaction({
    required String postId,
    required String commentId,
    String reaction = 'like',
  }) async {
    try {
      await _dioClient.post<dynamic>(
        ApiConstants.postCommentReactions(postId, commentId),
        data: {'reaction': reaction},
      );
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to react to comment: $e');
    }
  }

  @override
  Future<void> removeCommentReaction({
    required String postId,
    required String commentId,
  }) async {
    try {
      await _dioClient.delete<dynamic>(
        ApiConstants.postCommentReactions(postId, commentId),
      );
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to remove comment reaction: $e');
    }
  }

  @override
  Future<void> pinComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      await _dioClient.post<dynamic>(
        ApiConstants.postCommentPin(postId, commentId),
      );
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to pin comment: $e');
    }
  }

  @override
  Future<void> unpinComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      await _dioClient.delete<dynamic>(
        ApiConstants.postCommentPin(postId, commentId),
      );
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to unpin comment: $e');
    }
  }

  @override
  Future<String> uploadMedia({required String filePath}) async {
    try {
      final cleanPath = filePath.startsWith('file://')
          ? filePath.replaceFirst('file://', '')
          : filePath;
      final fileName = cleanPath.split('/').last;
      final multipartFile = await MultipartFile.fromFile(
        cleanPath,
        filename: fileName,
      );

      final formData = FormData.fromMap({
        'files': [multipartFile],
      });

      final response = await _dioClient.post<dynamic>(
        ApiConstants.uploadMultiple,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final rawUrls = data['fileUrls'];
        if (rawUrls is List && rawUrls.isNotEmpty) {
          return rawUrls.first.toString();
        }
        final rawFiles = data['files'];
        if (rawFiles is List && rawFiles.isNotEmpty) {
          final first = rawFiles.first;
          if (first is Map<String, dynamic> && first['url'] != null) {
            return first['url'].toString();
          }
        }
        if (data['url'] != null) {
          return data['url'].toString();
        }
      }
      throw const ServerException('Upload response missing file URL');
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to upload media: $e');
    }
  }
}
