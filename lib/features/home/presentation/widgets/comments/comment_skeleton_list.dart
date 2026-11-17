import 'package:flutter/material.dart';
import 'package:lotus_connect/app/theme/app_size.dart';

/// Skeleton loader displayed while comments are loading.
class CommentSkeletonList extends StatefulWidget {
  const CommentSkeletonList({super.key, this.itemCount = 5});

  final int itemCount;

  @override
  State<CommentSkeletonList> createState() => _CommentSkeletonListState();
}

class _CommentSkeletonListState extends State<CommentSkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: ListView.separated(
            padding: AppPadding.listTile,
            itemCount: widget.itemCount,
            separatorBuilder: (_, __) => AppGap.vXl,
            itemBuilder: (context, index) {
              final isIndented = index % 3 == 2;
              return Padding(
                padding: EdgeInsets.only(
                  left: isIndented ? AppSize.buttonHeightMd : AppSize.none,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar placeholder
                    Container(
                      width: isIndented ? AppSize.avatarSm : AppSize.avatarMd,
                      height: isIndented ? AppSize.avatarSm : AppSize.avatarMd,
                      decoration: BoxDecoration(
                        color: baseColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    AppGap.hMd,

                    // Content bubble lines
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 90,
                                height: AppSize.skeletonLineSm,
                                decoration: BoxDecoration(
                                  color: baseColor,
                                  borderRadius: AppRadius.sm,
                                ),
                              ),
                              AppGap.hSm,
                              Container(
                                width: 35,
                                height: AppSize.skeletonLineXs,
                                decoration: BoxDecoration(
                                  color: baseColor,
                                  borderRadius: AppRadius.xs,
                                ),
                              ),
                            ],
                          ),
                          AppGap.vSm,
                          Container(
                            width: double.infinity,
                            height: AppSize.skeletonLineSm,
                            decoration: BoxDecoration(
                              color: baseColor,
                              borderRadius: AppRadius.sm,
                            ),
                          ),
                          AppGap.vXs,
                          Container(
                            width: index.isEven ? 180 : 130,
                            height: AppSize.skeletonLineSm,
                            decoration: BoxDecoration(
                              color: baseColor,
                              borderRadius: AppRadius.sm,
                            ),
                          ),
                          AppGap.vSm,
                          Row(
                            children: [
                              Container(
                                width: AppSize.huge,
                                height: AppSize.skeletonLineXs,
                                decoration: BoxDecoration(
                                  color: baseColor,
                                  borderRadius: AppRadius.xs,
                                ),
                              ),
                              AppGap.hLg,
                              Container(
                                width: AppSize.xxxl,
                                height: AppSize.skeletonLineXs,
                                decoration: BoxDecoration(
                                  color: baseColor,
                                  borderRadius: AppRadius.xs,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    AppGap.hMd,
                    // Like heart placeholder
                    Container(
                      width: AppSize.iconXs,
                      height: AppSize.iconXs,
                      decoration: BoxDecoration(
                        color: baseColor,
                        borderRadius: AppRadius.xs,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
