import 'package:flutter/foundation.dart';

/// Parameters for updating an existing Chill reel.
/// Maps 1:1 with backend `UpdateChillRequest` (`UpdatePostRequest`).
@immutable
class UpdateChillParams {
  const UpdateChillParams({
    required this.chillId,
    this.caption,
    this.thumbnailUrl,
    this.audioTitle,
    this.audioArtist,
    this.audioUrl,
    this.tags,
    this.visibility,
    this.metadata,
  });

  final String chillId;
  final String? caption;
  final String? thumbnailUrl;
  final String? audioTitle;
  final String? audioArtist;
  final String? audioUrl;
  final List<String>? tags;
  final String? visibility;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() => {
        if (caption != null) 'caption': caption,
        if (caption != null) 'content': caption,
        if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
        if (audioTitle != null) 'audioTitle': audioTitle,
        if (audioArtist != null) 'audioArtist': audioArtist,
        if (audioUrl != null) 'audioUrl': audioUrl,
        if (tags != null) 'tags': tags,
        if (visibility != null) 'visibility': visibility,
        if (metadata != null) 'metadata': metadata,
      };
}
