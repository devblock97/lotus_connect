import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/errors/exception.dart';
import 'package:lotus_connect/core/network/dio_client.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/chatbot/application/providers.dart';

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

  /// Rejects a friend request.
  Future<void> rejectFriendRequest(String friendId) async {
    try {
      await dioClient.post(
        '/users/friends/reject',
        data: {'friendId': friendId},
      );
    } catch (e) {
      throw ServerException('Failed to reject friend request: $e');
    }
  }

  /// Fetches the accepted friends list.
  Future<List<User>> getFriends() async {
    try {
      final response = await dioClient.get('/users/friends');
      final list = response.data as List<dynamic>;
      return list.map((item) => User.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ServerException('Failed to get friends list: $e');
    }
  }

  /// Fetches the pending friend requests.
  Future<List<User>> getFriendRequests() async {
    try {
      final response = await dioClient.get('/users/friends/requests');
      final list = response.data as List<dynamic>;
      return list.map((item) => User.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ServerException('Failed to get friend requests: $e');
    }
  }

  /// Searches users by username, email, or full name.
  Future<List<User>> searchUsers(String query) async {
    try {
      final response = await dioClient.get(
        '/users/search',
        queryParameters: {'q': query},
      );
      final list = response.data as List<dynamic>;
      return list.map((item) => User.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ServerException('Failed to search users: $e');
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

  Future<Map<String, dynamic>> sendMessage({
    required String conversationId,
    required String content,
    String? replyToId,
  }) async {
      try {
        final response = await dioClient.post(
          'chats/$conversationId/messages',
          data: {
            'content': content,
            if (replyToId != null) 'replyToId': replyToId,
          },
        );
        return response.data as Map<String, dynamic>;
      } catch (e) {
        throw ServerException('Failed to send message: $e');
      }
  }

  Future<Map<String, dynamic>> deleteMessage({required String messageId}) async {
    try {
      final response = await dioClient.delete(
        '/chats/messages/$messageId',
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw ServerException('Failed to delete message: $e');
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

  /// Fetches call logs history for the authenticated user.
  Future<List<Map<String, dynamic>>> getCallHistory() async {
    try {
      final response = await dioClient.get('/calls/history');
      final list = response.data as List<dynamic>;
      return list.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      throw ServerException('Failed to fetch call history: $e');
    }
  }

  /// Fetches the user's notification list.
  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final response = await dioClient.get('/users/notifications');
      final list = response.data as List<dynamic>;
      return list.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      throw ServerException('Failed to get notifications: $e');
    }
  }

  /// Marks all notifications as read.
  Future<void> markNotificationsRead() async {
    try {
      await dioClient.post('/users/notifications/read');
    } catch (e) {
      throw ServerException('Failed to mark notifications as read: $e');
    }
  }
}

/// Global provider for ChatApiService REST client.
final chatApiServiceProvider = Provider<ChatApiService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ChatApiService(dioClient: dioClient);
});
