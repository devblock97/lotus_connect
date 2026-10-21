import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_stream.dart';
import 'package:lotus_connect/features/livestream/domain/repositories/livestream_repository.dart';

class GetListMyStreamsParam extends Equatable {
  const GetListMyStreamsParam({this.cursor, this.limit});

  final String? cursor;
  final int? limit;

  @override
  List<Object?> get props => [cursor, limit];
}

class GetListMyStreamsUseCase
    implements UseCase<List<LiveStream>, GetListMyStreamsParam> {
  const GetListMyStreamsUseCase(LiveStreamRepository repository)
      : _repository = repository;
  final LiveStreamRepository _repository;

  @override
  FutureResult<List<LiveStream>> call(GetListMyStreamsParam params) async {
    return _repository.listMyStreams(
      cursor: params.cursor,
      limit: params.limit,
    );
  }
}
