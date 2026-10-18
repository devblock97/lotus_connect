import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_leaderboard_item.dart';

/// Modal bottom sheet displaying top supporters & gifters leaderboard.
class LeaderboardSheet extends StatelessWidget {
  const LeaderboardSheet({
    required this.supporters,
    super.key,
  });

  final List<LiveLeaderboardItem> supporters;

  static Future<void> show(
    BuildContext context, {
    required List<LiveLeaderboardItem> supporters,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => LeaderboardSheet(supporters: supporters),
    );
  }

  @override
  Widget build(BuildContext context) {
    final top3 = supporters.take(3).toList();
    final remaining = supporters.skip(3).toList();

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF161823),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('🏆 ', style: TextStyle(fontSize: 18)),
                  Text(
                    'Top Supporters',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white60, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (supporters.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'No gifts sent yet! Be the first supporter 🎁',
                  style: TextStyle(color: Colors.white60),
                ),
              ),
            )
          else ...[
            // Top 3 Podium
            _buildPodium(top3),
            const SizedBox(height: 16),

            // Remaining list
            if (remaining.isNotEmpty) ...[
              const Divider(color: Colors.white12, height: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: remaining.length,
                  separatorBuilder: (_, __) =>
                      const Divider(color: Colors.white12, height: 1),
                  itemBuilder: (context, index) {
                    final item = remaining[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 24,
                            child: Text(
                              '${index + 4}',
                              style: const TextStyle(
                                color: Colors.white60,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildAvatar(item.user, 36),
                        ],
                      ),
                      title: Text(
                        (item.user.fullName?.isNotEmpty ?? false)
                            ? item.user.fullName!
                            : item.user.username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🪙 ', style: TextStyle(fontSize: 12)),
                          Text(
                            '${item.totalCoins}',
                            style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildPodium(List<LiveLeaderboardItem> top3) {
    // Podium order: 2nd (left), 1st (center), 3rd (right)
    final first = top3.isNotEmpty ? top3[0] : null;
    final second = top3.length > 1 ? top3[1] : null;
    final third = top3.length > 2 ? top3[2] : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (second != null)
          _buildPodiumSlot(
            second,
            rank: 2,
            height: 100,
            color: const Color(0xFFC0C0C0),
            crown: '🥈',
          ),
        if (first != null)
          _buildPodiumSlot(
            first,
            rank: 1,
            height: 125,
            color: const Color(0xFFFFD700),
            crown: '👑',
          ),
        if (third != null)
          _buildPodiumSlot(
            third,
            rank: 3,
            height: 85,
            color: const Color(0xFFCD7F32),
            crown: '🥉',
          ),
      ],
    );
  }

  Widget _buildPodiumSlot(
    LiveLeaderboardItem item, {
    required int rank,
    required double height,
    required Color color,
    required String crown,
  }) {
    return Container(
      width: 96,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(crown, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          _buildAvatar(item.user, rank == 1 ? 52 : 44, borderColor: color),
          const SizedBox(height: 6),
          Text(
            item.user.username,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🪙 ', style: TextStyle(fontSize: 10)),
              Text(
                '${item.totalCoins}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(PostAuthor user, double size, {Color? borderColor}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white24,
        border: borderColor != null
            ? Border.all(color: borderColor, width: 2)
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: user.avatarUrl!,
              fit: BoxFit.cover,
              errorWidget: (_, __, dynamic ___) => Center(
                child: Text(
                  user.initials,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            )
          : Center(
              child: Text(
                user.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }
}
