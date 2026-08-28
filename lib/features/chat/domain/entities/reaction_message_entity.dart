import 'package:equatable/equatable.dart';

class ReactionMessageEntity extends Equatable {
  const ReactionMessageEntity({
    required this.messageId,
    required this.userId,
    required this.reaction,
    required this.createdAt,
  });

  factory ReactionMessageEntity.fromJson(Map<String, dynamic> json) {
    return ReactionMessageEntity(
      messageId: json['messageId'] as String,
      userId: json['userId'] as String,
      reaction: json['reaction'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now().toLocal(),
    );
  }

  Map<String, dynamic> toJson() => {
        'messageId': messageId,
        'userId': userId,
        'reaction': reaction,
        'createdAt': createdAt,
      };

  final String messageId;
  final String userId;
  final String reaction;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        messageId,
        userId,
        reaction,
        createdAt,
      ];
}
