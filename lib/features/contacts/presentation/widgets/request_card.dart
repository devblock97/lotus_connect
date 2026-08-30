import 'package:flutter/material.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

class RequestCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final avatarColor =
        Colors.primaries[user.username.hashCode % Colors.primaries.length];
    final displayName = user.fullName ?? user.username;
    final initials = displayName.isNotEmpty
        ? displayName.substring(0, 1).toUpperCase()
        : '?';

    return Container(
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
            // Chat Button
            IconButton(
              icon: Icon(
                Icons.chat_bubble_outline,
                color: theme.colorScheme.primary,
              ),
              onPressed: startChat,
              tooltip: loc.chat,
            ),
            // Voice Call Button
            IconButton(
              icon: const Icon(Icons.phone_outlined, color: Colors.blue),
              onPressed: voiceCall,
              tooltip: loc.voiceCall,
            ),
            // Video Call Button
            IconButton(
              icon: const Icon(Icons.videocam_outlined, color: Colors.green),
              onPressed: videoCall,
              tooltip: loc.videoCall,
            ),
          ],
        ),
      ),
    );
  }
}
