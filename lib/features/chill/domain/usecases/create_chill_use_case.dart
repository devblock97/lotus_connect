import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chill/domain/entities/chill_item.dart';
import 'package:lotus_connect/features/chill/domain/entities/create_chill_params.dart';
import 'package:lotus_connect/features/chill/domain/repositories/chill_repository.dart';

class CreateChillUseCase implements UseCase<ChillItem, CreateChillParams> {
  const CreateChillUseCase({required ChillRepository repository})
      : _repository = repository;

  final ChillRepository _repository;

  @override
  FutureResult<ChillItem> call(CreateChillParams params) {
    return _repository.createChill(params);
  }
}
