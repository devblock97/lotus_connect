import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chat/domain/entities/reaction_message_entity.dart';
import 'package:lotus_connect/features/chat/domain/repositories/chat_repository.dart';

class ReactionMessageParam extends Equatable {
  const ReactionMessageParam({required this.messageId, required this.reaction});

  final String messageId;
  final String reaction;

  @override
  List<Object?> get props => [
        messageId,
        reaction,
      ];
}

class ReactionMessageUseCase
    implements UseCase<ReactionMessageEntity, ReactionMessageParam> {
  const ReactionMessageUseCase({required ChatRepository repository})
      : _repository = repository;

  final ChatRepository _repository;

  @override
  FutureResult<ReactionMessageEntity> call(ReactionMessageParam params) async {
    return _repository.reactMessage(params.messageId, params.reaction);
  }
}
