import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/features/home/application/comment_provider.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';
import 'package:lotus_connect/features/home/presentation/models/comment_ui_model.dart';
import 'package:lotus_connect/features/home/presentation/widgets/comments/comment_empty_state.dart';
import 'package:lotus_connect/features/home/presentation/widgets/comments/comment_input_bar.dart';
import 'package:lotus_connect/features/home/presentation/widgets/comments/comment_item_tile.dart';
import 'package:lotus_connect/features/home/presentation/widgets/comments/comment_skeleton_list.dart';
import 'package:lotus_connect/features/home/presentation/widgets/comments/comment_tree.dart';
import 'package:lotus_connect/features/settings/application/settings_notifier.dart';

class PostCommentsSheet extends ConsumerStatefulWidget {
  const PostCommentsSheet({
    required this.post,
    super.key,
    this.initialComments,
    this.isLoading = false,
    this.onAddComment,
    this.onEditComment,
    this.onDeleteComment,
    this.onToggleReaction,
    this.onPinComment,
    this.onSortChanged,
    this.onLoadReplies,
    this.onRefresh,
  });

  final PostItem post;
  final List<CommentUiModel>? initialComments;
  final bool isLoading;

  final void Function(
    String content, {
    String? parentCommentId,
    String? mediaUrl,
  })? onAddComment;

  final void Function(
    String commentId,
    String content, {
    String? mediaUrl,
  })? onEditComment;

  final void Function(String commentId)? onDeleteComment;
  final void Function(CommentUiModel comment, String reaction)?
      onToggleReaction;
  final void Function(CommentUiModel comment, {required bool isPinned})?
      onPinComment;
  final void Function(CommentSortOrder order)? onSortChanged;
  final void Function(CommentUiModel comment)? onLoadReplies;
  final Future<void> Function()? onRefresh;

  static Future<void> show(
    BuildContext context, {
    required PostItem post,
    List<CommentUiModel>? initialComments,
    bool isLoading = false,
    void Function(
      String content, {
      String? parentCommentId,
      String? mediaUrl,
    })? onAddComment,
    void Function(
      String commentId,
      String content, {
      String? mediaUrl,
    })? onEditComment,
    void Function(String commentId)? onDeleteComment,
    void Function(CommentUiModel comment, String reaction)? onToggleReaction,
    void Function(CommentUiModel comment, {required bool isPinned})?
        onPinComment,
    void Function(CommentSortOrder order)? onSortChanged,
    void Function(CommentUiModel comment)? onLoadReplies,
    Future<void> Function()? onRefresh,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => PostCommentsSheet(
        post: post,
        initialComments: initialComments,
        isLoading: isLoading,
        onAddComment: onAddComment,
        onEditComment: onEditComment,
        onDeleteComment: onDeleteComment,
        onToggleReaction: onToggleReaction,
        onPinComment: onPinComment,
        onSortChanged: onSortChanged,
        onLoadReplies: onLoadReplies,
        onRefresh: onRefresh,
      ),
    );
  }

  @override
  ConsumerState<PostCommentsSheet> createState() => _PostCommentsSheetState();
}

