import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lotus_connect/app/theme/app_size.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_gift.dart';

/// Full-screen animated celebration banner when a virtual gift is sent
/// (TikTok Gifts / Facebook Stars / YouTube SuperStickers).
class GiftAnimationOverlay extends StatefulWidget {
  const GiftAnimationOverlay({
    required this.giftEvent,
    super.key,
  });

  final LiveGiftEvent giftEvent;

  @override
  State<GiftAnimationOverlay> createState() => _GiftAnimationOverlayState();
}

class _GiftAnimationOverlayState extends State<GiftAnimationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _slideAnimation = Tween<double>(begin: -1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.25, curve: Curves.elasticOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.2, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.35, curve: Curves.bounceOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.85, 1, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final giftDef = widget.giftEvent.giftDefinition;
    final sender = widget.giftEvent.sender;
    final combo = widget.giftEvent.comboCount;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(_slideAnimation.value * 200, 0),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(left: AppSize.lg, top: 120),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Celebratory banner pill
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSize.md,
                vertical: AppSize.chipVertical,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    giftDef.gradientColors.first.withValues(alpha: 0.9),
                    giftDef.gradientColors.last.withValues(alpha: 0.75),
                  ],
                ),
                borderRadius: AppRadius.full,
                boxShadow: [
                  BoxShadow(
                    color: giftDef.gradientColors.first.withValues(alpha: 0.4),
                    blurRadius: AppSize.lg,
                    spreadRadius: AppSize.xxs,
                  ),
                ],
                border: AppBorder.all(
                  Colors.white.withValues(alpha: 0.6),
                  width: AppSize.borderMedium,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Sender avatar
                  Container(
                    width: AppSize.avatarMd,
                    height: AppSize.avatarMd,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black26,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child:
                        sender.avatarUrl != null && sender.avatarUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: sender.avatarUrl!,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, dynamic ___) =>
                                    Center(child: Text(sender.initials)),
                              )
                            : Center(
                                child: Text(
                                  sender.initials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                  ),
                  AppGap.hSm,

                  // Sender info & gift details
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        (sender.fullName?.isNotEmpty ?? false)
                            ? sender.fullName!
                            : sender.username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(blurRadius: 2, color: Colors.black54),
                          ],
                        ),
                      ),
                      Text(
                        'Sent ${giftDef.name}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  AppGap.hMd,

                  // Gift animated Icon
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Text(
                      giftDef.icon,
                      style: const TextStyle(fontSize: 36),
                    ),
                  ),
                ],
              ),
            ),

            // Animated Combo multiplier (e.g. x5 COMBO!)
            if (combo > 1) ...[
              AppGap.hSm,
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSize.sm,
                  vertical: AppSize.xs,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                  ),
                  borderRadius: AppRadius.md,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.6),
                      blurRadius: AppSize.md,
                      spreadRadius: AppSize.xxs,
                    ),
                  ],
                ),
                child: Text(
                  'x$combo',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
