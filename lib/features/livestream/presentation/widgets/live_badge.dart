import 'package:flutter/material.dart';
import 'package:lotus_connect/app/theme/app_size.dart';

/// Pulsing, glowing LIVE badge with TikTok/Instagram broadcast styling.
class LiveBadge extends StatefulWidget {
  const LiveBadge({
    super.key,
    this.isCompact = false,
    this.pulse = true,
  });

  final bool isCompact;
  final bool pulse;

  @override
  State<LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<LiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _glowAnimation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.pulse) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.pulse) {
      return _buildContent(1);
    }

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, _) => _buildContent(_glowAnimation.value),
    );
  }

  Widget _buildContent(double glow) {
    final isCompact = widget.isCompact;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? AppSize.xs : AppSize.sm,
        vertical: AppSize.xxs,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF0844),
            Color(0xFFFF4E50),
          ],
        ),
        borderRadius: isCompact ? AppRadius.xs : AppRadius.sm,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF0844).withValues(alpha: 0.4 * glow),
            blurRadius: AppSize.chipVertical * glow,
            spreadRadius: AppSize.elevationXs * glow,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isCompact ? AppSize.xs : AppSize.chipVertical,
            height: isCompact ? AppSize.xs : AppSize.chipVertical,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: glow),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: isCompact ? AppSize.xxs : AppSize.xs),
          Text(
            'LIVE',
            style: TextStyle(
              color: Colors.white,
              fontSize: isCompact ? 9 : 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
