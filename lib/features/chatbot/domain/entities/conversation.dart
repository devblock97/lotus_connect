import 'package:flutter/foundation.dart';

/// Pure Dart entity representing a Chatbot Conversation.
@immutable
class Conversation {
  /// Creates a [Conversation].
  const Conversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    this.isFavourite = false,
    this.modelName = 'gpt-4o',
    this.draftMessage,
    this.systemPrompt,
    this.isUserToUser = false,
    this.peerId = '',
  });

  /// Unique conversation identifier.
  final String id;

  /// Conversation title.
  final String title;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Last updated timestamp.
  final DateTime updatedAt;

  /// Pinned status flag.
  final bool isPinned;

  /// Favourite status flag.
  final bool isFavourite;

  /// Active AI model name for conversation.
  final String modelName;

  /// Draft unsent input message.
  final String? draftMessage;

  /// System prompt override.
  final String? systemPrompt;

  /// Whether the conversation is a user-to-user private chat.
  final bool isUserToUser;

  /// Target peer user ID (UUID) if user-to-user.
  final String peerId;

  /// Returns a copy of [Conversation] with updated fields.
  Conversation copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    bool? isFavourite,
    String? modelName,
    String? draftMessage,
    String? systemPrompt,
    bool? isUserToUser,
    String? peerId,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      isFavourite: isFavourite ?? this.isFavourite,
      modelName: modelName ?? this.modelName,
      draftMessage: draftMessage ?? this.draftMessage,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      isUserToUser: isUserToUser ?? this.isUserToUser,
      peerId: peerId ?? this.peerId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Conversation &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          isPinned == other.isPinned &&
          isFavourite == other.isFavourite &&
          modelName == other.modelName &&
          draftMessage == other.draftMessage &&
          systemPrompt == other.systemPrompt &&
          isUserToUser == other.isUserToUser &&
          peerId == other.peerId;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      isPinned.hashCode ^
      isFavourite.hashCode ^
      modelName.hashCode ^
      draftMessage.hashCode ^
      systemPrompt.hashCode ^
      isUserToUser.hashCode ^
      peerId.hashCode;
}
