import 'package:flutter/foundation.dart';

@immutable
class ChillUploadResult {
  const ChillUploadResult({
    required this.videoUrl,
    this.thumbnailUrl,
    this.duration,
    this.aspectRatio,
  });

  factory ChillUploadResult.fromJson(Map<String, dynamic> json) {
    return ChillUploadResult(
      videoUrl:
          (json['videoUrl'] ?? json['video_url'] ?? json['url']) as String? ??
              '',
      thumbnailUrl: (json['thumbnailUrl'] ?? json['thumbnail_url']) as String?,
      duration: (json['duration'] as num?)?.toDouble(),
      aspectRatio:
          (json['aspectRatio'] as double? ?? json['aspect_ratio'] as num?)
              ?.toDouble(),
    );
  }

  final String videoUrl;
  final String? thumbnailUrl;
  final double? duration;
  final double? aspectRatio;

  Map<String, dynamic> toJson() => {
        'videoUrl': videoUrl,
        if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
        if (duration != null) 'duration': duration,
        if (aspectRatio != null) 'aspectRatio': aspectRatio,
      };
}
