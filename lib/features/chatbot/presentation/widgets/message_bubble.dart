import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lotus_connect/app/theme/theme_extensions.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';
import 'package:lotus_connect/features/chatbot/presentation/widgets/markdown_message_view.dart';

/// Message bubble widget supporting Markdown, syntax highlighting, and actions.
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    required this.message,
    this.onCopy,
    this.onRegenerate,
    this.onRetry,
    super.key,
  });

  final Message message;
  final VoidCallback? onCopy;
  final VoidCallback? onRegenerate;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chatTheme = theme.extension<AppChatTheme>();
    final isUser = message.role.isUser;
    final timeStr = DateFormat('h:mm a').format(message.timestamp);

    if (isUser) {
      return Padding(
        padding: const EdgeInsets.only(left: 48, right: 16, top: 8, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: chatTheme?.userBubbleBg ?? Colors.black,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: chatTheme?.userBubbleFg ?? Colors.white,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeStr,
                  style: TextStyle(
                    color: theme.textTheme.bodySmall?.color
                        ?.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.done_all_rounded,
                  size: 14,
                  color:
                      theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // AI Assistant message bubble
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 32, top: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.smart_toy_outlined, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                'Neural AI',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: chatTheme?.aiBubbleBg ?? theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MarkdownMessageView(
                  content: message.content,
                  textColor: chatTheme?.aiBubbleFg ??
                      theme.textTheme.bodyLarge!.color!,
                ),
                const SizedBox(height: 12),
                Divider(
                  height: 1,
                  color: theme.dividerColor.withValues(alpha: 0.1),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.thumb_up_outlined, size: 16),
                      onPressed: () {},
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Like',
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      onPressed: onRegenerate,
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Regenerate',
                    ),
                    IconButton(
                      icon: const Icon(Icons.star_outline_rounded, size: 16),
                      onPressed: () {},
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Star',
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: message.content));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Message copied to clipboard'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Copy',
                    ),
                    const Spacer(),
                    Text(
                      timeStr,
                      style: TextStyle(
                        color: theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
