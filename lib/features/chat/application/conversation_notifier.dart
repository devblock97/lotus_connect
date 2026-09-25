import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lotus_connect/core/services/websocket/websocket_service.dart';
import 'package:lotus_connect/core/utils/utils.dart';
import 'package:lotus_connect/features/chat/application/chat_application.dart';
import 'package:lotus_connect/features/chat/application/chat_providers.dart';
import 'package:lotus_connect/features/chat/application/conversation_list_notifier.dart';
import 'package:lotus_connect/features/chat/domain/usecases/delete_local_message_usecase.dart';
import 'package:lotus_connect/features/chat/domain/usecases/get_remote_message_usecase.dart';
import 'package:lotus_connect/features/chat/domain/usecases/reaction_message_usecase.dart';
import 'package:lotus_connect/features/chat/domain/usecases/upload_file_usecase.dart';
import 'package:lotus_connect/features/chat_core/application/chat_core_providers.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';
import 'package:lotus_connect/features/chat_core/domain/usecases/get_local_message_usecase.dart';
import 'package:lotus_connect/features/chat_core/domain/usecases/save_draft_usecase.dart';
import 'package:lotus_connect/features/chat_core/domain/usecases/save_local_message_usecase.dart';
import 'package:lotus_connect/features/settings//application/settings_notifier.dart';

enum Status { initialize, success, failure, loading }

/// State representing the active user-to-user conversation message stream.
class PrivateActiveConversationState {
  const PrivateActiveConversationState({
    this.conversationId,
    this.messages = const [],
    this.draftInput = '',
    this.message,
    this.errorMessage,
    this.replyingToMessage,
    this.hasLoadMore = false,
    this.hasReachedMax = false,
    this.isMediaLoading = false,
    this.mediaLength = 0,
    this.status = Status.initialize,
  });

  final String? conversationId;
  final List<Message> messages;
  final Message? message;
  final String draftInput;
  final String? errorMessage;
  final Message? replyingToMessage;
  final bool hasLoadMore;
  final bool hasReachedMax;
  final bool isMediaLoading;
  final int mediaLength;
  final Status status;

  PrivateActiveConversationState copyWith({
    String? conversationId,
    List<Message>? messages,
    String? draftInput,
    String? errorMessage,
    Message? replyingToMessage,
    bool clearReplyingTo = false,
    bool? hasLoadMore,
    bool? hasReachedMax,
    bool? isMediaLoading,
    int? mediaLength,
    Status? status,
    Message? message,
  }) {
    return PrivateActiveConversationState(
      conversationId: conversationId ?? this.conversationId,
      messages: messages ?? this.messages,
      draftInput: draftInput ?? this.draftInput,
      errorMessage: errorMessage,
      replyingToMessage: clearReplyingTo
          ? null
          : (replyingToMessage ?? this.replyingToMessage),
      hasLoadMore: hasLoadMore ?? this.hasLoadMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isMediaLoading: isMediaLoading ?? this.isMediaLoading,
      mediaLength: mediaLength ?? this.mediaLength,
      status: status ?? this.status,
      message: message ?? this.message,
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
    required ChatCommandFactory commandFactory,
    required SaveLocalMessageUseCase saveLocalMessageUseCase,
    required DeleteLocalMessageUseCase deleteLocalMessageUseCase,
    // required DeleteRemoteMessageUseCase deleteRemoteMessageUseCase,
    // required UpdateMessageUseCase updateMessageUseCase,
    required SaveDraftMessageUseCase saveDraftMessageUseCase,
    // required SendMessageUseCase sendMessageUseCase,
    required ReactionMessageUseCase reactionMessageUseCase,
    required UploadFileUseCase uploadFileUseCase,
    // required GetMessageUseCase getMessageUseCase,
  })  : _getRemoteMessageUseCase = getRemoteMessageUseCase,
        _getLocalMessageUseCase = getLocalMessageUseCase,
        _commandFactory = commandFactory,
        _saveLocalMessageUseCase = saveLocalMessageUseCase,
        _deleteLocalMessageUseCase = deleteLocalMessageUseCase,
        // _deleteRemoteMessageUseCase = deleteRemoteMessageUseCase,
        // _updateMessageUseCase = updateMessageUseCase,
        _saveDraftMessageUseCase = saveDraftMessageUseCase,
        // _sendMessageUseCase = sendMessageUseCase,
        _reactionMessageUseCase = reactionMessageUseCase,
        _uploadFileUseCase = uploadFileUseCase,
        // _getMessagesUseCase = getMessageUseCase,
        super(const PrivateActiveConversationState()) {
    _init();
  }

  static const String _tag = 'PrivateActiveConversationNotifier';

  final GetRemoteMessageUseCase _getRemoteMessageUseCase;
  final GetLocalMessageUseCase _getLocalMessageUseCase;
  final SaveLocalMessageUseCase _saveLocalMessageUseCase;
  final DeleteLocalMessageUseCase _deleteLocalMessageUseCase;
  // final DeleteRemoteMessageUseCase _deleteRemoteMessageUseCase;
  // final UpdateMessageUseCase _updateMessageUseCase;
  final SaveDraftMessageUseCase _saveDraftMessageUseCase;
  // final SendMessageUseCase _sendMessageUseCase;
  final ReactionMessageUseCase _reactionMessageUseCase;
  final UploadFileUseCase _uploadFileUseCase;
  // final GetMessageUseCase _getMessagesUseCase;

