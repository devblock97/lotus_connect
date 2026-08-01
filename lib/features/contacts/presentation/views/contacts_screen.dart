import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/chat/presentation/view/chat_screen.dart';
import 'package:lotus_connect/features/chatbot/application/conversation_list_notifier.dart';
import 'package:lotus_connect/features/chat/application/private_conversation_list_notifier.dart';
import 'package:lotus_connect/features/chatbot/application/providers.dart';
import 'package:lotus_connect/features/chatbot/application/settings_notifier.dart';
import 'package:lotus_connect/features/contacts/application/contacts_notifier.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

/// Premium, high-fidelity screen displaying friends lists and contacts actions.
class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  final _searchController = TextEditingController();
  final _addFriendController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _addFriendController.dispose();
    super.dispose();
  }

  void _showAddFriendDialog(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
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
              decoration: const InputDecoration(
                hintText: 'e.g. johndoe',
                prefixIcon: Icon(Icons.alternate_email),
                border: OutlineInputBorder(),
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
                  .read(contactsProvider.notifier)
                  .sendFriendRequest(username);

              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Friend request sent to @$username'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _addFriendController.clear();
                } else {
                  final err = ref.read(contactsProvider).errorMessage;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(err ?? 'Failed to send request'),
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
    );
  }

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

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.contacts,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: () => _showAddFriendDialog(context),
            tooltip: loc.addFriend,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(contactsProvider.notifier).loadFriends(),
            tooltip: loc.refreshContacts,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(contactsProvider.notifier).loadFriends();
          if (_searchQuery.isNotEmpty) {
            await ref.read(contactsProvider.notifier).searchUsers(_searchQuery);
          }
        },
        child: Column(
          children: [
            // Search Input Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                  ref.read(contactsProvider.notifier).searchUsers(val);
                },
                decoration: InputDecoration(
                  hintText: 'Search friends...',
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
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Friends List Area
            Expanded(
              child: state.isLoading &&
                      state.friends.isEmpty &&
                      state.requests.isEmpty &&
                      state.searchResults.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : (_searchQuery.isEmpty && filteredFriends.isEmpty && state.requests.isEmpty)
                      ? _buildEmptyState(theme)
                      : ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          children: [
                            if (_searchQuery.isEmpty && state.requests.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 8.0),
                                child: Text(
                                  'FRIEND REQUESTS (${state.requests.length})',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                              ...state.requests.take(3).map(
                                  (req) => _buildRequestItem(theme, req)),
                              if (state.requests.length > 3)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const AllFriendRequestsScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(loc.viewMore),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 16),
                            ],
                            if (_searchQuery.isNotEmpty &&
                                filteredFriends.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 8.0),
                                child: Text(
                                  'MY FRIENDS',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                              ...filteredFriends.map(
                                  (friend) => _buildFriendItem(theme, friend)),
                              const SizedBox(height: 16),
                            ] else if (_searchQuery.isEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 8.0),
                                child: Text(
                                  'ALL FRIENDS',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade600,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                              ...filteredFriends.map(
                                  (friend) => _buildFriendItem(theme, friend)),
                            ],
                            if (_searchQuery.isNotEmpty &&
                                globalResults.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 8.0),
                                child: Text(
                                  'GLOBAL SEARCH / ADD FRIENDS',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade600,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                              ...globalResults.map(
                                  (user) => _buildGlobalUserItem(theme, user)),
                            ],
                            if (_searchQuery.isNotEmpty &&
                                filteredFriends.isEmpty &&
                                globalResults.isEmpty)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 40.0),
                                child: _buildEmptyState(theme),
                              ),
                          ],
                        ),
            ),
          ],
        ),
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
            'Requested',
            style: TextStyle(color: Colors.amber.shade800, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        );
      } else {
        trailingWidget = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check_circle_outline, color: Colors.green),
              onPressed: () async {
                final success = await ref.read(contactsProvider.notifier).acceptFriendRequest(user.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Friend request accepted!' : 'Failed to accept request'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              tooltip: loc.accept,
            ),
            IconButton(
              icon: const Icon(Icons.cancel_outlined, color: Colors.red),
              onPressed: () async {
                final success = await ref.read(contactsProvider.notifier).rejectFriendRequest(user.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Friend request rejected!' : 'Failed to reject request'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
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
              .read(contactsProvider.notifier)
              .sendFriendRequest(user.username);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(success
                    ? 'Friend request sent to @${user.username}'
                    : 'Failed to send request'),
                backgroundColor: success ? Colors.green : Colors.red,
              ),
            );
          }
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
      contentPadding:
          const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
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

  Widget _buildFriendItem(ThemeData theme, User friend) {
    final loc = AppLocalizations.of(context)!;
    final displayName = friend.fullName ?? friend.username;
    final initials = displayName.isNotEmpty
        ? displayName.substring(0, 1).toUpperCase()
        : '?';

    // Generates a nice background color based on the hash of the username
    final avatarColor =
        Colors.primaries[friend.username.hashCode % Colors.primaries.length];

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
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
        '@${friend.username}',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Chat Button
          IconButton(
            icon: Icon(Icons.chat_bubble_outline,
                color: theme.colorScheme.primary),
            onPressed: () => _startPrivateChat(friend),
            tooltip: loc.chat,
          ),
          // Voice Call Button
          IconButton(
            icon: const Icon(Icons.phone_outlined, color: Colors.blue),
            onPressed: () => _startCall(friend.id, isVideo: false),
            tooltip: loc.voiceCall,
          ),
          // Video Call Button
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: Colors.green),
            onPressed: () => _startCall(friend.id, isVideo: true),
            tooltip: loc.videoCall,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded,
              size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No Contacts found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'No matching results for your query.'
                : 'Send friend requests to start chatting and calling.',
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showAddFriendDialog(context),
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Add Friend'),
          ),
        ],
      ),
    );
  }

  Future<void> _startPrivateChat(User friend) async {
    final currentContext = context;
    final conv =
        await ref.read(privateConversationListProvider.notifier).createNewPrivateChat(
              friendId: friend.id,
              title: friend.fullName ?? friend.username,
            );

    if (conv != null && currentContext.mounted) {
      Navigator.of(currentContext).push(
        MaterialPageRoute<void>(
          builder: (_) => ChatScreen(conversationId: conv.id),
        ),
      );
    }
  }

  void _startCall(String friendId, {required bool isVideo}) {
    ref.read(callRequestProvider.notifier).state =
        CallRequest(recipientId: friendId, isVideo: isVideo);
    ref.read(shellIndexProvider.notifier).state = 2; // Switch to Calls tab
    context.pop(); // Pop back to main shell
  }

  Widget _buildRequestItem(ThemeData theme, User requestUser) {
    final loc = AppLocalizations.of(context)!;
    final displayName = requestUser.fullName ?? requestUser.username;
    final initials = displayName.isNotEmpty ? displayName.substring(0, 1).toUpperCase() : '?';
    final avatarColor = Colors.primaries[requestUser.username.hashCode % Colors.primaries.length];

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
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
        '@${requestUser.username}',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.redAccent),
            onPressed: () async {
              final success = await ref.read(contactsProvider.notifier).rejectFriendRequest(requestUser.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Declined friend request from @${requestUser.username}' : 'Failed to reject request'),
                    backgroundColor: success ? Colors.orange : Colors.red,
                  ),
                );
              }
            },
            tooltip: loc.decline,
          ),
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: () async {
              final success = await ref.read(contactsProvider.notifier).acceptFriendRequest(requestUser.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Accepted friend request from @${requestUser.username}' : 'Failed to accept request'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            tooltip: loc.accept,
          ),
        ],
      ),
    );
  }
}

