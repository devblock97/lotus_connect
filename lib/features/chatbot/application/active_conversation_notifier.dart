import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/features/chatbot/application/conversation_list_notifier.dart';
import 'package:lotus_connect/features/chatbot/application/providers.dart';
import 'package:lotus_connect/features/chatbot/application/settings_notifier.dart';
import 'package:lotus_connect/features/chatbot/domain/entities/message.dart';
import 'package:lotus_connect/features/chatbot/domain/usecases/save_draft_usecase.dart';
import 'package:lotus_connect/features/chatbot/domain/usecases/stream_ai_response_usecase.dart';

/// UI state for active conversation chat window.
class ActiveConversationState {
  const ActiveConversationState({
    this.conversationId,
    this.messages = const [],
    this.isGenerating = false,
    this.streamingContent = '',
    this.draftInput = '',
    this.errorMessage,
  });

  final String? conversationId;
  final List<Message> messages;
  final bool isGenerating;
  final String streamingContent;
  final String draftInput;
  final String? errorMessage;

  ActiveConversationState copyWith({
    String? conversationId,
    List<Message>? messages,
    bool? isGenerating,
    String? streamingContent,
    String? draftInput,
    String? errorMessage,
  }) {
    return ActiveConversationState(
      conversationId: conversationId ?? this.conversationId,
      messages: messages ?? this.messages,
      isGenerating: isGenerating ?? this.isGenerating,
      streamingContent: streamingContent ?? this.streamingContent,
      draftInput: draftInput ?? this.draftInput,
      errorMessage: errorMessage,
    );
  }
}

