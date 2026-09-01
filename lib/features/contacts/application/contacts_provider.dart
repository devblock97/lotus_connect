import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/features/chatbot/application/providers.dart';
import 'package:lotus_connect/features/contacts/data/datasources/contacts_remote_data_source.dart';
import 'package:lotus_connect/features/contacts/data/repositories/contacts_repository_impl.dart';
import 'package:lotus_connect/features/contacts/domain/repositories/contacts_repository.dart';
import 'package:lotus_connect/features/contacts/domain/usecases/accept_friend_request_usecase.dart';
import 'package:lotus_connect/features/contacts/domain/usecases/delete_friend_usecase.dart';
import 'package:lotus_connect/features/contacts/domain/usecases/get_contacts_usecase.dart';
import 'package:lotus_connect/features/contacts/domain/usecases/get_friend_requests_usecase.dart';
import 'package:lotus_connect/features/contacts/domain/usecases/reject_friend_request_usecase.dart';
import 'package:lotus_connect/features/contacts/domain/usecases/search_user_usecase.dart';
import 'package:lotus_connect/features/contacts/domain/usecases/send_friend_request_usecase.dart';

final contactRemoteDataSourceProvider =
    Provider<ContactsRemoteDataSource>((ref) {
  return ContactsRemoteDataSourceImpl(
    dioClient: ref.watch(dioClientProvider),
  );
});

final contactRepositoryProvider = Provider<ContactsRepository>((ref) {
  return ContactsRepositoryImpl(
    remoteDataSource: ref.watch(contactRemoteDataSourceProvider),
  );
});

final getContactsUseCaseProvider = Provider<GetContactsUseCase>((ref) {
  return GetContactsUseCase(repository: ref.watch(contactRepositoryProvider));
});

final sendFriendRequestUseCaseProvider =
    Provider<SendFriendRequestUseCase>((ref) {
  return SendFriendRequestUseCase(
    repository: ref.watch(contactRepositoryProvider),
  );
});

final acceptFriendRequestUseCaseProvider =
    Provider<AcceptFriendRequestUseCase>((ref) {
  return AcceptFriendRequestUseCase(
    repository: ref.watch(contactRepositoryProvider),
  );
});

final rejectFriendRequestUseCaseProvider =
    Provider<RejectFriendRequestUseCase>((ref) {
  return RejectFriendRequestUseCase(
    repository: ref.watch(contactRepositoryProvider),
  );
});

final deleteFriendUseCaseProvider = Provider<DeleteFriendUseCase>((ref) {
  return DeleteFriendUseCase(
    repository: ref.watch(contactRepositoryProvider),
  );
});

final getFriendRequestsUseCaseProvider =
    Provider<GetFriendRequestsUseCase>((ref) {
  return GetFriendRequestsUseCase(
    repository: ref.watch(contactRepositoryProvider),
  );
});

final searchUserUseCaseProvider = Provider<SearchUserUseCase>((ref) {
  return SearchUserUseCase(repository: ref.watch(contactRepositoryProvider));
});
