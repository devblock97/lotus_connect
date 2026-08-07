import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chat/data/datasources/private_chat_local_data_source.dart';
import 'package:lotus_connect/features/chat/data/datasources/private_chat_remote_data_source.dart';
import 'package:lotus_connect/features/chat/domain/repositories/private_chat_repository.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/conversation.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';

class PrivateChatRepositoryImpl implements PrivateChatRepository {
  PrivateChatRepositoryImpl({
    required PrivateChatRemoteDataSource remoteDataSource,
    required PrivateChatLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final PrivateChatRemoteDataSource _remoteDataSource;
  final PrivateChatLocalDataSource _localDataSource;

  @override
  FutureResult<Conversation> createPrivateChat({
    required String friendId,
    required String title,
  }) async {
    try {
      final chatData = await _remoteDataSource.createPrivateChat(friendId);
      final id = chatData['id'] as String;

      final conversation = await _localDataSource.saveLocalConversation(
        title: title,
        isUserToUser: true,
        peerId: friendId,
        id: id,
      );
      return Right(conversation);
    } catch (e) {
      return Left(DatabaseFailure('Failed to create private chat: $e', e));
    }
  }

  @override
  FutureResult<Message> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    try {
      final remoteMessage = await _remoteDataSource.sendMessage(
          conversationId: conversationId,
          content: content,
      );
      return Right(remoteMessage);
    } catch (e) {
      return Left(ServerFailure('Failed to send message: $e', e));
    }
  }

  @override
  FutureResult<void> deleteMessage(String messageId) async {
    try {
      await _remoteDataSource.deleteMessage(messageId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete message: $e', e));
    }
  }

  @override
  FutureResult<void> updateMessage({
    required String messageId,
    required String content,
  }) async {
    try {
      await _remoteDataSource.updateMessage(messageId, content);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to update message: $e', e));
    }
  }

  @override
  FutureResult<List<Message>> fetchRemoteMessages({
    required String conversationId,
    required String currentUserId,
  }) async {
    try {
      final remoteMessages = await _remoteDataSource.fetchRemoteMessages(
        conversationId: conversationId,
        currentUserId: currentUserId,
      );
      return Right(remoteMessages);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch remote messages: $e', e));
    }
  }
}
