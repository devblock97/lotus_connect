import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/contacts/application/contacts_notifier.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

class RequestCard extends ConsumerWidget {
  const RequestCard({
    required this.user,
    this.voiceCall,
    this.videoCall,
    this.startChat,
    super.key,
  });

  final User user;
  final VoidCallback? voiceCall;
  final VoidCallback? videoCall;
  final VoidCallback? startChat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final avatarColor =
        Colors.primaries[user.username.hashCode % Colors.primaries.length];
    final displayName = user.fullName ?? user.username;
    final initials = displayName.isNotEmpty
        ? displayName.substring(0, 1).toUpperCase()
        : '?';

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: avatarColor.withValues(alpha: 0.7),
          strokeAlign: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        leading: CircleAvatar(
          backgroundColor: avatarColor.withValues(alpha: 0.15),
          child: Text(
            initials,
            style: TextStyle(color: avatarColor, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          displayName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          '@${user.username}',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.chat_bubble_outline,
                color: theme.colorScheme.primary,
              ),
              onPressed: startChat,
              tooltip: loc.chat,
            ),
            IconButton(
              icon: const Icon(Icons.check_circle_outline, color: Colors.green),
              onPressed: () async {
                final success = await ref
                    .read(contactsProvider.notifier)
                    .acceptFriendRequest(user.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Friend request accepted!'
                            : 'Failed to accept request',
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              tooltip: loc.accept,
            ),
            IconButton(
              icon: const Icon(Icons.cancel_outlined, color: Colors.red),
              onPressed: () async {
                final success = await ref
                    .read(contactsProvider.notifier)
                    .rejectFriendRequest(user.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Friend request rejected!'
                            : 'Failed to reject request',
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              tooltip: loc.reject,
            ),
          ],
        ),
      ),
    );
  }
}
