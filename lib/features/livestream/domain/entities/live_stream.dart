import 'package:flutter/foundation.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';

@immutable
class LiveStream {
  const LiveStream({
    required this.id,
    required this.host,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.thumbnailUrl,
    this.status = 'created',
    this.privacy = 'public',
    this.playbackUrl,
    this.channelId,
    this.viewerCount = 0,
    this.peakViewers = 0,
    this.totalViews = 0,
    this.likeCount = 0,
    this.pinnedCommentId,
    this.startedAt,
    this.endedAt,
    this.durationSeconds = 0,
    this.recordingUrl,
    this.isHost = false,
    this.streamKey,
    this.ingestUrl,
  });

  factory LiveStream.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is String && val.isNotEmpty) {
        return DateTime.tryParse(val);
      }
      return null;
    }

    final hostJson = json['host'];
    final host = hostJson is Map<String, dynamic>
        ? PostAuthor.fromJson(hostJson)
        : const PostAuthor(id: '', username: 'host');

    return LiveStream(
      id: json['id'] as String? ?? '',
      host: host,
      title: json['title'] as String? ?? 'Untitled Live',
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      status: json['status'] as String? ?? 'created',
      privacy: json['privacy'] as String? ?? 'public',
      playbackUrl: json['playbackUrl'] as String?,
      channelId: json['channelId'] as String?,
      viewerCount: (json['viewerCount'] as num?)?.toInt() ?? 0,
      peakViewers: (json['peakViewers'] as num?)?.toInt() ?? 0,
      totalViews: (json['totalViews'] as num?)?.toInt() ?? 0,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      pinnedCommentId: json['pinnedCommentId'] as String?,
      startedAt: parseDate(json['startedAt']),
      endedAt: parseDate(json['endedAt']),
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      recordingUrl: json['recordingUrl'] as String?,
      isHost: json['isHost'] as bool? ?? false,
      streamKey: json['streamKey'] as String?,
      ingestUrl: json['ingestUrl'] as String?,
      createdAt: parseDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: parseDate(json['updatedAt']) ?? DateTime.now(),
    );
  }

  final String id;
  final PostAuthor host;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final String status; // 'created', 'live', 'ended'
  final String privacy; // 'public', 'friends', 'private'
  final String? playbackUrl;
  final String? channelId;
  final int viewerCount;
  final int peakViewers;
  final int totalViews;
  final int likeCount;
  final String? pinnedCommentId;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int durationSeconds;
  final String? recordingUrl;
  final bool isHost;
  final String? streamKey;
  final String? ingestUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isLive => status == 'live';
  bool get isEnded => status == 'ended';

  Map<String, dynamic> toJson() => {
        'id': id,
        'host': host.toJson(),
        'title': title,
        'description': description,
        'thumbnailUrl': thumbnailUrl,
        'status': status,
        'privacy': privacy,
        'playbackUrl': playbackUrl,
        'channelId': channelId,
        'viewerCount': viewerCount,
        'peakViewers': peakViewers,
        'totalViews': totalViews,
        'likeCount': likeCount,
        'pinnedCommentId': pinnedCommentId,
        'startedAt': startedAt?.toIso8601String(),
        'endedAt': endedAt?.toIso8601String(),
        'durationSeconds': durationSeconds,
        'recordingUrl': recordingUrl,
        'isHost': isHost,
        'streamKey': streamKey,
        'ingestUrl': ingestUrl,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  LiveStream copyWith({
    String? id,
    PostAuthor? host,
    String? title,
    String? description,
    String? thumbnailUrl,
    String? status,
    String? privacy,
    String? playbackUrl,
    String? channelId,
    int? viewerCount,
    int? peakViewers,
    int? totalViews,
    int? likeCount,
    String? pinnedCommentId,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationSeconds,
    String? recordingUrl,
    bool? isHost,
    String? streamKey,
    String? ingestUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LiveStream(
      id: id ?? this.id,
      host: host ?? this.host,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      status: status ?? this.status,
      privacy: privacy ?? this.privacy,
      playbackUrl: playbackUrl ?? this.playbackUrl,
      channelId: channelId ?? this.channelId,
      viewerCount: viewerCount ?? this.viewerCount,
      peakViewers: peakViewers ?? this.peakViewers,
      totalViews: totalViews ?? this.totalViews,
      likeCount: likeCount ?? this.likeCount,
      pinnedCommentId: pinnedCommentId ?? this.pinnedCommentId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      recordingUrl: recordingUrl ?? this.recordingUrl,
      isHost: isHost ?? this.isHost,
      streamKey: streamKey ?? this.streamKey,
      ingestUrl: ingestUrl ?? this.ingestUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
