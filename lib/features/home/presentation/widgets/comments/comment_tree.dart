import 'dart:io';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/home/presentation/models/comment_ui_model.dart';
import 'package:lotus_connect/features/home/presentation/widgets/comments/comment_reactions_overlay.dart';
import 'package:lotus_connect/features/home/presentation/widgets/comments/comment_reactions_sheet.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

class CommentTree extends StatelessWidget {
  const CommentTree({
    required this.root,
    required this.currentUserId,
    this.postAuthorId = '',
    this.currentUserName = '',
    this.onReply,
    this.onToggleLike,
    this.onSelectReaction,
    this.onToggleReplies,
    this.onLoadMoreReplies,
    this.onEdit,
    this.onDelete,
    this.onPinToggle,
    this.onAuthorTap,
    super.key,
  });

  final CommentUiModel root;
  final String currentUserId;
  final String postAuthorId;
  final String currentUserName;

  final ValueChanged<CommentUiModel>? onReply;
  final ValueChanged<CommentUiModel>? onToggleLike;
  final void Function(CommentUiModel comment, String reaction)?
      onSelectReaction;
  final ValueChanged<CommentUiModel>? onToggleReplies;
  final ValueChanged<CommentUiModel>? onLoadMoreReplies;
  final ValueChanged<CommentUiModel>? onEdit;
  final ValueChanged<CommentUiModel>? onDelete;
  final ValueChanged<CommentUiModel>? onPinToggle;
  final ValueChanged<PostAuthor>? onAuthorTap;

  @override
  Widget build(BuildContext context) {
    return _CommentNode(
      key: ValueKey(root.id),
      comment: root,
      depth: 0,
      currentUserId: currentUserId,
      postAuthorId: postAuthorId,
      onReply: onReply,
      onToggleLike: onToggleLike,
      onSelectReaction: onSelectReaction,
      onToggleReplies: onToggleReplies,
      onLoadMoreReplies: onLoadMoreReplies,
      onEdit: onEdit,
      onDelete: onDelete,
      onPinToggle: onPinToggle,
      onAuthorTap: onAuthorTap,
    );
  }
}

class _CommentNode extends StatefulWidget {
  const _CommentNode({
    required this.comment,
    required this.depth,
    required this.currentUserId,
    required this.postAuthorId,
    this.avatarKey,
    this.onReply,
    this.onToggleLike,
    this.onSelectReaction,
    this.onToggleReplies,
    this.onLoadMoreReplies,
    this.onEdit,
    this.onDelete,
    this.onPinToggle,
    this.onAuthorTap,
    super.key,
  });

  final CommentUiModel comment;
  final int depth;
  final String currentUserId;
  final String postAuthorId;
  final GlobalKey? avatarKey;

  final ValueChanged<CommentUiModel>? onReply;
  final ValueChanged<CommentUiModel>? onToggleLike;
  final void Function(CommentUiModel comment, String reaction)?
      onSelectReaction;
  final ValueChanged<CommentUiModel>? onToggleReplies;
  final ValueChanged<CommentUiModel>? onLoadMoreReplies;
  final ValueChanged<CommentUiModel>? onEdit;
  final ValueChanged<CommentUiModel>? onDelete;
  final ValueChanged<CommentUiModel>? onPinToggle;
  final ValueChanged<PostAuthor>? onAuthorTap;

  @override
  State<_CommentNode> createState() => _CommentNodeState();
}

class _CommentNodeState extends State<_CommentNode> {
  late bool _expanded;
  final GlobalKey _nodeKey = GlobalKey();
  late final GlobalKey _avatarKey;
  final Map<String, GlobalKey> _replyAvatarKeys = {};
  final GlobalKey _viewRepliesKey = GlobalKey();

  _ConnectorGeometry? _connectorGeometry;
  bool _measurementScheduled = false;

  bool get _isAuthor => widget.comment.author.id == widget.currentUserId;
  bool get _isPostAuthor => widget.currentUserId == widget.postAuthorId;

  @override
  void initState() {
    super.initState();
    _avatarKey = widget.avatarKey ?? GlobalKey();
    _expanded =
        widget.comment.isRepliesExpanded || widget.comment.replies.isNotEmpty;
  }

