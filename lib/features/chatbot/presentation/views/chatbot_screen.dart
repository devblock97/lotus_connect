import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/features/chatbot/application/active_conversation_notifier.dart';
import 'package:lotus_connect/features/chatbot/application/conversation_list_notifier.dart';
import 'package:lotus_connect/features/chatbot/application/providers.dart';
import 'package:lotus_connect/features/chatbot/application/settings_notifier.dart';
import 'package:lotus_connect/features/chatbot/domain/entities/conversation.dart';
import 'package:lotus_connect/features/chatbot/domain/entities/message.dart';
import 'package:lotus_connect/features/chatbot/presentation/widgets/chat_input_field.dart';
import 'package:lotus_connect/features/chatbot/presentation/widgets/message_bubble.dart';
import 'package:lotus_connect/features/chatbot/presentation/widgets/typing_indicator.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

/// Main Chatbot Screen view matching image1 design.
class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _formatModelDisplayName(String id) {
    switch (id) {
      case 'gemini-1.5-flash':
        return 'Gemini 1.5 Flash';
      case 'gemini-1.5-flash-8b':
        return 'Gemini 1.5 Flash 8B';
      case 'gemini-1.5-pro':
        return 'Gemini 1.5 Pro';
      case 'gemini-2.0-flash':
        return 'Gemini 2.0 Flash';
      case 'gemini-2.0-flash-lite':
        return 'Gemini 2.0 Flash Lite';
      case 'gemini-2.0-pro-exp-02-05':
        return 'Gemini 2.0 Pro Exp';
      case 'gemini-2.0-flash-thinking-exp-01-21':
        return 'Gemini 2.0 Thinking';
      case 'gpt-4o':
        return 'GPT-4o';
      case 'claude-3-5-sonnet':
        return 'Claude 3.5 Sonnet';
      default:
        return id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final convListState = ref.watch(conversationListProvider);
    final activeState = ref.watch(activeConversationProvider);
    final activeNotifier = ref.read(activeConversationProvider.notifier);
    final settings = ref.watch(settingsProvider);
    final aiProvider = ref.watch(activeAiProvider);
    final availableModels = aiProvider.availableModels;
    final loc = AppLocalizations.of(context)!;

    // Auto-scroll when new content streams
    ref.listen<ActiveConversationState>(activeConversationProvider, (_, next) {
      if (next.isGenerating || next.messages.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    });

    final aiConversations = convListState.conversations
        .where((conversation) => !conversation.isUserToUser)
        .toList();
    final currentConversation = aiConversations.firstWhere(
      (c) => c.id == activeState.conversationId,
      orElse: () => aiConversations.isNotEmpty
          ? aiConversations.first
          : Conversation(
              id: '',
              title: 'Neural AI Chat',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
    );

    if (activeState.conversationId != currentConversation.id &&
        currentConversation.id.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(conversationListProvider.notifier)
            .selectConversation(currentConversation.id);
      });
    }

    final selectedModel = availableModels.contains(settings.activeAiModel)
        ? settings.activeAiModel
        : availableModels.first;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentConversation.title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${loc.activeSession} (${aiProvider.displayName.split(' ').first})',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: DropdownButton<String>(
                value: selectedModel,
                underline: const SizedBox(),
                isDense: true,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyMedium?.color,
                ),
                items: availableModels.map((modelId) {
                  return DropdownMenuItem(
                    value: modelId,
                    child: Text(_formatModelDisplayName(modelId)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    ref.read(settingsProvider.notifier).setAiModel(val);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
      body: Column(
        children: [
          // Banner Notice
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //   color: theme.colorScheme.surfaceContainerHighest
          //       .withValues(alpha: 0.4),
          //   child: Row(
          //     children: [
          //       const Icon(Icons.push_pin_outlined, size: 14),
          //       const SizedBox(width: 8),
          //       Expanded(
          //         child: Text(
          //           loc.projectGoals,
          //           style: const TextStyle(fontSize: 12),
          //           overflow: TextOverflow.ellipsis,
          //         ),
          //       ),
          //       const Icon(Icons.close, size: 14),
          //     ],
          //   ),
          // ),

          // Message Feed
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                // Date Badge Pill
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      loc.today,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Render Messages
                ...activeState.messages.map(
                  (msg) => MessageBubble(
                    message: msg,
                    onRegenerate: activeNotifier.regenerateResponse,
                    onRetry: () => activeNotifier.retryMessage(msg),
                  ),
                ),

                // Render streaming chunk
                if (activeState.isGenerating &&
                    activeState.streamingContent.isNotEmpty)
                  MessageBubble(
                    message: Message(
                      id: 'streaming',
                      conversationId: activeState.conversationId ?? '',
                      role: MessageRole.assistant,
                      content: activeState.streamingContent,
                      timestamp: DateTime.now(),
                    ),
                  ),

                // Render animated typing indicator if waiting for first token
                if (activeState.isGenerating &&
                    activeState.streamingContent.isEmpty)
                  const TypingIndicator(),
              ],
            ),
          ),

          // Bottom Input Field
          ChatInputField(
            isGenerating: activeState.isGenerating,
            onSend: activeNotifier.sendMessage,
            onStop: activeNotifier.stopGeneration,
            initialText: activeState.draftInput,
            onChanged: activeNotifier.updateDraft,
            hintText: loc.messageInputHint,
          ),
        ],
      ),
    );
  }
}
