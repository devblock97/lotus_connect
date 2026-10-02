import 'package:flutter/material.dart';
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
    this.borderRadius = 4,
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
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              ShimmerBox(
                width: 38,
                height: 38,
                shape: BoxShape.circle,
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShimmerBox(width: 120, height: 12, borderRadius: 3),
                  SizedBox(height: 5),
                  ShimmerBox(width: 70, height: 9, borderRadius: 3),
                ],
              ),
              Spacer(),
              ShimmerBox(width: 16, height: 16),
            ],
          ),
        ),

        // Media area (1:1 aspect ratio)
        AspectRatio(
          aspectRatio: 1,
          child: ShimmerBox(
            width: double.infinity,
            height: double.infinity,
            borderRadius: 0,
          ),
        ),

        // Action Bar (Heart, Comment, Share, Bookmark)
        Padding(
          padding: EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 8),
          child: Row(
            children: [
              ShimmerBox(width: 22, height: 22, borderRadius: 5),
              SizedBox(width: 14),
              ShimmerBox(width: 22, height: 22, borderRadius: 5),
              SizedBox(width: 14),
              ShimmerBox(width: 22, height: 22, borderRadius: 5),
              Spacer(),
              ShimmerBox(width: 20, height: 22),
            ],
          ),
        ),

        // Likes section
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: ShimmerBox(width: 130, height: 11, borderRadius: 3),
        ),

        // Caption lines
        Padding(
          padding: EdgeInsets.only(left: 12, right: 12, top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ShimmerBox(width: 250, height: 11, borderRadius: 3),
              SizedBox(height: 5),
              ShimmerBox(width: 170, height: 11, borderRadius: 3),
            ],
          ),
        ),

        // Comments prompt
        Padding(
          padding: EdgeInsets.only(left: 12, right: 12, top: 8),
          child: ShimmerBox(width: 115, height: 10, borderRadius: 3),
        ),

        // Timestamp
        Padding(
          padding: EdgeInsets.only(left: 12, right: 12, top: 6),
          child: ShimmerBox(width: 60, height: 8, borderRadius: 3),
        ),

        SizedBox(height: 14),
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
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const StoriesTray(),
                Divider(
                  height: 1,
                  thickness: 0.5,
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
                  height: 1,
                  thickness: 0.5,
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
                    height: 1,
                    thickness: 0.5,
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
