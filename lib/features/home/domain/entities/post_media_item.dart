import 'package:flutter/foundation.dart';

/// Represents a media item (photo or video) attached to a post.
@immutable
class PostMediaItem {
  const PostMediaItem({
    required this.url,
    this.thumbnailUrl,
    this.fileName,
    this.fileSize,
    this.mimeType,
    this.duration,
    this.width,
    this.height,
  });

  factory PostMediaItem.fromJson(Map<String, dynamic> json) {
    return PostMediaItem(
      url: json['url'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String?,
      fileName: json['fileName'] as String?,
      fileSize: json['fileSize'] as int?,
      mimeType: json['mimeType'] as String?,
      duration: json['duration'] as int?,
      width: json['width'] as int?,
      height: json['height'] as int?,
    );
  }

  final String url;
  final String? thumbnailUrl;
  final String? fileName;
  final int? fileSize;
  final String? mimeType;
  final int? duration;
  final int? width;
  final int? height;

  Map<String, dynamic> toJson() => {
        'url': url,
        'thumbnailUrl': thumbnailUrl,
        'fileName': fileName,
        'fileSize': fileSize,
        'mimeType': mimeType,
        'duration': duration,
        'width': width,
        'height': height,
      };

  /// Returns true if this media item is a video.
  bool get isVideo {
    if (mimeType != null && mimeType!.toLowerCase().startsWith('video/')) {
      return true;
    }
    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.mp4') ||
        lowerUrl.endsWith('.mov') ||
        lowerUrl.endsWith('.webm') ||
        duration != null;
  }

  /// Calculates aspect ratio from width and height, defaulting to 1.0 (square).
  double get aspectRatio {
    if (width != null && height != null && height! > 0) {
      final ratio = width! / height!;
      // Constrain between 4:5 (0.8) and 1.91:1 (standard Instagram range)
      return ratio.clamp(0.8, 1.91);
    }
    return 1;
  }
}
