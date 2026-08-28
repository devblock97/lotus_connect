import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

enum MessageRole {
  user,
  assistant,
  system;

  bool get isUser => this == MessageRole.user;
  bool get isAssistant => this == MessageRole.assistant;
  bool get isSystem => this == MessageRole.system;
}

enum MessageStatus {
  sending,
  sent,
  read,
  streaming,
  error,
}

@immutable
class Message extends Equatable {
  const Message({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.timestamp,
    this.messageType,
    this.isError = false,
    this.status = MessageStatus.sent,
    this.replyToId,
    this.mediaUrl,
    this.thumbnailUrl,
    this.fileName,
    this.fileSize,
    this.mimeType,
    this.duration,
    this.updatedAt,
    this.reactions = const [],
    this.isEdited = false,
  });

  factory Message.fromJson(Map<String, dynamic> json, MessageRole role) {
    DateTime parseTime(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    List<Reaction> parseReactions(dynamic val) {
      if (val == null) return const [];
      if (val is List) {
        return val
            .whereType<Map<String, dynamic>>()
            .map(Reaction.fromJson)
            .toList();
      }
      if (val is String && val.trim().isNotEmpty) {
        try {
          final decoded = jsonDecode(val);
          if (decoded is List) {
            return decoded
                .whereType<Map<String, dynamic>>()
                .map(Reaction.fromJson)
                .toList();
          }
        } catch (_) {}
      }
      return const [];
    }

    return Message(
      id: (json['id'] ?? '').toString(),
      conversationId:
          (json['conversationId'] ?? json['conversation_id'] ?? '').toString(),
      role: role,
      content: (json['content'] ?? '').toString(),
      timestamp: parseTime(json['createdAt'] ?? json['created_at']),
      isError: json['isError'] as bool? ?? false,
      status: MessageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      messageType: json['message_type'] as String?,
      replyToId: (json['replyToId'] ?? json['reply_to_id'])?.toString(),
      mediaUrl: (json['mediaUrl'] ?? json['media_url'])?.toString(),
      thumbnailUrl: (json['thumbnailUrl'] ?? json['thumbnail_url'])?.toString(),
      fileName: (json['fileName'] ?? json['file_name'])?.toString(),
      fileSize: json['fileSize'] as int? ?? json['file_size'] as int?,
      mimeType: (json['mimeType'] ??
              json['mime_type'] ??
              json['mine_type'] ??
              json['mineType'])
          ?.toString(),
      duration: json['duration'] as int?,
      updatedAt: (json['updatedAt'] ?? json['updated_at'])?.toString(),
      reactions: parseReactions(json['reactions']),
      isEdited:
          json['isEdited'] as bool? ?? json['is_edited'] as bool? ?? false,
    );
  }

  final String id;
  final String conversationId;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final bool isError;
  final MessageStatus status;
  final String? replyToId;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final String? fileName;
  final int? fileSize;
  final String? mimeType;
  final int? duration;
  final String? updatedAt;
  final List<Reaction> reactions;
  final bool isEdited;
  final String? messageType;

  String? get serializedReactions => reactions.isNotEmpty
      ? jsonEncode(reactions.map((e) => e.toJson()).toList())
      : null;

  Message copyWith({
    String? id,
    String? conversationId,
    MessageRole? role,
    String? content,
    DateTime? timestamp,
    bool? isError,
    MessageStatus? status,
    String? replyToId,
    String? mediaUrl,
    String? thumbnailUrl,
    String? fileName,
    int? fileSize,
    String? mimeType,
    int? duration,
    String? updatedAt,
    List<Reaction>? reactions,
    bool? isEdited,
    String? messageType,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isError: isError ?? this.isError,
      status: status ?? this.status,
      replyToId: replyToId ?? this.replyToId,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      duration: duration ?? this.duration,
      updatedAt: updatedAt ?? this.updatedAt,
      reactions: reactions ?? this.reactions,
      isEdited: isEdited ?? this.isEdited,
      messageType: messageType ?? this.messageType,
    );
  }

  @override
  List<Object?> get props => [
        id,
        conversationId,
        role,
        content,
        timestamp,
        isError,
        status,
        replyToId,
        mediaUrl,
        thumbnailUrl,
        fileName,
        fileSize,
        mimeType,
        duration,
        updatedAt,
        reactions,
        isEdited,
      ];
}

class Reaction extends Equatable {
  const Reaction({
    required this.reaction,
    this.count = 0,
    this.users = const [],
  });

  factory Reaction.fromJson(Map<String, dynamic> json) {
    return Reaction(
      reaction: (json['reaction'] ?? '').toString(),
      count: (json['count'] as num?)?.toInt() ?? 0,
      users: (json['users'] as List<dynamic>?)
              ?.map((u) => u.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'reaction': reaction,
        'count': count,
        'users': users,
      };

  final String reaction;
  final int count;
  final List<String> users;

  @override
  List<Object?> get props => [
        reaction,
        count,
        users,
      ];
}
