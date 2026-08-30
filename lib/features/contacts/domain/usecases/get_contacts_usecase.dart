import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/contacts/domain/repositories/contacts_repository.dart';

class GetContactsUseCase implements UseCase<List<User>, NoParams> {
  const GetContactsUseCase({required ContactsRepository repository})
      : _repository = repository;

  final ContactsRepository _repository;

  @override
  FutureResult<List<User>> call(NoParams params) async {
    return _repository.contactsList();
  }
}
