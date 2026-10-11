import 'package:flutter/foundation.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/home/presentation/models/comment_ui_model.dart';

@immutable
class CommentModel {
  const CommentModel({
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
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
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
    final repliesList = <CommentModel>[];
    if (rawReplies is List) {
      for (final r in rawReplies) {
        if (r is Map<String, dynamic>) {
          repliesList.add(CommentModel.fromJson(r));
        }
      }
    }

    return CommentModel(
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

  factory CommentModel.fromUiModel(CommentUiModel ui) {
    return CommentModel(
      id: ui.id,
      postId: ui.postId,
      author: ui.author,
      parentCommentId: ui.parentCommentId,
      content: ui.content,
      mediaUrl: ui.mediaUrl,
      likeCount: ui.likeCount,
      replyCount: ui.replyCount,
      isPinned: ui.isPinned,
      pinnedAt: ui.pinnedAt,
      userHasLiked: ui.userHasLiked,
      userReaction: ui.userReaction,
      createdAt: ui.createdAt,
      updatedAt: ui.updatedAt,
      replies: ui.replies.map(CommentModel.fromUiModel).toList(),
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
  final List<CommentModel> replies;

  /// Serializes model to backend JSON payload.
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

  CommentUiModel toUiModel() {
    return CommentUiModel(
      id: id,
      postId: postId,
      author: author,
      parentCommentId: parentCommentId,
      content: content,
      mediaUrl: mediaUrl,
      likeCount: likeCount,
      replyCount: replyCount,
      isPinned: isPinned,
      pinnedAt: pinnedAt,
      userHasLiked: userHasLiked,
      userReaction: userReaction,
      createdAt: createdAt,
      updatedAt: updatedAt,
      replies: replies.map((r) => r.toUiModel()).toList(),
    );
  }

  CommentModel copyWith({
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
    List<CommentModel>? replies,
  }) {
    return CommentModel(
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
    );
  }
}