  final ChatCommandFactory _commandFactory;

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
      final currentUserId = _ref.read(settingsNotifierProvider).settings.userId;
      if (currentUserId.isEmpty) return;

      final remoteResult = await _getRemoteMessageUseCase(
        GetRemoteMessageParam(
          conversationId: conversationId,
          userId: currentUserId,
          limit: 15,
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

  Future<void> loadMoreMessage(String conversationId) async {
    if (state.hasLoadMore || state.hasReachedMax || state.messages.isEmpty) {
      return;
    }

    final currentUserId = _ref.read(settingsNotifierProvider).settings.userId;
    if (currentUserId.isEmpty) return;

    state = state.copyWith(hasLoadMore: true);

    const pageSize = 25;

    final lastMessage = state.messages.first;
    final cursor = lastMessage.id;

    final result = await _getRemoteMessageUseCase(
      GetRemoteMessageParam(
        conversationId: conversationId,
        userId: currentUserId,
        cursor: cursor,
      ),
    );

    await result.fold((error) {
      state = state.copyWith(errorMessage: error.message);
    }, (newMessages) async {
      for (final message in newMessages) {
        await _saveLocalMessageUseCase(
          SaveLocalMessageParam(message: message),
        );
      }

      final hasReachedMax = newMessages.length < pageSize;

      state = state.copyWith(
        hasLoadMore: false,
        hasReachedMax: hasReachedMax,
      );
    });
  }

  /// Sends a message over the WebSocket tunnel.
  Future<void> sendMessage(String text, [List<XFile> medias = const []]) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty && medias.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Message content cannot be empty',
      );
      return;
    }

    final convId = state.conversationId;
    if (convId == null) return;

    final command = _commandFactory.createSendMessageCommand(
      conversationId: convId,
      text: trimmedText,
      replyToId: state.replyingToMessage?.id,
      medias: medias,
    );

    final optimisticMessage = command.createOptimisticMessage();

    // Update UI immediately and clear active reply preview
    state = state.copyWith(
      messages: [...state.messages, optimisticMessage],
      clearReplyingTo: true,
      isMediaLoading: medias.isNotEmpty,
      mediaLength: medias.length,
    );

    await _saveLocalMessageUseCase(
      SaveLocalMessageParam(message: optimisticMessage),
    );
    await updateDraft('');

    final result = await command.execute();

    state = state.copyWith(isMediaLoading: false);

    result.fold(
      (failure) {
        state = state.copyWith(
          messages: state.messages
              .where((message) => message.id != command.id)
              .toList(),
          errorMessage: failure.message,
        );
      },
      (confirmedMessage) {
        state = state.copyWith(
          messages: state.messages
              .map(
                (message) =>
                    message.id == command.id ? confirmedMessage : message,
              )
              .toList(),
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
    await _saveDraftMessageUseCase(
      SaveDraftMessageParams(conversationId: convId, draft: draft),
    );

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
    final index =
        state.messages.indexWhere((message) => message.id == messageId);
    if (index == -1) return;

    final deletedMessage = state.messages[index];
    state = state.copyWith(
      messages:
          state.messages.where((message) => message.id != messageId).toList(),
    );

    final result =
        await _commandFactory.createDeleteMessageCommand(messageId).execute();

    result.fold(
      (failure) {
        final messages = [...state.messages];
        messages.insert(index.clamp(0, messages.length), deletedMessage);
        state = state.copyWith(
          messages: messages,
          errorMessage: failure.message,
        );
      },
      (_) {},
    );
  }

  Future<void> updateMessage(String messageId, String content) async {
    final result = await _commandFactory
        .createUpdateMessageCommand(messageId, content)
        .execute();

    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (_) {},
    );
  }

  Future<void> reactMessage(String messageId, String reaction) async {
    final result = await _commandFactory
        .createReactionMessageCommand(messageId, reaction)
        .execute();

    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (_) {},
    );
  }

  Future<void> uploadFile(String message, List<String> path) async {
    final result = await _uploadFileUseCase(
      UploadFileParam(paths: path),
    );

    result.fold((error) {
      state = state.copyWith(errorMessage: error.message);
    }, (fileUrl) {
      // sendMessage(message, fileUrl);
    });
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
    // deleteRemoteMessageUseCase: ref.watch(deleteRemoteMessageUseCaseProvider),
    // updateMessageUseCase: ref.watch(updateMessageUseCaseProvider),
    saveDraftMessageUseCase: ref.watch(saveDraftMessageUseCaseProvider),
    // sendMessageUseCase: ref.watch(sendMessageUseCaseProvider),
    reactionMessageUseCase: ref.watch(reactionMessageUseCaseProvider),
    uploadFileUseCase: ref.watch(uploadFileUseCaseProvider),
    // getMessageUseCase: ref.watch(getMessageUseCaseProvider),
    commandFactory: ref.watch(chatCommandFactoryProvider),
  );
});
