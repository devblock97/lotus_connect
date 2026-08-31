import 'package:equatable/equatable.dart';

/// Pure Dart domain entity representing a historical call log record.
class CallLog extends Equatable {
  const CallLog({
    required this.id,
    required this.hostId,
    required this.channelId,
    required this.isVideo,
    required this.status,
    required this.createdAt,
    this.conversationId,
    this.endedAt,
    this.hostName,
    this.username,
  });

  final String id;
  final String hostId;
  final String? conversationId;
  final String channelId;
  final bool isVideo;
  final String status;
  final DateTime createdAt;
  final DateTime? endedAt;
  final String? hostName;
  final String? username;

  /// Returns call duration in seconds.
  int get durationSeconds {
    if (endedAt == null) return 0;
    return endedAt!.difference(createdAt).inSeconds;
  }

  @override
  List<Object?> get props => [
        id,
        hostId,
        conversationId,
        channelId,
        isVideo,
        status,
        createdAt,
        endedAt,
        hostName,
        username,
      ];
}
