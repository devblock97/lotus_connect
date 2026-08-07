import 'package:flutter/foundation.dart';

@immutable
class Conversation {
  const Conversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    this.isFavourite = false,
    this.modelName = 'gemini-1.5-flash',
    this.draftMessage,
    this.systemPrompt,
    this.isUserToUser = false,
    this.peerId = '',
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;
  final bool isFavourite;
  final String modelName;
  final String? draftMessage;
  final String? systemPrompt;
  final bool isUserToUser;
  final String peerId;

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
