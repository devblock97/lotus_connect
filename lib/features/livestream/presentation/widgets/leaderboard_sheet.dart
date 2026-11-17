import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lotus_connect/app/theme/app_size.dart';
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
        borderRadius: AppRadius.bottomSheetTop,
      ),
      padding: const EdgeInsets.only(
        top: AppSize.md,
        left: AppSize.lg,
        right: AppSize.lg,
        bottom: AppSize.xxl,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: AppSize.sheetHandleWidth,
              height: AppSize.sheetHandleHeight,
              decoration: const BoxDecoration(
                color: Colors.white24,
                borderRadius: AppRadius.full,
              ),
            ),
          ),
          AppGap.vMd,
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
                icon: const Icon(
                  Icons.close,
                  color: Colors.white60,
                  size: AppSize.iconSm,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          AppGap.vLg,
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
            AppGap.vLg,

            // Remaining list
            if (remaining.isNotEmpty) ...[
              const Divider(
                color: Colors.white12,
                height: AppSize.dividerThickness,
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: remaining.length,
                  separatorBuilder: (_, __) => const Divider(
                    color: Colors.white12,
                    height: AppSize.dividerThickness,
                  ),
                  itemBuilder: (context, index) {
                    final item = remaining[index];
                    return ListTile(
                      contentPadding: AppPadding.zero,
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: AppSize.xxl,
                            child: Text(
                              '${index + 4}',
                              style: const TextStyle(
                                color: Colors.white60,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildAvatar(item.user, AppSize.buttonHeightSm),
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
      width: AppSize.avatarProfile,
      margin: AppPadding.hXs,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(crown, style: const TextStyle(fontSize: 20)),
          AppGap.vXs,
          _buildAvatar(
            item.user,
            rank == 1 ? AppSize.buttonHeightLg : AppSize.buttonHeightMd,
            borderColor: color,
          ),
          AppGap.vXs,
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
          AppGap.vXxs,
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
            ? AppBorder.all(borderColor, width: AppSize.borderThick)
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
