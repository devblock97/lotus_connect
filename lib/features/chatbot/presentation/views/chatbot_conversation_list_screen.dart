import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chat_core/application/chat_core_providers.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/conversation.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';
import 'package:lotus_connect/features/chatbot/application/conversation_list_notifier.dart';
import 'package:lotus_connect/features/chatbot/presentation/views/chatbot_screen.dart';

/// List of AI conversations. Titles are conversation summaries and subtitles
/// are kept up-to-date with the most recent local message.
class ChatbotConversationListScreen extends ConsumerWidget {
  const ChatbotConversationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(conversationListProvider);
    final notifier = ref.read(conversationListProvider.notifier);
    final conversations = state.filteredConversations
        .where((conversation) => !conversation.isUserToUser)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI conversations',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () async {
          final conversation = await notifier.createNewConversation();
          if (conversation != null && context.mounted) {
            _openConversation(context, conversation.id, notifier);
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: notifier.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search AI conversations...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
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
                : conversations.isEmpty
                    ? const _EmptyAiConversations()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: conversations.length,
                        itemBuilder: (context, index) => _AiConversationTile(
                          conversation: conversations[index],
                          onTap: () => _openConversation(
                            context,
                            conversations[index].id,
                            notifier,
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _openConversation(
    BuildContext context,
    String conversationId,
    ConversationListNotifier notifier,
  ) {
    notifier.selectConversation(conversationId);
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ChatbotScreen()),
    );
  }
}

class _AiConversationTile extends ConsumerWidget {
  const _AiConversationTile({required this.conversation, required this.onTap});

  final Conversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final repository = ref.watch(chatCoreRepositoryProvider);

    return StreamBuilder<Result<List<Message>>>(
      stream: repository.watchMessages(conversation.id),
      builder: (context, snapshot) {
        final messages = snapshot.data?.fold<List<Message>>(
          (_) => const [],
          (items) => items,
        );
        final lastMessage =
            messages != null && messages.isNotEmpty ? messages.last : null;
        final subtitle = lastMessage == null
            ? 'Start a conversation with the assistant'
            : lastMessage.content.replaceAll(RegExp(r'\s+'), ' ');
        final time = lastMessage?.timestamp ?? conversation.updatedAt;

        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(
              Icons.psychology_outlined,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          title: Text(
            conversation.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            DateFormat('h:mm a').format(time),
            style: TextStyle(
              fontSize: 11,
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: .65),
            ),
          ),
          onTap: onTap,
        );
      },
    );
  }
}

class _EmptyAiConversations extends StatelessWidget {
  const _EmptyAiConversations();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          'No AI conversations yet.\nTap + to start one.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
