import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/services/websocket/websocket_service.dart';
import 'package:lotus_connect/features/chat/application/private_chat_providers.dart';
import 'package:lotus_connect/features/chat/application/private_conversation_list_notifier.dart';
import 'package:lotus_connect/features/chat/domain/usecases/delete_local_message_usecase.dart';
import 'package:lotus_connect/features/chat/domain/usecases/delete_remote_message_usecase.dart';
import 'package:lotus_connect/features/chat/domain/usecases/get_remote_message_usecase.dart';
import 'package:lotus_connect/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:lotus_connect/features/chat/domain/usecases/update_message_usecase.dart';
import 'package:lotus_connect/features/chat_core/application/chat_core_providers.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';
import 'package:lotus_connect/features/chat_core/domain/usecases/get_local_message_usecase.dart';
import 'package:lotus_connect/features/chat_core/domain/usecases/save_draft_usecase.dart';
import 'package:lotus_connect/features/chat_core/domain/usecases/save_local_message_usecase.dart';
import 'package:lotus_connect/features/chatbot/application/settings_notifier.dart';

/// State representing the active user-to-user conversation message stream.
class PrivateActiveConversationState {
  const PrivateActiveConversationState({
    this.conversationId,
    this.messages = const [],
    this.draftInput = '',
    this.errorMessage,
    this.replyingToMessage,
  });

  final String? conversationId;
  final List<Message> messages;
  final String draftInput;
  final String? errorMessage;
  final Message? replyingToMessage;

  PrivateActiveConversationState copyWith({
    String? conversationId,
    List<Message>? messages,
    String? draftInput,
    String? errorMessage,
    Message? replyingToMessage,
    bool clearReplyingTo = false,
  }) {
    return PrivateActiveConversationState(
      conversationId: conversationId ?? this.conversationId,
      messages: messages ?? this.messages,
      draftInput: draftInput ?? this.draftInput,
      errorMessage: errorMessage,
      replyingToMessage: clearReplyingTo
          ? null
          : (replyingToMessage ?? this.replyingToMessage),
    );
  }
}

