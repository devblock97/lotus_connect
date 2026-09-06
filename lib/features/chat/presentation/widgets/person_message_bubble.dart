import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lotus_connect/app/theme/app_colors.dart';
import 'package:lotus_connect/features/chat/application/private_active_conversation_notifier.dart';
import 'package:lotus_connect/features/chat/presentation/widgets/video_thumbnail.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

/// Compact, conversational bubble used only for person-to-person messages.
class PersonMessageBubble extends ConsumerStatefulWidget {
  const PersonMessageBubble({
    required this.message,
    required this.peerName,
    this.repliedToMessage,
    this.onSelectReaction,
    super.key,
  });

  final Message message;
  final String peerName;
  final Message? repliedToMessage;
  final void Function(Message message, String emoji)? onSelectReaction;

  @override
  ConsumerState<PersonMessageBubble> createState() =>
      _PersonMessageBubbleState();
}

class _PersonMessageBubbleState extends ConsumerState<PersonMessageBubble> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(privateActiveConversationProvider);
    final theme = Theme.of(context);
    final isMine = widget.message.role.isUser;
    final time = DateFormat('h:mm a').format(widget.message.timestamp);
    final foreground = isMine
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurfaceVariant;
    final background = isMine
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceContainerHighest;

    return Padding(
      padding: EdgeInsets.fromLTRB(isMine ? 72 : 16, 6, isMine ? 16 : 72, 6),
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMine) ...[
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Text(
                widget.peerName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ),
          ],
          if (widget.message.medias.isNotEmpty) ...[
            GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.message.medias.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.message.medias.length >= 4
                    ? 4
                    : widget.message.medias.length,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemBuilder: (context, index) {
                final media = widget.message.medias[index];
                if (media.mimeType!.contains('video')) {
                  return MediaVideoThumbnail(url: media.url);
                }
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CachedNetworkImage(
                    imageUrl: media.thumbnailUrl ?? media.url,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (_, __, dynamic ___) =>
                        const Icon(Icons.broken_image),
                  ),
                );
              },
            ),
          ],
          GestureDetector(
            onLongPress: () => _showOptionsDialog(context, ref),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMine ? 18 : 4),
                  bottomRight: Radius.circular(isMine ? 4 : 18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.repliedToMessage != null) ...[
                    _buildBubbleReplyHeader(
                      context,
                      widget.repliedToMessage!,
                      theme,
                      isMine,
                    ),
                    const SizedBox(height: 6),
                  ],
                  if (widget.message.content.isNotEmpty)
                    Text(
                      widget.message.content,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 15,
                        height: 1.35,
                      ),
                    ),
                  if (widget.message.reactions.isNotEmpty)
                    _buildReactionBadges(context, theme, isMine),
                ],
              ),
            ),
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                time,
                style: TextStyle(
                  fontSize: 11,
                  color:
                      theme.textTheme.bodySmall?.color?.withValues(alpha: .65),
                ),
              ),
              if (isMine) ...[
                const SizedBox(width: 3),
                Icon(
                  widget.message.isError
                      ? Icons.error_outline
                      : Icons.done_all_rounded,
                  size: 14,
                  color: widget.message.isError
                      ? theme.colorScheme.error
                      : (widget.message.status == MessageStatus.read
                          ? AppColors.primaryLight
                          : theme.disabledColor.withValues(alpha: 0.6)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextAndMediaMessage(
    bool isMediaLoading,
    int mediaLength,
    Color background,
    Color foreground,
    bool isMine,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.repliedToMessage != null) ...[
            _buildBubbleReplyHeader(
              context,
              widget.repliedToMessage!,
              theme,
              isMine,
            ),
            const SizedBox(height: 6),
          ],
          if (isMediaLoading)
            GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: mediaLength,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: mediaLength >= 4 ? 4 : mediaLength,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
          Container(
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isMine ? 18 : 4),
                bottomRight: Radius.circular(isMine ? 4 : 18),
              ),
            ),
            child: Text(
              widget.message.content,
              style: TextStyle(
                color: foreground,
                fontSize: 15,
                height: 1.35,
              ),
            ),
          ),
          if (widget.message.reactions.isNotEmpty)
            _buildReactionBadges(context, theme, isMine),
        ],
      ),
    );
  }

  Widget _buildTextMessage(
    Color background,
    Color foreground,
    bool isMine,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isMine ? 18 : 4),
          bottomRight: Radius.circular(isMine ? 4 : 18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.repliedToMessage != null) ...[
            _buildBubbleReplyHeader(
              context,
              widget.repliedToMessage!,
              theme,
              isMine,
            ),
            const SizedBox(height: 6),
          ],
          Text(
            widget.message.content,
            style: TextStyle(
              color: foreground,
              fontSize: 15,
              height: 1.35,
            ),
          ),
          if (widget.message.reactions.isNotEmpty)
            _buildReactionBadges(context, theme, isMine),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(loc.deleteMessage),
          content: Text(loc.deleteMessageConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(loc.cancel),
            ),
            TextButton(
              onPressed: () {
                ref
                    .read(privateActiveConversationProvider.notifier)
                    .deleteMessage(widget.message.id);
                Navigator.of(context).pop();
              },
              child: Text(
                loc.deleteMessage,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showOptionsDialog(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final isMine = widget.message.role.isUser;
    final defaultEmojis = ['👍', '❤️', '😂', '😮', '😢', '🔥', '🙏'];

    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: defaultEmojis
                          .map(
                            (emoji) => InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                Navigator.of(context).pop();
                                widget.onSelectReaction
                                    ?.call(widget.message, emoji);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 4,
                                ),
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 4),
                // Action options
                ListTile(
                  leading: const Icon(Icons.reply_rounded, size: 20),
                  title: const Text('Reply'),
                  dense: true,
                  onTap: () {
                    Navigator.of(context).pop();
                    ref
                        .read(privateActiveConversationProvider.notifier)
                        .setReplyingToMessage(widget.message);
                  },
                ),
                if (isMine) ...[
                  ListTile(
                    leading: const Icon(Icons.edit_rounded, size: 20),
                    title: Text(loc.editMessage),
                    dense: true,
                    onTap: () {
                      Navigator.of(context).pop();
                      _showEditDialog(context, ref);
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.delete_rounded,
                      size: 20,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    title: Text(
                      loc.deleteMessage,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    dense: true,
                    onTap: () {
                      Navigator.of(context).pop();
                      _showDeleteConfirmation(context, ref);
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: widget.message.content);
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(loc.editMessage),
          content: TextField(
            controller: controller,
            maxLines: null,
            autofocus: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(loc.cancel),
            ),
            TextButton(
              onPressed: () {
                final newContent = controller.text.trim();
                if (newContent.isNotEmpty &&
                    newContent != widget.message.content) {
                  ref
                      .read(privateActiveConversationProvider.notifier)
                      .updateMessage(widget.message.id, newContent);
                }
                Navigator.of(context).pop();
              },
              child: Text(loc.save),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReactionBadges(
    BuildContext context,
    ThemeData theme,
    bool isMine,
  ) {
    if (widget.message.reactions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: widget.message.reactions.map((entry) {
          return GestureDetector(
            onTap: () =>
                widget.onSelectReaction?.call(widget.message, entry.reaction),
            child: Stack(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isMine
                        ? theme.colorScheme.onPrimary.withValues(alpha: 0.18)
                        : theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (isMine
                              ? theme.colorScheme.onPrimary
                              : theme.dividerColor)
                          .withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        entry.reaction,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                if (entry.count > 1)
                  Positioned(
                    bottom: -5,
                    right: -1,
                    child: Text(
                      entry.count.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBubbleReplyHeader(
    BuildContext context,
    Message repliedTo,
    ThemeData theme,
    bool isMine,
  ) {
    final repliedIsMine = repliedTo.role.isUser;
    final senderName = repliedIsMine ? 'You' : widget.peerName;
    final barColor = isMine
        ? theme.colorScheme.onPrimary.withValues(alpha: 0.6)
        : theme.colorScheme.primary;
    final textColor = isMine
        ? theme.colorScheme.onPrimary.withValues(alpha: 0.8)
        : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8);
    final titleColor =
        isMine ? theme.colorScheme.onPrimary : theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isMine
            ? theme.colorScheme.onPrimary.withValues(alpha: 0.1)
            : theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 3,
            height: 24,
            color: barColor,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  senderName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  repliedTo.content,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
