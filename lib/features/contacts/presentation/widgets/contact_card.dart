import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/app/theme/app_color.dart';
import 'package:lotus_connect/app/theme/app_size.dart';
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
    this.onProfileTap,
    super.key,
  });

  final User friend;
  final VoidCallback? startChat;
  final VoidCallback? voiceCall;
  final VoidCallback? videoCall;
  final VoidCallback? onDelete;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isOnline = _isOnline(ref, friend.id);
    final presenceColor = _getPresenceColor(context, ref, friend.id);
    final presenceText = _getPresenceStatusText(ref, friend.id, loc);
    final displayName = (friend.fullName?.isNotEmpty ?? false)
        ? friend.fullName!
        : friend.username;
    final initials = displayName.isNotEmpty
        ? displayName.substring(0, 1).toUpperCase()
        : '?';

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
      child: Material(
        color: AppColor.transparent.of(context),
        borderRadius: AppRadius.card,
        child: InkWell(
          borderRadius: AppRadius.card,
          onTap: startChat,
          child: Padding(
            padding: AppPadding.chatBubble,
            child: Row(
              children: [
                // Avatar with Presence Indicator
                GestureDetector(
                  onTap: onProfileTap,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: AppSize.avatarLg / 2,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        backgroundImage: friend.avatarUrl != null &&
                                friend.avatarUrl!.isNotEmpty
                            ? NetworkImage(friend.avatarUrl!)
                            : null,
                        child: friend.avatarUrl == null ||
                                friend.avatarUrl!.isEmpty
                            ? Text(
                                initials,
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: AppSize.none,
                        right: AppSize.none,
                        child: Container(
                          width: AppSize.statusDotMd,
                          height: AppSize.statusDotMd,
                          decoration: BoxDecoration(
                            color: presenceColor,
                            shape: BoxShape.circle,
                            border: AppBorder.all(
                              cardColor,
                              width: AppSize.borderThick,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AppGap.hMd,

                // Name & Presence status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppGap.vXxs,
                      Row(
                        children: [
                          if (isOnline) ...[
                            Container(
                              width: AppSize.statusDotSm,
                              height: AppSize.statusDotSm,
                              margin: const EdgeInsets.only(right: AppSize.xs),
                              decoration: BoxDecoration(
                                color: AppColor.onlineGreen.of(context),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                          Flexible(
                            child: Text(
                              presenceText,
                              style: TextStyle(
                                color: isOnline
                                    ? AppColor.success.of(context)
                                    : theme.colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.75),
                                fontSize: 12.5,
                                fontWeight: isOnline
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Action Buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildActionButton(
                      context: context,
                      icon: Icons.chat_bubble_outline_rounded,
                      color: theme.colorScheme.primary,
                      tooltip: loc.chat,
                      onPressed: startChat,
                    ),
                    _buildActionButton(
                      context: context,
                      icon: Icons.phone_outlined,
                      color: AppColor.actionBlue.of(context),
                      tooltip: loc.voiceCall,
                      onPressed: voiceCall,
                    ),
                    _buildActionButton(
                      context: context,
                      icon: Icons.videocam_outlined,
                      color: AppColor.success.of(context),
                      tooltip: loc.videoCall,
                      onPressed: videoCall,
                    ),
                    if (onDelete != null)
                      PopupMenuButton<String>(
                        tooltip: loc.moreOptions,
                        icon: Icon(
                          Icons.more_vert_rounded,
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.7),
                          size: AppSize.iconSm,
                        ),
                        padding: AppPadding.zero,
                        constraints: const BoxConstraints(),
                        shape: AppBorder.rounded(radius: AppSize.radiusMd),
                        onSelected: (value) {
                          if (value == 'profile') {
                            onProfileTap?.call();
                          } else if (value == 'unfriend') {
                            onDelete?.call();
                          }
                        },
                        itemBuilder: (context) => [
                          if (onProfileTap != null)
                            PopupMenuItem(
                              value: 'profile',
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.person_outline_rounded,
                                    size: AppSize.iconSm,
                                  ),
                                  AppGap.hSm,
                                  Text(loc.viewProfile),
                                ],
                              ),
                            ),
                          PopupMenuItem(
                            value: 'unfriend',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person_remove_outlined,
                                  color: AppColor.danger.of(context),
                                  size: AppSize.iconSm,
                                ),
                                AppGap.hSm,
                                Text(
                                  loc.unfriend,
                                  style: TextStyle(
                                    color: AppColor.danger.of(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, color: color, size: AppSize.iconSm),
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(AppSize.chipVertical),
      constraints: const BoxConstraints(
        minWidth: AppSize.iconButtonSm,
        minHeight: AppSize.iconButtonSm,
      ),
      splashRadius: AppSize.xl,
    );
  }

  bool _isOnline(WidgetRef ref, String peerId) {
    final presenceMap = ref.watch(presenceProvider);
    return presenceMap[peerId]?.isOnline ?? false;
  }

  String _getPresenceStatusText(
    WidgetRef ref,
    String peerId,
    AppLocalizations loc,
  ) {
    final presenceMap = ref.watch(presenceProvider);
    final peerPresence = presenceMap[peerId];
    if (peerPresence == null) {
      return loc.offline;
    }
    if (peerPresence.isOnline) {
      return loc.online;
    }
    final diff = DateTime.now().difference(peerPresence.lastSeen);
    if (diff.isNegative || diff.inSeconds < 60) {
      return loc.justNow;
    }
    if (diff.inMinutes < 60) {
      return loc.minutesAgo(diff.inMinutes);
    }
    if (diff.inHours < 24) {
      return loc.hoursAgo(diff.inHours);
    }
    return loc.daysAgo(diff.inDays);
  }

  Color _getPresenceColor(BuildContext context, WidgetRef ref, String peerId) {
    final presenceMap = ref.watch(presenceProvider);
    final peerPresence = presenceMap[peerId];
    final isOnline = peerPresence?.isOnline ?? false;
    if (isOnline) return AppColor.onlineGreen.of(context);
    return AppColor.inkSubtle.of(context);
  }
}