class _PostCommentsSheetState extends ConsumerState<PostCommentsSheet> {
  final FocusNode _inputFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final notifier =
          ref.read(postCommentsNotifierProvider(widget.post.id).notifier);
      if (widget.initialComments != null) {
        notifier.initialize(
          postId: widget.post.id,
          initialComments: widget.initialComments,
          isLoading: widget.isLoading,
        );
      } else {
        if (widget.isLoading) {
          notifier.setLoading(isLoading: true);
        } else {
          notifier.loadComments(postId: widget.post.id, isSilent: true);
        }
      }
    });
  }

  @override
  void didUpdateWidget(PostCommentsSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    final notifier =
        ref.read(postCommentsNotifierProvider(widget.post.id).notifier);
    if (widget.initialComments != null &&
        widget.initialComments != oldWidget.initialComments) {
      notifier.initialize(
        postId: widget.post.id,
        initialComments: widget.initialComments,
        isLoading: widget.isLoading,
      );
    } else if (widget.isLoading != oldWidget.isLoading) {
      notifier.setLoading(isLoading: widget.isLoading);
    }
  }

  @override
  void dispose() {
    _inputFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleAddComment(
    String content, {
    String? parentCommentId,
    String? mediaUrl,
  }) {
    final settings = ref.read(settingsNotifierProvider).settings;
    final currentAuthor = PostAuthor(
      id: settings.userId.isNotEmpty ? settings.userId : 'current_user',
      username: settings.username.isNotEmpty ? settings.username : 'you',
      fullName: settings.fullName.isNotEmpty ? settings.fullName : 'You',
      avatarUrl: settings.avatarUrl.isNotEmpty ? settings.avatarUrl : null,
    );

    ref.read(postCommentsNotifierProvider(widget.post.id).notifier).addComment(
          content: content,
          author: currentAuthor,
          parentCommentId: parentCommentId,
          mediaUrl: mediaUrl,
          persist: widget.onAddComment == null,
        );

    widget.onAddComment?.call(
      content,
      parentCommentId: parentCommentId,
      mediaUrl: mediaUrl,
    );
  }

  void _handleToggleLike(CommentUiModel comment) {
    final willLike = !comment.userHasLiked;
    ref
        .read(postCommentsNotifierProvider(widget.post.id).notifier)
        .toggleReaction(
          comment,
          persist: widget.onToggleReaction == null,
        );

    widget.onToggleReaction?.call(
      comment,
      willLike ? '❤️' : '',
    );
  }

  void _handleSelectReaction(CommentUiModel comment, String reaction) {
    ref
        .read(postCommentsNotifierProvider(widget.post.id).notifier)
        .selectReaction(
          comment,
          reaction,
          persist: widget.onToggleReaction == null,
        );

    widget.onToggleReaction?.call(comment, reaction);
  }

  void _handlePinToggle(CommentUiModel comment) {
    final nextPinned = !comment.isPinned;
    ref.read(postCommentsNotifierProvider(widget.post.id).notifier).togglePin(
          comment,
          persist: widget.onPinComment == null,
        );

    widget.onPinComment?.call(comment, isPinned: nextPinned);
  }

  void _handleDeleteComment(CommentUiModel comment) {
    ref
        .read(postCommentsNotifierProvider(widget.post.id).notifier)
        .deleteComment(
          comment.id,
          parentCommentId: comment.parentCommentId,
          persist: widget.onDeleteComment == null,
        );

    widget.onDeleteComment?.call(comment.id);
  }

  void _handleEditComment(CommentUiModel comment) {
    final textController = TextEditingController(text: comment.content);

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit comment'),
        content: TextField(
          controller: textController,
          autofocus: true,
          maxLines: 4,
          minLines: 1,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Edit your comment...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newText = textController.text.trim();
              final hasMedia =
                  comment.mediaUrl != null && comment.mediaUrl!.isNotEmpty;
              if (newText.isNotEmpty || hasMedia) {
                ref
                    .read(postCommentsNotifierProvider(widget.post.id).notifier)
                    .editComment(
                      commentId: comment.id,
                      newContent: newText,
                      mediaUrl: comment.mediaUrl,
                      persist: widget.onEditComment == null,
                    );
                widget.onEditComment?.call(
                  comment.id,
                  newText,
                  mediaUrl: comment.mediaUrl,
                );
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _handleToggleReplies(CommentUiModel comment) {
    final notifier =
        ref.read(postCommentsNotifierProvider(widget.post.id).notifier);
    if (widget.onLoadReplies != null) {
      notifier.toggleRepliesExpanded(comment.id);
      if (!comment.isRepliesExpanded && comment.replies.isEmpty) {
        widget.onLoadReplies!(comment);
      }
    } else {
      notifier.toggleReplies(comment);
    }
  }

  void _setSortOrder(CommentSortOrder order) {
    ref
        .read(postCommentsNotifierProvider(widget.post.id).notifier)
        .changeSortOrder(
          order,
          reload: widget.onSortChanged == null,
        );
    widget.onSortChanged?.call(order);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white60 : Colors.black54;

    final settings = ref.watch(settingsNotifierProvider).settings;
    final currentUserId =
        settings.userId.isNotEmpty ? settings.userId : 'current_user';
    final postAuthorId = widget.post.author.id;

    final commentState =
        ref.watch(postCommentsNotifierProvider(widget.post.id));
    final notifier =
        ref.read(postCommentsNotifierProvider(widget.post.id).notifier);

    final comments =
        (!commentState.isInitialized && widget.initialComments != null)
            ? widget.initialComments!
            : commentState.comments;
    final isLoading = (!commentState.isInitialized && widget.isLoading) ||
        commentState.isLoading;
    final totalCommentsCount =
        (!commentState.isInitialized && widget.initialComments != null)
            ? widget.initialComments!.fold<int>(
                0,
                (acc, c) => acc + 1 + c.replies.length,
              )
            : commentState.totalCommentsCount;
    final currentSort = commentState.sort;
    final replyingTo = commentState.replyingTo;

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag Handle
              const SizedBox(height: 10),
              Container(
                width: 38,
                height: 4.5,
                decoration: BoxDecoration(
                  color: theme.dividerColor.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 10),

              // Sheet Header: Title, Count, Sort Selector, Close
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Title and Count
                    Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$totalCommentsCount',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                    const Spacer(),

                    // Sort Order Popup Menu
                    PopupMenuButton<CommentSortOrder>(
                      initialValue: currentSort,
                      onSelected: _setSortOrder,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              currentSort.label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: subtextColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              CupertinoIcons.chevron_down,
                              size: 13,
                              color: subtextColor,
                            ),
                          ],
                        ),
                      ),
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: CommentSortOrder.popular,
                          child: Row(
                            children: [
                              Icon(Icons.whatshot, size: 18),
                              SizedBox(width: 10),
                              Text('Top comments'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: CommentSortOrder.newest,
                          child: Row(
                            children: [
                              Icon(Icons.access_time_rounded, size: 18),
                              SizedBox(width: 10),
                              Text('Newest first'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: CommentSortOrder.oldest,
                          child: Row(
                            children: [
                              Icon(Icons.history_rounded, size: 18),
                              SizedBox(width: 10),
                              Text('Oldest first'),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Close Button
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      splashRadius: 18,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              Divider(
                height: 1,
                thickness: 0.5,
                color: theme.dividerColor.withValues(alpha: 0.15),
              ),

              // Comments List View / Skeleton / Empty
              Expanded(
                child: isLoading
                  ? const CommentSkeletonList()
                  : comments.isEmpty
                      ? CommentEmptyState(
                          onStartCommentTap: _inputFocusNode.requestFocus,
                        )
                      : RefreshIndicator(
                          onRefresh:
                              widget.onRefresh ?? notifier.refreshComments,
                          child: ListView.builder(
                            controller: scrollController,
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: const EdgeInsets.only(
                              top: 8,
                              bottom: 20,
                            ),
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final comment = comments[index];
                              return CommentTree(
                                root: comment,
                                currentUserId: currentUserId,
                              );
                              return CommentItemTile(
                                key: ValueKey(comment.id),
                                comment: comment,
                                postAuthorId: postAuthorId,
                                currentUserId: currentUserId,
                                onReply: (target) {
                                  notifier.setReplyingTo(target);
                                  _inputFocusNode.requestFocus();
                                },
                                onToggleLike: _handleToggleLike,
                                onSelectReaction: _handleSelectReaction,
                                onToggleReplies: _handleToggleReplies,
                                onPinToggle: _handlePinToggle,
                                onEdit: _handleEditComment,
                                onDelete: _handleDeleteComment,
                              );
                            },
                          ),
                        ),
              ),

              // Fixed Input Bar anchored at bottom
              CommentInputBar(
                focusNode: _inputFocusNode,
                replyingTo: replyingTo,
                onCancelReply: () => notifier.setReplyingTo(null),
                currentUserAvatarUrl: settings.avatarUrl,
                currentUsername:
                    settings.username.isNotEmpty ? settings.username : 'you',
                onSubmit: _handleAddComment,
              ),
            ],
          ),
        );
      },
    );
  }
}
