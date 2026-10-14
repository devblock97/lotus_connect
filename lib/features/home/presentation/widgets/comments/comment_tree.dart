import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lotus_connect/features/home/presentation/home_presentation.dart';

class CommentTree extends StatelessWidget {
  const CommentTree({
    required this.root,
    required this.currentUserId,
    this.onReply,
    this.onEdit,
    this.onDelete,
    this.currentUserName = '',
    super.key,
  });

  final CommentUiModel root;
  final ValueChanged<CommentUiModel>? onReply;
  final ValueChanged<CommentUiModel>? onEdit;
  final ValueChanged<CommentUiModel>? onDelete;
  final String currentUserName;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    return _CommentNode(
      comment: root,
      depth: 0,
      onDelete: onDelete,
      onEdit: onEdit,
      onReply: onReply,
      currentUserId: currentUserId,
    );
  }
}

class _CommentNode extends StatefulWidget {
  const _CommentNode({
    required this.comment,
    required this.depth,
    required this.currentUserId,
    this.onReply,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final CommentUiModel comment;
  final int depth;
  final ValueChanged<CommentUiModel>? onReply;
  final ValueChanged<CommentUiModel>? onEdit;
  final ValueChanged<CommentUiModel>? onDelete;
  final String currentUserId;

  @override
  State<_CommentNode> createState() => _CommentNodeState();
}

class _CommentNodeState extends State<_CommentNode> {
  final bool _expanded = true;
  final GlobalKey _nodeKey = GlobalKey();
  late final GlobalKey _avatarKey;
  final Map<int, GlobalKey> _replayAvatarKeys = {};
  _ConnectorGeometry? _connectorGeometry;
  bool _measurementScheduled = false;


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final replies = widget.comment.replies;
    final hasReplies = replies.isNotEmpty;
    final avatarRadius = widget.depth == 0 ? 18.0 : 14.0;
    final isDepthCapped = widget.depth >= 2;
    final childIndent = isDepthCapped ? 0.0 : 24.0;

    final lineColor = theme.colorScheme.outlineVariant.withValues(alpha: 0.7);
    _scheduleConnectorMeasurement();

    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (_) {
        _scheduleConnectorMeasurement();
        return false;
      },
      child: SizeChangedLayoutNotifier(
        child: Stack(
          children: [
            if (_connectorGeometry != null && hasReplies && _expanded)
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
            Column(
              children: [
                Row(
                  children: [
                    _CommentAvatar(comment: widget.comment, radius: avatarRadius),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _CommentBubble(comment: widget.comment),
                          _CommentMeta(
                            comment: widget.comment,
                            hasReplies: widget.comment.hasReplies,
                            expanded: true,
                            canManage: true,
                            onReply: () {

                            },
                            onEdit: () {

                            },
                            onDelete: () {

                            },
                            onToggle: () {

                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (hasReplies && _expanded)
                  Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: avatarRadius + childIndent,
                    ),
                    child: Column(
                      children: [
                        for (final reply in replies)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _CommentNode(
                              comment: reply,
                              depth: widget.depth + 1,
                              onReply: widget.onReply,
                              onEdit: widget.onEdit,
                              onDelete: widget.onDelete,
                              currentUserId: widget.currentUserId,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _scheduleConnectorMeasurement() {
    if (!_expanded || widget.comment.replies.isEmpty || _measurementScheduled) {
      return;
    }

    _measurementScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measurementScheduled = false;
      if (!mounted || !_expanded) return;

      _measureConnector();
    });
  }

  void _measureConnector() {
    final replies = widget.comment.replies;
    final nodeBox = _nodeKey.currentContext?.findRenderObject() as RenderBox?;
    final parentAvatarBox = _avatarKey.currentContext?.findRenderObject() as RenderBox?;

    if (nodeBox == null || parentAvatarBox == null) return;

    final parentTopLeft = nodeBox.globalToLocal(
      parentAvatarBox.localToGlobal(Offset.zero),
    );
    final parentBottom = Offset(
      parentTopLeft.dx + parentAvatarBox.size.width / 2,
      parentTopLeft.dy + parentAvatarBox.size.height,
    );

    final replyCenters = <Offset>[];

    for (final reply in replies) {
      final avatarBox =
        _replayAvatarKeys[reply.id]?.currentContext?.findRenderObject()
          as RenderBox?;
      if (avatarBox == null) return;
      replyCenters.add(
        nodeBox.globalToLocal(
          avatarBox.localToGlobal(
            Offset(avatarBox.size.width / 2, avatarBox.size.height / 2),
          ),
        ),
      );
    }

    final geometry = _ConnectorGeometry(
      parentBottom: parentBottom,
      replyCenters: replyCenters,
    );

    if (geometry == _connectorGeometry) return;
    setState(() =>_connectorGeometry = geometry);
  }
}

class _CommentConnectorPainter extends CustomPainter {

  const _CommentConnectorPainter({
    required this.geometry,
    required this.lineColor,
  });

  final _ConnectorGeometry geometry;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

    final trunkX = geometry.parentBottom.dx;
    final lastReply = geometry.replyCenters.last;
    const curveRadius = 10.0;

    canvas.drawLine(
      geometry.parentBottom,
      Offset(trunkX, lastReply.dy - curveRadius),
      paint,
    );

    for (final replyCenter in geometry.replyCenters) {
      final direction = replyCenter.dx >= trunkX ? 1.0 : -1.0;
      final path = Path()
        ..moveTo(trunkX, replyCenter.dy - curveRadius)
        ..quadraticBezierTo(
          trunkX,
          replyCenter.dy,
          trunkX + (curveRadius * direction),
          replyCenter.dy,
        )
        ..lineTo(replyCenter.dx, replyCenter.dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CommentConnectorPainter oldDelegate) {
    return oldDelegate.geometry != geometry ||
        oldDelegate.lineColor != lineColor;
  }

}

class _ConnectorGeometry {
  const _ConnectorGeometry({
    required this.parentBottom,
    required this.replyCenters,
  });

  final Offset parentBottom;
  final List<Offset> replyCenters;

  @override
  bool operator ==(Object other) {
    return other is _ConnectorGeometry &&
      other.parentBottom == parentBottom &&
      _offsetListEqual(other.replyCenters, replyCenters);
  }

  @override
  int get hashCode => Object.hash(parentBottom, Object.hashAll(replyCenters));

  static bool _offsetListEqual(List<Offset> a, List<Offset> b) {
    if (a.length != b.length) return false;
    for (var index = 0; index < a.length; index++) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}

class _CommentMeta extends StatelessWidget {
  const _CommentMeta({
    required this.comment,
    required this.hasReplies,
    required this.expanded,
    required this.canManage,
    required this.onReply,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
    super.key,
  });

  final CommentUiModel comment;
  final bool hasReplies;
  final bool expanded;
  final bool canManage;
  final VoidCallback? onReply;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metaStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    );

    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 12),
      child: Wrap(
        children: [
          InkWell(
            onTap: onReply,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text('Reply', style: metaStyle),
            ),
          )
        ],
      ),
    );
  }
}


class _CommentBubble extends StatelessWidget {
  const _CommentBubble({
    required this.comment,
    super.key,
  });

  final CommentUiModel comment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    comment.author.fullName ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            if (comment.content.isNotEmpty) ... [
              const SizedBox(height: 2),
              Text(
                comment.content,
                softWrap: true,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  height: 1.25,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


class _CommentAvatar extends StatelessWidget {
  const _CommentAvatar({
    required this.comment, required this.radius, super.key,
  });

  final CommentUiModel comment;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final fallback = CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Text(
        comment.author.fullName?.characters.firstOrNull?.toUpperCase() ?? '?',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontSize: radius * 0.8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    if (comment.author.avatarUrl == null) return fallback;

    return CachedNetworkImage(
      imageUrl: comment.author.avatarUrl ?? '',
      imageBuilder: (_, imageProvider) =>
          CircleAvatar(radius: radius, backgroundImage: imageProvider,),
      placeholder: (_, __) => fallback,
      errorWidget: (_, __, ___) => fallback,
    );
  }
}

