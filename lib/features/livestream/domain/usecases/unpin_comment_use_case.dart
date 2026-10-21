import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/livestream/domain/repositories/livestream_repository.dart';

class UnpinCommentParam extends Equatable {
  const UnpinCommentParam({required this.streamId, required this.commentId});

  final String streamId;
  final String commentId;

  @override
  List<Object?> get props => [streamId, commentId];
}

class UnpinCommentUseCase implements UseCase<void, UnpinCommentParam> {
  const UnpinCommentUseCase(LiveStreamRepository repository)
      : _repository = repository;
  final LiveStreamRepository _repository;

  @override
  FutureResult<void> call(UnpinCommentParam params) {
    throw UnimplementedError();
  }
}
