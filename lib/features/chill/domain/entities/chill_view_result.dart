import 'package:flutter/foundation.dart';

@immutable
class ChillViewResult {
  const ChillViewResult({
    required this.postId,
    required this.viewCount,
    this.watchTimeSeconds = 0.0,
    this.isCompleted = false,
  });

  factory ChillViewResult.fromJson(Map<String, dynamic> json) {
    return ChillViewResult(
      postId: (json['postId'] ??
              json['post_id'] ??
              json['chillId'] ??
              json['chill_id'] ??
              json['reelId']) as String? ??
          '',
      viewCount: (json['viewCount'] ?? json['view_count']) as int? ?? 0,
      watchTimeSeconds: (json['watchTimeSeconds'] as double? ??
                  json['watch_time_seconds'] as num?)
              ?.toDouble() ??
          0.0,
      isCompleted:
          (json['isCompleted'] ?? json['is_completed']) as bool? ?? false,
    );
  }

  final String postId;
  final int viewCount;
  final double watchTimeSeconds;
  final bool isCompleted;

  Map<String, dynamic> toJson() => {
        'postId': postId,
        'viewCount': viewCount,
        'watchTimeSeconds': watchTimeSeconds,
        'isCompleted': isCompleted,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChillViewResult &&
          runtimeType == other.runtimeType &&
          postId == other.postId &&
          viewCount == other.viewCount &&
          watchTimeSeconds == other.watchTimeSeconds &&
          isCompleted == other.isCompleted;

  @override
  int get hashCode =>
      Object.hash(postId, viewCount, watchTimeSeconds, isCompleted);
}
