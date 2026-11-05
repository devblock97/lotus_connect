import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/home/domain/entities/post_media_item.dart';

@immutable
class PostItem {
  const PostItem({
    required this.id,
    required this.author,
    required this.content,
    this.postType = 'post',
    this.mediaItems = const [],
    this.visibility = 'public',
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.viewCount = 0,
    this.userHasLiked = false,
    this.userReaction,
    this.createdAt,
    this.updatedAt,
    this.isSaved = false,
    this.hasStory = true,
    this.likedByUsername,
  });

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
      postType:
          json['postType'] as String? ?? json['post_type'] as String? ?? 'post',
      content: json['content'] as String? ?? '',
      mediaItems: mediaList,
      visibility: json['visibility'] as String? ?? 'public',
      likeCount: json['likeCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      shareCount: (json['shareCount'] ?? json['share_count']) as int? ?? 0,
      viewCount: (json['viewCount'] ?? json['view_count']) as int? ?? 0,
      userHasLiked: json['userHasLiked'] as bool? ?? false,
      userReaction: json['userReaction'] as String?,
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  final String id;
  final PostAuthor author;
  final String postType;
  final String content;
  final List<PostMediaItem> mediaItems;
  final String visibility;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final int viewCount;
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
  bool get isChill => postType.toLowerCase() == 'chill';
  int get commentsCount => commentCount;
  bool get isLiked => userHasLiked;

  /// Primary media item if any
  PostMediaItem? get primaryMedia =>
      mediaItems.isNotEmpty ? mediaItems.first : null;

  String get mediaUrl => primaryMedia?.url ?? '';

  /// Formatted date string (e.g. 'September 21, 2026')
  String get formattedDate {
    if (createdAt == null) return '';
    return DateFormat('MMMM d, y').format(createdAt!);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'author': author.toJson(),
        'postType': postType,
        'content': content,
        'mediaItems': mediaItems.map((e) => e.toJson()).toList(),
        'visibility': visibility,
        'likeCount': likeCount,
        'commentCount': commentCount,
        'shareCount': shareCount,
        'viewCount': viewCount,
        'userHasLiked': userHasLiked,
        'userReaction': userReaction,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  PostItem copyWith({
    String? id,
    PostAuthor? author,
    String? postType,
    String? content,
    List<PostMediaItem>? mediaItems,
    String? visibility,
    int? likeCount,
    int? likesCount,
    int? commentCount,
    int? commentsCount,
    int? shareCount,
    int? viewCount,
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
      postType: postType ?? this.postType,
      content: content ?? this.content,
      mediaItems: mediaItems ?? this.mediaItems,
      visibility: visibility ?? this.visibility,
      likeCount: likesCount ?? likeCount ?? this.likeCount,
      commentCount: commentsCount ?? commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      viewCount: viewCount ?? this.viewCount,
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
