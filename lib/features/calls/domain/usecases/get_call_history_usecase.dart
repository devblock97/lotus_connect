import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/calls/domain/entities/call_log.dart';
import 'package:lotus_connect/features/calls/domain/repositories/calls_repository.dart';

class GetCallHistoryUseCase implements UseCase<List<CallLog>, NoParams> {
  const GetCallHistoryUseCase(this._repository);

  final CallsRepository _repository;

  @override
  FutureResult<List<CallLog>> call(NoParams params) {
    return _repository.getCallHistory();
  }
}
