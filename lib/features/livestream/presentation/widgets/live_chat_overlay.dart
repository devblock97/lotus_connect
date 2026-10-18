import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_comment.dart';

/// Live chat overlay streaming comments on top of the live video
/// (TikTok / YouTube Live / Facebook Live style).
class LiveChatOverlay extends StatefulWidget {
  const LiveChatOverlay({
    required this.comments,
    required this.hostId,
    required this.isHost,
    this.pinnedComment,
    this.onPinComment,
    this.onUnpinComment,
    super.key,
  });

  final List<LiveComment> comments;
  final LiveComment? pinnedComment;
  final String hostId;
  final bool isHost;
  final void Function(LiveComment comment)? onPinComment;
  final VoidCallback? onUnpinComment;

  @override
  State<LiveChatOverlay> createState() => _LiveChatOverlayState();
}

class _LiveChatOverlayState extends State<LiveChatOverlay> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(LiveChatOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.comments.length != oldWidget.comments.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pinned Comment Banner (YouTube SuperChat / TikTok Pinned Announcement)
        if (widget.pinnedComment != null)
          _buildPinnedComment(widget.pinnedComment!),

        const SizedBox(height: 6),

        // Real-Time Chat messages list
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 220),
          child: ShaderMask(
            shaderCallback: (bounds) {
              return const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black],
                stops: [0.0, 0.2],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: ListView.builder(
              controller: _scrollController,
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: widget.comments.length,
              itemBuilder: (context, index) {
                final comment = widget.comments[index];
                return _buildCommentBubble(comment);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPinnedComment(LiveComment pinned) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.25),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.push_pin,
            color: Color(0xFFFFD700),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      (pinned.user.fullName?.isNotEmpty ?? false)
                          ? pinned.user.fullName!
                          : pinned.user.username,
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'PINNED',
                        style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  pinned.content,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          if (widget.isHost && widget.onUnpinComment != null)
            GestureDetector(
              onTap: widget.onUnpinComment,
              child: const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Icon(
                  Icons.close,
                  color: Colors.white60,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentBubble(LiveComment comment) {
    final isStreamer = comment.user.id == widget.hostId;
    final isSystem = comment.isSystem;

    if (isSystem) {
      return Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          '${comment.user.username} ${comment.content}',
          style: TextStyle(
            color: const Color(0xFF64D2FF).withValues(alpha: 0.95),
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return GestureDetector(
      onLongPress: widget.isHost && widget.onPinComment != null
          ? () => _showCommentActions(comment)
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isStreamer
              ? const Color(0xFFFF0844).withValues(alpha: 0.4)
              : Colors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(16),
          border: isStreamer
              ? Border.all(
                  color: const Color(0xFFFF0844).withValues(alpha: 0.6),
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSmallAvatar(comment.user),
            const SizedBox(width: 6),
            Flexible(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${comment.user.username} ',
                      style: TextStyle(
                        color: isStreamer
                            ? const Color(0xFFFFD700)
                            : Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                    if (isStreamer)
                      const WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Text('👑', style: TextStyle(fontSize: 11)),
                        ),
                      ),
                    TextSpan(
                      text: comment.content,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallAvatar(PostAuthor user) {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white24,
      ),
      clipBehavior: Clip.antiAlias,
      child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: user.avatarUrl!,
              fit: BoxFit.cover,
              errorWidget: (_, __, dynamic ___) => Center(
                child: Text(
                  user.initials,
                  style: const TextStyle(fontSize: 9, color: Colors.white),
                ),
              ),
            )
          : Center(
              child: Text(
                user.initials,
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }

  void _showCommentActions(LiveComment comment) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1E1E2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.push_pin, color: Color(0xFFFFD700)),
                title: const Text(
                  'Pin Comment to Stream',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  comment.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white60),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  widget.onPinComment?.call(comment);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
