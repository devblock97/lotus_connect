import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';
import 'package:lotus_connect/features/profile/domain/entities/profile_media_item.dart';
import 'package:lotus_connect/features/profile/domain/entities/user_profile.dart';

enum ProfileTab {
  posts,
  photos,
  videos,
  about,
}

enum ProfilePostFilter {
  all('all'),
  media('media'),
  video('video');

  const ProfilePostFilter(this.apiValue);
  final String apiValue;
}

@immutable
class ProfileState extends Equatable {
  const ProfileState({
    this.profile,
    this.posts = const [],
    this.photos = const [],
    this.videos = const [],
    this.friends = const [],
    this.activeTab = ProfileTab.posts,
    this.postFilter = ProfilePostFilter.all,
    this.isLoadingProfile = false,
    this.isLoadingPosts = false,
    this.isLoadingMorePosts = false,
    this.isLoadingPhotos = false,
    this.isLoadingMorePhotos = false,
    this.isLoadingVideos = false,
    this.isLoadingMoreVideos = false,
    this.isLoadingFriends = false,
    this.isUpdatingProfile = false,
    this.isUploadingAvatar = false,
    this.isUploadingCover = false,
    this.isMutatingFriendship = false,
    this.postsCursor,
    this.hasReachedMaxPosts = false,
    this.photosCursor,
    this.hasReachedMaxPhotos = false,
    this.videosCursor,
    this.hasReachedMaxVideos = false,
    this.errorMessage,
  });

  final UserProfile? profile;
  final List<PostItem> posts;
  final List<ProfileMediaItem> photos;
  final List<ProfileMediaItem> videos;
  final List<User> friends;
  final ProfileTab activeTab;
  final ProfilePostFilter postFilter;

  final bool isLoadingProfile;
  final bool isLoadingPosts;
  final bool isLoadingMorePosts;
  final bool isLoadingPhotos;
  final bool isLoadingMorePhotos;
  final bool isLoadingVideos;
  final bool isLoadingMoreVideos;
  final bool isLoadingFriends;

  final bool isUpdatingProfile;
  final bool isUploadingAvatar;
  final bool isUploadingCover;
  final bool isMutatingFriendship;

  final String? postsCursor;
  final bool hasReachedMaxPosts;
  final String? photosCursor;
  final bool hasReachedMaxPhotos;
  final String? videosCursor;
  final bool hasReachedMaxVideos;

  final String? errorMessage;

  ProfileState copyWith({
    UserProfile? profile,
    List<PostItem>? posts,
    List<ProfileMediaItem>? photos,
    List<ProfileMediaItem>? videos,
    List<User>? friends,
    ProfileTab? activeTab,
    ProfilePostFilter? postFilter,
    bool? isLoadingProfile,
    bool? isLoadingPosts,
    bool? isLoadingMorePosts,
    bool? isLoadingPhotos,
    bool? isLoadingMorePhotos,
    bool? isLoadingVideos,
    bool? isLoadingMoreVideos,
    bool? isLoadingFriends,
    bool? isUpdatingProfile,
    bool? isUploadingAvatar,
    bool? isUploadingCover,
    bool? isMutatingFriendship,
    String? postsCursor,
    bool? hasReachedMaxPosts,
    String? photosCursor,
    bool? hasReachedMaxPhotos,
    String? videosCursor,
    bool? hasReachedMaxVideos,
    String? errorMessage,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      posts: posts ?? this.posts,
      photos: photos ?? this.photos,
      videos: videos ?? this.videos,
      friends: friends ?? this.friends,
      activeTab: activeTab ?? this.activeTab,
      postFilter: postFilter ?? this.postFilter,
      isLoadingProfile: isLoadingProfile ?? this.isLoadingProfile,
      isLoadingPosts: isLoadingPosts ?? this.isLoadingPosts,
      isLoadingMorePosts: isLoadingMorePosts ?? this.isLoadingMorePosts,
      isLoadingPhotos: isLoadingPhotos ?? this.isLoadingPhotos,
      isLoadingMorePhotos: isLoadingMorePhotos ?? this.isLoadingMorePhotos,
      isLoadingVideos: isLoadingVideos ?? this.isLoadingVideos,
      isLoadingMoreVideos: isLoadingMoreVideos ?? this.isLoadingMoreVideos,
      isLoadingFriends: isLoadingFriends ?? this.isLoadingFriends,
      isUpdatingProfile: isUpdatingProfile ?? this.isUpdatingProfile,
      isUploadingAvatar: isUploadingAvatar ?? this.isUploadingAvatar,
      isUploadingCover: isUploadingCover ?? this.isUploadingCover,
      isMutatingFriendship: isMutatingFriendship ?? this.isMutatingFriendship,
      postsCursor: postsCursor ?? this.postsCursor,
      hasReachedMaxPosts: hasReachedMaxPosts ?? this.hasReachedMaxPosts,
      photosCursor: photosCursor ?? this.photosCursor,
      hasReachedMaxPhotos: hasReachedMaxPhotos ?? this.hasReachedMaxPhotos,
      videosCursor: videosCursor ?? this.videosCursor,
      hasReachedMaxVideos: hasReachedMaxVideos ?? this.hasReachedMaxVideos,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        profile,
        posts,
        photos,
        videos,
        friends,
        activeTab,
        postFilter,
        isLoadingProfile,
        isLoadingPosts,
        isLoadingMorePosts,
        isLoadingPhotos,
        isLoadingMorePhotos,
        isLoadingVideos,
        isLoadingMoreVideos,
        isLoadingFriends,
        isUpdatingProfile,
        isUploadingAvatar,
        isUploadingCover,
        isMutatingFriendship,
        postsCursor,
        hasReachedMaxPosts,
        photosCursor,
        hasReachedMaxPhotos,
        videosCursor,
        hasReachedMaxVideos,
        errorMessage,
      ];
}
