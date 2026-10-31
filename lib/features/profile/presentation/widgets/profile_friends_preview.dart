import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

class ProfileFriendsPreview extends StatelessWidget {
  const ProfileFriendsPreview({
    required this.friends,
    required this.totalFriendCount,
    super.key,
    this.isSelf = false,
    this.onFriendTap,
    this.onSeeAllTap,
    this.onFindFriendsTap,
  });

  final List<User> friends;
  final int totalFriendCount;
  final bool isSelf;
  final ValueChanged<User>? onFriendTap;
  final VoidCallback? onSeeAllTap;
  final VoidCallback? onFindFriendsTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black87;
    final secondaryColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final loc = AppLocalizations.of(context);

    final previewItems = friends.take(6).toList();
    final effectiveCount =
        totalFriendCount > friends.length ? totalFriendCount : friends.length;

    return Container(
      color: theme.cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: "Friends" + count + "Find Friends"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc?.friends ?? 'Friends',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$effectiveCount '
                    '${loc?.friends.toLowerCase() ?? 'friends'}',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: secondaryColor,
                    ),
                  ),
                ],
              ),
              if (isSelf && onFindFriendsTap != null)
                TextButton(
                  onPressed: onFindFriendsTap,
                  child: Text(
                    loc?.addFriend ?? 'Find Friends',
                    style: const TextStyle(
                      color: Color(0xFF1877F2),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          if (previewItems.isNotEmpty) ...[
            const SizedBox(height: 12),

            // 3x2 Grid of Friends
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: previewItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 10,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (context, index) {
                final friend = previewItems[index];
                return _FriendGridTile(
                  friend: friend,
                  primaryColor: primaryColor,
                  isDark: isDark,
                  onTap: () => onFriendTap?.call(friend),
                );
              },
            ),

            const SizedBox(height: 12),

            // "See all friends" full-width tonal button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onSeeAllTap,
                style: FilledButton.styleFrom(
                  backgroundColor: isDark
                      ? const Color(0xFF3A3B3C)
                      : const Color(0xFFE4E6EB),
                  foregroundColor: primaryColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  loc?.allFriends ?? 'See all friends',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              loc?.noFriendsFound ?? 'No friends to show yet',
              style: TextStyle(
                fontSize: 13.5,
                color: secondaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FriendGridTile extends StatelessWidget {
  const _FriendGridTile({
    required this.friend,
    required this.primaryColor,
    required this.isDark,
    this.onTap,
  });

  final User friend;
  final Color primaryColor;
  final bool isDark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final displayName =
        (friend.fullName != null && friend.fullName!.trim().isNotEmpty)
            ? friend.fullName!.trim()
            : friend.username;
    final hasAvatar = friend.avatarUrl != null && friend.avatarUrl!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: double.infinity,
                child: hasAvatar
                    ? CachedNetworkImage(
                        imageUrl: friend.avatarUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _buildPlaceholder(displayName),
                        errorWidget: (_, __, dynamic ___) =>
                            _buildPlaceholder(displayName),
                      )
                    : _buildPlaceholder(displayName),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String name) {
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final colors = [
      const Color(0xFF4F46E5),
      const Color(0xFF0891B2),
      const Color(0xFF059669),
      const Color(0xFFD97706),
      const Color(0xFFE11D48),
    ];
    final bgColor = colors[friend.username.hashCode.abs() % colors.length];

    return ColoredBox(
      color: bgColor,
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet displaying all friends of a user with search filtering.
class ProfileFriendsSheet extends StatefulWidget {
  const ProfileFriendsSheet({
    required this.friends,
    required this.onFriendTap,
    super.key,
  });

  final List<User> friends;
  final ValueChanged<User> onFriendTap;

  static Future<void> show(
    BuildContext context, {
    required List<User> friends,
    required ValueChanged<User> onFriendTap,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProfileFriendsSheet(
        friends: friends,
        onFriendTap: onFriendTap,
      ),
    );
  }

  @override
  State<ProfileFriendsSheet> createState() => _ProfileFriendsSheetState();
}

class _ProfileFriendsSheetState extends State<ProfileFriendsSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final filtered = widget.friends.where((u) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return u.username.toLowerCase().contains(q) ||
          (u.fullName?.toLowerCase().contains(q) ?? false);
    }).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.45,
      maxChildSize: 0.94,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                child: Row(
                  children: [
                    Text(
                      '${loc?.friends ?? 'Friends'} (${widget.friends.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  onChanged: (val) => setState(() => _query = val),
                  decoration: InputDecoration(
                    hintText: loc?.searchFriends ?? 'Search friends...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    isDense: true,
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          loc?.noFriendsFound ?? 'No friends found',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final user = filtered[index];
                          final displayName = (user.fullName != null &&
                                  user.fullName!.trim().isNotEmpty)
                              ? user.fullName!.trim()
                              : user.username;
                          final hasAvatar = user.avatarUrl != null &&
                              user.avatarUrl!.isNotEmpty;

                          return ListTile(
                            leading: CircleAvatar(
                              radius: 22,
                              backgroundImage: hasAvatar
                                  ? CachedNetworkImageProvider(user.avatarUrl!)
                                  : null,
                              child: !hasAvatar
                                  ? Text(
                                      displayName.isNotEmpty
                                          ? displayName[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                            title: Text(
                              displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text('@${user.username}'),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () {
                              Navigator.pop(context);
                              widget.onFriendTap(user);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
