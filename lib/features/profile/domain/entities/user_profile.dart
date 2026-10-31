import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:lotus_connect/core/utils/media_url_normalizer.dart';

@immutable
class UserProfileStats extends Equatable {
  const UserProfileStats({
    this.postCount = 0,
    this.mediaCount = 0,
    this.friendCount = 0,
  });

  factory UserProfileStats.fromJson(Map<String, dynamic> json) {
    return UserProfileStats(
      postCount: (json['postCount'] as num?)?.toInt() ?? 0,
      mediaCount: (json['mediaCount'] as num?)?.toInt() ?? 0,
      friendCount: (json['friendCount'] as num?)?.toInt() ?? 0,
    );
  }

  final int postCount;
  final int mediaCount;
  final int friendCount;

  Map<String, dynamic> toJson() => {
        'postCount': postCount,
        'mediaCount': mediaCount,
        'friendCount': friendCount,
      };

  UserProfileStats copyWith({
    int? postCount,
    int? mediaCount,
    int? friendCount,
  }) {
    return UserProfileStats(
      postCount: postCount ?? this.postCount,
      mediaCount: mediaCount ?? this.mediaCount,
      friendCount: friendCount ?? this.friendCount,
    );
  }

  @override
  List<Object?> get props => [postCount, mediaCount, friendCount];
}

@immutable
class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.coverUrl,
    this.bio,
    this.website,
    this.location,
    this.isSelf = false,
    this.friendshipStatus,
    this.friendshipSenderId,
    this.isCloseFriend = false,
    this.postCount = 0,
    this.mediaCount = 0,
    this.friendCount = 0,
    this.stats = const UserProfileStats(),
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val is String && val.isNotEmpty) {
        return DateTime.tryParse(val);
      }
      return null;
    }

    final postCount = (json['postCount'] as num?)?.toInt() ?? 0;
    final mediaCount = (json['mediaCount'] as num?)?.toInt() ?? 0;
    final friendCount = (json['friendCount'] as num?)?.toInt() ?? 0;

    final rawStats = json['stats'];
    final stats = rawStats is Map<String, dynamic>
        ? UserProfileStats.fromJson(rawStats)
        : UserProfileStats(
            postCount: postCount,
            mediaCount: mediaCount,
            friendCount: friendCount,
          );

    return UserProfile(
      id: (json['id'] ?? json['userId'] ?? '') as String,
      username: (json['username'] ?? '') as String,
      fullName: json['fullName'] as String?,
      email: (json['email'] ?? '') as String,
      avatarUrl: json['avatarUrl'] as String?,
      coverUrl: json['coverUrl'] as String?,
      bio: json['bio'] as String?,
      website: json['website'] as String?,
      location: json['location'] as String?,
      isSelf: json['isSelf'] as bool? ?? false,
      friendshipStatus: json['friendshipStatus'] as String?,
      friendshipSenderId: json['friendshipSenderId'] as String?,
      isCloseFriend: json['isCloseFriend'] as bool? ?? false,
      postCount: postCount,
      mediaCount: mediaCount,
      friendCount: friendCount,
      stats: stats,
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  final String id;
  final String username;
  final String? fullName;
  final String email;
  final String? avatarUrl;
  final String? coverUrl;
  final String? bio;
  final String? website;
  final String? location;
  final bool isSelf;
  final String? friendshipStatus;
  final String? friendshipSenderId;
  final bool isCloseFriend;
  final int postCount;
  final int mediaCount;
  final int friendCount;
  final UserProfileStats stats;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get displayName {
    final trimmed = fullName?.trim() ?? '';
    if (trimmed.isNotEmpty) return trimmed;
    return username;
  }

  String get initials {
    final trimmed = fullName?.trim() ?? '';
    if (trimmed.isNotEmpty) {
      final parts = trimmed.split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      }
      return parts.first[0].toUpperCase();
    }
    if (username.isNotEmpty) {
      return username.substring(0, 1).toUpperCase();
    }
    return '?';
  }

  bool get isFriend => friendshipStatus == 'accepted';

  bool get isPendingRequest => friendshipStatus == 'pending';

  bool didSendFriendRequest(String currentUserId) =>
      isPendingRequest &&
      friendshipSenderId != null &&
      friendshipSenderId == currentUserId;

  bool didReceiveFriendRequest(String currentUserId) =>
      isPendingRequest &&
      friendshipSenderId != null &&
      friendshipSenderId != currentUserId;

  UserProfile normalizedForHost(String serverHost) {
    return copyWith(
      avatarUrl: avatarUrl != null && avatarUrl!.isNotEmpty
          ? normalizeMediaUrl(avatarUrl!, serverHost: serverHost)
          : avatarUrl,
      coverUrl: coverUrl != null && coverUrl!.isNotEmpty
          ? normalizeMediaUrl(coverUrl!, serverHost: serverHost)
          : coverUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        if (fullName != null) 'fullName': fullName,
        'email': email,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (coverUrl != null) 'coverUrl': coverUrl,
        if (bio != null) 'bio': bio,
        if (website != null) 'website': website,
        if (location != null) 'location': location,
        'isSelf': isSelf,
        if (friendshipStatus != null) 'friendshipStatus': friendshipStatus,
        if (friendshipSenderId != null)
          'friendshipSenderId': friendshipSenderId,
        'isCloseFriend': isCloseFriend,
        'postCount': postCount,
        'mediaCount': mediaCount,
        'friendCount': friendCount,
        'stats': stats.toJson(),
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  UserProfile copyWith({
    String? id,
    String? username,
    String? fullName,
    String? email,
    String? avatarUrl,
    String? coverUrl,
    String? bio,
    String? website,
    String? location,
    bool? isSelf,
    String? friendshipStatus,
    bool clearFriendshipStatus = false,
    String? friendshipSenderId,
    bool clearFriendshipSenderId = false,
    bool? isCloseFriend,
    int? postCount,
    int? mediaCount,
    int? friendCount,
    UserProfileStats? stats,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final nextPostCount = postCount ?? this.postCount;
    final nextMediaCount = mediaCount ?? this.mediaCount;
    final nextFriendCount = friendCount ?? this.friendCount;

    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      bio: bio ?? this.bio,
      website: website ?? this.website,
      location: location ?? this.location,
      isSelf: isSelf ?? this.isSelf,
      friendshipStatus: clearFriendshipStatus
          ? null
          : (friendshipStatus ?? this.friendshipStatus),
      friendshipSenderId: clearFriendshipSenderId
          ? null
          : (friendshipSenderId ?? this.friendshipSenderId),
      isCloseFriend: isCloseFriend ?? this.isCloseFriend,
      postCount: nextPostCount,
      mediaCount: nextMediaCount,
      friendCount: nextFriendCount,
      stats: stats ??
          UserProfileStats(
            postCount: nextPostCount,
            mediaCount: nextMediaCount,
            friendCount: nextFriendCount,
          ),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        username,
        fullName,
        email,
        avatarUrl,
        coverUrl,
        bio,
        website,
        location,
        isSelf,
        friendshipStatus,
        friendshipSenderId,
        isCloseFriend,
        postCount,
        mediaCount,
        friendCount,
        stats,
        createdAt,
        updatedAt,
      ];
}
