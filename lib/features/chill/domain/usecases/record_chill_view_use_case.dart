import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chill/domain/entities/chill_view_result.dart';
import 'package:lotus_connect/features/chill/domain/entities/record_chill_view_params.dart';
import 'package:lotus_connect/features/chill/domain/repositories/chill_repository.dart';

class RecordChillViewUseCase
    implements UseCase<ChillViewResult, RecordChillViewParams> {
  const RecordChillViewUseCase({required ChillRepository repository})
      : _repository = repository;

  final ChillRepository _repository;

  @override
  FutureResult<ChillViewResult> call(RecordChillViewParams params) {
    return _repository.recordChillView(params);
  }
}
