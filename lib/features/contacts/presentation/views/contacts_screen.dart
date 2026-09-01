import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/features/contacts/application/contacts_notifier.dart';
import 'package:lotus_connect/features/contacts/application/friend_request_notifier.dart';
import 'package:lotus_connect/features/contacts/presentation/views/friend_screen.dart';
import 'package:lotus_connect/features/contacts/presentation/views/history_screen.dart';
import 'package:lotus_connect/features/contacts/presentation/views/request_friend_screen.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  final _searchController = TextEditingController();
  final _addFriendController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _addFriendController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            loc.contacts,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add_alt_1),
              onPressed: () => _showAddFriendDialog(context),
              tooltip: loc.addFriend,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () =>
                  ref.read(contactsProvider.notifier).loadFriends(),
              tooltip: loc.refreshContacts,
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: loc.friends),
              Tab(text: loc.history),
              Tab(text: loc.pending),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            FriendScreen(),
            HistoryScreen(),
            AllFriendRequestsScreen(),
          ],
        ),
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
}
