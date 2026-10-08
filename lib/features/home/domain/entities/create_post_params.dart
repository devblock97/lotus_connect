import 'package:flutter/foundation.dart';
import 'package:lotus_connect/features/home/domain/entities/post_media_item.dart';

/// Parameters for creating a new post matching the lotus_connect_system
/// API contract.
@immutable
class CreatePostParams {
  const CreatePostParams({
    this.content,
    this.mediaItems,
    this.filePaths = const [],
    this.visibility = 'public',
    this.feeling,
    this.feelingEmoji,
    this.location,
  });

  final String? content;

  /// Pre-uploaded media items if available.
  final List<PostMediaItem>? mediaItems;

  final List<String> filePaths;

  final String visibility;

  final String? feeling;

  final String? feelingEmoji;

  final String? location;

  /// Returns whether this post has either non-empty content or media attached.
  bool get isValid =>
      (content != null && content!.trim().isNotEmpty) ||
      (mediaItems != null && mediaItems!.isNotEmpty) ||
      filePaths.isNotEmpty;

  /// Formatted full content including feeling and location annotations if set.
  String? get formattedContent {
    final buffer = StringBuffer();
    if (content != null && content!.trim().isNotEmpty) {
      buffer.write(content!.trim());
    }

    final annotations = <String>[];
    if (feeling != null && feeling!.isNotEmpty) {
      final emoji = feelingEmoji ?? '';
      annotations.add('$emoji feeling $feeling');
    }
    if (location != null && location!.isNotEmpty) {
      annotations.add('📍 at $location');
    }

    if (annotations.isNotEmpty) {
      if (buffer.isNotEmpty) {
        buffer.write('\n\n');
      }
      buffer.write('— ${annotations.join(' ')}');
    }

    return buffer.isEmpty ? null : buffer.toString();
  }

  CreatePostParams copyWith({
    String? content,
    List<PostMediaItem>? mediaItems,
    List<String>? filePaths,
    String? visibility,
    String? feeling,
    String? feelingEmoji,
    String? location,
  }) {
    return CreatePostParams(
      content: content ?? this.content,
      mediaItems: mediaItems ?? this.mediaItems,
      filePaths: filePaths ?? this.filePaths,
      visibility: visibility ?? this.visibility,
      feeling: feeling ?? this.feeling,
      feelingEmoji: feelingEmoji ?? this.feelingEmoji,
      location: location ?? this.location,
    );
  }
}