/// Notifier handling human-to-human active chat state over WebSockets.
class PrivateActiveConversationNotifier
    extends StateNotifier<PrivateActiveConversationState> {
  PrivateActiveConversationNotifier(
    this._ref, {
    required GetRemoteMessageUseCase getRemoteMessageUseCase,
    required GetLocalMessageUseCase getLocalMessageUseCase,
    required SaveLocalMessageUseCase saveLocalMessageUseCase,
    required DeleteLocalMessageUseCase deleteLocalMessageUseCase,
    required DeleteRemoteMessageUseCase deleteRemoteMessageUseCase,
    required UpdateMessageUseCase updateMessageUseCase,
    required SaveDraftMessageUseCase saveDraftMessageUseCase,
    required SendMessageUseCase sendMessageUseCase,
  })  : _getRemoteMessageUseCase = getRemoteMessageUseCase,
        _getLocalMessageUseCase = getLocalMessageUseCase,
        _saveLocalMessageUseCase = saveLocalMessageUseCase,
        _deleteLocalMessageUseCase = deleteLocalMessageUseCase,
        _deleteRemoteMessageUseCase = deleteRemoteMessageUseCase,
        _updateMessageUseCase = updateMessageUseCase,
        _saveDraftMessageUseCase = saveDraftMessageUseCase,
        _sendMessageUseCase = sendMessageUseCase,
        super(const PrivateActiveConversationState()) {
    _init();
  }

  final GetRemoteMessageUseCase _getRemoteMessageUseCase;
  final GetLocalMessageUseCase _getLocalMessageUseCase;
  final SaveLocalMessageUseCase _saveLocalMessageUseCase;
  final DeleteLocalMessageUseCase _deleteLocalMessageUseCase;
  final DeleteRemoteMessageUseCase _deleteRemoteMessageUseCase;
  final UpdateMessageUseCase _updateMessageUseCase;
  final SaveDraftMessageUseCase _saveDraftMessageUseCase;
  final SendMessageUseCase _sendMessageUseCase;

  Timer? _typingTimer;
  bool _isCurrentlyTyping = false;

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
      _syncMessages(conversationId);
    }
  }

  Future<void> _syncMessages(String conversationId) async {
    try {
      final currentUserId = _ref.read(settingsProvider).userId;
      if (currentUserId.isEmpty) return;

      // final messageCursor = state.messages.last.id;

      final remoteResult = await _getRemoteMessageUseCase(
        GetRemoteMessageParam(
          conversationId: conversationId,
          userId: currentUserId,
          limit: 100,
        ),
      );

      await remoteResult.fold(
        (failure) async {
          // Keep local messages if network/fetch fails
        },
        (remoteMessages) async {
          // 1. Save all remote messages locally
          for (final msg in remoteMessages) {
            await _saveLocalMessageUseCase(SaveLocalMessageParam(message: msg));
          }

          // 2. Reconcile deleted messages
          final localResult = await _getLocalMessageUseCase(
            GetLocalMessageParam(conversationId: conversationId),
          );
          await localResult.fold(
            (failure) async {},
            (localMessages) async {
              final uuidRegex = RegExp(
                '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-'
                r'[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
              );

              final remoteIds = remoteMessages.map((m) => m.id).toSet();

              if (remoteMessages.length < 100) {
                // If remote returned fewer than 100 messages,
                // we have fetched the complete history.
                // Any local message with a UUID not in remoteMessages
                // must have been deleted.
                for (final msg in localMessages) {
                  if (uuidRegex.hasMatch(msg.id) &&
                      !remoteIds.contains(msg.id)) {
                    await _deleteLocalMessageUseCase(msg.id);
                  }
                }
              } else {
                // Reconcile within the window of fetched remote messages.
                // Subtract 5 seconds to account for precision loss
                // in DB or clock skew.
                DateTime? minTimestamp;
                for (final msg in remoteMessages) {
                  if (minTimestamp == null ||
                      msg.timestamp.isBefore(minTimestamp)) {
                    minTimestamp = msg.timestamp;
                  }
                }

                if (minTimestamp != null) {
                  final adjustedMin =
                      minTimestamp.subtract(const Duration(seconds: 5));
                  for (final msg in localMessages) {
                    if (uuidRegex.hasMatch(msg.id) &&
                        (msg.timestamp.isAfter(adjustedMin) ||
                            msg.timestamp.isAtSameMomentAs(adjustedMin))) {
                      if (!remoteIds.contains(msg.id)) {
                        await _deleteLocalMessageUseCase(msg.id);
                      }
                    }
                  }
                }
              }
            },
          );
        },
      );
    } on Object catch (e) {
      debugPrint('check sync error message: $e');
      // Ignore background sync errors
    }
  }

  /// Sends a message over the WebSocket tunnel.
  Future<void> sendMessage(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Message content cannot be empty',
      );
      return;
    }

    final convId = state.conversationId;
    if (convId == null) return;

    final replyToId = state.replyingToMessage?.id;
    final optimisticId = DateTime.now().millisecondsSinceEpoch.toString();
    final userMessage = Message(
      id: optimisticId,
      conversationId: convId,
      role: MessageRole.user,
      content: trimmedText,
      timestamp: DateTime.now(),
      replyToId: replyToId,
    );

    // Update UI immediately and clear active reply preview
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      clearReplyingTo: true,
    );

    await _saveDraftMessageUseCase(
      SaveDraftMessageParams(conversationId: convId, draft: ''),
    );

    final result = await _sendMessageUseCase(
      SendMessageParams(
        conversationId: convId,
        text: trimmedText,
        replyToId: replyToId,
      ),
    );

    await result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (remoteMessage) async {
        // Delete optimistic message and save the permanent
        // server-synchronized message
        await deleteMessage(optimisticId);
        await _saveLocalMessageUseCase(
          SaveLocalMessageParam(message: remoteMessage),
        );
        state = state.copyWith(
          messages: [...state.messages, remoteMessage],
        );
      },
    );
  }

  void setReplyingToMessage(Message message) {
    state = state.copyWith(replyingToMessage: message);
  }

  void cancelReply() {
    state = state.copyWith(clearReplyingTo: true);
  }

  /// Updates local draft typing content.
  Future<void> updateDraft(String draft) async {
    final convId = state.conversationId;
    if (convId == null) return;
    state = state.copyWith(draftInput: draft);
    await _ref.read(chatCoreRepositoryProvider).saveDraftMessage(convId, draft);

    _sendTypingStatus(draft.trim().isNotEmpty);
  }

  void _sendTypingStatus(bool isTyping) {
    if (_isCurrentlyTyping == isTyping) return;
    _isCurrentlyTyping = isTyping;

    final listState = _ref.read(privateConversationListProvider);
    final conversation = listState.conversations
        .firstWhereOrNull((c) => c.id == state.conversationId);
    final recipientId = conversation?.peerId ?? '';

    if (recipientId.isNotEmpty && state.conversationId != null) {
      _ref.read(webSocketServiceProvider).sendTyping(
            recipientId: recipientId,
            conversationId: state.conversationId!,
            isTyping: isTyping,
          );
    }

    _typingTimer?.cancel();
    if (isTyping) {
      _typingTimer = Timer(const Duration(seconds: 3), () {
        _sendTypingStatus(false);
      });
    }
  }

  /// Deletes a message by its ID.
  Future<void> deleteMessage(String messageId) async {
    final uuidRegex = RegExp(
      '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-'
      r'[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );

    if (!uuidRegex.hasMatch(messageId)) {
      try {
        final result = await _deleteLocalMessageUseCase(messageId);
        await result.fold((error) {
          state = state.copyWith(
            errorMessage: "Can't delete message. Please try again",
          );
        }, (success) async {
          state = state.copyWith();
        });
      } on Object catch (e) {
        throw Exception(e.toString());
      }
      return;
    }
    final result = await _deleteRemoteMessageUseCase(
      DeleteRemoteMessageParam(messageId: messageId),
    );
    await result.fold((remoteError) {
      state = state.copyWith(
        errorMessage: "Can't delete message. Please try again",
      );
    }, (remoteSuccess) async {
      await _deleteLocalMessageUseCase(messageId);
    });
  }

  Future<void> updateMessage(String messageId, String content) async {
    final params = UpdateMessageParam(messageId: messageId, content: content);
    final result = await _updateMessageUseCase(params);
    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (_) {
        // State updates reactively via watched database query streams
      },
    );
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _typingTimer?.cancel();
    super.dispose();
  }
}

/// Provider for PrivateActiveConversationNotifier.
final privateActiveConversationProvider = StateNotifierProvider<
    PrivateActiveConversationNotifier, PrivateActiveConversationState>((ref) {
  return PrivateActiveConversationNotifier(
    ref,
    getRemoteMessageUseCase: ref.watch(getRemoteMessageUseCaseProvider),
    getLocalMessageUseCase: ref.watch(getLocalMessageUseCaseProvider),
    saveLocalMessageUseCase: ref.watch(saveMessageUseCaseProvider),
    deleteLocalMessageUseCase: ref.watch(deleteLocalMessageUseCaseProvider),
    deleteRemoteMessageUseCase: ref.watch(deleteRemoteMessageUseCaseProvider),
    updateMessageUseCase: ref.watch(updateMessageUseCaseProvider),
    saveDraftMessageUseCase: ref.watch(saveDraftMessageUseCaseProvider),
    sendMessageUseCase: ref.watch(sendMessageUseCaseProvider),
  );
});
