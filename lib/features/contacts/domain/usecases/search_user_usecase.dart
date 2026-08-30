import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/contacts/domain/repositories/contacts_repository.dart';

class SearchUserParam extends Equatable {
  const SearchUserParam({required this.query});

  final String query;

  @override
  List<Object?> get props => [query];
}

class SearchUserUseCase implements UseCase<List<User>, SearchUserParam> {
  const SearchUserUseCase({required ContactsRepository repository})
      : _repository = repository;

  final ContactsRepository _repository;

  @override
  FutureResult<List<User>> call(SearchUserParam params) async {
    return _repository.searchUsers(params.query);
  }
}
