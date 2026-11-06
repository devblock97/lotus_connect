import 'package:flutter/foundation.dart';

/// Parameters for recording watch analytics and completion for a Chill.
/// Maps 1:1 with backend `RecordPostViewRequest` / `RecordChillViewRequest`.
@immutable
class RecordChillViewParams {
  const RecordChillViewParams({
    required this.chillId,
    this.watchTimeSeconds,
    this.isCompleted,
  });

  final String chillId;
  final double? watchTimeSeconds;
  final bool? isCompleted;

  Map<String, dynamic> toJson() => {
        if (watchTimeSeconds != null) 'watchTimeSeconds': watchTimeSeconds,
        if (isCompleted != null) 'isCompleted': isCompleted,
      };
}
