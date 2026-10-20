import 'package:flutter/foundation.dart';
import 'package:lotus_connect/core/utils/media_url_normalizer.dart';

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

  bool get isVideo {
    final mime = mimeType?.toLowerCase() ?? '';
    if (mime.startsWith('video/') ||
        mime == 'application/x-mpegurl' ||
        mime == 'application/vnd.apple.mpegurl') {
      return true;
    }
    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.mp4') ||
        lowerUrl.endsWith('.mov') ||
        lowerUrl.endsWith('.webm') ||
        lowerUrl.endsWith('.m3u8') ||
        duration != null;
  }

  /// Whether this media item is an HLS playlist (.m3u8).
  bool get isHls {
    final mime = mimeType?.toLowerCase() ?? '';
    return mime == 'application/x-mpegurl' ||
        mime == 'application/vnd.apple.mpegurl' ||
        url.toLowerCase().endsWith('.m3u8');
  }

  PostMediaItem copyWith({
    String? url,
    String? thumbnailUrl,
    String? fileName,
    int? fileSize,
    String? mimeType,
    int? duration,
    int? width,
    int? height,
  }) {
    return PostMediaItem(
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      duration: duration ?? this.duration,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  /// Resolves this media item's URLs against the active server host.
  PostMediaItem normalizedForHost(String serverHost) {
    return copyWith(
      url: normalizeMediaUrl(url, serverHost: serverHost),
      thumbnailUrl: thumbnailUrl != null
          ? normalizeMediaUrl(thumbnailUrl!, serverHost: serverHost)
          : null,
    );
  }

  double get aspectRatio {
    if (width != null && height != null && height! > 0) {
      final ratio = width! / height!;
      // Constrain between 4:5 (0.8) and 1.91:1 (standard Instagram range)
      return ratio.clamp(0.8, 1.91);
    }
    return 1;
  }
}
