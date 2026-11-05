import 'package:flutter/foundation.dart';
import 'package:lotus_connect/features/chill/domain/entities/chill_audio.dart';
import 'package:lotus_connect/features/home/domain/entities/post_media_item.dart';

/// Parameters for creating and publishing a new Chill reel.
/// Maps 1:1 with backend `CreateChillRequest` (`CreatePostRequest`).
@immutable
class CreateChillParams {
  const CreateChillParams({
    required this.videoUrl,
    this.caption,
    this.thumbnailUrl,
    this.audioTitle,
    this.audioArtist,
    this.audioUrl,
    this.audio,
    this.duration,
    this.width,
    this.height,
    this.aspectRatio,
    this.remixParentId,
    this.tags = const [],
    this.visibility = 'public',
    this.metadata,
    this.mediaItems,
  });

  final String videoUrl;
  final String? caption;
  final String? thumbnailUrl;
  final String? audioTitle;
  final String? audioArtist;
  final String? audioUrl;
  final ChillAudio? audio;
  final double? duration;
  final int? width;
  final int? height;
  final double? aspectRatio;
  final String? remixParentId;
  final List<String> tags;
  final String visibility;
  final Map<String, dynamic>? metadata;
  final List<PostMediaItem>? mediaItems;

  Map<String, dynamic> toJson() => {
        'postType': 'chill',
        'videoUrl': videoUrl,
        if (caption != null) 'caption': caption,
        if (caption != null) 'content': caption,
        if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
        if (audioTitle != null || audio?.title != null)
          'audioTitle': audioTitle ?? audio?.title,
        if (audioArtist != null || audio?.artist != null)
          'audioArtist': audioArtist ?? audio?.artist,
        if (audioUrl != null || audio?.audioUrl != null)
          'audioUrl': audioUrl ?? audio?.audioUrl,
        if (duration != null) 'duration': duration,
        if (width != null) 'width': width,
        if (height != null) 'height': height,
        if (remixParentId != null) 'remixParentId': remixParentId,
        if (tags.isNotEmpty) 'tags': tags,
        'visibility': visibility,
        if (metadata != null) 'metadata': metadata,
        if (mediaItems != null && mediaItems!.isNotEmpty)
          'mediaItems': mediaItems!.map((m) => m.toJson()).toList(),
      };

  CreateChillParams copyWith({
    String? videoUrl,
    String? caption,
    String? thumbnailUrl,
    String? audioTitle,
    String? audioArtist,
    String? audioUrl,
    ChillAudio? audio,
    double? duration,
    int? width,
    int? height,
    double? aspectRatio,
    String? remixParentId,
    List<String>? tags,
    String? visibility,
    Map<String, dynamic>? metadata,
    List<PostMediaItem>? mediaItems,
  }) {
    return CreateChillParams(
      videoUrl: videoUrl ?? this.videoUrl,
      caption: caption ?? this.caption,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      audioTitle: audioTitle ?? this.audioTitle,
      audioArtist: audioArtist ?? this.audioArtist,
      audioUrl: audioUrl ?? this.audioUrl,
      audio: audio ?? this.audio,
      duration: duration ?? this.duration,
      width: width ?? this.width,
      height: height ?? this.height,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      remixParentId: remixParentId ?? this.remixParentId,
      tags: tags ?? this.tags,
      visibility: visibility ?? this.visibility,
      metadata: metadata ?? this.metadata,
      mediaItems: mediaItems ?? this.mediaItems,
    );
  }
}
