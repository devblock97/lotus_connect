import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/logging/app_logger.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';
import 'package:lotus_connect/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:lotus_connect/features/profile/domain/entities/profile_media_item.dart';
import 'package:lotus_connect/features/profile/domain/entities/update_profile_params.dart';
import 'package:lotus_connect/features/profile/domain/entities/user_profile.dart';
import 'package:lotus_connect/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl({
    required ProfileRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  FutureResult<UserProfile> getMyProfile() async {
    try {
      final profile = await _remoteDataSource.getMyProfile();
      return Right(profile);
    } on Object catch (e) {
      AppLogger.error('ProfileRepositoryImpl.getMyProfile error: $e');
      return Left(ServerFailure('Failed to load profile: $e'));
    }
  }

  @override
  FutureResult<UserProfile> getUserProfile(String userId) async {
    try {
      final profile = await _remoteDataSource.getUserProfile(userId);
      return Right(profile);
    } on Object catch (e) {
      AppLogger.error('ProfileRepositoryImpl.getUserProfile error: $e');
      return Left(ServerFailure('Failed to load user profile: $e'));
    }
  }

  @override
  FutureResult<UserProfile> getUserProfileByUsername(String username) async {
    try {
      final profile =
          await _remoteDataSource.getUserProfileByUsername(username);
      return Right(profile);
    } on Object catch (e) {
      AppLogger.error(
        'ProfileRepositoryImpl.getUserProfileByUsername error: $e',
      );
      return Left(ServerFailure('Failed to load user profile: $e'));
    }
  }

  @override
  FutureResult<UserProfile> updateMyProfile(UpdateProfileParams params) async {
    try {
      final profile = await _remoteDataSource.updateMyProfile(params);
      return Right(profile);
    } on Object catch (e) {
      AppLogger.error('ProfileRepositoryImpl.updateMyProfile error: $e');
      return Left(ServerFailure('Failed to update profile: $e'));
    }
  }

  @override
  FutureResult<String> uploadAvatar(String filePath) async {
    try {
      final url = await _remoteDataSource.uploadAvatar(filePath);
      return Right(url);
    } on Object catch (e) {
      AppLogger.error('ProfileRepositoryImpl.uploadAvatar error: $e');
      return Left(ServerFailure('Failed to upload avatar: $e'));
    }
  }

  @override
  FutureResult<UserProfile> uploadCover(String filePath) async {
    try {
      final profile = await _remoteDataSource.uploadCover(filePath);
      return Right(profile);
    } on Object catch (e) {
      AppLogger.error('ProfileRepositoryImpl.uploadCover error: $e');
      return Left(ServerFailure('Failed to upload cover photo: $e'));
    }
  }

  @override
  FutureResult<List<PostItem>> getUserPosts({
    String? userId,
    String? filter,
    String? cursor,
    int? limit,
  }) async {
    try {
      final posts = await _remoteDataSource.getUserPosts(
        userId: userId,
        filter: filter,
        cursor: cursor,
        limit: limit,
      );
      return Right(posts);
    } on Object catch (e) {
      AppLogger.error('ProfileRepositoryImpl.getUserPosts error: $e');
      return Left(ServerFailure('Failed to load user posts: $e'));
    }
  }

  @override
  FutureResult<List<ProfileMediaItem>> getUserMedia({
    String? userId,
    String? mediaType,
    String? cursor,
    int? limit,
  }) async {
    try {
      final media = await _remoteDataSource.getUserMedia(
        userId: userId,
        mediaType: mediaType,
        cursor: cursor,
        limit: limit,
      );
      return Right(media);
    } on Object catch (e) {
      AppLogger.error('ProfileRepositoryImpl.getUserMedia error: $e');
      return Left(ServerFailure('Failed to load user media: $e'));
    }
  }

  @override
  FutureResult<List<User>> getUserFriends({String? userId}) async {
    try {
      final friends = await _remoteDataSource.getUserFriends(userId: userId);
      return Right(friends);
    } on Object catch (e) {
      AppLogger.error('ProfileRepositoryImpl.getUserFriends error: $e');
      return Left(ServerFailure('Failed to load user friends: $e'));
    }
  }

  @override
  FutureResult<bool> setCloseFriend({
    required String friendId,
    required bool isCloseFriend,
  }) async {
    try {
      final success = await _remoteDataSource.setCloseFriend(
        friendId: friendId,
        isCloseFriend: isCloseFriend,
      );
      return Right(success);
    } on Object catch (e) {
      AppLogger.error('ProfileRepositoryImpl.setCloseFriend error: $e');
      return Left(ServerFailure('Failed to update close friend status: $e'));
    }
  }
}
