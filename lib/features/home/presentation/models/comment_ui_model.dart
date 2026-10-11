import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';

/// Available sorting modes for comments corresponding to backend CommentQuery.
enum CommentSortOrder {
  popular('popular', 'Top comments'),
  newest('newest', 'Newest first'),
  oldest('oldest', 'Oldest first');

  const CommentSortOrder(this.value, this.label);

  final String value;
  final String label;
}

/// Presentation model representing a comment or reply on a post.
/// Maps 1:1 with backend `CommentResponse` from `lotus_connect_system`.
@immutable
class CommentUiModel {
  const CommentUiModel({
    required this.id,
    required this.postId,
    required this.author,
    required this.content,
    required this.createdAt,
    this.parentCommentId,
    this.mediaUrl,
    this.likeCount = 0,
    this.replyCount = 0,
    this.isPinned = false,
    this.pinnedAt,
    this.userHasLiked = false,
    this.userReaction,
    this.updatedAt,
    this.replies = const [],
    this.isRepliesExpanded = false,
    this.isLoadingReplies = false,
    this.isOptimistic = false,
    this.hasError = false,
  });

  /// Factory constructor to parse backend Comment JSON directly.
  factory CommentUiModel.fromJson(Map<String, dynamic> json) {
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

    final rawReplies = json['replies'];
    final repliesList = <CommentUiModel>[];
    if (rawReplies is List) {
      for (final r in rawReplies) {
        if (r is Map<String, dynamic>) {
          repliesList.add(CommentUiModel.fromJson(r));
        }
      }
    }

    return CommentUiModel(
      id: json['id'] as String? ?? '',
      postId: (json['postId'] ?? json['post_id']) as String? ?? '',
      author: author,
      parentCommentId:
          (json['parentCommentId'] ?? json['parent_comment_id']) as String?,
      content: json['content'] as String? ?? '',
      mediaUrl: (json['mediaUrl'] ?? json['media_url']) as String?,
      likeCount: (json['likeCount'] ?? json['like_count']) as int? ?? 0,
      replyCount: (json['replyCount'] ?? json['reply_count']) as int? ?? 0,
      isPinned: (json['isPinned'] ?? json['is_pinned']) as bool? ?? false,
      pinnedAt: parseDate(json['pinnedAt'] ?? json['pinned_at']),
      userHasLiked:
          (json['userHasLiked'] ?? json['user_has_liked']) as bool? ?? false,
      userReaction: (json['userReaction'] ?? json['user_reaction']) as String?,
      createdAt:
          parseDate(json['createdAt'] ?? json['created_at']) ?? DateTime.now(),
      updatedAt: parseDate(json['updatedAt'] ?? json['updated_at']),
      replies: repliesList,
    );
  }

  final String id;
  final String postId;
  final PostAuthor author;
  final String? parentCommentId;
  final String content;
  final String? mediaUrl;
  final int likeCount;
  final int replyCount;
  final bool isPinned;
  final DateTime? pinnedAt;
  final bool userHasLiked;
  final String? userReaction;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Nested threaded replies for UI tree rendering
  final List<CommentUiModel> replies;
  final bool isRepliesExpanded;
  final bool isLoadingReplies;
  final bool isOptimistic;
  final bool hasError;

  /// True if this is a top-level root comment
  bool get isRoot => parentCommentId == null || parentCommentId!.isEmpty;

  /// True if comment has an attached sticker/GIF/photo
  bool get hasMedia => mediaUrl != null && mediaUrl!.trim().isNotEmpty;

  /// True if comment has any replies
  bool get hasReplies => replyCount > 0 || replies.isNotEmpty;

  /// True if this comment was edited
  bool get isEdited =>
      updatedAt != null &&
      createdAt != updatedAt &&
      updatedAt!.difference(createdAt).inMinutes >= 1;

  /// Active reaction emoji or default heart
  String get displayReaction => userReaction ?? (userHasLiked ? '❤️' : '');

