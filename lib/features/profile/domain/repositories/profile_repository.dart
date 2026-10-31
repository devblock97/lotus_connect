import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';
import 'package:lotus_connect/features/profile/domain/entities/profile_media_item.dart';
import 'package:lotus_connect/features/profile/domain/entities/update_profile_params.dart';
import 'package:lotus_connect/features/profile/domain/entities/user_profile.dart';

abstract class ProfileRepository {
  FutureResult<UserProfile> getMyProfile();

  FutureResult<UserProfile> getUserProfile(String userId);

  FutureResult<UserProfile> getUserProfileByUsername(String username);

  FutureResult<UserProfile> updateMyProfile(UpdateProfileParams params);

  FutureResult<String> uploadAvatar(String filePath);

  FutureResult<UserProfile> uploadCover(String filePath);

  FutureResult<List<PostItem>> getUserPosts({
    String? userId,
    String? filter,
    String? cursor,
    int? limit,
  });

  FutureResult<List<ProfileMediaItem>> getUserMedia({
    String? userId,
    String? mediaType,
    String? cursor,
    int? limit,
  });

  FutureResult<List<User>> getUserFriends({String? userId});

  FutureResult<bool> setCloseFriend({
    required String friendId,
    required bool isCloseFriend,
  });
}
