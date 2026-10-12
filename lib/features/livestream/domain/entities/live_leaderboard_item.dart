import 'package:flutter/foundation.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';

@immutable
class LiveLeaderboardItem {
  const LiveLeaderboardItem({
    required this.user,
    required this.totalCoins,
    required this.giftCount,
  });

  factory LiveLeaderboardItem.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    final user = userJson is Map<String, dynamic>
        ? PostAuthor.fromJson(userJson)
        : const PostAuthor(id: '', username: 'supporter');

    return LiveLeaderboardItem(
      user: user,
      totalCoins: (json['totalCoins'] as num?)?.toInt() ?? 0,
      giftCount: (json['giftCount'] as num?)?.toInt() ?? 0,
    );
  }

  final PostAuthor user;
  final int totalCoins;
  final int giftCount;

  Map<String, dynamic> toJson() => {
        'user': user.toJson(),
        'totalCoins': totalCoins,
        'giftCount': giftCount,
      };
}