  /// Computes compact human-friendly relative time
  /// (e.g. '2m', '5h', '3d', '1y').
  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays >= 365) {
      final years = (diff.inDays / 365).floor();
      return '${years}y';
    }
    if (diff.inDays >= 30) {
      final months = (diff.inDays / 30).floor();
      return '${months}mo';
    }
    if (diff.inDays >= 7) {
      final weeks = (diff.inDays / 7).floor();
      return '${weeks}w';
    }
    if (diff.inDays >= 1) {
      return '${diff.inDays}d';
    }
    if (diff.inHours >= 1) {
      return '${diff.inHours}h';
    }
    if (diff.inMinutes >= 1) {
      return '${diff.inMinutes}m';
    }
    return 'now';
  }

  /// Formatted date string (e.g. 'Oct 9, 2026 10:45 AM')
  String get formattedDateTime =>
      DateFormat('MMM d, y · h:mm a').format(createdAt);

  Map<String, dynamic> toJson() => {
        'id': id,
        'postId': postId,
        'author': author.toJson(),
        'parentCommentId': parentCommentId,
        'content': content,
        'mediaUrl': mediaUrl,
        'likeCount': likeCount,
        'replyCount': replyCount,
        'isPinned': isPinned,
        'pinnedAt': pinnedAt?.toIso8601String(),
        'userHasLiked': userHasLiked,
        'userReaction': userReaction,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'replies': replies.map((r) => r.toJson()).toList(),
      };

  CommentUiModel copyWith({
    String? id,
    String? postId,
    PostAuthor? author,
    String? parentCommentId,
    String? content,
    String? mediaUrl,
    int? likeCount,
    int? replyCount,
    bool? isPinned,
    DateTime? pinnedAt,
    bool? userHasLiked,
    String? userReaction,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<CommentUiModel>? replies,
    bool? isRepliesExpanded,
    bool? isLoadingReplies,
    bool? isOptimistic,
    bool? hasError,
  }) {
    return CommentUiModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      author: author ?? this.author,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      likeCount: likeCount ?? this.likeCount,
      replyCount: replyCount ?? this.replyCount,
      isPinned: isPinned ?? this.isPinned,
      pinnedAt: pinnedAt ?? this.pinnedAt,
      userHasLiked: userHasLiked ?? this.userHasLiked,
      userReaction: userReaction ?? this.userReaction,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      replies: replies ?? this.replies,
      isRepliesExpanded: isRepliesExpanded ?? this.isRepliesExpanded,
      isLoadingReplies: isLoadingReplies ?? this.isLoadingReplies,
      isOptimistic: isOptimistic ?? this.isOptimistic,
      hasError: hasError ?? this.hasError,
    );
  }
}

/// Presentation model representing a reaction on a comment.
/// Maps 1:1 with backend `CommentReactionResponse` from `lotus_connect_system`.
@immutable
class CommentReactionUiModel {
  const CommentReactionUiModel({
    required this.id,
    required this.commentId,
    required this.user,
    required this.reaction,
    required this.createdAt,
  });

  factory CommentReactionUiModel.fromJson(Map<String, dynamic> json) {
    final rawUser = json['user'];
    final user = rawUser is Map<String, dynamic>
        ? PostAuthor.fromJson(rawUser)
        : PostAuthor(
            id: json['userId'] as String? ?? '',
            username: json['username'] as String? ?? 'user',
          );

    DateTime? parseDate(dynamic val) {
      if (val is String && val.isNotEmpty) {
        return DateTime.tryParse(val);
      }
      return null;
    }

    return CommentReactionUiModel(
      id: json['id'] as String? ?? '',
      commentId: json['commentId'] as String? ?? '',
      user: user,
      reaction: json['reaction'] as String? ?? '❤️',
      createdAt: parseDate(json['createdAt']) ?? DateTime.now(),
    );
  }

  final String id;
  final String commentId;
  final PostAuthor user;
  final String reaction;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'commentId': commentId,
        'user': user.toJson(),
        'reaction': reaction,
        'createdAt': createdAt.toIso8601String(),
      };
}
