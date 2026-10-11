import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Supported comment reactions corresponding to backend capabilities.
const List<String> kAvailableCommentReactions = [
  '❤️',
  '👍',
  '🔥',
  '😂',
  '😮',
  '😢',
];

/// Floating reactions bubble overlay allowing users to choose
/// an emoji reaction.
class CommentReactionsOverlay extends StatefulWidget {
  const CommentReactionsOverlay({
    required this.onReactionSelected,
    super.key,
    this.currentReaction,
  });

  final String? currentReaction;
  final ValueChanged<String> onReactionSelected;

  static void show(
    BuildContext context, {
    required GlobalKey targetKey,
    required ValueChanged<String> onReactionSelected,
    String? currentReaction,
  }) {
    final renderBox =
        targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final overlay = Overlay.of(context);
    final targetPosition = renderBox.localToGlobal(Offset.zero);
    final targetSize = renderBox.size;

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (ctx) {
        return Stack(
          children: [
            // Tap outside to dismiss
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => entry.remove(),
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),
            // Floating bubble positioned above target
            Positioned(
              right: (MediaQuery.of(ctx).size.width -
                      targetPosition.dx -
                      targetSize.width)
                  .clamp(16.0, MediaQuery.of(ctx).size.width - 260.0),
              bottom: MediaQuery.of(ctx).size.height - targetPosition.dy + 8,
              child: Material(
                color: Colors.transparent,
                child: CommentReactionsOverlay(
                  currentReaction: currentReaction,
                  onReactionSelected: (reaction) {
                    entry.remove();
                    onReactionSelected(reaction);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(entry);
  }

  @override
  State<CommentReactionsOverlay> createState() =>
      _CommentReactionsOverlayState();
}

class _CommentReactionsOverlayState extends State<CommentReactionsOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ScaleTransition(
      scale: _scaleAnimation,
      alignment: Alignment.bottomRight,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF26262B) : const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.18),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.08),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: kAvailableCommentReactions.map((emoji) {
              final isSelected = widget.currentReaction == emoji;
              return _ReactionItem(
                emoji: emoji,
                isSelected: isSelected,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  widget.onReactionSelected(emoji);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _ReactionItem extends StatefulWidget {
  const _ReactionItem({
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_ReactionItem> createState() => _ReactionItemState();
}

class _ReactionItemState extends State<_ReactionItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => setState(() => _isHovered = false),
      onTapCancel: () => setState(() => _isHovered = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isHovered ? 1.35 : (widget.isSelected ? 1.15 : 1.0),
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(5),
          decoration: widget.isSelected
              ? BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                )
              : null,
          child: Text(
            widget.emoji,
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
