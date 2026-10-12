import 'package:flutter/material.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';

class LiveGiftType {
  const LiveGiftType({
    required this.id,
    required this.name,
    required this.coins,
    required this.icon,
    required this.gradientColors,
    required this.tag,
  });

  final String id;
  final String name;
  final int coins;
  final String icon;
  final List<Color> gradientColors;
  final String tag;

  static const List<LiveGiftType> all = [
    LiveGiftType(
      id: 'rose',
      name: 'Rose',
      coins: 1,
      icon: '🌹',
      gradientColors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
      tag: 'Popular',
    ),
    LiveGiftType(
      id: 'heart',
      name: 'Heart',
      coins: 5,
      icon: '💖',
      gradientColors: [Color(0xFFF355A0), Color(0xFFFF758C)],
      tag: 'Love',
    ),
    LiveGiftType(
      id: 'coffee',
      name: 'Coffee',
      coins: 10,
      icon: '☕',
      gradientColors: [Color(0xFF8B5A2B), Color(0xFFD4A373)],
      tag: 'Energy',
    ),
    LiveGiftType(
      id: 'diamond',
      name: 'Diamond',
      coins: 50,
      icon: '💎',
      gradientColors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
      tag: 'Special',
    ),
    LiveGiftType(
      id: 'firework',
      name: 'Fireworks',
      coins: 100,
      icon: '🎆',
      gradientColors: [Color(0xFFFF9A8B), Color(0xFFFF6A88)],
      tag: 'Celebration',
    ),
    LiveGiftType(
      id: 'rocket',
      name: 'Rocket',
      coins: 500,
      icon: '🚀',
      gradientColors: [Color(0xFF7F00FF), Color(0xFFE100FF)],
      tag: 'Epic',
    ),
    LiveGiftType(
      id: 'crown',
      name: 'Golden Crown',
      coins: 1000,
      icon: '👑',
      gradientColors: [Color(0xFFFFD700), Color(0xFFFFA500)],
      tag: 'Legendary',
    ),
  ];

  static LiveGiftType fromId(String id) {
    return all.firstWhere(
      (g) => g.id.toLowerCase() == id.toLowerCase(),
      orElse: () => all.first,
    );
  }
}

@immutable
class LiveGiftEvent {
  const LiveGiftEvent({
    required this.id,
    required this.streamId,
    required this.sender,
    required this.giftType,
    required this.giftCount,
    required this.coinAmount,
    required this.createdAt,
    this.comboCount = 1,
  });

  factory LiveGiftEvent.fromJson(Map<String, dynamic> json) {
    final senderJson = json['sender'];
    final sender = senderJson is Map<String, dynamic>
        ? PostAuthor.fromJson(senderJson)
        : const PostAuthor(id: '', username: 'sender');

    final createdAtStr = json['createdAt'] as String?;
    final createdAt = createdAtStr != null
        ? DateTime.tryParse(createdAtStr) ?? DateTime.now()
        : DateTime.now();

    return LiveGiftEvent(
      id: json['id'] as String? ?? '',
      streamId: json['streamId'] as String? ?? '',
      sender: sender,
      giftType: json['giftType'] as String? ?? 'rose',
      giftCount: (json['giftCount'] as num?)?.toInt() ?? 1,
      coinAmount: (json['coinAmount'] as num?)?.toInt() ?? 1,
      comboCount: (json['comboCount'] as num?)?.toInt() ?? 1,
      createdAt: createdAt,
    );
  }

  final String id;
  final String streamId;
  final PostAuthor sender;
  final String giftType;
  final int giftCount;
  final int coinAmount;
  final int comboCount;
  final DateTime createdAt;

  LiveGiftType get giftDefinition => LiveGiftType.fromId(giftType);

  Map<String, dynamic> toJson() => {
        'id': id,
        'streamId': streamId,
        'sender': sender.toJson(),
        'giftType': giftType,
        'giftCount': giftCount,
        'coinAmount': coinAmount,
        'comboCount': comboCount,
        'createdAt': createdAt.toIso8601String(),
      };
}
