import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/livestream/domain/repositories/livestream_repository.dart';

class PinCommentParam extends Equatable {
  const PinCommentParam({required this.streamId, required this.commentId});

  final String streamId;
  final String commentId;

  @override
  List<Object?> get props => [streamId, commentId];
}

class PinCommentUseCase implements UseCase<void, PinCommentParam> {
  const PinCommentUseCase(LiveStreamRepository repository)
      : _repository = repository;
  final LiveStreamRepository _repository;

  @override
  FutureResult<void> call(PinCommentParam params) async {
    return _repository.pinComment(params.streamId, params.commentId);
  }
}
