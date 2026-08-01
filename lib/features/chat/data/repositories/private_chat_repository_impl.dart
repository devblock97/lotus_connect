import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/services/api/chat_api_service.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chat/domain/repositories/private_chat_repository.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/conversation.dart';
import 'package:lotus_connect/features/chat_core/domain/repositories/chat_core_repository.dart';

class PrivateChatRepositoryImpl implements PrivateChatRepository {
  PrivateChatRepositoryImpl({
    required ChatApiService chatApiService,
    required ChatCoreRepository chatCoreRepository,
  })  : _chatApiService = chatApiService,
        _chatCoreRepository = chatCoreRepository;

  final ChatApiService _chatApiService;
  final ChatCoreRepository _chatCoreRepository;

  @override
  FutureResult<Conversation> createPrivateChat({
    required String friendId,
    required String title,
  }) async {
    try {
      final chatData = await _chatApiService.createPrivateChat(friendId);
      final id = chatData['id'] as String;

      final result = await _chatCoreRepository.createLocalConversation(
        title: title,
        isUserToUser: true,
        peerId: friendId,
        id: id,
      );
      return result;
    } catch (e) {
      return Left(DatabaseFailure('Failed to create private chat: $e', e));
    }
  }
}
