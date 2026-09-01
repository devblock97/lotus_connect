import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/features/contacts/application/friend_request_notifier.dart';
import 'package:lotus_connect/features/contacts/presentation/widgets/request_card.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

class AllFriendRequestsScreen extends ConsumerStatefulWidget {
  const AllFriendRequestsScreen({super.key});

  @override
  ConsumerState<AllFriendRequestsScreen> createState() =>
      _AllFriendRequestsScreenState();
}

class _AllFriendRequestsScreenState
    extends ConsumerState<AllFriendRequestsScreen> {
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
    final state = ref.watch(friendRequestProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.friendRequests,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(friendRequestProvider.notifier).loadFriendRequests(),
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.requests.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 64),
                      child: Center(
                        child: Text(
                          loc.noPendingRequests,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: state.requests.length,
                    itemBuilder: (context, index) {
                      return RequestCard(user: state.requests[index]);
                    },
                  ),
      ),
    );
  }
}
