import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/calls/presentation/views/calls_screen.dart';
import 'package:lotus_connect/features/chatbot/application/providers.dart';
import 'package:lotus_connect/features/chatbot/application/settings_notifier.dart';
import 'package:lotus_connect/features/contacts/application/contacts_notifier.dart';
import 'package:lotus_connect/features/contacts/application/friend_request_notifier.dart';
import 'package:lotus_connect/features/contacts/presentation/widgets/contact_card.dart';
import 'package:lotus_connect/features/contacts/presentation/widgets/request_card.dart';
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
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
                fillColor: Colors.grey.shade100,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
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
                          horizontal: 16,
                          vertical: 8,
                        ),
                        children: [
                          if (_searchQuery.isNotEmpty &&
                              filteredFriends.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 8,
                              ),
                              child: Text(
                                loc.myFriends,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            ...filteredFriends.map(
                              (friend) => RequestCard(user: friend),
                            ),
                            const SizedBox(height: 16),
                          ] else if (_searchQuery.isEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 8,
                              ),
                              child: Text(
                                loc.allFriends,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            ...filteredFriends.map(
                              (friend) => ContactCard(
                                friend: friend,
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
                              ),
                            ),
                          ],
                          if (_searchQuery.isNotEmpty &&
                              globalResults.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 8,
                              ),
                              child: Text(
                                loc.globalSearchAddFriends,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
                                  letterSpacing: 1,
                                ),
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
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: _buildEmptyState(theme, loc),
                            ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalUserItem(ThemeData theme, User user) {
    final loc = AppLocalizations.of(context)!;
    final displayName = user.fullName ?? user.username;
    final initials = displayName.isNotEmpty
        ? displayName.substring(0, 1).toUpperCase()
        : '?';
    final avatarColor =
        Colors.primaries[user.username.hashCode % Colors.primaries.length];
    final currentUserId = ref.watch(settingsProvider).userId;

    Widget trailingWidget;

    if (user.friendshipStatus == 'pending') {
      if (user.friendshipSenderId == currentUserId) {
        trailingWidget = Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Text(
            loc.requested,
            style: TextStyle(
              color: Colors.amber.shade800,
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
              icon: const Icon(Icons.check_circle_outline, color: Colors.green),
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
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              },
              tooltip: loc.accept,
            ),
            IconButton(
              icon: const Icon(Icons.cancel_outlined, color: Colors.red),
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
                    backgroundColor: success ? Colors.green : Colors.red,
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
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
        },
        icon: const Icon(Icons.person_add_alt_1, size: 16),
        label: Text(loc.add, style: const TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      leading: CircleAvatar(
        backgroundColor: avatarColor.withValues(alpha: 0.15),
        child: Text(
          initials,
          style: TextStyle(color: avatarColor, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        displayName,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      subtitle: Text(
        '@${user.username}',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      ),
      trailing: trailingWidget,
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations loc) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            loc.noContactsFound,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? loc.noMatchingResults
                : loc.sendFriendRequestsPrompt,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
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
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 12),
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
                        backgroundColor: Colors.green,
                      ),
                    );
                    _addFriendController.clear();
                  } else {
                    final err = ref.read(contactsProvider).errorMessage;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(err ?? loc.failedToSendRequest),
                        backgroundColor: Colors.red,
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
          loc.unfriendConfirmation.replaceAll('{name}', displayName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(loc.unfriend),
          ),
        ],
      ),
    );

    if ((confirmed ?? false) && mounted) {
      final messenger = ScaffoldMessenger.of(context);
      final success =
          await ref.read(contactsProvider.notifier).deleteFriend(friend.id);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            success ? loc.friendRemoved : loc.failedToRemoveFriend,
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }
}
