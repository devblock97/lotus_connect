import 'package:flutter/foundation.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';

@immutable
class LiveComment {
  const LiveComment({
    required this.id,
    required this.streamId,
    required this.user,
    required this.content,
    required this.createdAt,
    this.isPinned = false,
    this.isSystem = false,
  });

  factory LiveComment.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    final user = userJson is Map<String, dynamic>
        ? PostAuthor.fromJson(userJson)
        : const PostAuthor(id: '', username: 'viewer');

    final createdAtStr = json['createdAt'] as String?;
    final createdAt = createdAtStr != null
        ? DateTime.tryParse(createdAtStr) ?? DateTime.now()
        : DateTime.now();

    return LiveComment(
      id: json['id'] as String? ?? '',
      streamId: json['streamId'] as String? ?? '',
      user: user,
      content: json['content'] as String? ?? '',
      isPinned: json['isPinned'] as bool? ?? false,
      isSystem: json['isSystem'] as bool? ?? false,
      createdAt: createdAt,
    );
  }

  final String id;
  final String streamId;
  final PostAuthor user;
  final String content;
  final bool isPinned;
  final bool isSystem;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'streamId': streamId,
        'user': user.toJson(),
        'content': content,
        'isPinned': isPinned,
        'isSystem': isSystem,
        'createdAt': createdAt.toIso8601String(),
      };

  LiveComment copyWith({
    String? id,
    String? streamId,
    PostAuthor? user,
    String? content,
    bool? isPinned,
    bool? isSystem,
    DateTime? createdAt,
  }) {
    return LiveComment(
      id: id ?? this.id,
      streamId: streamId ?? this.streamId,
      user: user ?? this.user,
      content: content ?? this.content,
      isPinned: isPinned ?? this.isPinned,
      isSystem: isSystem ?? this.isSystem,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
