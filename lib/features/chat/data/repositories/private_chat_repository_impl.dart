import 'package:flutter/foundation.dart';
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
      final id = chatData.id;

      final conversation = await _localDataSource.saveLocalConversation(
        title: title,
        isUserToUser: true,
        peerId: friendId,
        id: id,
      );
      return Right(conversation);
    } on Object catch (e) {
      return Left(DatabaseFailure('Failed to create private chat: $e', e));
    }
  }

  @override
  FutureResult<Message> sendMessage({
    required String conversationId,
    required String content,
    String? replyToId,
  }) async {
    try {
      final remoteMessage = await _remoteDataSource.sendMessage(
        conversationId: conversationId,
        content: content,
        replyToId: replyToId,
      );
      return Right(remoteMessage);
    } on Object catch (e) {
      return Left(ServerFailure('Failed to send message: $e', e));
    }
  }

  @override
  FutureResult<void> deleteMessage(String messageId) async {
    try {
      await _remoteDataSource.deleteMessage(messageId);
      return const Right(null);
    } on Object catch (e) {
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
    } on Object catch (e) {
      return Left(ServerFailure('Failed to update message: $e', e));
    }
  }

  @override
  FutureResult<List<Message>> fetchRemoteMessages({
    required String conversationId,
    required String currentUserId,
    required int limit,
    String? cursor,
  }) async {
    debugPrint('fetch remote message triggered');
    try {
      final remoteMessages = await _remoteDataSource.fetchRemoteMessages(
        conversationId: conversationId,
        currentUserId: currentUserId,
        cursor: cursor,
        limit: limit,
      );
      return Right(remoteMessages);
    } on Object catch (e) {
      return Left(ServerFailure('Failed to fetch remote messages: $e', e));
    }
  }

  @override
  FutureResult<List<Conversation>> getConversationList() async {
    try {
      final conversations = await _remoteDataSource.getConversations();
      return Right(conversations);
    } on Object catch (e) {
      return Left(ServerFailure('Failed to get conversations list: $e'));
    }
  }
}
