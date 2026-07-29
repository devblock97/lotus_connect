import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/exception.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chatbot/data/datasources/chatbot_local_data_source.dart';
import 'package:lotus_connect/features/chatbot/data/datasources/chatbot_remote_data_source.dart';
import 'package:lotus_connect/features/chatbot/domain/entities/app_settings.dart';
import 'package:lotus_connect/features/chatbot/domain/entities/conversation.dart';
import 'package:lotus_connect/features/chatbot/domain/entities/message.dart';
import 'package:lotus_connect/core/services/api/chat_api_service.dart';
import 'package:lotus_connect/features/chatbot/domain/repositories/chatbot_repository.dart';

/// Repository implementation fulfilling [ChatbotRepository] contract.
class ChatbotRepositoryImpl implements ChatbotRepository {
  ChatbotRepositoryImpl({
    required ChatbotLocalDataSource localDataSource,
    required ChatbotRemoteDataSource remoteDataSource,
    required ChatApiService chatApiService,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _chatApiService = chatApiService;

  final ChatbotLocalDataSource _localDataSource;
  final ChatbotRemoteDataSource _remoteDataSource;
  final ChatApiService _chatApiService;

  @override
  StreamResult<List<Conversation>> watchConversations() {
    return _localDataSource
        .watchConversations()
        .map((list) => Right<Failure, List<Conversation>>(list))
        .handleError((Object error) {
      return Left<Failure, List<Conversation>>(
        DatabaseFailure('Failed to watch conversations: $error', error),
      );
    });
  }

  @override
  FutureResult<List<Conversation>> getConversations() async {
    try {
      final conversations = await _localDataSource.getConversations();
      return Right(conversations);
    } catch (e) {
      return Left(DatabaseFailure('Failed to retrieve conversations: $e', e));
    }
  }

  @override
  StreamResult<List<Message>> watchMessages(String conversationId) {
    return _localDataSource
        .watchMessages(conversationId)
        .map((list) => Right<Failure, List<Message>>(list))
        .handleError((Object error) {
      return Left<Failure, List<Message>>(
        DatabaseFailure('Failed to watch messages: $error', error),
      );
    });
  }

  @override
  FutureResult<Conversation> createConversation({
    required String title,
    String? modelName,
  }) async {
    try {
      final conversation = await _localDataSource.createConversation(
        title: title,
        modelName: modelName,
      );
      return Right(conversation);
    } catch (e) {
      return Left(DatabaseFailure('Failed to create conversation: $e', e));
    }
  }

  @override
  FutureResult<Conversation> createPrivateChat({
    required String friendId,
    required String title,
  }) async {
    try {
      final chatData = await _chatApiService.createPrivateChat(friendId);
      final id = chatData['id'] as String;

      final conversation = await _localDataSource.createConversation(
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
      return Left(DatabaseFailure('Failed to pin conversation: $e', e));
    }
  }

  @override
  FutureResult<void> toggleFavouriteConversation(String conversationId) async {
    try {
      await _localDataSource.toggleFavouriteConversation(conversationId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to favorite conversation: $e', e));
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
      return Left(DatabaseFailure('Failed to save draft: $e', e));
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
  StreamResult<String> streamAiResponse({
    required String conversationId,
    required String prompt,
    required String model,
    required List<Message> history,
  }) async* {
    try {
      final formattedHistory = history
          .map((m) => {'role': m.role.name, 'content': m.content})
          .toList();

      final stream = _remoteDataSource.streamMessage(
        prompt: prompt,
        model: model,
        history: formattedHistory,
      );

      await for (final chunk in stream) {
        yield Right(chunk);
      }
    } on NetworkException catch (e) {
      yield Left(NetworkFailure(e.message, e));
    } on AiProviderException catch (e) {
      yield Left(ApiFailure(e.message, cause: e));
    } catch (e) {
      yield Left(UnknownFailure('Streaming error occurred: $e', e));
    }
  }

  @override
  FutureResult<void> cancelAiGeneration() async {
    try {
      _remoteDataSource.cancelGeneration();
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure('Failed to cancel generation: $e', e));
    }
  }

  @override
  FutureResult<AppSettings> getSettings() async {
    try {
      final settings = await _localDataSource.getSettings();
      return Right(settings);
    } catch (e) {
      return Left(DatabaseFailure('Failed to fetch settings: $e', e));
    }
  }

  @override
  FutureResult<void> updateSettings(AppSettings settings) async {
    try {
      await _localDataSource.updateSettings(settings);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update settings: $e', e));
    }
  }
}
