import 'package:flutter/foundation.dart';

@immutable
class CreateStoryParams {
  const CreateStoryParams({
    this.filePath,
    this.mediaType = 'image',
    this.mediaUrl = 'text',
    this.thumbnailUrl,
    this.caption,
    this.duration = 5.0,
    this.visibility = 'public',
    this.backgroundColor,
    this.metadata,
  });

  final String? filePath;

  final String mediaType;

  final String? mediaUrl;

  final String? thumbnailUrl;

  final String? caption;

  final double duration;

  final String visibility;

  final String? backgroundColor;

  final Map<String, dynamic>? metadata;

  bool get isValid =>
      (filePath != null && filePath!.trim().isNotEmpty) ||
      (mediaUrl != null && mediaUrl!.trim().isNotEmpty) ||
      mediaType == 'text' ||
      (caption != null && caption!.trim().isNotEmpty);

  CreateStoryParams copyWith({
    String? filePath,
    String? mediaType,
    String? mediaUrl,
    String? thumbnailUrl,
    String? caption,
    double? duration,
    String? visibility,
    String? backgroundColor,
    Map<String, dynamic>? metadata,
  }) {
    return CreateStoryParams(
      filePath: filePath ?? this.filePath,
      mediaType: mediaType ?? this.mediaType,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      caption: caption ?? this.caption,
      duration: duration ?? this.duration,
      visibility: visibility ?? this.visibility,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      metadata: metadata ?? this.metadata,
    );
  }
}