/// Notifier managing active conversation chat messages & streaming state.
class ActiveConversationNotifier
    extends StateNotifier<ActiveConversationState> {
  ActiveConversationNotifier(this._ref) : super(const ActiveConversationState()) {
    _init();
  }

  final Ref _ref;
  StreamSubscription<dynamic>? _messageSubscription;
  StreamSubscription<dynamic>? _aiStreamSubscription;

  void _init() {
    // Initial check if a conversation is already selected
    final currentSelectedId =
        _ref.read(conversationListProvider).selectedConversationId;
    if (currentSelectedId != null) {
      _subscribeToConversation(currentSelectedId);
    }

    // Listen for future changes in selected conversation
    _ref.listen<ConversationListState>(conversationListProvider, (prev, next) {
      final selectedId = next.selectedConversationId;
      if (selectedId != state.conversationId) {
        _subscribeToConversation(selectedId);
      }
    });
  }

  void _subscribeToConversation(String? conversationId) {
    _messageSubscription?.cancel();
    _aiStreamSubscription?.cancel();

    state = ActiveConversationState(conversationId: conversationId);

    if (conversationId != null) {
      final repository = _ref.read(chatbotRepositoryProvider);
      _messageSubscription =
          repository.watchMessages(conversationId).listen((result) {
        result.fold(
          (failure) => state = state.copyWith(errorMessage: failure.message),
          (messages) {
            // Keep local unsaved messages if streaming
            if (state.isGenerating && state.messages.isNotEmpty) {
              final newMessages = List<Message>.from(messages);
              for (final m in state.messages) {
                if (!newMessages.any((x) => x.id == m.id)) {
                  newMessages.add(m);
                }
              }
              state = state.copyWith(messages: newMessages);
            } else {
              state = state.copyWith(messages: messages);
            }
          },
        );
      });
    }
  }

  /// Sends user prompt and streams AI response.
  Future<void> sendMessage(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    var convId = state.conversationId;

    // Auto-create a conversation if none is selected
    if (convId == null) {
      final title = trimmedText.length > 25
          ? '${trimmedText.substring(0, 25)}...'
          : trimmedText;
      final newConv = await _ref
          .read(conversationListProvider.notifier)
          .createNewConversation(title: title);

      if (newConv == null) return;
      convId = newConv.id;
      _subscribeToConversation(convId);
    }

    final repository = _ref.read(chatbotRepositoryProvider);
    final userMessageId = DateTime.now().millisecondsSinceEpoch.toString();
    final userMessage = Message(
      id: userMessageId,
      conversationId: convId,
      role: MessageRole.user,
      content: trimmedText,
      timestamp: DateTime.now(),
    );

    // Update UI IMMEDIATELY so the message bubble shows instantly!
    final updatedMessages = [...state.messages, userMessage];
    state = state.copyWith(messages: updatedMessages);

    // Save user message to database
    await repository.saveMessage(userMessage);

    // Clear draft
    await _ref.read(saveDraftUseCaseProvider)(
      SaveDraftParams(conversationId: convId, draft: ''),
    );

    // Trigger AI response streaming
    await _startAiStreaming(convId, userMessage.content);
  }

  Future<void> _startAiStreaming(String convId, String userPrompt) async {
    final streamUseCase = _ref.read(streamAiResponseUseCaseProvider);
    final repository = _ref.read(chatbotRepositoryProvider);

    state = state.copyWith(isGenerating: true, streamingContent: '');

    final aiMessageId = (DateTime.now().millisecondsSinceEpoch + 1).toString();
    final currentHistory = List<Message>.from(state.messages);

    final settings = _ref.read(settingsProvider);
    final activeModel = settings.activeAiModel;

    final streamResult = streamUseCase(
      StreamAiParams(
        conversationId: convId,
        prompt: userPrompt,
        model: activeModel,
        history: currentHistory,
      ),
    );

    var accumulatedText = '';

    _aiStreamSubscription = streamResult.listen(
      (result) {
        result.fold(
          (failure) {
            state = state.copyWith(
              isGenerating: false,
              errorMessage: failure.message,
            );
          },
          (chunk) {
            accumulatedText += chunk;
            state = state.copyWith(
              isGenerating: true,
              streamingContent: accumulatedText,
            );
          },
        );
      },
      onDone: () async {
        if (accumulatedText.isNotEmpty) {
          final aiMessage = Message(
            id: aiMessageId,
            conversationId: convId,
            role: MessageRole.assistant,
            content: accumulatedText,
            timestamp: DateTime.now(),
            status: MessageStatus.sent,
          );
          await repository.saveMessage(aiMessage);
        }
        state = state.copyWith(
          isGenerating: false,
          streamingContent: '',
        );
      },
      onError: (Object error) {
        state = state.copyWith(
          isGenerating: false,
          errorMessage: error.toString(),
        );
      },
    );
  }

  /// Cancels in-flight generation.
  Future<void> stopGeneration() async {
    await _aiStreamSubscription?.cancel();
    final repository = _ref.read(chatbotRepositoryProvider);
    await repository.cancelAiGeneration();

    if (state.streamingContent.isNotEmpty && state.conversationId != null) {
      final aiMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: state.conversationId!,
        role: MessageRole.assistant,
        content: state.streamingContent,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
      );
      await repository.saveMessage(aiMessage);
    }

    state = state.copyWith(isGenerating: false, streamingContent: '');
  }

  /// Regenerates last AI response.
  Future<void> regenerateResponse() async {
    final convId = state.conversationId;
    if (convId == null || state.messages.isEmpty) return;

    final lastUserMsg = state.messages.lastWhere(
      (m) => m.role == MessageRole.user,
      orElse: () => state.messages.last,
    );

    await _startAiStreaming(convId, lastUserMsg.content);
  }

  /// Retries a failed message.
  Future<void> retryMessage(Message message) async {
    if (message.role == MessageRole.user) {
      await sendMessage(message.content);
    } else {
      await regenerateResponse();
    }
  }

  /// Saves unsent draft text input.
  Future<void> updateDraft(String draft) async {
    final convId = state.conversationId;
    if (convId == null) return;
    state = state.copyWith(draftInput: draft);
    final saveDraft = _ref.read(saveDraftUseCaseProvider);
    await saveDraft(SaveDraftParams(conversationId: convId, draft: draft));
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _aiStreamSubscription?.cancel();
    super.dispose();
  }
}

/// Active conversation notifier provider.
final activeConversationProvider = StateNotifierProvider<
    ActiveConversationNotifier, ActiveConversationState>((ref) {
  return ActiveConversationNotifier(ref);
});
