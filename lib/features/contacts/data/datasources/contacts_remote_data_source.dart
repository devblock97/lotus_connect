import 'package:lotus_connect/core/entities/response_entity_base.dart';
import 'package:lotus_connect/core/errors/exception.dart';
import 'package:lotus_connect/core/network/dio_client.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';

abstract class ContactsRemoteDataSource {
  Future<List<User>> contactsList() => throw UnimplementedError('Stub');
  Future<void> sendFriendRequest(String username) =>
      throw UnimplementedError('Stub');
  Future<ResponseEntityBase> acceptFriendRequest(String targetId) =>
      throw UnimplementedError('Stub');
  Future<ResponseEntityBase> rejectFriendRequest(String targetId) =>
      throw UnimplementedError('Stub');
  Future<ResponseEntityBase> deleteFriend(String friendId) =>
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
  Future<ResponseEntityBase> acceptFriendRequest(String targetId) async {
    try {
      final response = await _dioClient.post(
        '/users/friends/accept',
        data: {'friendId': targetId},
      );
      return ResponseEntityBase.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ServerException('Failed to accept friend request: $e');
    }
  }

  @override
  Future<ResponseEntityBase> rejectFriendRequest(String friendId) async {
    try {
      final response = await _dioClient.post(
        '/users/friends/reject',
        data: {'friendId': friendId},
      );
      return ResponseEntityBase.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ServerException('Failed to reject friend request: $e');
    }
  }

  @override
  Future<ResponseEntityBase> deleteFriend(String friendId) async {
    try {
      final response = await _dioClient.delete(
        '/users/friends/$friendId',
      );
      return ResponseEntityBase.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ServerException('Failed to delete friend: $e');
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
