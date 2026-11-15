import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lotus_connect/app/theme/theme_extensions.dart';
import 'package:lotus_connect/core/theme/app_size.dart';
import 'package:lotus_connect/features/chat/presentation/widgets/markdown_message_view.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

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
    final loc = AppLocalizations.of(context);
    final chatTheme = theme.extension<AppChatTheme>();
    final isUser = message.role.isUser;
    final timeStr = DateFormat('h:mm a').format(message.timestamp);

    if (isUser) {
      return Padding(
        padding: const EdgeInsets.only(
          left: AppSize.massive,
          right: AppSize.lg,
          top: AppSize.sm,
          bottom: AppSize.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: AppPadding.listTile,
              decoration: BoxDecoration(
                color: chatTheme?.userBubbleBg ?? Colors.black,
                borderRadius: AppRadius.chatBubbleOwn,
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
            AppGap.vXs,
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
                AppGap.hXs,
                Icon(
                  Icons.done_all_rounded,
                  size: AppSize.iconXs,
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
      padding: const EdgeInsets.only(
        left: AppSize.lg,
        right: AppSize.xxxl,
        top: AppSize.sm,
        bottom: AppSize.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppSize.iconLg,
                height: AppSize.iconLg,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: AppRadius.sm,
                ),
                child: const Icon(
                  Icons.smart_toy_outlined,
                  size: AppSize.iconSm,
                ),
              ),
              AppGap.hSm,
              Text(
                loc?.neuralAi ?? 'Neural AI',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          AppGap.vSm,
          Container(
            padding: AppPadding.card,
            decoration: BoxDecoration(
              color: chatTheme?.aiBubbleBg ?? theme.cardColor,
              borderRadius: AppRadius.card,
              border: AppBorder.all(
                theme.dividerColor.withValues(alpha: 0.1),
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
                AppGap.vMd,
                Divider(
                  height: AppSize.dividerThickness,
                  color: theme.dividerColor.withValues(alpha: 0.1),
                ),
                AppGap.vSm,
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.thumb_up_outlined,
                        size: AppSize.iconXs,
                      ),
                      onPressed: () {},
                      visualDensity: VisualDensity.compact,
                      tooltip: loc?.likeAction ?? 'Like',
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.refresh_rounded,
                        size: AppSize.iconXs,
                      ),
                      onPressed: onRegenerate,
                      visualDensity: VisualDensity.compact,
                      tooltip: loc?.regenerate ?? 'Regenerate',
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.star_outline_rounded,
                        size: AppSize.iconXs,
                      ),
                      onPressed: () {},
                      visualDensity: VisualDensity.compact,
                      tooltip: loc?.star ?? 'Star',
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.copy_rounded,
                        size: AppSize.iconXs,
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: message.content));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              loc?.messageCopied ??
                                  'Message copied to clipboard',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      visualDensity: VisualDensity.compact,
                      tooltip: loc?.copy ?? 'Copy',
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
