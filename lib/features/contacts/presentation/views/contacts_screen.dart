import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/app/theme/app_color.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(friendRequestProvider.notifier).loadFriendRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pendingCount = ref.watch(friendRequestProvider).requests.length;

    final indicatorGradient = LinearGradient(
      colors: [
        AppColor.contactsBannerStart.of(context),
        AppColor.contactsBannerMid.of(context),
        AppColor.contactsBannerEnd.of(context),
      ],
    );

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            loc.contacts,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 22,
              letterSpacing: -0.4,
            ),
          ),
          elevation: 0,
          scrolledUnderElevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add_alt_1_outlined),
              onPressed: () => _showAddFriendDialog(context),
              tooltip: loc.addFriend,
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () {
                ref.read(contactsProvider.notifier).loadFriends();
                ref.read(friendRequestProvider.notifier).loadFriendRequests();
              },
              tooltip: loc.refreshContacts,
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(52),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColor.onMedia.of(context).withValues(alpha: 0.06)
                      : theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    gradient: indicatorGradient,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.contactsSelectedTabBg
                            .of(context)
                            .withValues(alpha: 0.28),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorPadding: const EdgeInsets.all(3),
                  dividerColor: AppColor.transparent.of(context),
                  overlayColor: WidgetStateProperty.all(
                    AppColor.transparent.of(context),
                  ),
                  labelColor: AppColor.contactsTabLabel.of(context),
                  unselectedLabelColor:
                      theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: -0.2,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    letterSpacing: -0.2,
                  ),
                  tabs: [
                    Tab(
                      height: 38,
                      child: Text(loc.friends),
                    ),
                    Tab(
                      height: 38,
                      child: Text(loc.history),
                    ),
                    Tab(
                      height: 38,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(loc.pending),
                          if (pendingCount > 0) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.contactsTabLabel
                                    .of(context)
                                    .withValues(alpha: isDark ? 0.18 : 0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$pendingCount',
                                style: TextStyle(
                                  color: AppColor.contactsTabLabel.of(context),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                style: TextStyle(
                  fontSize: 13,
                  color: AppColor.inkMuted.of(context),
                ),
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
}
