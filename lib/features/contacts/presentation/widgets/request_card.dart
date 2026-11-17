import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/app/theme/app_color.dart';
import 'package:lotus_connect/app/theme/app_size.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/contacts/application/friend_request_notifier.dart';
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
    final avatarColor = AppColor
        .avatarPalette[user.username.hashCode % AppColor.avatarPalette.length]
        .of(context);
    final displayName = user.fullName ?? user.username;
    final initials = displayName.isNotEmpty
        ? displayName.substring(0, 1).toUpperCase()
        : '?';

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
        leading: CircleAvatar(
          radius: AppSize.avatarMd / 2,
          backgroundColor: avatarColor.withValues(alpha: 0.15),
          backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
              ? NetworkImage(user.avatarUrl!)
              : null,
          child: user.avatarUrl == null || user.avatarUrl!.isEmpty
              ? Text(
                  initials,
                  style: TextStyle(
                    color: avatarColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                )
              : null,
        ),
        title: Text(
          displayName,
          style: const TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
        subtitle: Text(
          '@${user.username}',
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
            fontSize: 13,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (startChat != null)
              IconButton(
                icon: Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: theme.colorScheme.primary,
                  size: AppSize.iconSm,
                ),
                onPressed: startChat,
                tooltip: loc.chat,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.all(AppSize.chipVertical),
                constraints: const BoxConstraints(
                  minWidth: AppSize.iconButtonSm,
                  minHeight: AppSize.iconButtonSm,
                ),
              ),
            IconButton(
              icon: Icon(
                Icons.check_circle_rounded,
                color: AppColor.successGreen.of(context),
                size: AppSize.iconMd,
              ),
              onPressed: () async {
                final success = await ref
                    .read(friendRequestProvider.notifier)
                    .acceptFriendRequest(user.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? loc.friendRequestAccepted
                            : loc.failedToAcceptRequest,
                      ),
                      backgroundColor: success
                          ? AppColor.success.of(context)
                          : AppColor.danger.of(context),
                    ),
                  );
                }
              },
              tooltip: loc.accept,
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.all(AppSize.chipVertical),
              constraints: const BoxConstraints(
                minWidth: AppSize.iconButtonSm,
                minHeight: AppSize.iconButtonSm,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.cancel_rounded,
                color: AppColor.dangerAccent.of(context),
                size: AppSize.iconMd,
              ),
              onPressed: () async {
                final success = await ref
                    .read(friendRequestProvider.notifier)
                    .rejectFriendRequest(user.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? loc.friendRequestRejected
                            : loc.failedToRejectRequest,
                      ),
                      backgroundColor: success
                          ? AppColor.success.of(context)
                          : AppColor.danger.of(context),
                    ),
                  );
                }
              },
              tooltip: loc.reject,
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.all(AppSize.chipVertical),
              constraints: const BoxConstraints(
                minWidth: AppSize.iconButtonSm,
                minHeight: AppSize.iconButtonSm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
