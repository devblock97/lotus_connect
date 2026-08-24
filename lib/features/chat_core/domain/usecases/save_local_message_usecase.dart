import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';
import 'package:lotus_connect/features/chat_core/domain/repositories/chat_core_repository.dart';

class SaveLocalMessageParam extends Equatable {
  const SaveLocalMessageParam({required this.message});

  final Message message;

  @override
  List<Object?> get props => [message];
}

class SaveLocalMessageUseCase implements UseCase<void, SaveLocalMessageParam> {
  const SaveLocalMessageUseCase({
    required ChatCoreRepository chatCoreRepository,
  }) : _repository = chatCoreRepository;

  final ChatCoreRepository _repository;

  @override
  FutureResult<void> call(SaveLocalMessageParam params) async {
    return _repository.saveMessage(params.message);
  }
}
