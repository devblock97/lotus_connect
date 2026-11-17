import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lotus_connect/app/theme/app_color.dart';
import 'package:lotus_connect/app/theme/app_size.dart';
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
        _resolvePeerName(loc, log, friends, ref);
    final initials =
        peerName.isNotEmpty ? peerName.substring(0, 1).toUpperCase() : '?';

    final isMissed = log.status == 'missed' || log.status == 'rejected';
    final timeText = DateFormat('h:mm a').format(log.createdAt.toLocal());

    IconData badgeIcon;
    Color badgeColor;
    if (isMissed) {
      badgeIcon = Icons.close;
      badgeColor = AppColor.danger.of(context);
    } else {
      final currentUserId = ref.read(settingsNotifierProvider).settings.userId;
      final isOutgoing = log.hostId == currentUserId;
      badgeIcon = isOutgoing ? Icons.arrow_upward : Icons.arrow_downward;
      badgeColor = isOutgoing
          ? AppColor.infoBlue.of(context)
          : AppColor.successGreen.of(context);
    }

    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark
        ? theme.colorScheme.surfaceContainer
        : AppColor.surfaceCard.of(context);
    final borderColor = isDark
        ? theme.colorScheme.outlineVariant.withValues(alpha: 0.3)
        : theme.colorScheme.outlineVariant.withValues(alpha: 0.45);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSize.xs),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: AppRadius.card,
        border: AppBorder.all(borderColor),
        boxShadow: [
          BoxShadow(
            color: AppColor.black
                .of(context)
                .withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, AppSize.xxs),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSize.bubbleHorizontal,
          vertical: AppSize.chipVertical,
        ),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: AppSize.avatarMd / 2,
              backgroundColor: isMissed
                  ? AppColor.danger.of(context).withValues(alpha: 0.12)
                  : theme.colorScheme.primaryContainer,
              child: Text(
                initials,
                style: TextStyle(
                  color: isMissed
                      ? AppColor.danger.of(context)
                      : theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Positioned(
              bottom: AppSize.none,
              right: AppSize.none,
              child: Container(
                width: AppSize.avatarBadgeSm,
                height: AppSize.avatarBadgeSm,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                  border: AppBorder.all(
                    cardColor,
                    width: AppSize.borderThick,
                  ),
                ),
                child: Icon(
                  badgeIcon,
                  size: AppSize.iconXxs,
                  color: AppColor.onMedia.of(context),
                ),
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
              size: AppSize.iconXs,
              color: isMissed
                  ? AppColor.dangerAccent.of(context)
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
            ),
            AppGap.hXs,
            Text(
              log.isVideo ? loc.videoCall : loc.voiceCall,
              style: TextStyle(
                color: isMissed
                    ? AppColor.dangerAccent.of(context)
                    : theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.75),
                fontSize: 13,
              ),
            ),
            if (isMissed || log.durationSeconds > 0) ...[
              AppGap.hSm,
              Icon(
                Icons.circle,
                size: AppSize.xs,
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              AppGap.hSm,
              Text(
                _formatDurationText(loc, log.durationSeconds),
                style: TextStyle(
                  color: isMissed
                      ? AppColor.dangerAccent.of(context)
                      : theme.colorScheme.onSurfaceVariant
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
            AppGap.hMd,
            CircleAvatar(
              radius: AppSize.avatarMd / 2,
              backgroundColor: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.7),
              child: IconButton(
                icon: Icon(
                  log.isVideo ? Icons.videocam_rounded : Icons.phone_rounded,
                  size: AppSize.iconXs,
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

  String _formatDurationText(AppLocalizations loc, int seconds) {
    if (seconds <= 0) {
      return loc.missed;
    }
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m > 0) {
      return loc.callDurationMinutesSeconds(m, s);
    }
    return loc.callDurationSeconds(s);
  }

  String _resolvePeerName(
    AppLocalizations loc,
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
      final shortId = targetId.length > 8 ? targetId.substring(0, 8) : targetId;
      return loc.userWithId(shortId);
    }
    return loc.unknownUser;
  }
}
