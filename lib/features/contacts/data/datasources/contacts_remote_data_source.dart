import 'package:lotus_connect/core/errors/exception.dart';
import 'package:lotus_connect/core/network/dio_client.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';

abstract class ContactsRemoteDataSource {
  Future<List<User>> contactsList() => throw UnimplementedError('Stub');
  Future<void> sendFriendRequest(String username) =>
      throw UnimplementedError('Stub');
  Future<void> acceptFriendRequest(String targetId) =>
      throw UnimplementedError('Stub');
  Future<void> rejectFriendRequest(String targetId) =>
      throw UnimplementedError('Stub');
  Future<List<User>> getFriendRequests() => throw UnimplementedError('Stub');
  Future<List<User>> searchUsers(String query) =>
      throw UnimplementedError('Stub');
}

class ContactsRemoteDataSourceImpl implements ContactsRemoteDataSource {
  const ContactsRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  final DioClient _dioClient;

  @override
  Future<List<User>> contactsList() async {
    try {
      final response = await _dioClient.get('/users/friends');
      final list = response.data as List<dynamic>;
      return list
          .map((item) => User.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get friends list: $e');
    }
  }

  @override
  Future<void> sendFriendRequest(String username) async {
    try {
      await _dioClient.post(
        '/users/friends',
        data: {'username': username},
      );
    } catch (e) {
      throw ServerException('Failed to send friend request: $e');
    }
  }

  @override
  Future<void> acceptFriendRequest(String targetId) async {
    try {
      await _dioClient.post(
        '/users/friends/accept',
        data: {'friendId': targetId},
      );
    } catch (e) {
      throw ServerException('Failed to accept friend request: $e');
    }
  }

  @override
  Future<void> rejectFriendRequest(String friendId) async {
    try {
      await _dioClient.post(
        '/users/friends/reject',
        data: {'friendId': friendId},
      );
    } catch (e) {
      throw ServerException('Failed to reject friend request: $e');
    }
  }

  @override
  Future<List<User>> getFriendRequests() async {
    try {
      final response = await _dioClient.get('/users/friends/requests');
      final list = response.data as List<dynamic>;
      return list
          .map((item) => User.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get friend requests: $e');
    }
  }

  @override
  Future<List<User>> searchUsers(String query) async {
    try {
      final response = await _dioClient.get(
        '/users/search',
        queryParameters: {'q': query},
      );
      final list = response.data as List<dynamic>;
      return list
          .map((item) => User.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException('Failed to search users: $e');
    }
  }
}
