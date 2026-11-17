import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/app/theme/app_color.dart';
import 'package:lotus_connect/app/theme/app_size.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/calls/data/models/call_request.dart';
import 'package:lotus_connect/features/calls/presentation/views/calls_screen.dart';
import 'package:lotus_connect/features/chat/application/conversation_list_notifier.dart';
import 'package:lotus_connect/features/chat/presentation/views/chat_screen.dart';
import 'package:lotus_connect/features/contacts/application/contacts_notifier.dart';
import 'package:lotus_connect/features/contacts/application/friend_request_notifier.dart';
import 'package:lotus_connect/features/contacts/presentation/widgets/contact_card.dart';
import 'package:lotus_connect/features/profile/presentation/views/profile_screen.dart';
import 'package:lotus_connect/features/settings/application/settings_notifier.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

class FriendScreen extends ConsumerStatefulWidget {
  const FriendScreen({super.key});

  @override
  ConsumerState<FriendScreen> createState() => _FriendScreenState();
}

class _FriendScreenState extends ConsumerState<FriendScreen> {
  final _searchController = TextEditingController();
  final _addFriendController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final state = ref.watch(contactsProvider);
    // Filter friends list based on search query
    final filteredFriends = state.friends.where((friend) {
      final name = (friend.fullName ?? '').toLowerCase();
      final username = friend.username.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || username.contains(query);
    }).toList();

