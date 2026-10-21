import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_leaderboard_item.dart';
import 'package:lotus_connect/features/livestream/domain/repositories/livestream_repository.dart';

class GetLeaderBoardParam extends Equatable {
  const GetLeaderBoardParam({required this.streamId});
  final String streamId;

  @override
  List<Object?> get props => [streamId];
}

class GetLeaderBoardUseCase
    implements UseCase<List<LiveLeaderboardItem>, GetLeaderBoardParam> {
  const GetLeaderBoardUseCase(LiveStreamRepository repository)
      : _repository = repository;
  final LiveStreamRepository _repository;

  @override
  FutureResult<List<LiveLeaderboardItem>> call(
    GetLeaderBoardParam params,
  ) async {
    return _repository.getLeaderboard(params.streamId);
  }
}
