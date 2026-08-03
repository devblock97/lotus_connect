import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lotus_connect/features/chat/presentation/views/chat_screen.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/chat/application/private_conversation_list_notifier.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/conversation.dart';
import 'package:lotus_connect/features/contacts/application/contacts_notifier.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

/// Conversation history list view drawer / tab matching image2 mock.
class ConversationListView extends ConsumerWidget {
  const ConversationListView({
    this.onSelectConversation,
    super.key,
  });

  final VoidCallback? onSelectConversation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final state = ref.watch(privateConversationListProvider);
    final notifier = ref.read(privateConversationListProvider.notifier);
    final conversations = state.filteredConversations;
    final pinnedConversations =
        conversations.where((conversation) => conversation.isPinned).toList();
    final unpinnedConversations =
        conversations.where((conversation) => !conversation.isPinned).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.tabChats,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.contacts_outlined),
            onPressed: () => context.push('/contacts'),
            tooltip: loc.contactsAndFriends,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) {
              return SafeArea(
                child: Wrap(
                  children: [
                    ListTile(
                      leading:
                          const Icon(Icons.person_outline, color: Colors.green),
                      title: Text(loc.startChatWithUserUuid),
                      onTap: () {
                        Navigator.pop(context);
                        _showStartPrivateChatDialog(context, ref, notifier);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.contacts_outlined,
                          color: Colors.amber),
                      title: Text(loc.viewContactsAndFriends),
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/contacts');
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Search Input Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: notifier.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      if (pinnedConversations.isNotEmpty) ...[
                        _buildSectionHeader(context, 'PINNED'),
                        ...pinnedConversations.map(
                          (c) => _buildConversationTile(
                            context,
                            ref,
                            c,
                            state.selectedConversationId == c.id,
                          ),
                        ),
                      ],
                      if (unpinnedConversations.isNotEmpty) ...[
                        if (pinnedConversations.isNotEmpty)
                          _buildSectionHeader(context, 'RECENT'),
                        ...unpinnedConversations.map(
                          (c) => _buildConversationTile(
                            context,
                            ref,
                            c,
                            state.selectedConversationId == c.id,
                          ),
                        ),
                      ],
                      if (conversations.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: Text(
                              'No private chats found.\nTap + to start a chat!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: theme.dividerColor.withValues(alpha: 0.2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: theme.dividerColor.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(
    BuildContext context,
    WidgetRef ref,
    Conversation conversation,
    bool isSelected,
  ) {
    final theme = Theme.of(context);
    final notifier = ref.read(privateConversationListProvider.notifier);
    final timeStr = DateFormat('h:mm a').format(conversation.updatedAt);
    final displayTitle = _displayTitle(
      conversation,
      ref.watch(contactsProvider).friends,
    );

    return Dismissible(
      key: Key(conversation.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        notifier.deleteConversation(conversation.id);
      },
      child: ListTile(
        selected: isSelected,
        selectedTileColor:
            theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          child: Text(
            displayTitle.isNotEmpty ? displayTitle[0].toUpperCase() : 'C',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                displayTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (conversation.isPinned)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.push_pin, size: 14, color: Colors.amber),
              ),
          ],
        ),
        subtitle: Text(
          conversation.draftMessage?.isNotEmpty == true
              ? 'Draft: ${conversation.draftMessage}'
              : 'Tap to resume conversation...',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: conversation.draftMessage?.isNotEmpty == true
                ? Colors.redAccent
                : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
          ),
        ),
        trailing: Text(
          timeStr,
          style: TextStyle(
            fontSize: 11,
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
          ),
        ),
        onTap: () {
          notifier.selectConversation(conversation.id);
          if (conversation.isUserToUser) {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => ChatScreen(conversationId: conversation.id),
              ),
            );
          } else {
            onSelectConversation?.call();
          }
        },
      ),
    );
  }

  String _displayTitle(Conversation conversation, List<User> friends) {
    if (!conversation.isUserToUser) return conversation.title;

    for (final friend in friends) {
      if (friend.id == conversation.peerId) {
        final fullName = friend.fullName;
        return fullName != null && fullName.trim().isNotEmpty
            ? fullName
            : friend.username;
      }
    }
    return conversation.title;
  }

  void _showStartPrivateChatDialog(
    BuildContext context,
    WidgetRef ref,
    PrivateConversationListNotifier notifier,
  ) {
    final loc = AppLocalizations.of(context)!;
    final friendIdController = TextEditingController();
    final titleController = TextEditingController();
    final screenContext = context;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('New User-to-User Chat'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: friendIdController,
                decoration: const InputDecoration(
                  labelText: 'Recipient User UUID',
                  hintText: 'e.g. friend-uuid-v7',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Conversation Title',
                  hintText: 'e.g. Secret Chat',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(loc.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final friendId = friendIdController.text.trim();
                final title = titleController.text.trim();
                if (friendId.isEmpty || title.isEmpty) return;

                Navigator.pop(dialogContext);
                final conv = await notifier.createNewPrivateChat(
                  friendId: friendId,
                  title: title,
                );
                if (conv != null && screenContext.mounted) {
                  Navigator.of(screenContext).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ChatScreen(conversationId: conv.id),
                    ),
                  );
                } else {
                  final err = ref.read(privateConversationListProvider).errorMessage;
                  if (screenContext.mounted) {
                    ScaffoldMessenger.of(screenContext).showSnackBar(
                      SnackBar(
                          content:
                              Text(err ?? 'Failed to start chat with user')),
                    );
                  }
                }
              },
              child: const Text('Start'),
            ),
          ],
        );
      },
    );
  }
}
