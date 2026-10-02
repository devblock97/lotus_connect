import 'package:flutter/material.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';

@immutable
class Story {
  const Story({
    required this.id,
    required this.author,
    required this.mediaType,
    required this.mediaUrl,
    required this.createdAt,
    this.thumbnailUrl,
    this.caption,
    this.duration = 5.0,
    this.visibility = 'public',
    this.backgroundColor,
    this.metadata,
    this.expiresAt,
    this.viewCount = 0,
    this.hasViewed = false,
    this.viewerReaction,
    this.isCloseFriend = false,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val is DateTime) return val;
      if (val is String) {
        return DateTime.tryParse(val) ?? DateTime.now();
      }
      return DateTime.now();
    }

    DateTime? parseOptionalDate(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    final authorData = json['author'] is Map<String, dynamic>
        ? json['author'] as Map<String, dynamic>
        : <String, dynamic>{};

    return Story(
      id: json['id'] as String? ?? '',
      author: PostAuthor.fromJson(authorData),
      mediaType: json['mediaType'] as String? ?? 'image',
      mediaUrl: json['mediaUrl'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String?,
      caption: json['caption'] as String?,
      duration: (json['duration'] as num?)?.toDouble() ?? 5.0,
      visibility: json['visibility'] as String? ?? 'public',
      backgroundColor: json['backgroundColor'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: parseDate(json['createdAt']),
      expiresAt: parseOptionalDate(json['expiresAt']),
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      hasViewed: json['hasViewed'] as bool? ?? false,
      viewerReaction: json['viewerReaction'] as String?,
      isCloseFriend: json['isCloseFriend'] as bool? ?? false,
    );
  }

  final String id;
  final PostAuthor author;
  final String mediaType;
  final String mediaUrl;
  final String? thumbnailUrl;
  final String? caption;
  final double duration;
  final String visibility;
  final String? backgroundColor;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final int viewCount;
  final bool hasViewed;
  final String? viewerReaction;
  final bool isCloseFriend;

  bool get isVideo => mediaType.toLowerCase() == 'video';

  bool get isCloseFriendsStory =>
      visibility.toLowerCase() == 'close_friends' || isCloseFriend;

  Color? get parsedBackgroundColor {
    if (backgroundColor == null || backgroundColor!.isEmpty) return null;
    try {
      var hex = backgroundColor!.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    } on Object catch (_) {
      return null;
    }
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'author': author.toJson(),
        'mediaType': mediaType,
        'mediaUrl': mediaUrl,
        'thumbnailUrl': thumbnailUrl,
        'caption': caption,
        'duration': duration,
        'visibility': visibility,
        'backgroundColor': backgroundColor,
        'metadata': metadata,
        'createdAt': createdAt.toIso8601String(),
        'expiresAt': expiresAt?.toIso8601String(),
        'viewCount': viewCount,
        'hasViewed': hasViewed,
        'viewerReaction': viewerReaction,
        'isCloseFriend': isCloseFriend,
      };

  Story copyWith({
    String? id,
    PostAuthor? author,
    String? mediaType,
    String? mediaUrl,
    String? thumbnailUrl,
    String? caption,
    double? duration,
    String? visibility,
    String? backgroundColor,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? viewCount,
    bool? hasViewed,
    String? viewerReaction,
    bool? isCloseFriend,
  }) {
    return Story(
      id: id ?? this.id,
      author: author ?? this.author,
      mediaType: mediaType ?? this.mediaType,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      caption: caption ?? this.caption,
      duration: duration ?? this.duration,
      visibility: visibility ?? this.visibility,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      viewCount: viewCount ?? this.viewCount,
      hasViewed: hasViewed ?? this.hasViewed,
      viewerReaction: viewerReaction ?? this.viewerReaction,
      isCloseFriend: isCloseFriend ?? this.isCloseFriend,
    );
  }
}
