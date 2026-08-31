import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/calls/domain/entities/call_log.dart';
import 'package:lotus_connect/features/chat/application/private_conversation_list_notifier.dart';
import 'package:lotus_connect/features/chatbot/application/settings_notifier.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

class HistoryCard extends ConsumerWidget {
  const HistoryCard({
    required this.log,
    this.friends = const [],
    super.key,
  });

  final CallLog log;
  final List<User> friends;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final peerName = log.hostName ?? log.username;
    final initials = peerName?.substring(0, 1).toUpperCase();

    final isMissed = log.status == 'missed' || log.status == 'rejected';
    final timeText = DateFormat('h:mm a').format(log.createdAt.toLocal());

    IconData badgeIcon;
    Color badgeColor;
    if (isMissed) {
      badgeIcon = Icons.close;
      badgeColor = Colors.red;
    } else {
      final currentUserId = ref.read(settingsProvider).userId;
      final isOutgoing = log.hostId == currentUserId;
      badgeIcon = isOutgoing ? Icons.arrow_upward : Icons.arrow_downward;
      badgeColor = isOutgoing ? Colors.blue : Colors.green;
    }

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
              backgroundColor:
                  isMissed ? Colors.red.shade50 : Colors.grey.shade100,
              child: Text(
                initials!,
                style: TextStyle(
                  color: isMissed ? Colors.red : Colors.grey.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(badgeIcon, size: 10, color: Colors.white),
              ),
            ),
          ],
        ),
        title: Text(
          peerName!,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Row(
          children: [
            Icon(
              log.isVideo ? Icons.videocam_outlined : Icons.phone_outlined,
              size: 14,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              log.isVideo ? loc.videoCall : loc.voiceCall,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            if (log.durationSeconds > 0) ...[
              const SizedBox(width: 8),
              const Icon(Icons.circle, size: 4, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                _formatDurationText(context, log.durationSeconds),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              timeText,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade100,
              child: IconButton(
                icon: Icon(
                  log.isVideo ? Icons.videocam : Icons.phone,
                  size: 16,
                  color: Colors.black87,
                ),
                onPressed: () {
                  final targetPeerId = _resolvePeerId(log, ref);
                  if (targetPeerId.isNotEmpty) {
                    // _peerIdController.text = targetPeerId;
                    // _startCall(isVideo: log.isVideo);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _resolvePeerId(CallLog log, WidgetRef ref) {
    final currentUserId = ref.read(settingsProvider).userId;
    if (log.hostId != currentUserId) {
      return log.hostId;
    }
    if (log.conversationId != null) {
      final conversations =
          ref.read(privateConversationListProvider).conversations;
      for (final c in conversations) {
        if (c.id == log.conversationId && c.isUserToUser) {
          return c.peerId;
        }
      }
    }
    return '';
  }

  String _formatDurationText(BuildContext context, int seconds) {
    if (seconds <= 0) {
      final loc = AppLocalizations.of(context)!;
      return loc.missed;
    }
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m > 0) {
      return '${m}m ${s}s';
    }
    return '${s}s';
  }

  String _resolvePeerName(CallLog log, List<User> friends, WidgetRef ref) {
    final targetId = _resolvePeerId(log, ref);
    if (targetId.isNotEmpty) {
      for (final f in friends) {
        if (f.id == targetId) {
          return f.fullName ?? f.username;
        }
      }
      return 'User ${targetId.substring(0, 8)}';
    }
    return 'Unknown User';
  }
}
