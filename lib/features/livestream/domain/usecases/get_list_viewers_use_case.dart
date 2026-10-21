import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_viewer.dart';
import 'package:lotus_connect/features/livestream/domain/repositories/livestream_repository.dart';

class GetListViewersParam extends Equatable {
  const GetListViewersParam({required this.streamId, this.limit});

  final String streamId;
  final int? limit;

  @override
  List<Object?> get props => [streamId, limit];
}

class GetListViewersUseCase
    implements UseCase<List<LiveViewer>, GetListViewersParam> {
  const GetListViewersUseCase(LiveStreamRepository repository)
      : _repository = repository;
  final LiveStreamRepository _repository;

  @override
  FutureResult<List<LiveViewer>> call(GetListViewersParam params) async {
    return _repository.listViewers(
      params.streamId,
      limit: params.limit,
    );
  }
}
