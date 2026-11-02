import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lotus_connect/app/router/app_router.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/chat/application/conversation_list_notifier.dart';
import 'package:lotus_connect/features/contacts/application/friend_request_notifier.dart';
import 'package:lotus_connect/features/livestream/presentation/views/livestream_explore_screen.dart';
import 'package:lotus_connect/features/notifications/application/notifications_notifier.dart';
import 'package:lotus_connect/features/notifications/domain/entities/app_notification.dart';
import 'package:lotus_connect/features/notifications/presentation/widgets/notification_options_sheet.dart';
import 'package:lotus_connect/features/notifications/presentation/widgets/notification_skeleton.dart';
import 'package:lotus_connect/features/notifications/presentation/widgets/notification_tile.dart';
import 'package:lotus_connect/features/profile/presentation/views/profile_screen.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';
import 'package:lotus_connect/main_shell_screen.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final ScrollController _controller = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;

  static const Color _fbBlue = Color(0xFF1877F2);

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      ref.read(notificationsProvider.notifier).loadMoreNotifications();
    }
  }

  bool get _isBottom {
    if (!_controller.hasClients) return false;
    final currScroll = _controller.position.pixels;
    final maxScroll = _controller.position.maxScrollExtent;
    return currScroll >= (maxScroll * 0.9);
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        ref.read(notificationsProvider.notifier).setSearchQuery('');
        _searchFocusNode.unfocus();
      } else {
        _searchFocusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(notificationsProvider);
    final notifier = ref.read(notificationsProvider.notifier);
    final friendRequestsState = ref.watch(friendRequestProvider);
    final pendingRequests = friendRequestsState.requests;

    final filtered = state.filteredNotifications;
    final groups = _groupNotificationsByTime(filtered);

    final showFriendRequestsPreview = !_isSearching &&
        state.searchQuery.isEmpty &&
        (state.activeFilter == NotificationFilter.all ||
            state.activeFilter == NotificationFilter.requests) &&
        pendingRequests.isNotEmpty;

    final circleBtnBg = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.65);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
          ),
        ),
        actions: [
          if (state.unreadCount > 0) ...[
            _HeaderCircleIconButton(
              icon: Icons.done_all_rounded,
              tooltip: 'Mark all as read',
              backgroundColor: circleBtnBg,
              iconColor: isDark ? theme.colorScheme.primary : _fbBlue,
              onTap: notifier.markAllRead,
            ),
            const SizedBox(width: 8),
          ],
          _HeaderCircleIconButton(
            icon: Icons.more_horiz_rounded,
            tooltip: 'More options',
            backgroundColor: circleBtnBg,
            onTap: () {
              NotificationsHeaderMenuSheet.show(
                context,
                hasUnread: state.unreadCount > 0,
                onMarkAllRead: notifier.markAllRead,
                onRefresh: notifier.refreshNotifications,
                onOpenSettings: () => context.push(AppRouter.settings),
              );
            },
          ),
          const SizedBox(width: 8),
          _HeaderCircleIconButton(
            icon: _isSearching ? Icons.close_rounded : CupertinoIcons.search,
            tooltip: _isSearching ? 'Close search' : 'Search notifications',
            backgroundColor: _isSearching
                ? (isDark ? theme.colorScheme.primary : _fbBlue)
                    .withValues(alpha: 0.18)
                : circleBtnBg,
            iconColor: _isSearching
                ? (isDark ? theme.colorScheme.primary : _fbBlue)
                : null,
            onTap: _toggleSearch,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: _buildFilterPillsBar(
            context,
            state: state,
            notifier: notifier,
            pendingRequestsCount: pendingRequests.length,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: isDark ? theme.colorScheme.primary : _fbBlue,
          onRefresh: () async {
            await Future.wait([
              notifier.refreshNotifications(),
              ref.read(friendRequestProvider.notifier).loadFriendRequests(),
            ]);
          },
          child: CustomScrollView(
            controller: _controller,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Animated Inline Search Bar (when toggled)
              SliverToBoxAdapter(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: _isSearching
                      ? _buildSearchField(context, notifier)
                      : const SizedBox.shrink(),
                ),
              ),

              SliverToBoxAdapter(
                child: Divider(
                  height: 1,
                  thickness: 0.5,
                  color: theme.dividerColor.withValues(alpha: 0.16),
                ),
              ),

              // Shimmer Skeleton while Initial Loading
              if (state.isLoading && state.notifications.isEmpty)
                const SliverNotificationListSkeleton()
              else ...[
                // Pending Friend Requests Section
                if (showFriendRequestsPreview)
                  SliverToBoxAdapter(
                    child: _buildFriendRequestsSection(
                      context,
                      pendingRequests,
                    ),
                  ),

                // Empty State or Time-Grouped Notification Sections
                if (filtered.isEmpty && !showFriendRequestsPreview)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(context, state, notifier),
                  )
                else ...[
                  if (groups.newItems.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: _buildSectionHeader(
                        context,
                        title: 'New',
                        trailingText:
                            state.unreadCount > 0 ? 'Mark all as read' : null,
                        onTrailingTap:
                            state.unreadCount > 0 ? notifier.markAllRead : null,
                      ),
                    ),
                    _buildNotificationSliverList(
                      context,
                      groups.newItems,
                      notifier,
                    ),
                  ],
                  if (groups.todayItems.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: _buildSectionHeader(
                        context,
                        title: 'Today',
                        trailingText:
                            groups.newItems.isEmpty && state.unreadCount > 0
                                ? 'Mark all as read'
                                : null,
                        onTrailingTap:
                            groups.newItems.isEmpty && state.unreadCount > 0
                                ? notifier.markAllRead
                                : null,
                      ),
                    ),
                    _buildNotificationSliverList(
                      context,
                      groups.todayItems,
                      notifier,
                    ),
                  ],
                  if (groups.earlierItems.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: _buildSectionHeader(
                        context,
                        title: 'Earlier',
                        trailingText: groups.newItems.isEmpty &&
                                groups.todayItems.isEmpty &&
                                state.unreadCount > 0
                            ? 'Mark all as read'
                            : null,
                        onTrailingTap: groups.newItems.isEmpty &&
                                groups.todayItems.isEmpty &&
                                state.unreadCount > 0
                            ? notifier.markAllRead
                            : null,
                      ),
                    ),
                    _buildNotificationSliverList(
                      context,
                      groups.earlierItems,
                      notifier,
                    ),
                  ],
                  if (state.isLoadingMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 24),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    NotificationsState state,
    NotificationsNotifier notifier,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final circleBtnBg = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.65);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 6),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Notifications',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
          ),
          if (state.unreadCount > 0) ...[
            _HeaderCircleIconButton(
              icon: Icons.done_all_rounded,
              tooltip: 'Mark all as read',
              backgroundColor: circleBtnBg,
              iconColor: isDark ? theme.colorScheme.primary : _fbBlue,
              onTap: notifier.markAllRead,
            ),
            const SizedBox(width: 8),
          ],
          _HeaderCircleIconButton(
            icon: Icons.more_horiz_rounded,
            tooltip: 'More options',
            backgroundColor: circleBtnBg,
            onTap: () {
              NotificationsHeaderMenuSheet.show(
                context,
                hasUnread: state.unreadCount > 0,
                onMarkAllRead: notifier.markAllRead,
                onRefresh: notifier.refreshNotifications,
                onOpenSettings: () => context.push(AppRouter.settings),
              );
            },
          ),
          const SizedBox(width: 8),
          _HeaderCircleIconButton(
            icon: _isSearching ? Icons.close_rounded : CupertinoIcons.search,
            tooltip: _isSearching ? 'Close search' : 'Search notifications',
            backgroundColor: _isSearching
                ? (isDark ? theme.colorScheme.primary : _fbBlue)
                    .withValues(alpha: 0.18)
                : circleBtnBg,
            iconColor: _isSearching
                ? (isDark ? theme.colorScheme.primary : _fbBlue)
                : null,
            onTap: _toggleSearch,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(
    BuildContext context,
    NotificationsNotifier notifier,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fillColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: SizedBox(
        height: 40,
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onChanged: notifier.setSearchQuery,
          style: const TextStyle(fontSize: 14.5),
          decoration: InputDecoration(
            hintText: 'Search notifications...',
            hintStyle: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            prefixIcon: Icon(
              CupertinoIcons.search,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.cancel_rounded, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      notifier.setSearchQuery('');
                      setState(() {});
                    },
                  )
                : null,
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPillsBar(
    BuildContext context, {
    required NotificationsState state,
    required NotificationsNotifier notifier,
    required int pendingRequestsCount,
  }) {
    final filters = <({
      NotificationFilter filter,
      String label,
      int badgeCount,
    })>[
      (
        filter: NotificationFilter.all,
        label: 'All',
        badgeCount: 0,
      ),
      (
        filter: NotificationFilter.unread,
        label: 'Unread',
        badgeCount: state.unreadCount,
      ),
      (
        filter: NotificationFilter.social,
        label: 'Activity',
        badgeCount: 0,
      ),
      (
        filter: NotificationFilter.requests,
        label: 'Requests',
        badgeCount: pendingRequestsCount,
      ),
      (
        filter: NotificationFilter.callsAndChats,
        label: 'Calls & Chats',
        badgeCount: 0,
      ),
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 4),
        itemBuilder: (context, index) {
          final item = filters[index];
          final isSelected = state.activeFilter == item.filter;
          return _FilterPill(
            label: item.label,
            badgeCount: item.badgeCount,
            isSelected: isSelected,
            onTap: () => notifier.setFilter(item.filter),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    String? trailingText,
    VoidCallback? onTrailingTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final actionColor = isDark ? theme.colorScheme.primary : _fbBlue;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (trailingText != null && onTrailingTap != null)
            TextButton(
              onPressed: onTrailingTap,
              style: TextButton.styleFrom(
                foregroundColor: actionColor,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                trailingText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFriendRequestsSection(
    BuildContext context,
    List<User> pendingRequests,
  ) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final previewUsers = pendingRequests.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          title: loc?.friendRequests ?? 'Friend requests',
          trailingText: 'See all (${pendingRequests.length})',
          onTrailingTap: () {
            ref.read(shellIndexProvider.notifier).state = 2;
          },
        ),
        ...previewUsers.map(
          (user) => _FriendRequestNotificationRow(
            user: user,
            onAccept: () async {
              final success = await ref
                  .read(friendRequestProvider.notifier)
                  .acceptFriendRequest(user.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? (loc?.friendRequestAccepted ??
                              'Friend request accepted!')
                          : (loc?.failedToAcceptRequest ??
                              'Failed to accept request'),
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            onDecline: () async {
              final success = await ref
                  .read(friendRequestProvider.notifier)
                  .rejectFriendRequest(user.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? (loc?.friendRequestRejected ??
                              'Friend request removed')
                          : (loc?.failedToRejectRequest ??
                              'Failed to reject request'),
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            onTapProfile: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                    userId: user.id,
                    initialUsername: user.username,
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Divider(
            height: 1,
            thickness: 0.5,
            color: theme.dividerColor.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }

  SliverList _buildNotificationSliverList(
    BuildContext context,
    List<AppNotification> items,
    NotificationsNotifier notifier,
  ) {
    return SliverList.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final notification = items[index];
        final actorId = notification.actorId;

        return NotificationTile(
          notification: notification,
          onTap: () => _handleNotificationTap(context, notification, notifier),
          onToggleRead: () => notifier.toggleReadStatus(notification.id),
          onRemove: () => _handleRemoveNotification(
            context,
            notification,
            notifier,
          ),
          onMoreTap: () {
            NotificationOptionsSheet.show(
              context,
              notification: notification,
              onToggleRead: () => notifier.toggleReadStatus(notification.id),
              onRemove: () => _handleRemoveNotification(
                context,
                notification,
                notifier,
              ),
              onOpenSettings: () => context.push(AppRouter.settings),
            );
          },
          onAcceptRequest: notification.kind == NotificationKind.friendRequest
              ? () async {
                  if (!notification.isRead) {
                    await notifier.readNotification(notification.id);
                  }
                  if (actorId != null && actorId.isNotEmpty) {
                    await ref
                        .read(friendRequestProvider.notifier)
                        .acceptFriendRequest(actorId);
                  } else {
                    ref.read(shellIndexProvider.notifier).state = 2;
                  }
                }
              : null,
          onDeclineRequest: notification.kind == NotificationKind.friendRequest
              ? () async {
                  if (actorId != null && actorId.isNotEmpty) {
                    await ref
                        .read(friendRequestProvider.notifier)
                        .rejectFriendRequest(actorId);
                  }
                  if (context.mounted) {
                    _handleRemoveNotification(context, notification, notifier);
                  }
                }
              : null,
          onPrimaryAction: notification.kind == NotificationKind.missedCall
              ? () {
                  if (!notification.isRead) {
                    notifier.readNotification(notification.id);
                  }
                  ref.read(shellIndexProvider.notifier).state = 2;
                }
              : null,
        );
      },
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    AppNotification notification,
    NotificationsNotifier notifier,
  ) {
    if (!notification.isRead) {
      notifier.readNotification(notification.id);
    }

    switch (notification.kind) {
      case NotificationKind.chat:
        final convId = notification.conversationId;
        if (convId != null && convId.isNotEmpty) {
          ref
              .read(privateConversationListProvider.notifier)
              .selectConversation(convId);
        }
        ref.read(shellIndexProvider.notifier).state = 1;
      case NotificationKind.missedCall:
      case NotificationKind.call:
      case NotificationKind.friendRequest:
      case NotificationKind.friendAccept:
        ref.read(shellIndexProvider.notifier).state = 2;
      case NotificationKind.livestream:
        Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) => const LiveStreamExploreScreen(),
          ),
        );
      case NotificationKind.like:
      case NotificationKind.love:
      case NotificationKind.comment:
      case NotificationKind.mention:
      case NotificationKind.post:
      case NotificationKind.story:
        final actorId = notification.actorId;
        if (actorId != null &&
            actorId.isNotEmpty &&
            notification.data?['postId'] == null) {
          Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => ProfileScreen(
                userId: actorId,
                initialUsername: notification.actorName,
              ),
            ),
          );
        } else {
          ref.read(shellIndexProvider.notifier).state = 0;
        }
      case NotificationKind.system:
        break;
    }
  }

  void _handleRemoveNotification(
    BuildContext context,
    AppNotification notification,
    NotificationsNotifier notifier,
  ) {
    final removedIndex = notifier.removeNotification(notification.id);
    if (removedIndex == -1) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Notification removed'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              notifier.restoreNotification(
                notification,
                index: removedIndex,
              );
            },
          ),
        ),
      );
  }

  Widget _buildEmptyState(
    BuildContext context,
    NotificationsState state,
    NotificationsNotifier notifier,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasActiveFilter = state.activeFilter != NotificationFilter.all ||
        state.searchQuery.trim().isNotEmpty;

    var title = "You're all caught up";
    var subtitle =
        'When friends react to your posts, leave comments, or call you, '
        'you will see it here.';
    var icon = Icons.notifications_none_rounded;

    if (state.searchQuery.trim().isNotEmpty) {
      title = 'No matching notifications';
      subtitle = 'No notifications matched "${state.searchQuery.trim()}". '
          'Try a different keyword.';
      icon = CupertinoIcons.search;
    } else if (state.activeFilter == NotificationFilter.unread) {
      title = 'No unread notifications';
      subtitle = "You've read all your recent notifications.";
      icon = Icons.done_all_rounded;
    } else if (state.activeFilter == NotificationFilter.requests) {
      title = 'No friend request alerts';
      subtitle = 'New friend requests and confirmations will appear here.';
      icon = Icons.people_outline_rounded;
    } else if (state.activeFilter == NotificationFilter.callsAndChats) {
      title = 'No call or chat alerts';
      subtitle = 'Missed calls and direct message alerts will show up here.';
      icon = Icons.phone_callback_outlined;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
              ),
              child: Icon(
                icon,
                size: 42,
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (hasActiveFilter) ...[
              const SizedBox(height: 20),
              FilledButton.tonal(
                onPressed: () {
                  _searchController.clear();
                  notifier
                    ..setSearchQuery('')
                    ..setFilter(NotificationFilter.all);
                },
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('See all notifications'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _NotificationTimeGroups _groupNotificationsByTime(
    List<AppNotification> list,
  ) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    final newItems = <AppNotification>[];
    final todayItems = <AppNotification>[];
    final earlierItems = <AppNotification>[];

    for (final item in list) {
      final isToday = !item.createdAt.isBefore(startOfToday);
      final isWithinLast6Hours =
          now.difference(item.createdAt) <= const Duration(hours: 6);

      if (!item.isRead && (isToday || isWithinLast6Hours)) {
        newItems.add(item);
      } else if (isToday) {
        todayItems.add(item);
      } else {
        earlierItems.add(item);
      }
    }

    return _NotificationTimeGroups(
      newItems: newItems,
      todayItems: todayItems,
      earlierItems: earlierItems,
    );
  }
}

class _NotificationTimeGroups {
  const _NotificationTimeGroups({
    required this.newItems,
    required this.todayItems,
    required this.earlierItems,
  });

  final List<AppNotification> newItems;
  final List<AppNotification> todayItems;
  final List<AppNotification> earlierItems;
}

class _HeaderCircleIconButton extends StatelessWidget {
  const _HeaderCircleIconButton({
    required this.icon,
    required this.tooltip,
    required this.backgroundColor,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String tooltip;
  final Color backgroundColor;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: backgroundColor,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(
              icon,
              size: 21,
              color: iconColor ?? theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.badgeCount,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final int badgeCount;
  final bool isSelected;
  final VoidCallback onTap;

  static const Color _fbBlue = Color(0xFF1877F2);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeAccent = isDark ? theme.colorScheme.primary : _fbBlue;

    final bgColor = isSelected
        ? activeAccent.withValues(alpha: isDark ? 0.22 : 0.13)
        : (isDark
            ? Colors.white.withValues(alpha: 0.08)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6));

    final fgColor =
        isSelected ? activeAccent : theme.colorScheme.onSurfaceVariant;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: fgColor,
                ),
              ),
              if (badgeCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1.5,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? activeAccent : const Color(0xFFE41E3F),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badgeCount > 99 ? '99+' : '$badgeCount',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSelected && isDark
                          ? theme.colorScheme.onPrimary
                          : Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FriendRequestNotificationRow extends StatelessWidget {
  const _FriendRequestNotificationRow({
    required this.user,
    required this.onAccept,
    required this.onDecline,
    required this.onTapProfile,
  });

  final User user;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onTapProfile;

  static const Color _fbBlue = Color(0xFF1877F2);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final displayName =
        (user.fullName != null && user.fullName!.trim().isNotEmpty)
            ? user.fullName!.trim()
            : user.username;
    final initials = displayName.isNotEmpty
        ? displayName.substring(0, 1).toUpperCase()
        : '?';
    final secondaryBtnBg = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.75);

    return InkWell(
      onTap: onTapProfile,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 56x56 Avatar + Friend Request Badge
            SizedBox(
              width: 58,
              height: 58,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: _fbBlue.withValues(alpha: 0.15),
                    backgroundImage:
                        user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                            ? CachedNetworkImageProvider(user.avatarUrl!)
                            : null,
                    child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                        ? Text(
                            initials,
                            style: const TextStyle(
                              color: _fbBlue,
                              fontWeight: FontWeight.w800,
                              fontSize: 19,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    right: -1,
                    bottom: -1,
                    child: Container(
                      width: 26,
                      height: 26,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        shape: BoxShape.circle,
                      ),
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          color: _fbBlue,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_add_alt_1_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.32,
                        color: theme.colorScheme.onSurface,
                      ),
                      children: [
                        TextSpan(
                          text: displayName,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const TextSpan(
                          text: ' sent you a friend request.',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${user.username}',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: FilledButton(
                            onPressed: onAccept,
                            style: FilledButton.styleFrom(
                              backgroundColor:
                                  isDark ? theme.colorScheme.primary : _fbBlue,
                              foregroundColor: isDark
                                  ? theme.colorScheme.onPrimary
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: const Text('Confirm'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: TextButton(
                            onPressed: onDecline,
                            style: TextButton.styleFrom(
                              backgroundColor: secondaryBtnBg,
                              foregroundColor: theme.colorScheme.onSurface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
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
