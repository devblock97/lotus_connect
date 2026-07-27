import 'package:dio/dio.dart';
import 'package:lotus_connect/core/errors/exception.dart';
import 'package:lotus_connect/core/network/dio_client.dart';

/// REST client service managing friends, file uploads, push notifications, and private chats.
class ChatApiService {
  ChatApiService({required this.dioClient});

  final DioClient dioClient;

  /// Sends a friend request.
  Future<void> sendFriendRequest(String username) async {
    try {
      await dioClient.post(
        '/users/friends',
        data: {'username': username},
      );
    } catch (e) {
      throw ServerException('Failed to send friend request: $e');
    }
  }

  /// Accepts a friend request.
  Future<void> acceptFriendRequest(String friendId) async {
    try {
      await dioClient.post(
        '/users/friends/accept',
        data: {'friendId': friendId},
      );
    } catch (e) {
      throw ServerException('Failed to accept friend request: $e');
    }
  }

  /// Creates a new private conversation with a friend.
  Future<Map<String, dynamic>> createPrivateChat(String friendId) async {
    try {
      final response = await dioClient.post(
        '/chats/private',
        data: {'friendId': friendId},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw ServerException('Failed to create private chat: $e');
    }
  }

  /// Fetches conversation messages with cursor pagination.
  Future<List<Map<String, dynamic>>> getMessages({
    required String conversationId,
    String? cursor,
    int limit = 20,
  }) async {
    try {
      final response = await dioClient.get(
        '/chats/$conversationId/messages',
        queryParameters: {
          if (cursor != null) 'cursor': cursor,
          'limit': limit,
        },
      );
      final list = response.data as List<dynamic>;
      return list.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      throw ServerException('Failed to fetch messages: $e');
    }
  }

  /// Uploads binary files using multipart/form-data.
  Future<String> uploadFile({
    required String filePath,
    required String fileName,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      final response = await dioClient.post(
        '/uploads',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      final data = response.data as Map<String, dynamic>;
      return data['fileUrl'] as String;
    } catch (e) {
      throw ServerException('Failed to upload file: $e');
    }
  }

  /// Registers a FCM/APNS push token for background notifications.
  Future<void> registerDeviceToken({
    required String token,
    required String platform, // "ios" or "android"
  }) async {
    try {
      await dioClient.post(
        '/users/devices',
        data: {
          'token': token,
          'platform': platform,
        },
      );
    } catch (e) {
      throw ServerException('Failed to register device token: $e');
    }
  }
}
