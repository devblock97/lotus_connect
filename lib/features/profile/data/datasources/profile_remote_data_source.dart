import 'package:dio/dio.dart';
import 'package:lotus_connect/core/constants/api_constants.dart';
import 'package:lotus_connect/core/errors/exception.dart';
import 'package:lotus_connect/core/network/dio_client.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';
import 'package:lotus_connect/features/profile/domain/entities/profile_media_item.dart';
import 'package:lotus_connect/features/profile/domain/entities/update_profile_params.dart';
import 'package:lotus_connect/features/profile/domain/entities/user_profile.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfile> getMyProfile();

  Future<UserProfile> getUserProfile(String userId);

  Future<UserProfile> getUserProfileByUsername(String username);

  Future<UserProfile> updateMyProfile(UpdateProfileParams params);

  Future<String> uploadAvatar(String filePath);

  Future<UserProfile> uploadCover(String filePath);

  Future<List<PostItem>> getUserPosts({
    String? userId,
    String? filter,
    String? cursor,
    int? limit,
  });

  Future<List<ProfileMediaItem>> getUserMedia({
    String? userId,
    String? mediaType,
    String? cursor,
    int? limit,
  });

  Future<List<User>> getUserFriends({String? userId});

  Future<bool> setCloseFriend({
    required String friendId,
    required bool isCloseFriend,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  const ProfileRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  final DioClient _dioClient;

  @override
  Future<UserProfile> getMyProfile() async {
    try {
      final response = await _dioClient.get<dynamic>(ApiConstants.myProfile);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return UserProfile.fromJson(data);
      }
      throw const ServerException('Invalid response format for own profile');
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to fetch profile: $e');
    }
  }

  @override
  Future<UserProfile> getUserProfile(String userId) async {
    try {
      final response = await _dioClient.get<dynamic>(
        ApiConstants.userProfile(userId),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return UserProfile.fromJson(data);
      }
      throw const ServerException('Invalid response format for user profile');
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to fetch user profile: $e');
    }
  }

  @override
  Future<UserProfile> getUserProfileByUsername(String username) async {
    try {
      final response = await _dioClient.get<dynamic>(
        ApiConstants.userProfileByUsername(username),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return UserProfile.fromJson(data);
      }
      throw const ServerException(
        'Invalid response format for profile by username',
      );
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to fetch profile by username: $e');
    }
  }

  @override
  Future<UserProfile> updateMyProfile(UpdateProfileParams params) async {
    try {
      final response = await _dioClient.put<dynamic>(
        ApiConstants.updateMyProfile,
        data: params.toJson(),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return UserProfile.fromJson(data);
      }
      throw const ServerException(
        'Invalid response format for updated profile',
      );
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to update profile: $e');
    }
  }

  @override
  Future<String> uploadAvatar(String filePath) async {
    try {
      final fileName = filePath.split('/').last;
      final multipartFile = await MultipartFile.fromFile(
        filePath,
        filename: fileName.isNotEmpty ? fileName : 'avatar.jpg',
      );

      final formData = FormData.fromMap({
        'file': multipartFile,
      });

      final response = await _dioClient.post<dynamic>(
        ApiConstants.uploadAvatar,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final avatarUrl = data['avatarUrl'] ?? data['fileUrl'];
        if (avatarUrl is String && avatarUrl.isNotEmpty) {
          return avatarUrl;
        }
        final userMap = data['user'];
        if (userMap is Map<String, dynamic>) {
          final userAvatar = userMap['avatarUrl'];
          if (userAvatar is String && userAvatar.isNotEmpty) {
            return userAvatar;
          }
        }
      }
      throw const ServerException('Invalid response format for avatar upload');
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to upload avatar: $e');
    }
  }

  @override
  Future<UserProfile> uploadCover(String filePath) async {
    try {
      final fileName = filePath.split('/').last;
      final multipartFile = await MultipartFile.fromFile(
        filePath,
        filename: fileName.isNotEmpty ? fileName : 'cover.jpg',
      );

      final formData = FormData.fromMap({
        'file': multipartFile,
      });

      final response = await _dioClient.post<dynamic>(
        ApiConstants.uploadCover,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final userMap = data['user'];
        if (userMap is Map<String, dynamic>) {
          return UserProfile.fromJson(userMap);
        }
        if (data.containsKey('id') && data.containsKey('username')) {
          return UserProfile.fromJson(data);
        }
      }
      throw const ServerException('Invalid response format for cover upload');
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to upload cover photo: $e');
    }
  }

  @override
  Future<List<PostItem>> getUserPosts({
    String? userId,
    String? filter,
    String? cursor,
    int? limit,
  }) async {
    try {
      final endpoint = (userId == null || userId.isEmpty || userId == 'me')
          ? ApiConstants.myPosts
          : ApiConstants.userPosts(userId);

      final response = await _dioClient.get<dynamic>(
        endpoint,
        queryParameters: {
          if (filter != null && filter.isNotEmpty && filter != 'all')
            'filter': filter,
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
          if (limit != null) 'limit': limit,
        },
      );

      final data = response.data;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(PostItem.fromJson)
            .toList();
      }
      if (data is Map<String, dynamic>) {
        final rawItems = data['data'] ?? data['items'] ?? data['posts'];
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
      throw ServerException('Failed to fetch user posts: $e');
    }
  }

  @override
  Future<List<ProfileMediaItem>> getUserMedia({
    String? userId,
    String? mediaType,
    String? cursor,
    int? limit,
  }) async {
    try {
      final endpoint = (userId == null || userId.isEmpty || userId == 'me')
          ? ApiConstants.myMedia
          : ApiConstants.userMedia(userId);

      final response = await _dioClient.get<dynamic>(
        endpoint,
        queryParameters: {
          if (mediaType != null && mediaType.isNotEmpty && mediaType != 'all')
            'type': mediaType,
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
          if (limit != null) 'limit': limit,
        },
      );

      final data = response.data;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(ProfileMediaItem.fromJson)
            .toList();
      }
      if (data is Map<String, dynamic>) {
        final rawItems = data['data'] ?? data['items'] ?? data['media'];
        if (rawItems is List) {
          return rawItems
              .whereType<Map<String, dynamic>>()
              .map(ProfileMediaItem.fromJson)
              .toList();
        }
      }
      return <ProfileMediaItem>[];
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to fetch user media: $e');
    }
  }

  @override
  Future<List<User>> getUserFriends({String? userId}) async {
    try {
      final endpoint = (userId == null || userId.isEmpty || userId == 'me')
          ? ApiConstants.friends
          : ApiConstants.userFriends(userId);

      final response = await _dioClient.get<dynamic>(endpoint);
      final data = response.data;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(User.fromJson)
            .toList();
      }
      return <User>[];
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to fetch user friends: $e');
    }
  }

  @override
  Future<bool> setCloseFriend({
    required String friendId,
    required bool isCloseFriend,
  }) async {
    try {
      if (isCloseFriend) {
        await _dioClient.post<dynamic>(
          ApiConstants.closeFriends,
          data: {'friendId': friendId},
        );
      } else {
        await _dioClient.delete<dynamic>(
          ApiConstants.removeCloseFriend(friendId),
        );
      }
      return true;
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to update close friend status: $e');
    }
  }
}
