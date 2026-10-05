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
    final isDark = theme.brightness == Brightness.dark;
    final isOnline = _isOnline(ref, friend.id);
    final presenceColor = _getPresenceColor(ref, friend.id);
    final presenceText = _getPresenceStatusText(ref, friend.id, loc);
    final displayName = (friend.fullName?.isNotEmpty ?? false)
        ? friend.fullName!
        : friend.username;
    final initials = displayName.isNotEmpty
        ? displayName.substring(0, 1).toUpperCase()
        : '?';

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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: startChat,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                // Avatar with Presence Indicator
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 23,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      backgroundImage: friend.avatarUrl != null &&
                              friend.avatarUrl!.isNotEmpty
                          ? NetworkImage(friend.avatarUrl!)
                          : null,
                      child:
                          friend.avatarUrl == null || friend.avatarUrl!.isEmpty
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
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 13,
                        height: 13,
                        decoration: BoxDecoration(
                          color: presenceColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: cardColor,
                            width: 2.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),

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
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          if (isOnline) ...[
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(right: 5),
                              decoration: const BoxDecoration(
                                color: Color(0xFF22C55E),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                          Flexible(
                            child: Text(
                              presenceText,
                              style: TextStyle(
                                color: isOnline
                                    ? (isDark
                                        ? Colors.greenAccent
                                        : const Color(0xFF16A34A))
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
                      color: Colors.blue.shade600,
                      tooltip: loc.voiceCall,
                      onPressed: voiceCall,
                    ),
                    _buildActionButton(
                      context: context,
                      icon: Icons.videocam_outlined,
                      color: const Color(0xFF16A34A),
                      tooltip: loc.videoCall,
                      onPressed: videoCall,
                    ),
                    if (onDelete != null)
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert_rounded,
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.7),
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
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
      icon: Icon(icon, color: color, size: 21),
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
      splashRadius: 18,
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
    if (isOnline) return const Color(0xFF22C55E);
    return Colors.grey.shade400;
  }
}
