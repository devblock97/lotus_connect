import 'package:flutter/foundation.dart';

/// Role of message sender.
enum MessageRole {
  user,
  assistant,
  system;

  bool get isUser => this == MessageRole.user;
  bool get isAssistant => this == MessageRole.assistant;
  bool get isSystem => this == MessageRole.system;
}

/// Delivery / generation status of message.
enum MessageStatus {
  sending,
  sent,
  streaming,
  error,
}

/// Pure Dart entity representing a Chat Message.
@immutable
class Message {
  /// Creates a [Message].
  const Message({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isError = false,
    this.status = MessageStatus.sent,
  });

  /// Unique message ID.
  final String id;

  /// Belongs to conversation.
  final String conversationId;

  /// Sender role.
  final MessageRole role;

  /// Message body text.
  final String content;

  /// Timestamp.
  final DateTime timestamp;

  /// Indicates if this message failed to transmit or generate.
  final bool isError;

  /// Message status.
  final MessageStatus status;

  /// Returns a copy of [Message] with updated properties.
  Message copyWith({
    String? id,
    String? conversationId,
    MessageRole? role,
    String? content,
    DateTime? timestamp,
    bool? isError,
    MessageStatus? status,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isError: isError ?? this.isError,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          conversationId == other.conversationId &&
          role == other.role &&
          content == other.content &&
          timestamp == other.timestamp &&
          isError == other.isError &&
          status == other.status;

  @override
  int get hashCode =>
      id.hashCode ^
      conversationId.hashCode ^
      role.hashCode ^
      content.hashCode ^
      timestamp.hashCode ^
      isError.hashCode ^
      status.hashCode;
}
