import 'package:flutter/material.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/home/domain/entities/story.dart';

/// Represents a story tray group belonging to a single user.
@immutable
class UserStory {
  const UserStory({
    required this.user,
    this.stories = const [],
    this.hasUnseen = false,
    this.totalStories = 0,
    this.latestStoryCreatedAt,
    this.hasCloseFriendsStory = false,
    this.isSelf = false,
  });

  factory UserStory.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : <String, dynamic>{};

    final rawStories = json['stories'];
    final parsedStories = <Story>[];
    if (rawStories is List) {
      for (final item in rawStories) {
        if (item is Map<String, dynamic>) {
          parsedStories.add(Story.fromJson(item));
        }
      }
    }

    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    final hasCloseFriends = json['hasCloseFriendsStory'] as bool? ??
        json['hasCloseFriendStory'] as bool? ??
        false;

    return UserStory(
      user: PostAuthor.fromJson(userData),
      stories: parsedStories,
      hasUnseen: json['hasUnseen'] as bool? ?? false,
      totalStories:
          (json['totalStories'] as num?)?.toInt() ?? parsedStories.length,
      latestStoryCreatedAt: parseDate(json['latestStoryCreatedAt']),
      hasCloseFriendsStory: hasCloseFriends,
      isSelf: json['isSelf'] as bool? ?? false,
    );
  }

  final PostAuthor user;
  final List<Story> stories;
  final bool hasUnseen;
  final int totalStories;
  final DateTime? latestStoryCreatedAt;
  final bool hasCloseFriendsStory;
  final bool isSelf;

  String get id => user.id;
  String get username => user.username;
  String? get fullName => user.fullName;
  String? get avatarUrl => user.avatarUrl;
  bool get hasStories => stories.isNotEmpty;
  bool get isSeen => !hasUnseen;

  Map<String, dynamic> toJson() => {
        'user': user.toJson(),
        'stories': stories.map((s) => s.toJson()).toList(),
        'hasUnseen': hasUnseen,
        'totalStories': totalStories,
        'latestStoryCreatedAt': latestStoryCreatedAt?.toIso8601String(),
        'hasCloseFriendsStory': hasCloseFriendsStory,
        'isSelf': isSelf,
      };

  UserStory copyWith({
    PostAuthor? user,
    List<Story>? stories,
    bool? hasUnseen,
    int? totalStories,
    DateTime? latestStoryCreatedAt,
    bool? hasCloseFriendsStory,
    bool? isSelf,
  }) {
    return UserStory(
      user: user ?? this.user,
      stories: stories ?? this.stories,
      hasUnseen: hasUnseen ?? this.hasUnseen,
      totalStories: totalStories ?? this.totalStories,
      latestStoryCreatedAt: latestStoryCreatedAt ?? this.latestStoryCreatedAt,
      hasCloseFriendsStory: hasCloseFriendsStory ?? this.hasCloseFriendsStory,
      isSelf: isSelf ?? this.isSelf,
    );
  }
}
