import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';
import 'package:lotus_connect/features/chat_core/domain/repositories/chat_core_repository.dart';

class GetLocalMessageParam extends Equatable {
  const GetLocalMessageParam({required this.conversationId});

  final String conversationId;

  @override
  List<Object?> get props => [conversationId];
}

class GetLocalMessageUseCase
    implements UseCase<List<Message>, GetLocalMessageParam> {
  const GetLocalMessageUseCase({required ChatCoreRepository repository})
      : _repository = repository;

  final ChatCoreRepository _repository;

  @override
  FutureResult<List<Message>> call(GetLocalMessageParam params) async {
    return _repository.getLocalMessages(params.conversationId);
  }
}
