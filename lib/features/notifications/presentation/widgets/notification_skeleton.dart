import 'package:flutter/material.dart';
import 'package:lotus_connect/app/theme/app_size.dart';
import 'package:lotus_connect/features/home/presentation/widgets/post_card_skeleton.dart';

class NotificationTileSkeleton extends StatelessWidget {
  const NotificationTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPadding.listTile,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 56x56 Avatar + overlapping badge placeholder
          SizedBox(
            width: AppSize.avatarXl + AppSize.xxs,
            height: AppSize.avatarXl + AppSize.xxs,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const ShimmerBox(
                  width: AppSize.avatarXl,
                  height: AppSize.avatarXl,
                  shape: BoxShape.circle,
                ),
                Positioned(
                  right: AppSize.none,
                  bottom: AppSize.none,
                  child: Container(
                    padding: AppPadding.xxs,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: const ShimmerBox(
                      width: AppSize.avatarBadgeMd,
                      height: AppSize.avatarBadgeMd,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppGap.hMd,
          // Text lines + timestamp
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: AppSize.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(
                    width: double.infinity,
                    height: AppSize.skeletonLineMd,
                  ),
                  AppGap.vSm,
                  ShimmerBox(
                    width: 210,
                    height: AppSize.skeletonLineMd,
                  ),
                  AppGap.vSm,
                  ShimmerBox(
                    width: AppSize.giant,
                    height: AppSize.skeletonLineXs,
                  ),
                ],
              ),
            ),
          ),
          AppGap.hMd,
          const Padding(
            padding: EdgeInsets.only(top: AppSize.xl),
            child: ShimmerBox(
              width: AppSize.xl,
              height: AppSize.statusDotSm,
            ),
          ),
        ],
      ),
    );
  }
}

/// Sliver list of [NotificationTileSkeleton] items with a section header.
class SliverNotificationListSkeleton extends StatelessWidget {
  const SliverNotificationListSkeleton({
    super.key,
    this.itemCount = 7,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Shimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSize.lg,
                AppSize.md,
                AppSize.lg,
                AppSize.xs,
              ),
              child: ShimmerBox(
                width: 72,
                height: AppSize.lg,
              ),
            ),
            ...List.generate(
              itemCount,
              (_) => const NotificationTileSkeleton(),
            ),
          ],
        ),
      ),
    );
  }
}
