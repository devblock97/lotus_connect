import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chat_core/data/datasources/chat_core_local_data_source.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/conversation.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';
import 'package:lotus_connect/features/chat_core/domain/repositories/chat_core_repository.dart';

class ChatCoreRepositoryImpl implements ChatCoreRepository {
  ChatCoreRepositoryImpl(this._localDataSource);

  final ChatCoreLocalDataSource _localDataSource;

  @override
  StreamResult<List<Conversation>> watchConversations() {
    return _localDataSource.watchConversations().map(Right.new);
  }

  @override
  FutureResult<List<Conversation>> getConversations() async {
    try {
      final conversations = await _localDataSource.getConversations();
      return Right(conversations);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get conversations: $e', e));
    }
  }

  @override
  StreamResult<List<Message>> watchMessages(String conversationId) {
    return _localDataSource.watchMessages(conversationId).map(Right.new);
  }

  @override
  FutureResult<void> renameConversation(
    String conversationId,
    String newTitle,
  ) async {
    try {
      await _localDataSource.renameConversation(conversationId, newTitle);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to rename conversation: $e', e));
    }
  }

  @override
  FutureResult<void> deleteConversation(String conversationId) async {
    try {
      await _localDataSource.deleteConversation(conversationId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete conversation: $e', e));
    }
  }

  @override
  FutureResult<void> togglePinConversation(String conversationId) async {
    try {
      await _localDataSource.togglePinConversation(conversationId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to toggle pin conversation: $e', e));
    }
  }

  @override
  FutureResult<void> toggleFavouriteConversation(String conversationId) async {
    try {
      await _localDataSource.toggleFavouriteConversation(conversationId);
      return const Right(null);
    } catch (e) {
      return Left(
          DatabaseFailure('Failed to toggle favourite conversation: $e', e));
    }
  }

  @override
  FutureResult<void> saveDraftMessage(
    String conversationId,
    String draft,
  ) async {
    try {
      await _localDataSource.saveDraftMessage(conversationId, draft);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to save draft message: $e', e));
    }
  }

  @override
  FutureResult<void> saveMessage(Message message) async {
    try {
      await _localDataSource.saveMessage(message);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to save message: $e', e));
    }
  }

  @override
  FutureResult<Conversation> createLocalConversation({
    required String title,
    String? modelName,
    bool isUserToUser = false,
    String peerId = '',
    String? id,
  }) async {
    try {
      final conversation = await _localDataSource.createConversation(
        title: title,
        modelName: modelName,
        isUserToUser: isUserToUser,
        peerId: peerId,
        id: id,
      );
      return Right(conversation);
    } catch (e) {
      return Left(DatabaseFailure('Failed to create local conversation: $e', e));
    }
  }

  @override
  FutureResult<void> deleteMessage(String id) async {
    try {
      await _localDataSource.deleteMessage(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete message: $e', e));
    }
  }

  @override
  FutureResult<List<Message>> getMessages(String conversationId) async {
    try {
      final messages = await _localDataSource.getMessages(conversationId);
      return Right(messages);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get messages: $e', e));
    }
  }

  @override
  FutureResult<Message?> getMessage(String messageId) async {
    try {
      final message = await _localDataSource.getMessage(messageId);
      return Right(message);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get message: $e', e));
    }
  }
}
