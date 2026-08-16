import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class Conversation extends Equatable {
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

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isPinned: json['isPinned'] as bool? ?? false,
      isFavourite: json['isFavourite'] as bool? ?? false,
      modelName: json['modelName'] as String? ?? 'gemini-1.5-flash',
      draftMessage: json['draftMessage'] as String? ?? '',
      systemPrompt: json['systemPrompt'] as String? ?? '',
      isUserToUser: json['isUserToUser'] as bool? ?? false,
      peerId: json['peerId'] as String? ?? '',
    );
  }

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isPinned': isPinned,
      'isFavourite': isFavourite,
      'modelName': modelName,
      'draftMessage': draftMessage,
      'systemPrompt': systemPrompt,
      'isUserToUser': isUserToUser,
      'peerId': peerId,
    };
  }

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
  List<Object?> get props => [
        id,
        title,
        createdAt,
        updatedAt,
        isPinned,
        isFavourite,
        modelName,
        draftMessage,
        systemPrompt,
        isUserToUser,
        peerId,
      ];
}
