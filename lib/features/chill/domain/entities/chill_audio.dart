import 'package:flutter/foundation.dart';

/// Represents audio / background music information associated with a Chill (Reel).
@immutable
class ChillAudio {
  const ChillAudio({
    required this.title,
    this.id,
    this.artist,
    this.audioUrl,
    this.thumbnailUrl,
    this.duration,
    this.isOriginal = true,
  });

  factory ChillAudio.fromJson(Map<String, dynamic> json) {
    return ChillAudio(
      id: json['id'] as String?,
      title: json['title'] as String? ?? 'Original Audio',
      artist: (json['artist'] ?? json['author']) as String?,
      audioUrl:
          (json['audioUrl'] ?? json['audio_url'] ?? json['url']) as String?,
      thumbnailUrl: (json['thumbnailUrl'] ?? json['thumbnail_url']) as String?,
      duration: (json['duration'] as num?)?.toDouble(),
      isOriginal: (json['isOriginal'] ?? json['is_original']) as bool? ?? true,
    );
  }

  final String? id;
  final String title;
  final String? artist;
  final String? audioUrl;
  final String? thumbnailUrl;
  final double? duration;
  final bool isOriginal;

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'title': title,
        if (artist != null) 'artist': artist,
        if (audioUrl != null) 'audioUrl': audioUrl,
        if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
        if (duration != null) 'duration': duration,
        'isOriginal': isOriginal,
      };

  ChillAudio copyWith({
    String? id,
    String? title,
    String? artist,
    String? audioUrl,
    String? thumbnailUrl,
    double? duration,
    bool? isOriginal,
  }) {
    return ChillAudio(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      audioUrl: audioUrl ?? this.audioUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      isOriginal: isOriginal ?? this.isOriginal,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChillAudio &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          artist == other.artist &&
          audioUrl == other.audioUrl &&
          isOriginal == other.isOriginal;

  @override
  int get hashCode => Object.hash(id, title, artist, audioUrl, isOriginal);
}
