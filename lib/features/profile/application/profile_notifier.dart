import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/utils/media_url_normalizer.dart';
import 'package:lotus_connect/features/contacts/domain/usecases/accept_friend_request_usecase.dart';
import 'package:lotus_connect/features/contacts/domain/usecases/delete_friend_usecase.dart';
import 'package:lotus_connect/features/contacts/domain/usecases/reject_friend_request_usecase.dart';
import 'package:lotus_connect/features/contacts/domain/usecases/send_friend_request_usecase.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';
import 'package:lotus_connect/features/home/domain/usecases/delete_post_usecase.dart';
import 'package:lotus_connect/features/profile/application/profile_state.dart';
import 'package:lotus_connect/features/profile/domain/entities/profile_media_item.dart';
import 'package:lotus_connect/features/profile/domain/entities/update_profile_params.dart';
import 'package:lotus_connect/features/profile/domain/entities/user_profile.dart';
import 'package:lotus_connect/features/profile/domain/usecases/get_profile_friends_usecase.dart';
import 'package:lotus_connect/features/profile/domain/usecases/get_profile_media_usecase.dart';
import 'package:lotus_connect/features/profile/domain/usecases/get_profile_posts_usecase.dart';
import 'package:lotus_connect/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:lotus_connect/features/profile/domain/usecases/set_close_friend_use_case.dart';
import 'package:lotus_connect/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:lotus_connect/features/profile/domain/usecases/upload_avatar_usecase.dart';
import 'package:lotus_connect/features/profile/domain/usecases/upload_cover_usecase.dart';

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier({
    required GetProfileUseCase getProfileUseCase,
    required GetProfilePostsUseCase getProfilePostsUseCase,
    required GetProfileMediaUseCase getProfileMediaUseCase,
    required GetProfileFriendsUseCase getProfileFriendsUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required UploadAvatarUseCase uploadAvatarUseCase,
    required UploadCoverUseCase uploadCoverUseCase,
    required SetCloseFriendUseCase setCloseFriendUseCase,
    this.deletePostUseCase,
    this.sendFriendRequestUseCase,
    this.acceptFriendRequestUseCase,
    this.rejectFriendRequestUseCase,
    this.deleteFriendUseCase,
    this.targetUserId,
    this.targetUsername,
    this.serverHost = '',
    this.currentUserId = '',
    this.onSelfProfileUpdated,
  })  : _getProfileUseCase = getProfileUseCase,
        _getProfilePostsUseCase = getProfilePostsUseCase,
        _getProfileMediaUseCase = getProfileMediaUseCase,
        _getProfileFriendsUseCase = getProfileFriendsUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        _uploadAvatarUseCase = uploadAvatarUseCase,
        _uploadCoverUseCase = uploadCoverUseCase,
        _setCloseFriendUseCase = setCloseFriendUseCase,
        super(const ProfileState());

  final GetProfileUseCase _getProfileUseCase;
  final GetProfilePostsUseCase _getProfilePostsUseCase;
  final GetProfileMediaUseCase _getProfileMediaUseCase;
  final GetProfileFriendsUseCase _getProfileFriendsUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final UploadAvatarUseCase _uploadAvatarUseCase;
  final UploadCoverUseCase _uploadCoverUseCase;
  final SetCloseFriendUseCase _setCloseFriendUseCase;

  final DeletePostUseCase? deletePostUseCase;
  final SendFriendRequestUseCase? sendFriendRequestUseCase;
  final AcceptFriendRequestUseCase? acceptFriendRequestUseCase;
  final RejectFriendRequestUseCase? rejectFriendRequestUseCase;
  final DeleteFriendUseCase? deleteFriendUseCase;

  final String? targetUserId;
  final String? targetUsername;
  final String serverHost;
  final String currentUserId;
  final void Function(UserProfile updatedProfile)? onSelfProfileUpdated;

  String? get _effectiveUserId {
    final loadedId = state.profile?.id;
    if (loadedId != null && loadedId.isNotEmpty) {
      if (state.profile!.isSelf) return 'me';
      return loadedId;
    }
    return targetUserId;
  }

  Future<void> loadAll() async {
    await loadProfile();
    if (!mounted) return;
    await Future.wait([
      loadPosts(),
      loadFriends(),
      loadPhotos(),
      loadVideos(),
    ]);
  }

  Future<void> refresh() async {
    await loadAll();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoadingProfile: true);

    final result = await _getProfileUseCase(
      GetProfileParams(
        userId: targetUserId,
        username: targetUsername,
      ),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingProfile: false,
          errorMessage: failure.message,
        );
      },
      (profile) {
        final normalized = serverHost.isNotEmpty
            ? profile.normalizedForHost(serverHost)
            : profile;
        state = state.copyWith(
          profile: normalized,
          isLoadingProfile: false,
        );
        if (normalized.isSelf) {
          onSelfProfileUpdated?.call(normalized);
        }
      },
    );
  }

  Future<void> loadPosts() async {
    state = state.copyWith(isLoadingPosts: true);

    final result = await _getProfilePostsUseCase(
      GetProfilePostsParams(
        userId: _effectiveUserId,
        filter: state.postFilter.apiValue,
      ),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingPosts: false,
          errorMessage: failure.message,
        );
      },
      (posts) {
        final normalizedPosts = _normalizePosts(posts);
        state = state.copyWith(
          posts: normalizedPosts,
          isLoadingPosts: false,
          postsCursor:
              normalizedPosts.isNotEmpty ? normalizedPosts.last.id : null,
          hasReachedMaxPosts: normalizedPosts.isEmpty,
        );
      },
    );
  }

  Future<void> loadMorePosts() async {
    if (state.isLoadingPosts ||
        state.isLoadingMorePosts ||
        state.hasReachedMaxPosts) {
      return;
    }

    state = state.copyWith(isLoadingMorePosts: true);

    final result = await _getProfilePostsUseCase(
      GetProfilePostsParams(
        userId: _effectiveUserId,
        filter: state.postFilter.apiValue,
        cursor: state.postsCursor,
        limit: 10,
      ),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingMorePosts: false,
          errorMessage: failure.message,
        );
      },
      (morePosts) {
        final normalizedMore = _normalizePosts(morePosts);
        final existingIds = state.posts.map((p) => p.id).toSet();
        final uniqueNew =
            normalizedMore.where((p) => !existingIds.contains(p.id)).toList();
        final merged = [...state.posts, ...uniqueNew];

        state = state.copyWith(
          posts: merged,
          isLoadingMorePosts: false,
          postsCursor: merged.isNotEmpty ? merged.last.id : state.postsCursor,
          hasReachedMaxPosts: uniqueNew.isEmpty,
        );
      },
    );
  }

  Future<void> loadPhotos() async {
    state = state.copyWith(isLoadingPhotos: true);

    final result = await _getProfileMediaUseCase(
      GetProfileMediaParams(
        userId: _effectiveUserId,
        mediaType: 'image',
      ),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingPhotos: false,
          errorMessage: failure.message,
        );
      },
      (items) {
        final normalized = _normalizeMedia(items);
        state = state.copyWith(
          photos: normalized,
          isLoadingPhotos: false,
          photosCursor: normalized.isNotEmpty ? normalized.last.postId : null,
          hasReachedMaxPhotos: normalized.isEmpty,
        );
      },
    );
  }

  Future<void> loadMorePhotos() async {
    if (state.isLoadingPhotos ||
        state.isLoadingMorePhotos ||
        state.hasReachedMaxPhotos) {
      return;
    }

    state = state.copyWith(isLoadingMorePhotos: true);

    final result = await _getProfileMediaUseCase(
      GetProfileMediaParams(
        userId: _effectiveUserId,
        mediaType: 'image',
        cursor: state.photosCursor,
      ),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingMorePhotos: false,
          errorMessage: failure.message,
        );
      },
      (moreItems) {
        final normalized = _normalizeMedia(moreItems);
        final existingKeys =
            state.photos.map((m) => '${m.postId}_${m.mediaIndex}').toSet();
        final uniqueNew = normalized
            .where((m) => !existingKeys.contains('${m.postId}_${m.mediaIndex}'))
            .toList();
        final merged = [...state.photos, ...uniqueNew];

        state = state.copyWith(
          photos: merged,
          isLoadingMorePhotos: false,
          photosCursor:
              merged.isNotEmpty ? merged.last.postId : state.photosCursor,
          hasReachedMaxPhotos: uniqueNew.isEmpty,
        );
      },
    );
  }

  Future<void> loadVideos() async {
    state = state.copyWith(isLoadingVideos: true);

    final result = await _getProfileMediaUseCase(
      GetProfileMediaParams(
        userId: _effectiveUserId,
        mediaType: 'video',
      ),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingVideos: false,
          errorMessage: failure.message,
        );
      },
      (items) {
        final normalized = _normalizeMedia(items);
        state = state.copyWith(
          videos: normalized,
          isLoadingVideos: false,
          videosCursor: normalized.isNotEmpty ? normalized.last.postId : null,
          hasReachedMaxVideos: normalized.isEmpty,
        );
      },
    );
  }

  Future<void> loadMoreVideos() async {
    if (state.isLoadingVideos ||
        state.isLoadingMoreVideos ||
        state.hasReachedMaxVideos) {
      return;
    }

    state = state.copyWith(isLoadingMoreVideos: true);

    final result = await _getProfileMediaUseCase(
      GetProfileMediaParams(
        userId: _effectiveUserId,
        mediaType: 'video',
        cursor: state.videosCursor,
      ),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingMoreVideos: false,
          errorMessage: failure.message,
        );
      },
      (moreItems) {
        final normalized = _normalizeMedia(moreItems);
        final existingKeys =
            state.videos.map((m) => '${m.postId}_${m.mediaIndex}').toSet();
        final uniqueNew = normalized
            .where((m) => !existingKeys.contains('${m.postId}_${m.mediaIndex}'))
            .toList();
        final merged = [...state.videos, ...uniqueNew];

        state = state.copyWith(
          videos: merged,
          isLoadingMoreVideos: false,
          videosCursor:
              merged.isNotEmpty ? merged.last.postId : state.videosCursor,
          hasReachedMaxVideos: uniqueNew.isEmpty,
        );
      },
    );
  }

  Future<void> loadFriends() async {
    final uid = state.profile?.id ?? targetUserId;
    state = state.copyWith(isLoadingFriends: true);

    final result = await _getProfileFriendsUseCase(uid);

    if (!mounted) return;

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingFriends: false,
          errorMessage: failure.message,
        );
      },
      (friends) {
        final normalizedFriends = friends
            .map(
              (u) => u.copyWith(
                avatarUrl: u.avatarUrl != null && u.avatarUrl!.isNotEmpty
                    ? normalizeMediaUrl(
                        u.avatarUrl!,
                        serverHost: serverHost,
                      )
                    : u.avatarUrl,
              ),
            )
            .toList();
        state = state.copyWith(
          friends: normalizedFriends,
          isLoadingFriends: false,
        );
      },
    );
  }

  void setActiveTab(ProfileTab tab) {
    if (state.activeTab == tab) return;
    state = state.copyWith(activeTab: tab);
    if (tab == ProfileTab.photos &&
        state.photos.isEmpty &&
        !state.isLoadingPhotos) {
      unawaited(loadPhotos());
    } else if (tab == ProfileTab.videos &&
        state.videos.isEmpty &&
        !state.isLoadingVideos) {
      unawaited(loadVideos());
    }
  }

  Future<void> setPostFilter(ProfilePostFilter filter) async {
    if (state.postFilter == filter) return;
    state = state.copyWith(
      postFilter: filter,
      hasReachedMaxPosts: false,
    );
    await loadPosts();
  }

  Future<bool> updateProfile(UpdateProfileParams params) async {
    state = state.copyWith(isUpdatingProfile: true);

    final result = await _updateProfileUseCase(params);
    if (!mounted) return false;

    return result.fold(
      (failure) {
        state = state.copyWith(
          isUpdatingProfile: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (updatedProfile) {
        final normalized = serverHost.isNotEmpty
            ? updatedProfile.normalizedForHost(serverHost)
            : updatedProfile;
        state = state.copyWith(
          profile: normalized,
          isUpdatingProfile: false,
        );
        onSelfProfileUpdated?.call(normalized);
        return true;
      },
    );
  }

  Future<bool> uploadAvatar(String filePath) async {
    state = state.copyWith(isUploadingAvatar: true);

    final result = await _uploadAvatarUseCase(filePath);
    if (!mounted) return false;

    return result.fold(
      (failure) {
        state = state.copyWith(
          isUploadingAvatar: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (newAvatarUrl) {
        final normalizedUrl = serverHost.isNotEmpty
            ? normalizeMediaUrl(newAvatarUrl, serverHost: serverHost)
            : newAvatarUrl;
        final currentProfile = state.profile;
        if (currentProfile != null) {
          final updated = currentProfile.copyWith(avatarUrl: normalizedUrl);
          state = state.copyWith(
            profile: updated,
            isUploadingAvatar: false,
          );
          if (updated.isSelf) {
            onSelfProfileUpdated?.call(updated);
          }
        } else {
          state = state.copyWith(isUploadingAvatar: false);
        }
        return true;
      },
    );
  }

  Future<bool> uploadCover(String filePath) async {
    state = state.copyWith(isUploadingCover: true);

    final result = await _uploadCoverUseCase(filePath);
    if (!mounted) return false;

    return result.fold(
      (failure) {
        state = state.copyWith(
          isUploadingCover: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (updatedProfile) {
        final normalized = serverHost.isNotEmpty
            ? updatedProfile.normalizedForHost(serverHost)
            : updatedProfile;
        state = state.copyWith(
          profile: normalized,
          isUploadingCover: false,
        );
        if (normalized.isSelf) {
          onSelfProfileUpdated?.call(normalized);
        }
        return true;
      },
    );
  }

  Future<bool> sendFriendRequest() async {
    final profile = state.profile;
    final useCase = sendFriendRequestUseCase;
    if (profile == null || useCase == null) return false;

    state = state.copyWith(isMutatingFriendship: true);
    final result = await useCase(
      SendFriendRequestParam(username: profile.username),
    );
    if (!mounted) return false;

    return result.fold(
      (failure) {
        state = state.copyWith(
          isMutatingFriendship: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(
          isMutatingFriendship: false,
          profile: profile.copyWith(
            friendshipStatus: 'pending',
            friendshipSenderId:
                currentUserId.isNotEmpty ? currentUserId : profile.id,
          ),
        );
        return true;
      },
    );
  }

  Future<bool> acceptFriendRequest() async {
    final profile = state.profile;
    final useCase = acceptFriendRequestUseCase;
    if (profile == null || useCase == null) return false;

    state = state.copyWith(isMutatingFriendship: true);
    final result = await useCase(
      AcceptFriendRequestParam(targetId: profile.id),
    );
    if (!mounted) return false;

    return result.fold(
      (failure) {
        state = state.copyWith(
          isMutatingFriendship: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(
          isMutatingFriendship: false,
          profile: profile.copyWith(
            friendshipStatus: 'accepted',
            friendCount: profile.friendCount + 1,
          ),
        );
        unawaited(loadAll());
        return true;
      },
    );
  }

  Future<bool> rejectFriendRequest() async {
    final profile = state.profile;
    final useCase = rejectFriendRequestUseCase;
    if (profile == null || useCase == null) return false;

    state = state.copyWith(isMutatingFriendship: true);
    final result = await useCase(
      RejectFriendRequestParam(targetId: profile.id),
    );
    if (!mounted) return false;

    return result.fold(
      (failure) {
        state = state.copyWith(
          isMutatingFriendship: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(
          isMutatingFriendship: false,
          profile: profile.copyWith(
            clearFriendshipStatus: true,
            clearFriendshipSenderId: true,
          ),
        );
        return true;
      },
    );
  }

  Future<bool> unfriend() async {
    final profile = state.profile;
    final useCase = deleteFriendUseCase;
    if (profile == null || useCase == null) return false;

    state = state.copyWith(isMutatingFriendship: true);
    final result = await useCase(
      DeleteFriendParam(friendId: profile.id),
    );
    if (!mounted) return false;

    return result.fold(
      (failure) {
        state = state.copyWith(
          isMutatingFriendship: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        final nextCount = profile.friendCount > 0 ? profile.friendCount - 1 : 0;
        state = state.copyWith(
          isMutatingFriendship: false,
          profile: profile.copyWith(
            clearFriendshipStatus: true,
            clearFriendshipSenderId: true,
            isCloseFriend: false,
            friendCount: nextCount,
          ),
        );
        unawaited(loadAll());
        return true;
      },
    );
  }

  Future<bool> toggleCloseFriend() async {
    final profile = state.profile;
    if (profile == null) return false;

    final nextCloseFriend = !profile.isCloseFriend;
    final result = await _setCloseFriendUseCase(
      SetCloseFriendParam(
        friendId: profile.id,
        isCloseFriend: nextCloseFriend,
      ),
    );
    if (!mounted) return false;

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(
          profile: profile.copyWith(isCloseFriend: nextCloseFriend),
        );
        return true;
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Post Interactions on Profile Timeline
  // ---------------------------------------------------------------------------

  void toggleLike(String postId, {required bool isLiked}) {
    state = state.copyWith(
      posts: state.posts.map((post) {
        if (post.id == postId) {
          final newCount = isLiked
              ? post.likeCount + 1
              : (post.likeCount > 0 ? post.likeCount - 1 : 0);
          return post.copyWith(
            userHasLiked: isLiked,
            likeCount: newCount,
          );
        }
        return post;
      }).toList(),
    );
  }

  void toggleSave(String postId, {required bool isSaved}) {
    state = state.copyWith(
      posts: state.posts.map((post) {
        if (post.id == postId) {
          return post.copyWith(isSaved: isSaved);
        }
        return post;
      }).toList(),
    );
  }

  void addPost(PostItem post) {
    final normalized = _normalizePosts([post]).first;
    final currentProfile = state.profile;
    state = state.copyWith(
      posts: [normalized, ...state.posts],
      profile: currentProfile?.copyWith(
        postCount: currentProfile.postCount + 1,
        mediaCount: currentProfile.mediaCount + normalized.mediaItems.length,
      ),
    );
  }

  void updatePost(PostItem updatedPost) {
    final normalized = _normalizePosts([updatedPost]).first;
    state = state.copyWith(
      posts: state.posts.map((p) {
        return p.id == normalized.id ? normalized : p;
      }).toList(),
    );
  }

  Future<bool> deletePost(String postId) async {
    final useCase = deletePostUseCase;
    if (useCase != null) {
      final result = await useCase(DeletePostParams(postId));
      if (!mounted) return false;
      return result.fold(
        (failure) {
          state = state.copyWith(errorMessage: failure.message);
          return false;
        },
        (_) {
          removePost(postId);
          return true;
        },
      );
    }
    removePost(postId);
    return true;
  }

  void removePost(String postId) {
    final removedPost = state.posts.where((p) => p.id == postId).firstOrNull;
    final nextPosts = state.posts.where((p) => p.id != postId).toList();
    final nextPhotos = state.photos.where((m) => m.postId != postId).toList();
    final nextVideos = state.videos.where((m) => m.postId != postId).toList();
    final currentProfile = state.profile;

    state = state.copyWith(
      posts: nextPosts,
      photos: nextPhotos,
      videos: nextVideos,
      profile: currentProfile?.copyWith(
        postCount:
            currentProfile.postCount > 0 ? currentProfile.postCount - 1 : 0,
        mediaCount: removedPost != null
            ? (currentProfile.mediaCount - removedPost.mediaItems.length)
                .clamp(0, 1 << 30)
            : currentProfile.mediaCount,
      ),
    );
  }

  List<PostItem> _normalizePosts(List<PostItem> items) {
    if (serverHost.isEmpty) return items;
    return items.map((post) {
      final authorAvatar = post.author.avatarUrl;
      return post.copyWith(
        author: post.author.copyWith(
          avatarUrl: authorAvatar != null && authorAvatar.isNotEmpty
              ? normalizeMediaUrl(authorAvatar, serverHost: serverHost)
              : authorAvatar,
        ),
        mediaItems: post.mediaItems
            .map((m) => m.normalizedForHost(serverHost))
            .toList(),
      );
    }).toList();
  }

  List<ProfileMediaItem> _normalizeMedia(List<ProfileMediaItem> items) {
    if (serverHost.isEmpty) return items;
    return items.map((m) => m.normalizedForHost(serverHost)).toList();
  }
}
