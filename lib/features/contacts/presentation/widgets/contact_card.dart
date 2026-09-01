import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/utils/utils.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/chat/application/presence_notifier.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

class ContactCard extends ConsumerWidget {
  const ContactCard({
    required this.friend,
    this.voiceCall,
    this.videoCall,
    this.startChat,
    this.onDelete,
    super.key,
  });

  final User friend;
  final VoidCallback? startChat;
  final VoidCallback? voiceCall;
  final VoidCallback? videoCall;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final presenceColor = _getPresenceColor(ref, friend.id);
    final presenceText = _getPresenceStatusText(ref, friend.id, loc);
    final displayName = friend.fullName ?? friend.username;
    final initials = displayName.isNotEmpty
        ? displayName.substring(0, 1).toUpperCase()
        : '?';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: presenceColor.withValues(alpha: 0.1),
              child: Text(
                initials,
                style: TextStyle(
                  color: presenceColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: presenceColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        title: Text(
          displayName,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          presenceText,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.chat_bubble_outline,
                color: theme.colorScheme.primary,
                size: 22,
              ),
              tooltip: loc.chat,
              onPressed: startChat,
            ),
            IconButton(
              icon: const Icon(
                Icons.phone_outlined,
                color: Colors.blue,
                size: 22,
              ),
              tooltip: loc.voiceCall,
              onPressed: () {
                voiceCall?.call();
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.videocam_outlined,
                color: Colors.green,
                size: 22,
              ),
              tooltip: loc.videoCall,
              onPressed: () {
                videoCall?.call();
              },
            ),
            if (onDelete != null)
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  if (value == 'unfriend') {
                    onDelete?.call();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'unfriend',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person_remove_outlined,
                          color: Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          loc.unfriend,
                          style: const TextStyle(color: Colors.red),
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

  String _getPresenceStatusText(
    WidgetRef ref,
    String peerId,
    AppLocalizations loc,
  ) {
    final presenceMap = ref.watch(presenceProvider);
    final peerPresence = presenceMap[peerId];
    final isOnline = peerPresence?.isOnline ?? false;
    final lastSeen = peerPresence?.lastSeen ?? DateTime.now();
    if (isOnline) {
      return loc.online;
    } else {
      return formatLastSeen(isOnline, lastSeen);
    }
  }

  Color _getPresenceColor(WidgetRef ref, String peerId) {
    final presenceMap = ref.watch(presenceProvider);
    final peerPresence = presenceMap[peerId];
    final isOnline = peerPresence?.isOnline ?? false;
    if (isOnline) return Colors.green;
    return Colors.grey;
  }
}
