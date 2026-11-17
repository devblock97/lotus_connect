import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lotus_connect/app/theme/app_color.dart';
import 'package:lotus_connect/app/theme/app_size.dart';
import 'package:lotus_connect/features/notifications/domain/entities/app_notification.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onMoreTap,
    required this.onToggleRead,
    required this.onRemove,
    this.onAcceptRequest,
    this.onDeclineRequest,
    this.onPrimaryAction,
    super.key,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onMoreTap;
  final VoidCallback onToggleRead;
  final VoidCallback onRemove;
  final VoidCallback? onAcceptRequest;
  final VoidCallback? onDeclineRequest;
  final VoidCallback? onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final unreadDotColor =
        isDark ? theme.colorScheme.primary : AppColor.socialBlue.of(context);

    final rowBgColor = notification.isRead
        ? AppColor.transparent.of(context)
        : (isDark
            ? theme.colorScheme.primary.withValues(alpha: 0.13)
            : AppColor.socialBlueTint.of(context).withValues(alpha: 0.72));

    final timeString = formatRelativeTime(notification.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSize.xxs),
      child: Dismissible(
        key: ValueKey('notif_${notification.id}'),
        background: Container(
          color: unreadDotColor.withValues(alpha: 0.85),
          alignment: Alignment.centerLeft,
          padding: AppPadding.hXl,
          child: Row(
            children: [
              Icon(
                notification.isRead
                    ? Icons.mark_chat_unread_rounded
                    : Icons.done_all_rounded,
                color: AppColor.onMedia.of(context),
                size: AppSize.iconMd,
              ),
              AppGap.hSm,
              Text(
                notification.isRead ? 'Unread' : 'Read',
                style: TextStyle(
                  color: AppColor.onMedia.of(context),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        secondaryBackground: Container(
          color: AppColor.badgeRed.of(context),
          alignment: Alignment.centerRight,
          padding: AppPadding.hXl,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Remove',
                style: TextStyle(
                  color: AppColor.onMedia.of(context),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              AppGap.hSm,
              Icon(
                Icons.delete_outline_rounded,
                color: AppColor.onMedia.of(context),
                size: AppSize.iconMd,
              ),
            ],
          ),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            onToggleRead();
            return false;
          }
          return true;
        },
        onDismissed: (_) => onRemove(),
        child: Material(
          color: rowBgColor,
          child: InkWell(
            onTap: onTap,
            onLongPress: onMoreTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSize.lg,
                AppSize.md,
                AppSize.sm,
                AppSize.md,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 56x56 Avatar + 24x24 Overlapping Badge
                  _NotificationAvatarWithBadge(
                    notification: notification,
                    surfaceColor: notification.isRead
                        ? theme.scaffoldBackgroundColor
                        : Color.alphaBlend(
                            rowBgColor,
                            theme.scaffoldBackgroundColor,
                          ),
                  ),
                  AppGap.hMd,
                  // Rich Text + Timestamp + Inline Action Buttons
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSize.xxs),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRichMessage(context),
                          AppGap.vXs,
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  timeString,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: notification.isRead
                                        ? FontWeight.w400
                                        : FontWeight.w600,
                                    color: notification.isRead
                                        ? theme.colorScheme.onSurfaceVariant
                                            .withValues(alpha: 0.78)
                                        : unreadDotColor,
                                  ),
                                ),
                              ),
                              if (_categoryLabel(notification.kind) !=
                                  null) ...[
                                Text(
                                  ' • ${_categoryLabel(notification.kind)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.65),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (_hasInlineActions) ...[
                            AppGap.vMd,
                            _buildInlineActions(context),
                          ],
                        ],
                      ),
                    ),
                  ),
                  // Optional post/story media preview thumbnail
                  if (notification.previewImageUrl != null) ...[
                    AppGap.hSm,
                    Padding(
                      padding: const EdgeInsets.only(top: AppSize.xs),
                      child: ClipRRect(
                        borderRadius: AppRadius.sm,
                        child: CachedNetworkImage(
                          imageUrl: notification.previewImageUrl!,
                          width: AppSize.avatarLg,
                          height: AppSize.avatarLg,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => AppGap.shrink,
                        ),
                      ),
                    ),
                  ],
                  // Trailing Unread Dot + `...` More Menu Button
                  Padding(
                    padding: const EdgeInsets.only(
                      left: AppSize.xs,
                      top: AppSize.xs,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!notification.isRead)
                          Container(
                            width: AppSize.statusDotSm,
                            height: AppSize.statusDotSm,
                            margin: const EdgeInsets.only(right: AppSize.xxs),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: unreadDotColor,
                            ),
                          ),
                        IconButton(
                          icon: Icon(
                            Icons.more_horiz_rounded,
                            size: AppSize.iconSm,
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.8),
                          ),
                          visualDensity: VisualDensity.compact,
                          splashRadius: AppSize.xl,
                          tooltip: 'More options',
                          onPressed: onMoreTap,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get _hasInlineActions {
    if (notification.kind == NotificationKind.friendRequest &&
        (onAcceptRequest != null || onDeclineRequest != null)) {
      return true;
    }
    if (notification.kind == NotificationKind.missedCall &&
        onPrimaryAction != null) {
      return true;
    }
    return false;
  }

  Widget _buildRichMessage(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.onSurface;
    final secondaryColor = notification.isRead
        ? theme.colorScheme.onSurface.withValues(alpha: 0.85)
        : theme.colorScheme.onSurface;

    final title = notification.title.trim();
    final body = notification.body.trim();
    final actor = notification.actorName;

    // If actorName is present and body doesn't already start with it
    if (actor != null &&
        actor.isNotEmpty &&
        !body.toLowerCase().startsWith(actor.toLowerCase()) &&
        body.isNotEmpty) {
      return Text.rich(
        TextSpan(
          style: TextStyle(
            fontSize: 14.5,
            height: 1.32,
            color: secondaryColor,
          ),
          children: [
            TextSpan(
              text: '$actor ',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: baseColor,
              ),
            ),
            if (title.isNotEmpty &&
                title.toLowerCase() != actor.toLowerCase()) ...[
              TextSpan(
                text: '$title: ',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: baseColor,
                ),
              ),
            ],
            TextSpan(
              text: body,
              style: TextStyle(
                fontWeight:
                    notification.isRead ? FontWeight.w400 : FontWeight.w500,
              ),
            ),
          ],
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      );
    }

    // Standard Facebook-style: Bold title/lead + regular body flow
    if (title.isNotEmpty && body.isNotEmpty) {
      // Check if body already starts with title to avoid duplication
      if (body.toLowerCase().startsWith(title.toLowerCase())) {
        final remainder = body.substring(title.length);
        return Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: 14.5,
              height: 1.32,
              color: secondaryColor,
            ),
            children: [
              TextSpan(
                text: title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: baseColor,
                ),
              ),
              TextSpan(
                text: remainder,
                style: TextStyle(
                  fontWeight:
                      notification.isRead ? FontWeight.w400 : FontWeight.w500,
                ),
              ),
            ],
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        );
      }

      // Check if title looks like a person's name or action subject
      final separator =
          title.endsWith('.') || title.endsWith('!') || title.endsWith('?')
              ? ' '
              : ' — ';

      return Text.rich(
        TextSpan(
          style: TextStyle(
            fontSize: 14.5,
            height: 1.32,
            color: secondaryColor,
          ),
          children: [
            TextSpan(
              text: title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: baseColor,
              ),
            ),
            TextSpan(
              text: '$separator$body',
              style: TextStyle(
                fontWeight:
                    notification.isRead ? FontWeight.w400 : FontWeight.w500,
              ),
            ),
          ],
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      );
    }

    final singleText = title.isNotEmpty ? title : body;
    return Text(
      singleText,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 14.5,
        height: 1.32,
        fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
        color: baseColor,
      ),
    );
  }

  Widget _buildInlineActions(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryBtnBg = isDark
        ? AppColor.onMedia12.of(context)
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.75);

    if (notification.kind == NotificationKind.friendRequest) {
      return Row(
        children: [
          if (onAcceptRequest != null)
            Expanded(
              child: SizedBox(
                height: AppSize.buttonHeightSm,
                child: FilledButton(
                  onPressed: onAcceptRequest,
                  style: FilledButton.styleFrom(
                    backgroundColor: isDark
                        ? theme.colorScheme.primary
                        : AppColor.socialBlue.of(context),
                    foregroundColor: isDark
                        ? theme.colorScheme.onPrimary
                        : AppColor.onMedia.of(context),
                    padding: AppPadding.hMd,
                    shape: AppBorder.rounded(radius: AppSize.radiusChip),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Confirm'),
                ),
              ),
            ),
          if (onAcceptRequest != null && onDeclineRequest != null) AppGap.hSm,
          if (onDeclineRequest != null)
            Expanded(
              child: SizedBox(
                height: AppSize.buttonHeightSm,
                child: TextButton(
                  onPressed: onDeclineRequest,
                  style: TextButton.styleFrom(
                    backgroundColor: secondaryBtnBg,
                    foregroundColor: theme.colorScheme.onSurface,
                    padding: AppPadding.hMd,
                    shape: AppBorder.rounded(radius: AppSize.radiusChip),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Delete'),
                ),
              ),
            ),
        ],
      );
    }

    if (notification.kind == NotificationKind.missedCall &&
        onPrimaryAction != null) {
      return SizedBox(
        height: AppSize.buttonHeightSm,
        child: TextButton.icon(
          onPressed: onPrimaryAction,
          icon: Icon(
            Icons.phone_callback_rounded,
            size: AppSize.iconXs,
            color: theme.colorScheme.onSurface,
          ),
          label: const Text('View in Calls'),
          style: TextButton.styleFrom(
            backgroundColor: secondaryBtnBg,
            foregroundColor: theme.colorScheme.onSurface,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSize.bubbleHorizontal,
            ),
            shape: AppBorder.rounded(radius: AppSize.radiusChip),
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return AppGap.shrink;
  }

  static String? _categoryLabel(NotificationKind kind) {
    switch (kind) {
      case NotificationKind.missedCall:
        return 'Missed call';
      case NotificationKind.call:
        return 'Call';
      case NotificationKind.friendRequest:
        return 'Friend request';
      case NotificationKind.friendAccept:
        return 'Friends';
      case NotificationKind.livestream:
        return 'Live';
      case NotificationKind.chat:
        return 'Message';
      case NotificationKind.like:
      case NotificationKind.love:
      case NotificationKind.comment:
      case NotificationKind.mention:
      case NotificationKind.post:
      case NotificationKind.story:
      case NotificationKind.system:
        return null;
    }
  }

  /// Formats [dateTime] in Facebook's concise relative style.
  static String formatRelativeTime(DateTime dateTime, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final diff = current.difference(dateTime);

    if (diff.inSeconds < 60) {
      return 'Just now';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    }
    if (diff.inHours < 24 && current.day == dateTime.day) {
      return '${diff.inHours}h';
    }
    final yesterday = current.subtract(const Duration(days: 1));
    if (dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day) {
      return 'Yesterday at ${DateFormat.jm().format(dateTime)}';
    }
    if (diff.inDays < 7) {
      final dayName = DateFormat.E().format(dateTime);
      final timePart = DateFormat.jm().format(dateTime);
      return '$dayName at $timePart';
    }
    if (dateTime.year == current.year) {
      final monthDay = DateFormat.MMMd().format(dateTime);
      final timePart = DateFormat.jm().format(dateTime);
      return '$monthDay at $timePart';
    }
    return DateFormat.yMMMd().format(dateTime);
  }
}

class _NotificationAvatarWithBadge extends StatelessWidget {
  const _NotificationAvatarWithBadge({
    required this.notification,
    required this.surfaceColor,
  });

  final AppNotification notification;
  final Color surfaceColor;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = notification.actorAvatarUrl;
    final seedText = (notification.actorName ?? notification.title).trim();
    final initials = _extractInitials(seedText);
    final avatarColor = _avatarColorFor(context, seedText);
    final badgeSpec = _BadgeSpec.forKind(
      context,
      notification.kind,
      Theme.of(context),
    );

    return SizedBox(
      width: AppSize.avatarXl + AppSize.xxs,
      height: AppSize.avatarXl + AppSize.xxs,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 56x56 Main Circular Avatar
          Container(
            width: AppSize.avatarXl,
            height: AppSize.avatarXl,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  avatarColor.withValues(alpha: 0.22),
                  avatarColor.withValues(alpha: 0.10),
                ],
              ),
              border: AppBorder.all(
                avatarColor.withValues(alpha: 0.2),
              ),
            ),
            child: ClipOval(
              child: avatarUrl != null && avatarUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: avatarUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _InitialsFallback(
                        initials: initials,
                        color: avatarColor,
                        fallbackIcon: badgeSpec.icon,
                      ),
                      errorWidget: (_, __, ___) => _InitialsFallback(
                        initials: initials,
                        color: avatarColor,
                        fallbackIcon: badgeSpec.icon,
                      ),
                    )
                  : _InitialsFallback(
                      initials: initials,
                      color: avatarColor,
                      fallbackIcon: badgeSpec.icon,
                    ),
            ),
          ),
          // 24x24 Overlapping Semantic Reaction/Type Badge at bottom-right
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: AppSize.avatarBadgeMd,
              height: AppSize.avatarBadgeMd,
              padding: AppPadding.xxs,
              decoration: BoxDecoration(
                color: surfaceColor,
                shape: BoxShape.circle,
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: badgeSpec.colors,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: badgeSpec.colors.first.withValues(alpha: 0.35),
                      blurRadius: AppSize.xs,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(
                  badgeSpec.icon,
                  size: AppSize.iconXxs,
                  color: AppColor.onMedia.of(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _extractInitials(String text) {
    final cleaned =
        text.replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), '').trim();
    if (cleaned.isEmpty) return '';
    final parts = cleaned.split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return cleaned.substring(0, 1).toUpperCase();
  }

  static Color _avatarColorFor(BuildContext context, String seed) {
    const palette = AppColor.notificationAvatarPalette;
    if (seed.isEmpty) return palette.first.of(context);
    return palette[seed.hashCode.abs() % palette.length].of(context);
  }
}

class _InitialsFallback extends StatelessWidget {
  const _InitialsFallback({
    required this.initials,
    required this.color,
    required this.fallbackIcon,
  });

  final String initials;
  final Color color;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    if (initials.isEmpty) {
      return Center(
        child: Icon(
          fallbackIcon,
          color: color,
          size: AppSize.iconMd,
        ),
      );
    }
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 19,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}

class _BadgeSpec {
  const _BadgeSpec({
    required this.icon,
    required this.colors,
  });

  factory _BadgeSpec.forKind(
    BuildContext context,
    NotificationKind kind,
    ThemeData theme,
  ) {
    switch (kind) {
      case NotificationKind.like:
        return _BadgeSpec(
          icon: Icons.thumb_up_alt_rounded,
          colors: [
            AppColor.badgeBlueLight.of(context),
            AppColor.socialBlue.of(context),
          ],
        );
      case NotificationKind.love:
        return _BadgeSpec(
          icon: Icons.favorite_rounded,
          colors: [
            AppColor.badgePinkLight.of(context),
            AppColor.badgeRed.of(context),
          ],
        );
      case NotificationKind.comment:
        return _BadgeSpec(
          icon: Icons.mode_comment_rounded,
          colors: [
            AppColor.badgeMintLight.of(context),
            AppColor.successBright.of(context),
          ],
        );
      case NotificationKind.mention:
        return _BadgeSpec(
          icon: Icons.alternate_email_rounded,
          colors: [
            AppColor.badgeSkyLight.of(context),
            AppColor.badgeSkyDark.of(context),
          ],
        );
      case NotificationKind.friendRequest:
      case NotificationKind.friendAccept:
        return _BadgeSpec(
          icon: Icons.person_rounded,
          colors: [
            AppColor.badgeBlueLight.of(context),
            AppColor.socialBlue.of(context),
          ],
        );
      case NotificationKind.missedCall:
        return _BadgeSpec(
          icon: Icons.call_missed_rounded,
          colors: [
            AppColor.badgeRedLight.of(context),
            AppColor.badgeRedDark.of(context),
          ],
        );
      case NotificationKind.call:
        return _BadgeSpec(
          icon: Icons.phone_in_talk_rounded,
          colors: [
            AppColor.badgePurpleLight.of(context),
            AppColor.purpleAccent.of(context),
          ],
        );
      case NotificationKind.chat:
        return _BadgeSpec(
          icon: Icons.chat_bubble_rounded,
          colors: [
            AppColor.badgeMessengerLight.of(context),
            AppColor.badgeMessengerDark.of(context),
          ],
        );
      case NotificationKind.livestream:
        return _BadgeSpec(
          icon: Icons.sensors_rounded,
          colors: [
            AppColor.postCoralStart.of(context),
            AppColor.badgeRed.of(context),
          ],
        );
      case NotificationKind.story:
        return _BadgeSpec(
          icon: Icons.auto_awesome_rounded,
          colors: [
            AppColor.badgeAmberLight.of(context),
            AppColor.badgeAmberDark.of(context),
          ],
        );
      case NotificationKind.post:
        return _BadgeSpec(
          icon: Icons.article_rounded,
          colors: [
            AppColor.badgeBlueSoft.of(context),
            AppColor.profileCoverStart.of(context),
          ],
        );
      case NotificationKind.system:
        return _BadgeSpec(
          icon: Icons.notifications_rounded,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary,
          ],
        );
    }
  }

  final IconData icon;
  final List<Color> colors;
}
