import 'package:flutter/material.dart';
import 'package:lotus_connect/app/theme/app_size.dart';
import 'package:lotus_connect/features/home/presentation/widgets/stories_tray.dart';

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0, 0);
  }
}

class ShimmerScope extends InheritedWidget {
  const ShimmerScope({
    required this.linearGradient,
    required super.child,
    super.key,
  });

  final LinearGradient linearGradient;

  static ShimmerScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ShimmerScope>();
  }

  @override
  bool updateShouldNotify(ShimmerScope oldWidget) =>
      linearGradient != oldWidget.linearGradient;
}

class Shimmer extends StatefulWidget {
  const Shimmer({
    required this.child,
    super.key,
    this.duration = const Duration(milliseconds: 1400),
  });

  final Widget child;
  final Duration duration;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseColor =
        isDark ? const Color(0xFF1E1E24) : const Color(0xFFE4E4E8);
    final highlightColor =
        isDark ? const Color(0xFF2E2E38) : const Color(0xFFF4F4F8);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final gradient = LinearGradient(
          colors: [
            baseColor,
            highlightColor,
            baseColor,
          ],
          stops: const [0.1, 0.5, 0.9],
          transform: _SlidingGradientTransform(
            slidePercent: _controller.value * 2.4 - 1.2,
          ),
        );

        return ShimmerScope(
          linearGradient: gradient,
          child: widget.child,
        );
      },
    );
  }
}

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = AppSize.radiusXs,
    this.shape = BoxShape.rectangle,
  });

  final double? width;
  final double? height;
  final double borderRadius;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fallbackColor =
        isDark ? const Color(0xFF1E1E24) : const Color(0xFFE4E4E8);

    final shimmer = ShimmerScope.of(context);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: shape == BoxShape.circle
            ? null
            : BorderRadius.circular(borderRadius),
        color: shimmer == null ? fallbackColor : null,
        gradient: shimmer?.linearGradient,
      ),
    );
  }
}

class PostCardSkeleton extends StatelessWidget {
  const PostCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Padding(
          padding: AppPadding.buttonCompact,
          child: Row(
            children: [
              ShimmerBox(
                width: AppSize.avatarMd,
                height: AppSize.avatarMd,
                shape: BoxShape.circle,
              ),
              AppGap.hSm,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShimmerBox(
                    width: 120,
                    height: AppSize.skeletonLineSm,
                  ),
                  AppGap.vXs,
                  ShimmerBox(
                    width: 70,
                    height: AppSize.skeletonLineXs,
                  ),
                ],
              ),
              Spacer(),
              ShimmerBox(
                width: AppSize.iconXs,
                height: AppSize.iconXs,
              ),
            ],
          ),
        ),

        // Media area (1:1 aspect ratio)
        AspectRatio(
          aspectRatio: 1,
          child: ShimmerBox(
            width: double.infinity,
            height: double.infinity,
            borderRadius: AppSize.radiusNone,
          ),
        ),

        // Action Bar (Heart, Comment, Share, Bookmark)
        Padding(
          padding: EdgeInsets.only(
            left: AppSize.md,
            right: AppSize.md,
            top: AppSize.sm,
            bottom: AppSize.sm,
          ),
          child: Row(
            children: [
              ShimmerBox(
                width: AppSize.iconMd,
                height: AppSize.iconMd,
              ),
              AppGap.hMd,
              ShimmerBox(
                width: AppSize.iconMd,
                height: AppSize.iconMd,
              ),
              AppGap.hMd,
              ShimmerBox(
                width: AppSize.iconMd,
                height: AppSize.iconMd,
              ),
              Spacer(),
              ShimmerBox(
                width: AppSize.iconSm,
                height: AppSize.iconMd,
              ),
            ],
          ),
        ),

        // Likes section
        Padding(
          padding: AppPadding.hMd,
          child: ShimmerBox(
            width: 130,
            height: AppSize.skeletonLineXs,
          ),
        ),

        // Caption lines
        Padding(
          padding: EdgeInsets.only(
            left: AppSize.md,
            right: AppSize.md,
            top: AppSize.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ShimmerBox(
                width: 250,
                height: AppSize.skeletonLineXs,
              ),
              AppGap.vXs,
              ShimmerBox(
                width: 170,
                height: AppSize.skeletonLineXs,
              ),
            ],
          ),
        ),

        // Comments prompt
        Padding(
          padding: EdgeInsets.only(
            left: AppSize.md,
            right: AppSize.md,
            top: AppSize.sm,
          ),
          child: ShimmerBox(
            width: 115,
            height: AppSize.skeletonLineXs,
          ),
        ),

        // Timestamp
        Padding(
          padding: EdgeInsets.only(
            left: AppSize.md,
            right: AppSize.md,
            top: AppSize.xs,
          ),
          child: ShimmerBox(
            width: 60,
            height: AppSize.sm,
          ),
        ),

        AppGap.vMd,
      ],
    );
  }
}

class PostListSkeleton extends StatelessWidget {
  const PostListSkeleton({
    super.key,
    this.itemCount = 3,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Shimmer(
      child: ListView.builder(
        padding: AppPadding.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const StoriesTray(),
                Divider(
                  height: AppSize.dividerThickness,
                  thickness: AppSize.borderHairline,
                  color: theme.dividerColor.withValues(alpha: 0.15),
                ),
              ],
            );
          }

          final postIndex = index - 1;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const PostCardSkeleton(),
              if (postIndex < itemCount - 1)
                Divider(
                  height: AppSize.dividerThickness,
                  thickness: AppSize.borderHairline,
                  color: theme.dividerColor.withValues(alpha: 0.1),
                ),
            ],
          );
        },
      ),
    );
  }
}

class SliverPostListSkeleton extends StatelessWidget {
  const SliverPostListSkeleton({
    super.key,
    this.itemCount = 3,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: Shimmer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            itemCount,
            (index) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const PostCardSkeleton(),
                if (index < itemCount - 1)
                  Divider(
                    height: AppSize.dividerThickness,
                    thickness: AppSize.borderHairline,
                    color: theme.dividerColor.withValues(alpha: 0.1),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
