import 'package:flutter/material.dart';
import 'package:lotus_connect/features/home/presentation/widgets/post_card_skeleton.dart';

class NotificationTileSkeleton extends StatelessWidget {
  const NotificationTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 56x56 Avatar + overlapping badge placeholder
          SizedBox(
            width: 58,
            height: 58,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const ShimmerBox(
                  width: 56,
                  height: 56,
                  shape: BoxShape.circle,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: const ShimmerBox(
                      width: 22,
                      height: 22,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Text lines + timestamp
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(
                    width: double.infinity,
                    height: 13,
                  ),
                  SizedBox(height: 7),
                  ShimmerBox(
                    width: 210,
                    height: 13,
                  ),
                  SizedBox(height: 8),
                  ShimmerBox(
                    width: 64,
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Padding(
            padding: EdgeInsets.only(top: 18),
            child: ShimmerBox(
              width: 20,
              height: 8,
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
              padding: EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: ShimmerBox(
                width: 72,
                height: 16,
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
