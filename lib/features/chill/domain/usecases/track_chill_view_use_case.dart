import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chill/domain/entities/record_chill_view_params.dart';
import 'package:lotus_connect/features/chill/domain/repositories/chill_repository.dart';

class TrackChillViewParams extends Equatable {
  const TrackChillViewParams({
    required this.chillId,
    this.watchTimeSeconds,
    this.isCompleted,
  });

  final String chillId;
  final double? watchTimeSeconds;
  final bool? isCompleted;

  @override
  List<Object?> get props => [chillId, watchTimeSeconds, isCompleted];
}

class TrackChillViewUseCase implements UseCase<bool, TrackChillViewParams> {
  const TrackChillViewUseCase({required ChillRepository repository})
      : _repository = repository;

  final ChillRepository _repository;

  @override
  FutureResult<bool> call(TrackChillViewParams params) async {
    final result = await _repository.recordChillView(
      RecordChillViewParams(
        chillId: params.chillId,
        watchTimeSeconds: params.watchTimeSeconds,
        isCompleted: params.isCompleted,
      ),
    );
    return result.map((_) => true);
  }
}
