import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lotus_connect/app/theme/app_size.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_viewer.dart';

/// Modal bottom sheet displaying active stream viewers.
class ViewersSheet extends StatelessWidget {
  const ViewersSheet({
    required this.viewers,
    required this.totalCount,
    super.key,
  });

  final List<LiveViewer> viewers;
  final int totalCount;

  static Future<void> show(
    BuildContext context, {
    required List<LiveViewer> viewers,
    required int totalCount,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ViewersSheet(
        viewers: viewers,
        totalCount: totalCount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        maxHeight: MediaQuery.of(context).size.height * 0.6,
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
              Text(
                'Viewers ($totalCount)',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
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
          AppGap.vMd,
          Expanded(
            child: viewers.isEmpty
                ? const Center(
                    child: Text(
                      'No other viewers yet',
                      style: TextStyle(color: Colors.white60),
                    ),
                  )
                : ListView.separated(
                    itemCount: viewers.length,
                    separatorBuilder: (_, __) => const Divider(
                      color: Colors.white12,
                      height: AppSize.dividerThickness,
                    ),
                    itemBuilder: (context, index) {
                      final viewer = viewers[index];
                      final user = viewer.user;

                      return ListTile(
                        contentPadding: AppPadding.zero,
                        leading: _buildAvatar(user),
                        title: Text(
                          (user.fullName?.isNotEmpty ?? false)
                              ? user.fullName!
                              : user.username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          '@${user.username}',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                        trailing: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFFF2D55),
                            side: AppBorder.thin(const Color(0xFFFF2D55)),
                            shape: AppBorder.rounded(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSize.bubbleHorizontal,
                              vertical: AppSize.xs,
                            ),
                          ),
                          onPressed: () {},
                          child: const Text(
                            'Follow',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(PostAuthor user) {
    return Container(
      width: AppSize.avatarMd,
      height: AppSize.avatarMd,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white24,
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
