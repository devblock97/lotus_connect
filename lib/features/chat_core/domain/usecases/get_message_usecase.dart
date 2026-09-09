import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';
import 'package:lotus_connect/features/chat_core/domain/repositories/chat_core_repository.dart';

class GetMessageParam extends Equatable {
  const GetMessageParam({required this.messageId});

  final String messageId;

  @override
  List<Object?> get props => [messageId];
}

class GetMessageUseCase extends UseCase<Message?, GetMessageParam> {
  GetMessageUseCase({required ChatCoreRepository repository})
      : _repository = repository;

  final ChatCoreRepository _repository;

  @override
  FutureResult<Message?> call(GetMessageParam params) async {
    return _repository.getMessage(params.messageId);
  }
}