class AllFriendRequestsScreen extends ConsumerWidget {
  const AllFriendRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final state = ref.watch(contactsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.friendRequests, style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(contactsProvider.notifier).loadFriends(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          children: [
            if (state.requests.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                child: Text(
                  'PENDING REQUESTS (${state.requests.length})',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              ...state.requests.map((req) => _buildRequestItem(context, ref, req)),
              const SizedBox(height: 24),
            ] else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32.0),
                child: Center(
                  child: Text('No pending requests', style: TextStyle(color: Colors.grey)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              child: Text(
                'MY FRIENDS (${state.friends.length})',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            if (state.friends.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32.0),
                child: Center(
                  child: Text('No friends yet', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ...state.friends.map((friend) => _buildFriendItem(context, ref, theme, friend)),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestItem(BuildContext context, WidgetRef ref, User requestUser) {
    final loc = AppLocalizations.of(context)!;
    final displayName = requestUser.fullName ?? requestUser.username;
    final initials = displayName.isNotEmpty ? displayName.substring(0, 1).toUpperCase() : '?';
    final avatarColor = Colors.primaries[requestUser.username.hashCode % Colors.primaries.length];

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
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
        '@${requestUser.username}',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.redAccent),
            onPressed: () async {
              final success = await ref.read(contactsProvider.notifier).rejectFriendRequest(requestUser.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Declined friend request from @${requestUser.username}' : 'Failed to reject request'),
                    backgroundColor: success ? Colors.orange : Colors.red,
                  ),
                );
              }
            },
            tooltip: loc.decline,
          ),
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: () async {
              final success = await ref.read(contactsProvider.notifier).acceptFriendRequest(requestUser.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Accepted friend request from @${requestUser.username}' : 'Failed to accept request'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            tooltip: loc.accept,
          ),
        ],
      ),
    );
  }

  Widget _buildFriendItem(BuildContext context, WidgetRef ref, ThemeData theme, User friend) {
    final loc = AppLocalizations.of(context)!;
    final displayName = friend.fullName ?? friend.username;
    final initials = displayName.isNotEmpty ? displayName.substring(0, 1).toUpperCase() : '?';
    final avatarColor = Colors.primaries[friend.username.hashCode % Colors.primaries.length];

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
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
        '@${friend.username}',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.chat_bubble_outline, color: theme.colorScheme.primary),
            onPressed: () => _startPrivateChat(context, ref, friend),
            tooltip: loc.chat,
          ),
          IconButton(
            icon: const Icon(Icons.phone_outlined, color: Colors.blue),
            onPressed: () => _startCall(context, ref, friend.id, isVideo: false),
            tooltip: loc.voiceCall,
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: Colors.green),
            onPressed: () => _startCall(context, ref, friend.id, isVideo: true),
            tooltip: loc.videoCall,
          ),
        ],
      ),
    );
  }

  Future<void> _startPrivateChat(BuildContext context, WidgetRef ref, User friend) async {
    final currentContext = context;
    final conv = await ref.read(privateConversationListProvider.notifier).createNewPrivateChat(
          friendId: friend.id,
          title: friend.fullName ?? friend.username,
        );

    if (conv != null && currentContext.mounted) {
      Navigator.of(currentContext).push(
        MaterialPageRoute<void>(
          builder: (_) => ChatScreen(conversationId: conv.id),
        ),
      );
    }
  }

  void _startCall(BuildContext context, WidgetRef ref, String friendId, {required bool isVideo}) {
    ref.read(callRequestProvider.notifier).state = CallRequest(recipientId: friendId, isVideo: isVideo);
    ref.read(shellIndexProvider.notifier).state = 2; // Switch to Calls tab
    Navigator.of(context).popUntil((route) => route.isFirst); // Pop back to main shell
  }
}
