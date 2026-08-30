import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';

abstract class ContactsRepository {
  FutureResult<List<User>> contactsList() => throw UnimplementedError('Stub');

  FutureResult<void> sendFriendRequest({required String username});

  FutureResult<void> acceptFriendRequest({required String targetId});

  FutureResult<void> rejectFriendRequest({required String targetId});

  FutureResult<List<User>> getFriendRequests();

  FutureResult<List<User>> searchUsers(String query);
}
