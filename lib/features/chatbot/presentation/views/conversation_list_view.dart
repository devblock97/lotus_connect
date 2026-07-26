import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lotus_connect/features/chatbot/application/conversation_list_notifier.dart';
import 'package:lotus_connect/features/chatbot/domain/entities/conversation.dart';

/// Conversation history list view drawer / tab matching image2 mock.
class ConversationListView extends ConsumerWidget {
  const ConversationListView({
    this.onSelectConversation,
    super.key,
  });

  final VoidCallback? onSelectConversation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(conversationListProvider);
    final notifier = ref.read(conversationListProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chats',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              child: const Icon(Icons.person, size: 18),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final conv = await notifier.createNewConversation();
          if (conv != null) {
            onSelectConversation?.call();
          }
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
                      if (state.pinnedConversations.isNotEmpty) ...[
                        _buildSectionHeader(context, 'PINNED'),
                        ...state.pinnedConversations.map(
                          (c) => _buildConversationTile(
                            context,
                            ref,
                            c,
                            state.selectedConversationId == c.id,
                          ),
                        ),
                      ],
                      if (state.unpinnedConversations.isNotEmpty) ...[
                        if (state.pinnedConversations.isNotEmpty)
                          _buildSectionHeader(context, 'RECENT'),
                        ...state.unpinnedConversations.map(
                          (c) => _buildConversationTile(
                            context,
                            ref,
                            c,
                            state.selectedConversationId == c.id,
                          ),
                        ),
                      ],
                      if (state.conversations.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: Text(
                              'No conversations found.\nTap + to start a new chat!',
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
    final notifier = ref.read(conversationListProvider.notifier);
    final timeStr = DateFormat('h:mm a').format(conversation.updatedAt);

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
            conversation.title.isNotEmpty
                ? conversation.title[0].toUpperCase()
                : 'C',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                conversation.title,
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
          onSelectConversation?.call();
        },
      ),
    );
  }
}
