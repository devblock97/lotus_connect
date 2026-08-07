import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lotus_connect/features/chat/application/private_active_conversation_notifier.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

/// Compact, conversational bubble used only for person-to-person messages.
class PersonMessageBubble extends ConsumerWidget {
  const PersonMessageBubble({
    required this.message,
    required this.peerName,
    super.key,
  });

  final Message message;
  final String peerName;

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
                    .deleteMessage(message.id);
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isMine = message.role.isUser;
    final time = DateFormat('h:mm a').format(message.timestamp);
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
                peerName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ),
          ],
          GestureDetector(
            onLongPress: isMine ? () => _showDeleteConfirmation(context, ref) : null,
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
              child: Text(
                message.content,
                style: TextStyle(color: foreground, fontSize: 15, height: 1.35),
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
                  message.isError
                      ? Icons.error_outline
                      : Icons.done_all_rounded,
                  size: 14,
                  color: message.isError
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary.withValues(alpha: .75),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
