import 'package:lotus_connect/core/entities/response_entity_base.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';

abstract class ContactsRepository {
  FutureResult<List<User>> contactsList() => throw UnimplementedError('Stub');

  FutureResult<void> sendFriendRequest({required String username});

  FutureResult<ResponseEntityBase> acceptFriendRequest({
    required String targetId,
  }) =>
      throw UnimplementedError('Stub');

  FutureResult<ResponseEntityBase> rejectFriendRequest({
    required String targetId,
  }) =>
      throw UnimplementedError('Stub');

  FutureResult<ResponseEntityBase> deleteFriend({
    required String friendId,
  }) =>
      throw UnimplementedError('Stub');

  FutureResult<List<User>> getFriendRequests();

  FutureResult<List<User>> searchUsers(String query);
}
