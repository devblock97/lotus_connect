import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/home/domain/entities/post_media_item.dart';

/// Represents a social media post item from the feed API.
@immutable
class PostItem {
  const PostItem({
    required this.id,
    required this.author,
    required this.content,
    this.mediaItems = const [],
    this.visibility = 'public',
    this.likeCount = 0,
    this.commentCount = 0,
    this.userHasLiked = false,
    this.userReaction,
    this.createdAt,
    this.updatedAt,
    this.isSaved = false,
    this.hasStory = true,
    this.likedByUsername,
  });

  /// Factory constructor to parse backend Feed JSON directly.
  factory PostItem.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val is String && val.isNotEmpty) {
        return DateTime.tryParse(val);
      }
      return null;
    }

    final rawAuthor = json['author'];
    final author = rawAuthor is Map<String, dynamic>
        ? PostAuthor.fromJson(rawAuthor)
        : PostAuthor(
            id: json['authorId'] as String? ?? '',
            username: json['username'] as String? ?? 'user',
          );

    final rawMedia = json['mediaItems'];
    final mediaList = <PostMediaItem>[];
    if (rawMedia is List) {
      for (final item in rawMedia) {
        if (item is Map<String, dynamic>) {
          mediaList.add(PostMediaItem.fromJson(item));
        }
      }
    }

    return PostItem(
      id: json['id'] as String? ?? '',
      author: author,
      content: json['content'] as String? ?? '',
      mediaItems: mediaList,
      visibility: json['visibility'] as String? ?? 'public',
      likeCount: json['likeCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      userHasLiked: json['userHasLiked'] as bool? ?? false,
      userReaction: json['userReaction'] as String?,
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  final String id;
  final PostAuthor author;
  final String content;
  final List<PostMediaItem> mediaItems;
  final String visibility;
  final int likeCount;
  final int commentCount;
  final bool userHasLiked;
  final String? userReaction;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isSaved;
  final bool hasStory;
  final String? likedByUsername;

  // Convenience getters for UI components
  String get username => author.username;
  String get userAvatarUrl => author.avatarUrl ?? '';
  String get caption => content;
  int get likesCount => likeCount;
  int get commentsCount => commentCount;
  bool get isLiked => userHasLiked;

  /// Primary media item if any
  PostMediaItem? get primaryMedia =>
      mediaItems.isNotEmpty ? mediaItems.first : null;

  String get mediaUrl => primaryMedia?.url ?? '';

  /// Computes human-friendly relative time (e.g., '4d ago', '2h ago')
  String get timeAgo {
    if (createdAt == null) return 'recently';
    final diff = DateTime.now().difference(createdAt!);

    if (diff.inDays >= 365) {
      final years = (diff.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
    if (diff.inDays >= 30) {
      final months = (diff.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    }
    if (diff.inDays >= 7) {
      final weeks = (diff.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    }
    if (diff.inDays >= 1) {
      return '${diff.inDays} ${diff.inDays == 1 ? 'day' : 'days'} ago';
    }
    if (diff.inHours >= 1) {
      return '${diff.inHours} ${diff.inHours == 1 ? 'hour' : 'hours'} ago';
    }
    if (diff.inMinutes >= 1) {
      return '${diff.inMinutes}m ago';
    }
    return 'Just now';
  }

  /// Formatted date string (e.g. 'September 21, 2026')
  String get formattedDate {
    if (createdAt == null) return '';
    return DateFormat('MMMM d, y').format(createdAt!);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'author': author.toJson(),
        'content': content,
        'mediaItems': mediaItems.map((e) => e.toJson()).toList(),
        'visibility': visibility,
        'likeCount': likeCount,
        'commentCount': commentCount,
        'userHasLiked': userHasLiked,
        'userReaction': userReaction,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  PostItem copyWith({
    String? id,
    PostAuthor? author,
    String? content,
    List<PostMediaItem>? mediaItems,
    String? visibility,
    int? likeCount,
    int? likesCount,
    int? commentCount,
    int? commentsCount,
    bool? userHasLiked,
    bool? isLiked,
    String? userReaction,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSaved,
    bool? hasStory,
    String? likedByUsername,
  }) {
    return PostItem(
      id: id ?? this.id,
      author: author ?? this.author,
      content: content ?? this.content,
      mediaItems: mediaItems ?? this.mediaItems,
      visibility: visibility ?? this.visibility,
      likeCount: likesCount ?? likeCount ?? this.likeCount,
      commentCount: commentsCount ?? commentCount ?? this.commentCount,
      userHasLiked: isLiked ?? userHasLiked ?? this.userHasLiked,
      userReaction: userReaction ?? this.userReaction,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSaved: isSaved ?? this.isSaved,
      hasStory: hasStory ?? this.hasStory,
      likedByUsername: likedByUsername ?? this.likedByUsername,
    );
  }
}
