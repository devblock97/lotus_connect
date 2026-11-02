import 'package:flutter/material.dart';
import 'package:lotus_connect/features/notifications/domain/entities/app_notification.dart';

class NotificationOptionsSheet extends StatelessWidget {
  const NotificationOptionsSheet({
    required this.notification,
    required this.onToggleRead,
    required this.onRemove,
    required this.onOpenSettings,
    super.key,
  });

  final AppNotification notification;
  final VoidCallback onToggleRead;
  final VoidCallback onRemove;
  final VoidCallback onOpenSettings;

  static Future<void> show(
    BuildContext context, {
    required AppNotification notification,
    required VoidCallback onToggleRead,
    required VoidCallback onRemove,
    required VoidCallback onOpenSettings,
  }) {
    final theme = Theme.of(context);
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => NotificationOptionsSheet(
        notification: notification,
        onToggleRead: onToggleRead,
        onRemove: onRemove,
        onOpenSettings: onOpenSettings,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconBgColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.65);

    final displayTitle = notification.title.trim();
    final displayBody = notification.body.trim();
    final summaryText = displayTitle.isNotEmpty && displayBody.isNotEmpty
        ? '$displayTitle • $displayBody'
        : (displayTitle.isNotEmpty ? displayTitle : displayBody);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            // Mini notification preview header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text(
                    summaryText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Divider(
                    height: 1,
                    color: theme.dividerColor.withValues(alpha: 0.2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            _SheetOptionTile(
              icon: notification.isRead
                  ? Icons.mark_chat_unread_outlined
                  : Icons.check_circle_outline_rounded,
              iconBgColor: iconBgColor,
              title: notification.isRead ? 'Mark as unread' : 'Mark as read',
              subtitle: notification.isRead
                  ? 'Keep this notification highlighted as new'
                  : 'Clear the unread indicator for this notification',
              onTap: () {
                Navigator.of(context).pop();
                onToggleRead();
              },
            ),
            _SheetOptionTile(
              icon: Icons.cancel_presentation_rounded,
              iconBgColor: iconBgColor,
              title: 'Remove this notification',
              subtitle: 'Hide this alert from your notifications list',
              onTap: () {
                Navigator.of(context).pop();
                onRemove();
              },
            ),
            _SheetOptionTile(
              icon: Icons.tune_rounded,
              iconBgColor: iconBgColor,
              title: 'Notification settings',
              subtitle: 'Manage push and in-app alert preferences',
              onTap: () {
                Navigator.of(context).pop();
                onOpenSettings();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationsHeaderMenuSheet extends StatelessWidget {
  const NotificationsHeaderMenuSheet({
    required this.hasUnread,
    required this.onMarkAllRead,
    required this.onRefresh,
    required this.onOpenSettings,
    super.key,
  });

  final bool hasUnread;
  final VoidCallback onMarkAllRead;
  final VoidCallback onRefresh;
  final VoidCallback onOpenSettings;

  static Future<void> show(
    BuildContext context, {
    required bool hasUnread,
    required VoidCallback onMarkAllRead,
    required VoidCallback onRefresh,
    required VoidCallback onOpenSettings,
  }) {
    final theme = Theme.of(context);
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => NotificationsHeaderMenuSheet(
        hasUnread: hasUnread,
        onMarkAllRead: onMarkAllRead,
        onRefresh: onRefresh,
        onOpenSettings: onOpenSettings,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconBgColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.65);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            if (hasUnread)
              _SheetOptionTile(
                icon: Icons.done_all_rounded,
                iconBgColor: iconBgColor,
                title: 'Mark all as read',
                subtitle: 'Clear unread badges across all notifications',
                onTap: () {
                  Navigator.of(context).pop();
                  onMarkAllRead();
                },
              ),
            _SheetOptionTile(
              icon: Icons.refresh_rounded,
              iconBgColor: iconBgColor,
              title: 'Refresh notifications',
              subtitle: 'Fetch the latest activity from Lotus Connect',
              onTap: () {
                Navigator.of(context).pop();
                onRefresh();
              },
            ),
            _SheetOptionTile(
              icon: Icons.settings_outlined,
              iconBgColor: iconBgColor,
              title: 'Notification settings',
              subtitle: 'Choose what alerts you receive',
              onTap: () {
                Navigator.of(context).pop();
                onOpenSettings();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetOptionTile extends StatelessWidget {
  const _SheetOptionTile({
    required this.icon,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 21,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
