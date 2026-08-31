import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/chat/application/private_conversation_list_notifier.dart';
import 'package:lotus_connect/features/chat/presentation/views/chat_screen.dart';
import 'package:lotus_connect/features/chatbot/application/providers.dart';
import 'package:lotus_connect/features/contacts/application/contacts_notifier.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
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
        onRefresh: () => ref.read(contactsProvider.notifier).loadFriends(),
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: state.requests.length,
                itemBuilder: (context, index) {
                  final requesters = state.requests;
                  if (requesters.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          'No pending requests',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  return RequestCard(user: requesters[index]);
                },
              ),
      ),
    );
  }

  Future<void> _startPrivateChat(
    BuildContext context,
    WidgetRef ref,
    User friend,
  ) async {
    final currentContext = context;
    final conv = await ref
        .read(privateConversationListProvider.notifier)
        .createNewPrivateChat(
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

  void _startCall(
    BuildContext context,
    WidgetRef ref,
    String friendId, {
    required bool isVideo,
  }) {
    ref.read(callRequestProvider.notifier).state =
        CallRequest(recipientId: friendId, isVideo: isVideo);
    ref.read(shellIndexProvider.notifier).state = 2; // Switch to Calls tab
    Navigator.of(context)
        .popUntil((route) => route.isFirst); // Pop back to main shell
  }
}
