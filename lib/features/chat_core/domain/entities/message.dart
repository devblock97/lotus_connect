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
    this.isError = false,
    this.status = MessageStatus.sent,
    this.replyToId,
  });

  final String id;
  final String conversationId;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final bool isError;
  final MessageStatus status;
  final String? replyToId;

  Message copyWith({
    String? id,
    String? conversationId,
    MessageRole? role,
    String? content,
    DateTime? timestamp,
    bool? isError,
    MessageStatus? status,
    String? replyToId,
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
      ];
}
