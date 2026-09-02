import 'package:lotus_connect/core/entities/response_entity_base.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/notfications/domain/repositories/notification_repository.dart';

class MarkNotificationReadUseCase
    implements UseCase<ResponseEntityBase, NoParams> {
  const MarkNotificationReadUseCase({
    required NotificationRepository repository,
  }) : _repository = repository;

  final NotificationRepository _repository;

  @override
  FutureResult<ResponseEntityBase> call(NoParams params) async {
    return _repository.markNotificationRead();
  }
}
