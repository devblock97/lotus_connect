import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/calls/domain/entities/call_log.dart';
import 'package:lotus_connect/features/chat/application/conversation_list_notifier.dart';
import 'package:lotus_connect/features/settings/application/settings_notifier.dart';
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
    final peerName = log.hostName ??
        log.username ??
        _resolvePeerName(context, log, friends, ref);
    final initials =
        peerName.isNotEmpty ? peerName.substring(0, 1).toUpperCase() : '?';

    final isMissed = log.status == 'missed' || log.status == 'rejected';
    final timeText = DateFormat('h:mm a').format(log.createdAt.toLocal());

    IconData badgeIcon;
    Color badgeColor;
    if (isMissed) {
      badgeIcon = Icons.close;
      badgeColor = Colors.red;
    } else {
      final currentUserId = ref.read(settingsNotifierProvider).settings.userId;
      final isOutgoing = log.hostId == currentUserId;
      badgeIcon = isOutgoing ? Icons.arrow_upward : Icons.arrow_downward;
      badgeColor = isOutgoing ? Colors.blue : Colors.green;
    }

    final isDark = theme.brightness == Brightness.dark;
    final cardColor =
        isDark ? theme.colorScheme.surfaceContainer : Colors.white;
    final borderColor = isDark
        ? theme.colorScheme.outlineVariant.withValues(alpha: 0.3)
        : theme.colorScheme.outlineVariant.withValues(alpha: 0.45);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: isMissed
                  ? Colors.red.withValues(alpha: 0.12)
                  : theme.colorScheme.primaryContainer,
              child: Text(
                initials,
                style: TextStyle(
                  color: isMissed
                      ? Colors.red
                      : theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
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
                  border: Border.all(color: cardColor, width: 2),
                ),
                child: Icon(badgeIcon, size: 10, color: Colors.white),
              ),
            ),
          ],
        ),
        title: Text(
          peerName,
          style: const TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(
              log.isVideo ? Icons.videocam_outlined : Icons.phone_outlined,
              size: 14,
              color: isMissed
                  ? Colors.red.shade400
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
            ),
            const SizedBox(width: 4),
            Text(
              log.isVideo ? loc.videoCall : loc.voiceCall,
              style: TextStyle(
                color: isMissed
                    ? Colors.red.shade400
                    : theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.75),
                fontSize: 13,
              ),
            ),
            if (log.durationSeconds > 0) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.circle,
                size: 4,
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 8),
              Text(
                _formatDurationText(context, log.durationSeconds),
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.75),
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              timeText,
              style: TextStyle(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 18,
              backgroundColor: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.7),
              child: IconButton(
                icon: Icon(
                  log.isVideo ? Icons.videocam_rounded : Icons.phone_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurface,
                ),
                tooltip: log.isVideo ? loc.videoCall : loc.voiceCall,
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
    final currentUserId = ref.read(settingsNotifierProvider).settings.userId;
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

  String _resolvePeerName(
    BuildContext context,
    CallLog log,
    List<User> friends,
    WidgetRef ref,
  ) {
    final targetId = _resolvePeerId(log, ref);
    if (targetId.isNotEmpty) {
      for (final f in friends) {
        if (f.id == targetId) {
          return f.fullName ?? f.username;
        }
      }
      return 'User ${targetId.substring(0, 8)}';
    }
    final loc = AppLocalizations.of(context)!;
    return loc.unknownUser;
  }
}