    // Filter global search results to exclude existing friends
    final globalResults = state.searchResults.where((user) {
      return !state.friends.any((friend) => friend.id == user.id);
    }).toList();

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(contactsProvider.notifier).loadFriends();
        if (_searchQuery.isNotEmpty) {
          await ref.read(contactsProvider.notifier).searchUsers(_searchQuery);
        }
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSize.screenPadding,
              AppSize.md,
              AppSize.screenPadding,
              AppSize.chipVertical,
            ),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColor.black.of(context).withValues(
                          alpha:
                              theme.brightness == Brightness.dark ? 0.2 : 0.03,
                        ),
                    blurRadius: AppSize.sm,
                    offset: const Offset(0, AppSize.xxs),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                  ref.read(contactsProvider.notifier).searchUsers(val);
                },
                decoration: InputDecoration(
                  hintText: loc.searchFriends,
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.7),
                    size: AppSize.iconMd,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear_rounded,
                            size: AppSize.iconSm,
                          ),
                          tooltip: loc.clearSearch,
                          onPressed: () {
                            _searchController.clear();
                            ref.read(contactsProvider.notifier).clearSearch();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: theme.brightness == Brightness.dark
                      ? theme.colorScheme.surfaceContainer
                      : AppColor.surfaceCard.of(context),
                  contentPadding: AppPadding.input,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.input,
                    borderSide: AppBorder.thin(
                      theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.input,
                    borderSide: AppBorder.thin(
                      theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.input,
                    borderSide: AppBorder.medium(theme.colorScheme.primary),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: state.isLoading &&
                    state.friends.isEmpty &&
                    state.searchResults.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : (_searchQuery.isEmpty && filteredFriends.isEmpty)
                    ? _buildEmptyState(theme, loc)
                    : ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSize.screenPadding,
                          vertical: AppSize.sm,
                        ),
                        children: [
                          if (_searchQuery.isNotEmpty &&
                              filteredFriends.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.only(
                                left: AppSize.xs,
                                right: AppSize.xs,
                                top: AppSize.sm,
                                bottom: AppSize.xs,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    loc.myFriends.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: theme.colorScheme.primary,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  AppGap.hSm,
                                  Container(
                                    padding: AppPadding.badge,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.12),
                                      borderRadius: AppRadius.md,
                                    ),
                                    child: Text(
                                      '${filteredFriends.length}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...filteredFriends.map(_buildFriendCard),
                            AppGap.vLg,
                          ] else if (_searchQuery.isEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.only(
                                left: AppSize.xs,
                                right: AppSize.xs,
                                top: AppSize.sm,
                                bottom: AppSize.xs,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    loc.allFriends.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: theme.colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.8),
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  AppGap.hSm,
                                  Container(
                                    padding: AppPadding.badge,
                                    decoration: BoxDecoration(
                                      color: theme
                                          .colorScheme.surfaceContainerHighest
                                          .withValues(alpha: 0.6),
                                      borderRadius: AppRadius.md,
                                    ),
                                    child: Text(
                                      '${filteredFriends.length}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...filteredFriends.map(_buildFriendCard),
                          ],
                          if (_searchQuery.isNotEmpty &&
                              globalResults.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.only(
                                left: AppSize.xs,
                                right: AppSize.xs,
                                top: AppSize.md,
                                bottom: AppSize.xs,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    loc.globalSearchAddFriends.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: theme.colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.8),
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  AppGap.hSm,
                                  Container(
                                    padding: AppPadding.badge,
                                    decoration: BoxDecoration(
                                      color: theme
                                          .colorScheme.surfaceContainerHighest
                                          .withValues(alpha: 0.6),
                                      borderRadius: AppRadius.md,
                                    ),
                                    child: Text(
                                      '${globalResults.length}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...globalResults.map(
                              (user) => _buildGlobalUserItem(theme, user),
                            ),
                          ],
                          if (_searchQuery.isNotEmpty &&
                              filteredFriends.isEmpty &&
                              globalResults.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSize.huge,
                              ),
                              child: _buildEmptyState(theme, loc),
                            ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendCard(User friend) {
    return ContactCard(
      friend: friend,
      onProfileTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => ProfileScreen(
              userId: friend.id,
              initialUsername: friend.username,
            ),
          ),
        );
      },
      startChat: () async {
        final conversation = await ref
            .read(
              privateConversationListProvider.notifier,
            )
            .createNewPrivateChat(
              friendId: friend.id,
              title: friend.fullName ?? friend.username,
            );
        if (conversation != null) {
          if (!mounted) return;
          await Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => ChatScreen(
                conversation: conversation,
              ),
            ),
          );
        }
      },
      voiceCall: () {
        _startCall(
          recipientId: friend.id,
          isVideo: false,
        );
      },
      videoCall: () {
        _startCall(
          recipientId: friend.id,
          isVideo: true,
        );
      },
      onDelete: () {
        _showDeleteFriendDialog(context, friend);
      },
    );
  }

  Widget _buildGlobalUserItem(ThemeData theme, User user) {
    final loc = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final displayName = user.fullName ?? user.username;
    final initials = displayName.isNotEmpty
        ? displayName.substring(0, 1).toUpperCase()
        : '?';
    final avatarColor = AppColor
        .avatarPalette[user.username.hashCode % AppColor.avatarPalette.length]
        .of(context);
    final currentUserId = ref.watch(settingsNotifierProvider).settings.userId;

    final cardColor = isDark
        ? theme.colorScheme.surfaceContainer
        : AppColor.surfaceCard.of(context);
    final borderColor = isDark
        ? theme.colorScheme.outlineVariant.withValues(alpha: 0.3)
        : theme.colorScheme.outlineVariant.withValues(alpha: 0.45);

    Widget trailingWidget;

    if (user.friendshipStatus == 'pending') {
      if (user.friendshipSenderId == currentUserId) {
        trailingWidget = Container(
          padding: AppPadding.chip,
          decoration: BoxDecoration(
            color: AppColor.warningSoft.of(context),
            borderRadius: AppRadius.chip,
            border: AppBorder.all(AppColor.warningBorder.of(context)),
          ),
          child: Text(
            loc.requested,
            style: TextStyle(
              color: AppColor.amberStrong.of(context),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      } else {
        trailingWidget = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.check_circle_outline,
                color: AppColor.successGreen.of(context),
              ),
              onPressed: () async {
                final success = await ref
                    .read(friendRequestProvider.notifier)
                    .acceptFriendRequest(user.id);
                if (!mounted) return;
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
              },
              tooltip: loc.accept,
            ),
            IconButton(
              icon: Icon(
                Icons.cancel_outlined,
                color: AppColor.danger.of(context),
              ),
              onPressed: () async {
                final success = await ref
                    .read(friendRequestProvider.notifier)
                    .rejectFriendRequest(user.id);
                if (!mounted) return;
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
              },
              tooltip: loc.reject,
            ),
          ],
        );
      }
    } else {
      trailingWidget = ElevatedButton.icon(
        onPressed: () async {
          final success = await ref
              .read(friendRequestProvider.notifier)
              .sendFriendRequest(user.username);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? loc.friendRequestSentTo(user.username)
                    : loc.failedToSendRequest,
              ),
              backgroundColor: success
                  ? AppColor.success.of(context)
                  : AppColor.danger.of(context),
            ),
          );
        },
        icon: const Icon(Icons.person_add_alt_1, size: AppSize.iconXs),
        label: Text(loc.add, style: const TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          padding: AppPadding.buttonCompact,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: AppSize.elevationNone,
          shape: AppBorder.rounded(radius: AppSize.radiusChip),
        ),
      );
    }

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
                .withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: AppSize.sm,
            offset: const Offset(0, AppSize.xxs),
          ),
        ],
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => ProfileScreen(
                userId: user.id,
                initialUsername: user.username,
              ),
            ),
          );
        },
        contentPadding: const EdgeInsets.symmetric(
          vertical: AppSize.xs,
          horizontal: AppSize.md,
        ),
        leading: CircleAvatar(
          radius: AppSize.avatarMd / 2,
          backgroundColor: avatarColor.withValues(alpha: 0.15),
          child: Text(
            initials,
            style: TextStyle(color: avatarColor, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          displayName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(
          '@${user.username}',
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
            fontSize: 13,
          ),
        ),
        trailing: trailingWidget,
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations loc) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: AppSize.iconHero,
            color: AppColor.inkSubtle.of(context),
          ),
          AppGap.vLg,
          Text(
            loc.noContactsFound,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          AppGap.vSm,
          Text(
            _searchQuery.isNotEmpty
                ? loc.noMatchingResults
                : loc.sendFriendRequestsPrompt,
            style: TextStyle(color: AppColor.inkMuted.of(context)),
            textAlign: TextAlign.center,
          ),
          AppGap.vLg,
          ElevatedButton.icon(
            onPressed: () => _showAddFriendDialog(context),
            icon: const Icon(Icons.person_add_alt_1),
            label: Text(loc.addFriend),
          ),
        ],
      ),
    );
  }

  void _startCall({required String recipientId, required bool isVideo}) {
    final callRequest = CallRequest(recipientId: recipientId, isVideo: isVideo);
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CallsScreen(callRequest: callRequest),
      ),
    );
  }

  Future<void> _showAddFriendDialog(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    unawaited(
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(loc.addFriend),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.enterUsernameToSendRequest,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColor.inkMuted.of(context),
                ),
              ),
              AppGap.vMd,
              TextField(
                controller: _addFriendController,
                decoration: InputDecoration(
                  hintText: loc.egUsernameHint,
                  prefixIcon: const Icon(Icons.alternate_email),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(loc.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final username = _addFriendController.text.trim();
                if (username.isEmpty) return;

                Navigator.pop(context);
                final success = await ref
                    .read(friendRequestProvider.notifier)
                    .sendFriendRequest(username);

                if (context.mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(loc.friendRequestSentTo(username)),
                        backgroundColor: AppColor.success.of(context),
                      ),
                    );
                    _addFriendController.clear();
                  } else {
                    final err = ref.read(friendRequestProvider).message ??
                        ref.read(contactsProvider).errorMessage;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(err ?? loc.failedToSendRequest),
                        backgroundColor: AppColor.danger.of(context),
                      ),
                    );
                  }
                }
              },
              child: Text(loc.sendRequest),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteFriendDialog(
    BuildContext context,
    User friend,
  ) async {
    final loc = AppLocalizations.of(context)!;
    final displayName = friend.fullName ?? friend.username;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.unfriend),
        content: Text(
          loc.unfriendConfirmation(displayName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.danger.of(context),
              foregroundColor: AppColor.onMedia.of(context),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(loc.unfriend),
          ),
        ],
      ),
    );

    if ((confirmed ?? false) && mounted) {
      final messenger = ScaffoldMessenger.of(this.context);
      final success =
          await ref.read(contactsProvider.notifier).deleteFriend(friend.id);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            success ? loc.friendRemoved : loc.failedToRemoveFriend,
          ),
          backgroundColor: success
              ? AppColor.success.of(this.context)
              : AppColor.danger.of(this.context),
        ),
      );
    }
  }
}
