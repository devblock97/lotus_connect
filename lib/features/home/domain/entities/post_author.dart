import 'package:flutter/foundation.dart';

/// Represents the author of a social media post.
@immutable
class PostAuthor {
  const PostAuthor({
    required this.id,
    required this.username,
    this.fullName,
    this.avatarUrl,
  });

  factory PostAuthor.fromJson(Map<String, dynamic> json) {
    return PostAuthor(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? 'user',
      fullName: json['fullName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  final String id;
  final String username;
  final String? fullName;
  final String? avatarUrl;

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'fullName': fullName,
        'avatarUrl': avatarUrl,
      };

  PostAuthor copyWith({
    String? id,
    String? username,
    String? fullName,
    String? avatarUrl,
  }) {
    return PostAuthor(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  /// Initial letters for avatar fallback (e.g. "NN" or "U")
  String get initials {
    if (fullName != null && fullName!.trim().isNotEmpty) {
      final parts = fullName!.trim().split(RegExp(r'\s+'));
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
}
