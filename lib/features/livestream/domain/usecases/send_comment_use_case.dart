import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_comment.dart';
import 'package:lotus_connect/features/livestream/domain/repositories/livestream_repository.dart';

class SendCommentParam extends Equatable {
  const SendCommentParam({required this.streamId, required this.content});

  final String streamId;
  final String content;

  @override
  List<Object?> get props => [streamId, content];
}

class SendCommentUseCase implements UseCase<LiveComment, SendCommentParam> {
  const SendCommentUseCase(LiveStreamRepository repository)
      : _repository = repository;
  final LiveStreamRepository _repository;

  @override
  FutureResult<LiveComment> call(SendCommentParam params) async {
    return _repository.sendComment(
      params.streamId,
      params.content,
    );
  }
}
