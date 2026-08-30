import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/chat/application/private_conversation_list_notifier.dart';
import 'package:lotus_connect/features/chat/presentation/views/chat_screen.dart';
import 'package:lotus_connect/features/chatbot/application/providers.dart';
import 'package:lotus_connect/features/contacts/application/contacts_notifier.dart';
import 'package:lotus_connect/features/contacts/presentation/widgets/request_card.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

class AllFriendRequestsScreen extends ConsumerWidget {
  const AllFriendRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final state = ref.watch(contactsProvider);

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
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            if (state.requests.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Text(
                  'PENDING REQUESTS (${state.requests.length})',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    letterSpacing: 1,
                  ),
                ),
              ),
              ...state.requests.map((user) => RequestCard(user: user)),
              const SizedBox(height: 24),
            ] else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'No pending requests',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
          ],
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
