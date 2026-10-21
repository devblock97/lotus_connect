import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_comment.dart';
import 'package:lotus_connect/features/livestream/domain/repositories/livestream_repository.dart';

class GetListCommentParam extends Equatable {
  const GetListCommentParam({required this.streamId, this.cursor, this.limit});
  final String streamId;
  final String? cursor;
  final int? limit;

  @override
  List<Object?> get props => [
        streamId,
        cursor,
        limit,
      ];
}

class GetListCommentUseCase
    implements UseCase<List<LiveComment>, GetListCommentParam> {
  const GetListCommentUseCase(LiveStreamRepository repository)
      : _repository = repository;
  final LiveStreamRepository _repository;

  @override
  FutureResult<List<LiveComment>> call(GetListCommentParam params) async {
    return _repository.listComments(
      params.streamId,
      cursor: params.cursor,
      limit: params.limit,
    );
  }
}
