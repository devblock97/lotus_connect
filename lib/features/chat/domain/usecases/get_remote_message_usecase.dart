import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chat/domain/repositories/private_chat_repository.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';

class GetRemoteMessageParam extends Equatable {
  const GetRemoteMessageParam({
    required this.conversationId,
    required this.userId,
    this.cursor,
    this.limit = 25,
  });

  final String conversationId;
  final String userId;
  final String? cursor;
  final int limit;

  @override
  List<Object?> get props => [
        conversationId,
        userId,
      ];
}

class GetRemoteMessageUseCase
    implements UseCase<List<Message>, GetRemoteMessageParam> {
  const GetRemoteMessageUseCase({required PrivateChatRepository repository})
      : _repository = repository;

  final PrivateChatRepository _repository;

  @override
  FutureResult<List<Message>> call(GetRemoteMessageParam params) async {
    return _repository.fetchRemoteMessages(
      conversationId: params.conversationId,
      currentUserId: params.userId,
      limit: params.limit,
      cursor: params.cursor,
    );
  }
}
