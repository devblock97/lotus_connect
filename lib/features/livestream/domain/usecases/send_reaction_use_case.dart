import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/livestream/domain/repositories/livestream_repository.dart';

class SendReactionParam extends Equatable {
  const SendReactionParam({
    required this.streamId,
    this.reaction = 'heart',
    this.count = 1,
  });

  final String streamId;
  final String reaction;
  final int count;
  @override
  List<Object?> get props => [streamId, reaction, count];
}

class SendReactionUseCase implements UseCase<int, SendReactionParam> {
  const SendReactionUseCase(LiveStreamRepository repository)
      : _repository = repository;
  final LiveStreamRepository _repository;

  @override
  FutureResult<int> call(SendReactionParam params) async {
    return _repository.sendReaction(
      params.streamId,
      reaction: params.reaction,
      count: params.count,
    );
  }
}
