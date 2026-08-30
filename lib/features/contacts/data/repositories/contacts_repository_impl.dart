import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/contacts/data/datasources/contacts_remote_data_source.dart';
import 'package:lotus_connect/features/contacts/domain/repositories/contacts_repository.dart';

class ContactsRepositoryImpl implements ContactsRepository {
  const ContactsRepositoryImpl({
    required ContactsRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final ContactsRemoteDataSource _remoteDataSource;
  @override
  FutureResult<List<User>> contactsList() async {
    try {
      final response = await _remoteDataSource.contactsList();
      return Right(response);
    } on Object {
      return const Left(ServerFailure('Failed to load contacts list'));
    }
  }

  @override
  FutureResult<void> sendFriendRequest({required String username}) async {
    try {
      final response = await _remoteDataSource.sendFriendRequest(username);
      return const Right(null);
    } on Object {
      return const Left(ServerFailure('Failed to send friend request'));
    }
  }

  @override
  FutureResult<void> acceptFriendRequest({required String targetId}) async {
    try {
      final response = await _remoteDataSource.acceptFriendRequest(targetId);
      return const Right(null);
    } on Object {
      return const Left(ServerFailure('Failed to accept friend request'));
    }
  }

  @override
  FutureResult<void> rejectFriendRequest({required String targetId}) async {
    try {
      final response = await _remoteDataSource.rejectFriendRequest(targetId);
      return const Right(null);
    } on Object {
      return const Left(ServerFailure('Failed to reject friend request'));
    }
  }

  @override
  FutureResult<List<User>> getFriendRequests() async {
    try {
      final response = await _remoteDataSource.getFriendRequests();
      return Right(response);
    } on Object {
      return const Left(ServerFailure('Failed to get friend requests'));
    }
  }

  @override
  FutureResult<List<User>> searchUsers(String query) async {
    try {
      final response = await _remoteDataSource.searchUsers(query);
      return Right(response);
    } on Object {
      return const Left(ServerFailure('Failed to search user'));
    }
  }
}
