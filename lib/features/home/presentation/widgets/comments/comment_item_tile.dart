import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lotus_connect/app/theme/app_size.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/home/presentation/models/comment_ui_model.dart';
import 'package:lotus_connect/features/home/presentation/widgets/comments/comment_reactions_overlay.dart';
import 'package:lotus_connect/features/home/presentation/widgets/comments/comment_reactions_sheet.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

class CommentItemTile extends StatefulWidget {
  const CommentItemTile({
    required this.comment,
    required this.postAuthorId,
    required this.currentUserId,
    super.key,
    this.isReply = false,
    this.onReply,
    this.onToggleLike,
    this.onSelectReaction,
    this.onToggleReplies,
    this.onLoadMoreReplies,
    this.onEdit,
    this.onDelete,
    this.onPinToggle,
    this.onAuthorTap,
  });

  final CommentUiModel comment;
  final String postAuthorId;
  final String currentUserId;
  final bool isReply;

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
  State<CommentItemTile> createState() => _CommentItemTileState();
}

class _CommentItemTileState extends State<CommentItemTile>
    with SingleTickerProviderStateMixin {
  final GlobalKey _reactionKey = GlobalKey();
  bool _isTextExpanded = false;
  late final AnimationController _heartAnimController;
  late final Animation<double> _heartScaleAnimation;

  bool get _isAuthor => widget.comment.author.id == widget.currentUserId;
  bool get _isPostAuthor => widget.currentUserId == widget.postAuthorId;
  bool get _isCommenterPostAuthor =>
      widget.comment.author.id == widget.postAuthorId;

  @override
  void initState() {
    super.initState();
    _heartAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _heartScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1), weight: 50),
    ]).animate(_heartAnimController);
  }

  @override
  void dispose() {
    _heartAnimController.dispose();
    super.dispose();
  }

  void _triggerLike() {
    HapticFeedback.lightImpact();
    _heartAnimController.forward(from: 0);
    widget.onToggleLike?.call(widget.comment);
  }

  void _showReactionPicker() {
    CommentReactionsOverlay.show(
      context,
      targetKey: _reactionKey,
      currentReaction: widget.comment.userReaction,
      onReactionSelected: (reaction) {
        widget.onSelectReaction?.call(widget.comment, reaction);
      },
    );
  }

  void _showOptionsMenu() {
    HapticFeedback.mediumImpact();
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSize.radiusXl),
            ),
          ),
          padding: EdgeInsets.only(
            top: AppSize.md,
            bottom: MediaQuery.of(ctx).padding.bottom + AppSize.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppSize.sheetHandleWidth,
                height: AppSize.sheetHandleHeight,
                decoration: BoxDecoration(
                  color: theme.dividerColor.withValues(alpha: 0.3),
                  borderRadius: AppRadius.full,
                ),
              ),
              AppGap.vMd,

              // Pin/Unpin option (available to Post Author on top-level comments)
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

              // Edit option (available to comment author)
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

              // Reply option
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

              // Copy text option
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

              // Delete option (comment author or post author moderator)
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

  void _showMediaPreview(String url) {
    final isNetwork = url.startsWith('http://') || url.startsWith('https://');
    final cleanPath =
        url.startsWith('file://') ? url.replaceFirst('file://', '') : url;

    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: AppPadding.lg,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: AppRadius.card,
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
                        size: AppSize.iconXxl,
                      ),
                    ),
            ),
            Positioned(
              top: AppSize.sm,
              right: AppSize.sm,
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: AppSize.iconLg,
                ),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    final author = widget.comment.author;
    final size = widget.isReply ? AppSize.avatarSm : AppSize.avatarMd;

    return GestureDetector(
      onTap: () => widget.onAuthorTap?.call(author),
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: ClipOval(
          child: author.avatarUrl != null && author.avatarUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: author.avatarUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => _buildInitials(author),
                  errorWidget: (_, __, dynamic ___) => _buildInitials(author),
                )
              : _buildInitials(author),
        ),
      ),
    );
  }

  Widget _buildInitials(PostAuthor author) {
    final colors = [
      const Color(0xFF673AB7),
      const Color(0xFF3F51B5),
      const Color(0xFF009688),
      const Color(0xFFE91E63),
      const Color(0xFFFF5722),
    ];
    final color = colors[author.username.hashCode.abs() % colors.length];

    return Container(
      color: color,
      alignment: Alignment.center,
      child: Text(
        author.initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: widget.isReply ? 11 : 12.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white54 : Colors.black45;

    final comment = widget.comment;

    return Padding(
      padding: EdgeInsets.only(
        left: widget.isReply ? AppSize.massive : AppSize.lg,
        right: AppSize.lg,
        top: AppSize.xs,
        bottom: AppSize.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pinned badge banner if comment is pinned
          if (comment.isPinned && !widget.isReply)
            Container(
              margin: const EdgeInsets.only(bottom: AppSize.xs),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSize.sm,
                vertical: AppSize.xxs,
              ),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.12),
                borderRadius: AppRadius.md,
                border: AppBorder.all(
                  Colors.amber.withValues(alpha: 0.35),
                  width: AppSize.borderHairline,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    CupertinoIcons.pin_fill,
                    size: AppSize.iconXxs,
                    color: Colors.amber,
                  ),
                  AppGap.hXs,
                  Text(
                    loc?.pinnedByCreator ?? 'Pinned by creator',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ),

          // Main Comment Row: [Avatar] [Body] [Heart/Reaction]
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(theme),
              AppGap.hMd,

              // Comment Content Body
              Expanded(
                child: GestureDetector(
                  onLongPress: _showOptionsMenu,
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header line: Username + badges + timestamp
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: AppSize.xs,
                        runSpacing: AppSize.xxs,
                        children: [
                          GestureDetector(
                            onTap: () =>
                                widget.onAuthorTap?.call(comment.author),
                            child: Text(
                              comment.author.username,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: primaryTextColor,
                              ),
                            ),
                          ),

                          // Creator / Post Author badge
                          if (_isCommenterPostAuthor)
                            Container(
                              padding: AppPadding.badge,
                              decoration: BoxDecoration(
                                color:
                                    theme.primaryColor.withValues(alpha: 0.15),
                                borderRadius: AppRadius.xs,
                              ),
                              child: Text(
                                loc?.authorBadge ?? 'Author',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ),

                          // Timestamp
                          Text(
                            comment.timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color: subtextColor,
                            ),
                          ),

                          // Edited indicator
                          if (comment.isEdited)
                            Text(
                              loc != null ? '(${loc.editedTag})' : '(edited)',
                              style: TextStyle(
                                fontSize: 11,
                                color: subtextColor,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                      AppGap.vXxs,

                      // Comment Text (with hashtags & mentions highlight)
                      if (comment.content.trim().isNotEmpty) ...[
                        _buildContentText(
                          comment.content,
                          primaryTextColor,
                          theme.primaryColor,
                        ),
                      ],

                      // Attached Media / Sticker (if any)
                      if (comment.hasMedia) ...[
                        if (comment.content.trim().isNotEmpty) AppGap.vXs,
                        GestureDetector(
                          onTap: () => _showMediaPreview(comment.mediaUrl!),
                          child: ClipRRect(
                            borderRadius: AppRadius.md,
                            child: Container(
                              constraints: const BoxConstraints(
                                maxHeight: 150,
                                maxWidth: 200,
                              ),
                              color:
                                  isDark ? Colors.grey[900] : Colors.grey[100],
                              child: _buildMediaAttachment(
                                comment.mediaUrl!,
                                isDark: isDark,
                              ),
                            ),
                          ),
                        ),
                      ],
                      AppGap.vXs,

                      // Action Subrow: [Like Count] · [Reply] · [3-Dots]
                      Row(
                        children: [
                          if (comment.likeCount > 0)
                            GestureDetector(
                              onTap: () => CommentReactionsSheet.show(
                                context,
                                comment: comment,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  right: AppSize.md,
                                ),
                                child: Text(
                                  comment.likeCount == 1
                                      ? (loc?.likeCountSingular ?? '1 like')
                                      : (loc?.likeCountPlural(
                                            comment.likeCount,
                                          ) ??
                                          '${comment.likeCount} likes'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: subtextColor,
                                  ),
                                ),
                              ),
                            ),

                          // Reply button
                          GestureDetector(
                            onTap: () => widget.onReply?.call(comment),
                            child: Padding(
                              padding: const EdgeInsets.only(right: AppSize.md),
                              child: Text(
                                loc?.replyAction ?? 'Reply',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: subtextColor,
                                ),
                              ),
                            ),
                          ),

                          // Options button (3 dots)
                          GestureDetector(
                            onTap: _showOptionsMenu,
                            child: Icon(
                              Icons.more_horiz,
                              size: AppSize.iconXs,
                              color: subtextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              AppGap.hSm,

              // Like / Heart Reaction Button
              GestureDetector(
                key: _reactionKey,
                onTap: _triggerLike,
                onLongPress: _showReactionPicker,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: AppSize.xs,
                    left: AppSize.sm,
                    right: AppSize.xxs,
                  ),
                  child: ScaleTransition(
                    scale: _heartScaleAnimation,
                    child: comment.userReaction != null &&
                            comment.userReaction!.isNotEmpty &&
                            comment.userReaction != '❤️' &&
                            comment.userReaction != 'like'
                        ? Text(
                            comment.userReaction!,
                            style: const TextStyle(fontSize: 16),
                          )
                        : Icon(
                            comment.userHasLiked
                                ? CupertinoIcons.heart_fill
                                : CupertinoIcons.heart,
                            size: AppSize.iconXs,
                            color: comment.userHasLiked
                                ? const Color(0xFFED4956)
                                : subtextColor,
                          ),
                  ),
                ),
              ),
            ],
          ),

          // Threaded Replies Accordion (if root comment and has replies)
          if (!widget.isReply && comment.hasReplies) ...[
            AppGap.vXs,
            Padding(
              padding: const EdgeInsets.only(left: AppSize.massive),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Expand / Collapse Replies bar
                  GestureDetector(
                    onTap: () => widget.onToggleReplies?.call(comment),
                    child: Padding(
                      padding: AppPadding.vXs,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: AppSize.xxl,
                            height: AppSize.dividerThickness,
                            color: subtextColor.withValues(alpha: 0.5),
                          ),
                          AppGap.hSm,
                          Text(
                            comment.isRepliesExpanded
                                ? (loc?.hideReplies ?? 'Hide replies')
                                : comment.replyCount == 1
                                    ? (loc?.viewOneReply ?? 'View 1 reply')
                                    : (loc?.viewReplies(comment.replyCount) ??
                                        'View ${comment.replyCount} replies'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: subtextColor,
                            ),
                          ),
                          AppGap.hXs,
                          Icon(
                            comment.isRepliesExpanded
                                ? CupertinoIcons.chevron_up
                                : CupertinoIcons.chevron_down,
                            size: AppSize.iconXxs,
                            color: subtextColor,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Expanded Replies List
                  if (comment.isRepliesExpanded) ...[
                    if (comment.isLoadingReplies)
                      const Padding(
                        padding: AppPadding.vSm,
                        child: CupertinoActivityIndicator(radius: AppSize.sm),
                      )
                    else ...[
                      ...comment.replies.map(
                        (reply) => CommentItemTile(
                          key: ValueKey(reply.id),
                          comment: reply,
                          postAuthorId: widget.postAuthorId,
                          currentUserId: widget.currentUserId,
                          isReply: true,
                          onReply: widget.onReply,
                          onToggleLike: widget.onToggleLike,
                          onSelectReaction: widget.onSelectReaction,
                          onEdit: widget.onEdit,
                          onDelete: widget.onDelete,
                          onAuthorTap: widget.onAuthorTap,
                        ),
                      ),
                      if (comment.replies.length < comment.replyCount)
                        GestureDetector(
                          onTap: () => widget.onLoadMoreReplies?.call(comment),
                          child: Padding(
                            padding: AppPadding.vXs,
                            child: Text(
                              loc?.viewMoreReplies ?? 'Load more replies...',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Parses text to format mentions (@username) and hashtags (#tag)
  /// in accent color.
  Widget _buildContentText(
    String content,
    Color defaultColor,
    Color accentColor,
  ) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'(@\w+|#\w+)');
    var start = 0;

    for (final match in regex.allMatches(content)) {
      if (match.start > start) {
        spans.add(
          TextSpan(
            text: content.substring(start, match.start),
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

    if (start < content.length) {
      spans.add(
        TextSpan(
          text: content.substring(start),
          style: TextStyle(color: defaultColor),
        ),
      );
    }

    final isLong = content.length > 180;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          maxLines: _isTextExpanded ? null : (isLong ? 3 : null),
          overflow: _isTextExpanded
              ? TextOverflow.visible
              : (isLong ? TextOverflow.ellipsis : TextOverflow.visible),
          text: TextSpan(
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.35,
            ),
            children: spans,
          ),
        ),
        if (isLong && !_isTextExpanded)
          GestureDetector(
            onTap: () => setState(() => _isTextExpanded = true),
            child: Padding(
              padding: const EdgeInsets.only(top: AppSize.xxs),
              child: Text(
                AppLocalizations.of(context)?.seeMore ?? 'more',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMediaAttachment(String url, {required bool isDark}) {
    final isNetwork = url.startsWith('http://') || url.startsWith('https://');
    if (isNetwork) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          width: AppSize.avatarProfile,
          height: AppSize.avatarProfile,
          color: isDark ? Colors.white10 : Colors.black12,
          child: const Center(
            child: CupertinoActivityIndicator(),
          ),
        ),
        errorWidget: (_, __, dynamic ___) => const Icon(
          Icons.broken_image_outlined,
          color: Colors.grey,
        ),
      );
    }

    final cleanPath =
        url.startsWith('file://') ? url.replaceFirst('file://', '') : url;
    return Image.file(
      File(cleanPath),
      fit: BoxFit.cover,
      errorBuilder: (_, __, dynamic ___) => const Icon(
        Icons.broken_image_outlined,
        color: Colors.grey,
      ),
    );
  }
}
