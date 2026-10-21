import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_stream.dart';
import 'package:lotus_connect/features/livestream/domain/repositories/livestream_repository.dart';

class ListStreamParam extends Equatable {
  const ListStreamParam({
    this.status,
    this.cursor,
    this.limit,
  });

  final String? status;
  final String? cursor;
  final int? limit;

  @override
  List<Object?> get props => [
        status,
        cursor,
        limit,
      ];
}

class GetListStreamUseCase
    implements UseCase<List<LiveStream>, ListStreamParam> {
  const GetListStreamUseCase(LiveStreamRepository repository)
      : _repository = repository;
  final LiveStreamRepository _repository;

  @override
  FutureResult<List<LiveStream>> call(ListStreamParam params) async {
    return _repository.listStreams(
      status: params.status,
      cursor: params.cursor,
      limit: params.limit,
    );
  }
}
