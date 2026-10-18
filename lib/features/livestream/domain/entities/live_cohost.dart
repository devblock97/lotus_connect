import 'package:flutter/foundation.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';

/// Represents a co-host session participant (PK Battle / Multi-Guest),
@immutable
class LiveCohost {
  const LiveCohost({
    required this.id,
    required this.streamId,
    required this.user,
    required this.status, // 'pending', 'accepted', 'rejected', 'left'
    required this.createdAt,
  });

  factory LiveCohost.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    final user = userJson is Map<String, dynamic>
        ? PostAuthor.fromJson(userJson)
        : const PostAuthor(id: '', username: 'cohost');

    final createdAtStr = json['createdAt'] as String?;
    final createdAt = createdAtStr != null
        ? DateTime.tryParse(createdAtStr) ?? DateTime.now()
        : DateTime.now();

    return LiveCohost(
      id: json['id'] as String? ?? '',
      streamId: json['streamId'] as String? ?? '',
      user: user,
      status: json['status'] as String? ?? 'pending',
      createdAt: createdAt,
    );
  }

  final String id;
  final String streamId;
  final PostAuthor user;
  final String status;
  final DateTime createdAt;

  bool get isAccepted => status == 'accepted';

  Map<String, dynamic> toJson() => {
        'id': id,
        'streamId': streamId,
        'user': user.toJson(),
        'status': status,
        'createdAt': createdAt.toIso8601String(),
      };
}
