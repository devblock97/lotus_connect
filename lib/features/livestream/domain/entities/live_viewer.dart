import 'package:flutter/foundation.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';

@immutable
class LiveViewer {
  const LiveViewer({
    required this.id,
    required this.user,
    required this.joinedAt,
    this.isActive = true,
  });

  factory LiveViewer.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    final user = userJson is Map<String, dynamic>
        ? PostAuthor.fromJson(userJson)
        : const PostAuthor(id: '', username: 'viewer');

    final joinedAtStr = json['joinedAt'] as String?;
    final joinedAt = joinedAtStr != null
        ? DateTime.tryParse(joinedAtStr) ?? DateTime.now()
        : DateTime.now();

    return LiveViewer(
      id: json['id'] as String? ?? '',
      user: user,
      joinedAt: joinedAt,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  final String id;
  final PostAuthor user;
  final DateTime joinedAt;
  final bool isActive;

  Map<String, dynamic> toJson() => {
        'id': id,
        'user': user.toJson(),
        'joinedAt': joinedAt.toIso8601String(),
        'isActive': isActive,
      };
}
