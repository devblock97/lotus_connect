import 'package:lotus_connect/features/calls/domain/entities/call_log.dart';

/// Data model representing a CallLog record DTO from network JSON.
class CallLogModel extends CallLog {
  const CallLogModel({
    required super.id,
    required super.hostId,
    required super.channelId,
    required super.isVideo,
    required super.status,
    required super.createdAt,
    super.conversationId,
    super.endedAt,
    super.hostName,
    super.username,
  });

  factory CallLogModel.fromJson(Map<String, dynamic> json) {
    return CallLogModel(
      id: json['id'] as String? ?? '',
      hostId: json['hostId'] as String? ?? json['host_id'] as String? ?? '',
      hostName: json['hostName'] as String? ?? json['host_name'] as String?,
      username: json['username'] as String?,
      conversationId: json['conversationId'] as String? ??
          json['conversation_id'] as String?,
      channelId:
          json['channelId'] as String? ?? json['channel_id'] as String? ?? '',
      isVideo: json['isVideo'] as bool? ?? json['is_video'] as bool? ?? false,
      status: json['status'] as String? ?? 'initiated',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : json['created_at'] != null
              ? DateTime.tryParse(json['created_at'] as String) ??
                  DateTime.now()
              : DateTime.now(),
      endedAt: json['endedAt'] != null
          ? DateTime.tryParse(json['endedAt'] as String)
          : json['ended_at'] != null
              ? DateTime.tryParse(json['ended_at'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hostId': hostId,
      if (hostName != null) 'hostName': hostName,
      if (username != null) 'username': username,
      if (conversationId != null) 'conversationId': conversationId,
      'channelId': channelId,
      'isVideo': isVideo,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      if (endedAt != null) 'endedAt': endedAt!.toIso8601String(),
    };
  }
}