  @override
  void didUpdateWidget(covariant _CommentNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.comment.isRepliesExpanded !=
        oldWidget.comment.isRepliesExpanded) {
      _expanded = widget.comment.isRepliesExpanded;
    }
    if (widget.comment.replies.length != oldWidget.comment.replies.length ||
        widget.comment.replyCount != oldWidget.comment.replyCount) {
      _scheduleConnectorMeasurement();
    }
  }

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
    });
    widget.onToggleReplies?.call(widget.comment);
    _scheduleConnectorMeasurement();
  }

  void _scheduleConnectorMeasurement() {
    if (!widget.comment.hasReplies || _measurementScheduled) {
      return;
    }

    _measurementScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measurementScheduled = false;
      if (!mounted) return;
      _measureConnector();
    });
  }

  void _measureConnector() {
    if (!mounted) return;

    final nodeBox = _nodeKey.currentContext?.findRenderObject() as RenderBox?;
    final parentAvatarBox =
        _avatarKey.currentContext?.findRenderObject() as RenderBox?;

    if (nodeBox == null ||
        !nodeBox.attached ||
        parentAvatarBox == null ||
        !parentAvatarBox.attached) {
      return;
    }

    final parentTopLeft = nodeBox.globalToLocal(
      parentAvatarBox.localToGlobal(Offset.zero),
    );
    final parentBottom = Offset(
      parentTopLeft.dx + parentAvatarBox.size.width / 2,
      parentTopLeft.dy + parentAvatarBox.size.height,
    );

    final targets = <Offset>[];

    if (_expanded && widget.comment.replies.isNotEmpty) {
      for (final reply in widget.comment.replies) {
        final avatarBox = _replyAvatarKeys[reply.id]
            ?.currentContext
            ?.findRenderObject() as RenderBox?;
        if (avatarBox == null || !avatarBox.attached) {
          _scheduleConnectorMeasurement();
          return;
        }

        final replyTopLeft = nodeBox.globalToLocal(
          avatarBox.localToGlobal(Offset.zero),
        );
        final targetX = replyTopLeft.dx + avatarBox.size.width / 2;
        if (targetX > parentBottom.dx) {
          targets.add(
            Offset(
              targetX,
              replyTopLeft.dy + avatarBox.size.height / 2,
            ),
          );
        }
      }
    } else if (widget.comment.hasReplies) {
      final viewRepliesBox =
          _viewRepliesKey.currentContext?.findRenderObject() as RenderBox?;
      if (viewRepliesBox != null && viewRepliesBox.attached) {
        final boxTopLeft = nodeBox.globalToLocal(
          viewRepliesBox.localToGlobal(Offset.zero),
        );
        final targetX = boxTopLeft.dx - 6.0;
        if (targetX > parentBottom.dx) {
          targets.add(
            Offset(
              targetX,
              boxTopLeft.dy + viewRepliesBox.size.height / 2,
            ),
          );
        }
      }
    }

    if (targets.isEmpty) {
      if (_connectorGeometry != null) {
        setState(() => _connectorGeometry = null);
      }
      return;
    }

    final geometry = _ConnectorGeometry(
      parentBottom: parentBottom,
      targets: targets,
    );

    if (geometry == _connectorGeometry) return;
    setState(() => _connectorGeometry = geometry);
  }

  void _showOptionsMenu() {
    HapticFeedback.mediumImpact();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final loc = AppLocalizations.of(context);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            top: 12,
            bottom: MediaQuery.of(ctx).padding.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              if (_isPostAuthor && widget.comment.isRoot)
                ListTile(
                  leading: Icon(
                    widget.comment.isPinned
                        ? CupertinoIcons.pin_slash
                        : CupertinoIcons.pin,
                    color: primaryTextColor,
                  ),
                  title: Text(
                    widget.comment.isPinned
                        ? (loc?.unpinComment ?? 'Unpin comment')
                        : (loc?.pinComment ?? 'Pin comment'),
                    style: TextStyle(color: primaryTextColor),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    widget.onPinToggle?.call(widget.comment);
                  },
                ),
              if (_isAuthor)
                ListTile(
                  leading: Icon(Icons.edit_outlined, color: primaryTextColor),
                  title: Text(
                    loc?.editComment ?? 'Edit comment',
                    style: TextStyle(color: primaryTextColor),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    widget.onEdit?.call(widget.comment);
                  },
                ),
              ListTile(
                leading: Icon(CupertinoIcons.reply, color: primaryTextColor),
                title: Text(
                  loc?.replyToUserAction(widget.comment.author.username) ??
                      'Reply to @${widget.comment.author.username}',
                  style: TextStyle(color: primaryTextColor),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  widget.onReply?.call(widget.comment);
                },
              ),
              ListTile(
                leading: Icon(Icons.copy_rounded, color: primaryTextColor),
                title: Text(
                  loc?.copyText ?? 'Copy text',
                  style: TextStyle(color: primaryTextColor),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  Clipboard.setData(
                    ClipboardData(text: widget.comment.content),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        loc?.commentCopied ?? 'Comment copied to clipboard',
                      ),
                    ),
                  );
                },
              ),
              if (_isAuthor || _isPostAuthor)
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                  ),
                  title: Text(
                    loc?.deleteComment ?? 'Delete comment',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _confirmDelete();
                  },
                )
              else
                ListTile(
                  leading: const Icon(
                    Icons.report_problem_outlined,
                    color: Colors.redAccent,
                  ),
                  title: Text(
                    loc?.reportComment ?? 'Report comment',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          loc?.reportSubmitted ?? 'Report submitted',
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete() async {
    final loc = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc?.deleteCommentConfirmTitle ?? 'Delete comment?'),
        content: Text(
          loc?.deleteCommentConfirmMessage ??
              'Are you sure you want to delete this comment? '
                  'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(loc?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: Text(loc?.deleteComment ?? 'Delete'),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      widget.onDelete?.call(widget.comment);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final replies = widget.comment.replies;
    final hasReplies = widget.comment.hasReplies;
    final avatarRadius = widget.depth == 0 ? 18.0 : 14.0;
    final isDepthCapped = widget.depth >= 2;
    final childIndent =
        isDepthCapped ? 16.0 : (widget.depth == 0 ? 38.0 : 28.0);

    final lineColor = isDark
        ? Colors.white.withValues(alpha: 0.16)
        : Colors.black.withValues(alpha: 0.14);

    _scheduleConnectorMeasurement();

    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (_) {
        _scheduleConnectorMeasurement();
        return false;
      },
      child: SizeChangedLayoutNotifier(
        child: Stack(
          key: _nodeKey,
          children: [
            if (_connectorGeometry != null && hasReplies)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _CommentConnectorPainter(
                      geometry: _connectorGeometry!,
                      lineColor: lineColor,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.only(
                left: widget.depth == 0 ? 16.0 : 0.0,
                right: widget.depth == 0 ? 16.0 : 0.0,
                top: 4,
                bottom: 4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CommentAvatar(
                        key: _avatarKey,
                        comment: widget.comment,
                        radius: avatarRadius,
                        onTap: () =>
                            widget.onAuthorTap?.call(widget.comment.author),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _CommentBubble(
                              comment: widget.comment,
                              postAuthorId: widget.postAuthorId,
                              currentUserId: widget.currentUserId,
                              onAuthorTap: widget.onAuthorTap,
                              onOptionsTap: _showOptionsMenu,
                            ),
                            const SizedBox(height: 3),
                            _CommentMeta(
                              comment: widget.comment,
                              onReply: () =>
                                  widget.onReply?.call(widget.comment),
                              onToggleLike: () =>
                                  widget.onToggleLike?.call(widget.comment),
                              onSelectReaction: (rx) => widget.onSelectReaction
                                  ?.call(widget.comment, rx),
                              onOptions: _showOptionsMenu,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Collapsed replies button
                  if (hasReplies && !_expanded)
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: avatarRadius * 2 + 12.0,
                        top: 4,
                        bottom: 4,
                      ),
                      child: _ViewRepliesButton(
                        key: _viewRepliesKey,
                        comment: widget.comment,
                        onTap: _toggleExpanded,
                      ),
                    ),

                  // Expanded nested replies tree
                  if (hasReplies && _expanded)
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: childIndent,
                        top: 6,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.comment.isLoadingReplies)
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 16,
                              ),
                              child: CupertinoActivityIndicator(radius: 8),
                            )
                          else ...[
                            for (final reply in replies)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: _CommentNode(
                                  key: ValueKey(reply.id),
                                  comment: reply,
                                  depth: widget.depth + 1,
                                  currentUserId: widget.currentUserId,
                                  postAuthorId: widget.postAuthorId,
                                  avatarKey: _replyAvatarKeys.putIfAbsent(
                                    reply.id,
                                    GlobalKey.new,
                                  ),
                                  onReply: widget.onReply,
                                  onToggleLike: widget.onToggleLike,
                                  onSelectReaction: widget.onSelectReaction,
                                  onToggleReplies: widget.onToggleReplies,
                                  onLoadMoreReplies: widget.onLoadMoreReplies,
                                  onEdit: widget.onEdit,
                                  onDelete: widget.onDelete,
                                  onPinToggle: widget.onPinToggle,
                                  onAuthorTap: widget.onAuthorTap,
                                ),
                              ),
                            if (replies.length < widget.comment.replyCount)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  top: 2,
                                  bottom: 4,
                                ),
                                child: GestureDetector(
                                  onTap: () => widget.onLoadMoreReplies
                                      ?.call(widget.comment),
                                  child: Text(
                                    loc?.viewMoreReplies ??
                                        'View more replies...',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 16,
                                top: 2,
                                bottom: 4,
                              ),
                              child: GestureDetector(
                                onTap: _toggleExpanded,
                                child: Text(
                                  loc?.hideReplies ?? 'Hide replies',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentConnectorPainter extends CustomPainter {
  const _CommentConnectorPainter({
    required this.geometry,
    required this.lineColor,
  });

  final _ConnectorGeometry geometry;
  final Color lineColor;
  static const double _strokeWidth = 1.4;

  @override
  void paint(Canvas canvas, Size size) {
    if (geometry.targets.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final trunkX = geometry.parentBottom.dx;
    final lastTarget = geometry.targets.last;
    const curveRadius = 14.0;

    final lastAvailableWidth = lastTarget.dx - trunkX;
    final lastR = lastAvailableWidth > 0
        ? math.min(curveRadius, lastAvailableWidth)
        : curveRadius;
    final lastCurveStartY = lastTarget.dy - lastR;
    if (lastCurveStartY > geometry.parentBottom.dy) {
      canvas.drawLine(
        geometry.parentBottom,
        Offset(trunkX, lastCurveStartY),
        paint,
      );
    }

    for (final target in geometry.targets) {
      final targetX = target.dx;
      final targetY = target.dy;

      if (targetX <= trunkX) continue;

      final availableWidth = targetX - trunkX;
      final r = math.min(curveRadius, availableWidth);
      final curveStartY = targetY - r;

      final path = Path();
      if (curveStartY >= geometry.parentBottom.dy) {
        path
          ..moveTo(trunkX, curveStartY)
          ..quadraticBezierTo(
            trunkX,
            targetY,
            trunkX + r,
            targetY,
          );
      } else {
        path
          ..moveTo(trunkX, geometry.parentBottom.dy)
          ..quadraticBezierTo(
            trunkX,
            targetY,
            trunkX + r,
            targetY,
          );
      }

      if (targetX > trunkX + r) {
        path.lineTo(targetX, targetY);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CommentConnectorPainter oldDelegate) {
    return oldDelegate.geometry != geometry ||
        oldDelegate.lineColor != lineColor;
  }
}

@immutable
class _ConnectorGeometry {
  const _ConnectorGeometry({
    required this.parentBottom,
    required this.targets,
  });

  final Offset parentBottom;
  final List<Offset> targets;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _ConnectorGeometry &&
        other.parentBottom == parentBottom &&
        _offsetListEqual(other.targets, targets);
  }

  @override
  int get hashCode => Object.hash(parentBottom, Object.hashAll(targets));

  static bool _offsetListEqual(List<Offset> a, List<Offset> b) {
    if (a.length != b.length) return false;
    for (var index = 0; index < a.length; index++) {
      if ((a[index].dx - b[index].dx).abs() > 0.5 ||
          (a[index].dy - b[index].dy).abs() > 0.5) {
        return false;
      }
    }
    return true;
  }
}

class _CommentBubble extends StatefulWidget {
  const _CommentBubble({
    required this.comment,
    required this.postAuthorId,
    required this.currentUserId,
    this.onAuthorTap,
    this.onOptionsTap,
  });

  final CommentUiModel comment;
  final String postAuthorId;
  final String currentUserId;
  final ValueChanged<PostAuthor>? onAuthorTap;
  final VoidCallback? onOptionsTap;

  @override
  State<_CommentBubble> createState() => _CommentBubbleState();
}

class _CommentBubbleState extends State<_CommentBubble> {
  bool _isTextExpanded = false;

  bool get _isCommenterPostAuthor =>
      widget.comment.author.id == widget.postAuthorId;

  void _showMediaPreview(String url) {
    final isNetwork = url.startsWith('http://') || url.startsWith('https://');
    final cleanPath =
        url.startsWith('file://') ? url.replaceFirst('file://', '') : url;

    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: isNetwork
                  ? CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.contain,
                    )
                  : Image.file(
                      File(cleanPath),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, dynamic ___) => const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white70,
                        size: 48,
                      ),
                    ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentText(
    String content,
    Color defaultColor,
    Color accentColor,
  ) {
    const maxChars = 220;
    final isLong = content.length > maxChars;
    final displayContent = (isLong && !_isTextExpanded)
        ? '${content.substring(0, maxChars)}...'
        : content;

    final spans = <TextSpan>[];
    final regex = RegExp(r'(@\w+|#\w+)');
    var start = 0;

    for (final match in regex.allMatches(displayContent)) {
      if (match.start > start) {
        spans.add(
          TextSpan(
            text: displayContent.substring(start, match.start),
            style: TextStyle(color: defaultColor),
          ),
        );
      }
      spans.add(
        TextSpan(
          text: match.group(0),
          style: TextStyle(
            color: accentColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
      start = match.end;
    }

    if (start < displayContent.length) {
      spans.add(
        TextSpan(
          text: displayContent.substring(start),
          style: TextStyle(color: defaultColor),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(children: spans),
          style: TextStyle(
            fontSize: 13.5,
            height: 1.25,
            color: defaultColor,
          ),
        ),
        if (isLong)
          GestureDetector(
            onTap: () => setState(() => _isTextExpanded = !_isTextExpanded),
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                _isTextExpanded
                    ? (AppLocalizations.of(context)?.seeLess ?? 'See less')
                    : (AppLocalizations.of(context)?.seeMore ?? 'See more'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bubbleColor = isDark
        ? const Color(0xFF3A3B3C)
        : theme.colorScheme.surfaceContainerHighest;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final hasReactions = widget.comment.likeCount > 0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onLongPress: widget.onOptionsTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            margin: EdgeInsets.only(bottom: hasReactions ? 6.0 : 0.0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 2,
                  children: [
                    GestureDetector(
                      onTap: () =>
                          widget.onAuthorTap?.call(widget.comment.author),
                      child: Text(
                        (widget.comment.author.fullName?.isNotEmpty ?? false)
                            ? widget.comment.author.fullName!
                            : widget.comment.author.username,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                          color: primaryTextColor,
                        ),
                      ),
                    ),
                    if (_isCommenterPostAuthor)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          loc?.authorBadge ?? 'Author',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    if (widget.comment.isPinned)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              CupertinoIcons.pin_fill,
                              size: 10,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              loc?.pinnedBadge ?? 'Pinned',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                if (widget.comment.content.trim().isNotEmpty) ...[
                  const SizedBox(height: 3),
                  _buildContentText(
                    widget.comment.content,
                    primaryTextColor,
                    theme.colorScheme.primary,
                  ),
                ],
                if (widget.comment.hasMedia) ...[
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => _showMediaPreview(widget.comment.mediaUrl!),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        constraints: const BoxConstraints(
                          maxHeight: 180,
                          maxWidth: 220,
                        ),
                        color: isDark ? Colors.grey[900] : Colors.grey[100],
                        child: CachedNetworkImage(
                          imageUrl: widget.comment.mediaUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            height: 120,
                            color: isDark ? Colors.grey[850] : Colors.grey[200],
                            child: const Center(
                              child: CupertinoActivityIndicator(),
                            ),
                          ),
                          errorWidget: (_, __, dynamic ___) => const Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Facebook reaction pill anchored at bottom right of bubble
        if (hasReactions)
          Positioned(
            right: 8,
            bottom: -6,
            child: GestureDetector(
              onTap: () => CommentReactionsSheet.show(
                context,
                comment: widget.comment,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF242526) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.black12,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      (widget.comment.userReaction?.isNotEmpty ?? false)
                          ? widget.comment.userReaction!
                          : '❤️',
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (widget.comment.likeCount > 1) ...[
                      const SizedBox(width: 3),
                      Text(
                        '${widget.comment.likeCount}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CommentMeta extends StatelessWidget {
  _CommentMeta({
    required this.comment,
    required this.onReply,
    required this.onToggleLike,
    required this.onSelectReaction,
    required this.onOptions,
  });

  final CommentUiModel comment;
  final VoidCallback? onReply;
  final VoidCallback? onToggleLike;
  final ValueChanged<String>? onSelectReaction;
  final VoidCallback? onOptions;

  final GlobalKey _likeKey = GlobalKey();

  void _showReactionPicker(BuildContext context) {
    CommentReactionsOverlay.show(
      context,
      targetKey: _likeKey,
      currentReaction: comment.userReaction,
      onReactionSelected: (reaction) {
        onSelectReaction?.call(reaction);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final subtextColor = theme.colorScheme.onSurfaceVariant;
    final metaStyle = theme.textTheme.labelSmall?.copyWith(
      color: subtextColor,
      fontWeight: FontWeight.w600,
      fontSize: 12,
    );

    // Map active reaction to Facebook text & color
    var likeText = loc?.likeAction ?? 'Like';
    Color? likeColor = subtextColor;

    if (comment.userReaction != null && comment.userReaction!.isNotEmpty) {
      switch (comment.userReaction) {
        case '❤️':
          likeText = loc?.loveAction ?? 'Love';
          likeColor = Colors.redAccent;
        case '👍':
          likeText = loc?.likeAction ?? 'Like';
          likeColor = Colors.blue;
        case '😂':
          likeText = loc?.hahaAction ?? 'Haha';
          likeColor = Colors.amber[800];
        case '🔥':
          likeText = loc?.fireAction ?? 'Fire';
          likeColor = Colors.deepOrange;
        case '😮':
          likeText = loc?.wowAction ?? 'Wow';
          likeColor = Colors.amber[800];
        case '😢':
          likeText = loc?.sadAction ?? 'Sad';
          likeColor = Colors.amber[800];
        default:
          likeText = loc?.likeAction ?? 'Like';
          likeColor = Colors.blue;
      }
    } else if (comment.userHasLiked) {
      likeText = loc?.likeAction ?? 'Like';
      likeColor = Colors.blue;
    }

    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 8),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        children: [
          Text(comment.timeAgo, style: metaStyle),
          GestureDetector(
            key: _likeKey,
            onTap: onToggleLike,
            onLongPress: () => _showReactionPicker(context),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                likeText,
                style: metaStyle?.copyWith(
                  color: likeColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onReply,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                loc?.replyAction ?? 'Reply',
                style: metaStyle?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (comment.isEdited)
            Text(
              loc != null ? '(${loc.editedTag})' : '(edited)',
              style: metaStyle?.copyWith(
                fontStyle: FontStyle.italic,
                fontSize: 11,
              ),
            ),
          GestureDetector(
            onTap: onOptions,
            behavior: HitTestBehavior.opaque,
            child: Icon(
              Icons.more_horiz,
              size: 16,
              color: subtextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewRepliesButton extends StatelessWidget {
  const _ViewRepliesButton({
    required this.comment,
    required this.onTap,
    super.key,
  });

  final CommentUiModel comment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final count =
        comment.replyCount > 0 ? comment.replyCount : comment.replies.length;
    final text = count == 1
        ? (loc?.viewOneReply ?? 'View 1 reply')
        : (loc?.viewReplies(count) ?? 'View $count replies');

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _CommentAvatar extends StatelessWidget {
  const _CommentAvatar({
    required this.comment,
    required this.radius,
    this.onTap,
    super.key,
  });

  final CommentUiModel comment;
  final double radius;
  final VoidCallback? onTap;

  Widget _buildFallback(BuildContext context) {
    final colors = [
      const Color(0xFF673AB7),
      const Color(0xFF3F51B5),
      const Color(0xFF009688),
      const Color(0xFFE91E63),
      const Color(0xFFFF5722),
    ];
    final color =
        colors[comment.author.username.hashCode.abs() % colors.length];

    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: Text(
        comment.author.fullName?.characters.firstOrNull?.toUpperCase() ??
            comment.author.username.characters.firstOrNull?.toUpperCase() ??
            '?',
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.85,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = comment.author.avatarUrl;

    final avatarWidget = (avatarUrl == null || avatarUrl.isEmpty)
        ? _buildFallback(context)
        : CachedNetworkImage(
            imageUrl: avatarUrl,
            imageBuilder: (_, imageProvider) => CircleAvatar(
              radius: radius,
              backgroundImage: imageProvider,
            ),
            placeholder: (ctx, __) => _buildFallback(ctx),
            errorWidget: (ctx, __, dynamic ___) => _buildFallback(ctx),
          );

    return GestureDetector(
      onTap: onTap,
      child: avatarWidget,
    );
  }
}
