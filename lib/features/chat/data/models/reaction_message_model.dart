import 'package:equatable/equatable.dart';
import 'package:lotus_connect/features/chat/domain/entities/reaction_message_entity.dart';

class ReactionMessageModel extends Equatable {
  const ReactionMessageModel({
    required this.messageId,
    required this.userId,
    required this.reaction,
    required this.createdAt,
  });

  factory ReactionMessageModel.fromEntity(ReactionMessageEntity entity) {
    return ReactionMessageModel(
      messageId: entity.messageId,
      userId: entity.userId,
      reaction: entity.reaction,
      createdAt: entity.createdAt,
    );
  }

  factory ReactionMessageModel.fromJson(Map<String, dynamic> json) {
    return ReactionMessageModel(
      messageId: json['messageId'] as String,
      userId: json['userId'] as String,
      reaction: json['reaction'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now().toLocal(),
    );
  }

  final String messageId;
  final String userId;
  final String reaction;
  final DateTime createdAt;

  ReactionMessageEntity toEntity() {
    return ReactionMessageEntity(
      messageId: messageId,
      userId: userId,
      reaction: reaction,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        messageId,
        userId,
        reaction,
        createdAt,
      ];
}
