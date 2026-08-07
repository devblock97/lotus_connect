import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/features/chat/application/private_chat_providers.dart';
import 'package:lotus_connect/features/chat/application/private_conversation_list_notifier.dart';
import 'package:lotus_connect/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:lotus_connect/features/chat/domain/usecases/delete_message_usecase.dart';
import 'package:lotus_connect/features/chat_core/application/chat_core_providers.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';

/// State representing the active user-to-user conversation message stream.
class PrivateActiveConversationState {
  const PrivateActiveConversationState({
    this.conversationId,
    this.messages = const [],
    this.draftInput = '',
    this.errorMessage,
  });

  final String? conversationId;
  final List<Message> messages;
  final String draftInput;
  final String? errorMessage;

  PrivateActiveConversationState copyWith({
    String? conversationId,
    List<Message>? messages,
    String? draftInput,
    String? errorMessage,
  }) {
    return PrivateActiveConversationState(
      conversationId: conversationId ?? this.conversationId,
      messages: messages ?? this.messages,
      draftInput: draftInput ?? this.draftInput,
      errorMessage: errorMessage,
    );
  }
}

/// Notifier handling human-to-human active chat state over WebSockets.
class PrivateActiveConversationNotifier
    extends StateNotifier<PrivateActiveConversationState> {
  PrivateActiveConversationNotifier(this._ref)
      : super(const PrivateActiveConversationState()) {
    _init();
  }

  final Ref _ref;
  StreamSubscription<dynamic>? _messageSubscription;

  void _init() {
    final currentSelectedId =
        _ref.read(privateConversationListProvider).selectedConversationId;
    if (currentSelectedId != null) {
      _subscribeToConversation(currentSelectedId);
    }

    _ref.listen<PrivateConversationListState>(privateConversationListProvider,
        (prev, next) {
      final selectedId = next.selectedConversationId;
      if (selectedId != state.conversationId) {
        _subscribeToConversation(selectedId);
      }
    });
  }

  void _subscribeToConversation(String? conversationId) {
    _messageSubscription?.cancel();
    state = PrivateActiveConversationState(conversationId: conversationId);

    if (conversationId != null) {
      final repository = _ref.read(chatCoreRepositoryProvider);
      _messageSubscription =
          repository.watchMessages(conversationId).listen((result) {
        result.fold(
          (failure) => state = state.copyWith(errorMessage: failure.message),
          (messages) => state = state.copyWith(messages: messages),
        );
      });
    }
  }

  /// Sends a message over the WebSocket tunnel.
  Future<void> sendMessage(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    final convId = state.conversationId;
    if (convId == null) return;

    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: convId,
      role: MessageRole.user,
      content: trimmedText,
      timestamp: DateTime.now(),
    );

    // Update UI immediately
    state = state.copyWith(messages: [...state.messages, userMessage]);

    final useCase = _ref.read(sendMessageUseCaseProvider);
    final result = await useCase(
      SendMessageParams(
        conversationId: convId,
        text: trimmedText,
      ),
    );

    await result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (_) async {
        // Clear draft locally
        // await _chatCoreRepository.saveDraftMessage(params.conversationId, '');

        // Send over WebSocket
        // _webSocketService.sendChatMessage(
        //   conversationId: params.conversationId,
        //   content: trimmedText,
        // );
      },
    );
  }

  /// Updates local draft typing content.
  Future<void> updateDraft(String draft) async {
    final convId = state.conversationId;
    if (convId == null) return;
    state = state.copyWith(draftInput: draft);
    await _ref.read(chatCoreRepositoryProvider).saveDraftMessage(convId, draft);
  }

  /// Deletes a message by its ID.
  Future<void> deleteMessage(String messageId) async {
    final useCase = _ref.read(deleteMessageUseCaseProvider);
    final result = await useCase(messageId);
    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (_) {
        // State updates reactively via the watched SQLite query stream.
      },
    );
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }
}

/// Provider for PrivateActiveConversationNotifier.
final privateActiveConversationProvider = StateNotifierProvider<
    PrivateActiveConversationNotifier, PrivateActiveConversationState>((ref) {
  return PrivateActiveConversationNotifier(ref);
});
