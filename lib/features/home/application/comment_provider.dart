import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/network/dio_client.dart';
import 'package:lotus_connect/features/home/application/comment_notifier.dart';
import 'package:lotus_connect/features/home/data/datasources/comment_remote_data_source.dart';
import 'package:lotus_connect/features/home/data/repositories/comment_repository_impl.dart';
import 'package:lotus_connect/features/home/domain/repositories/comment_repository.dart';
import 'package:lotus_connect/features/home/domain/usecases/create_comment_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/delete_comment_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/get_comment_by_id_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/get_comment_replies_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/get_comments_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/pin_comment_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/react_to_comment_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/update_comment_usecase.dart';
import 'package:lotus_connect/features/home/domain/usecases/upload_comment_media_usecase.dart';

final commentRemoteDataSourceProvider =
    Provider<CommentRemoteDataSource>((ref) {
  return CommentRemoteDataSourceImpl(
    dioClient: ref.watch(dioClientProvider),
  );
});

final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return CommentRepositoryImpl(
    remoteDataSource: ref.watch(commentRemoteDataSourceProvider),
  );
});

final getCommentsUseCaseProvider = Provider<GetCommentsUseCase>((ref) {
  return GetCommentsUseCase(
    repository: ref.watch(commentRepositoryProvider),
  );
});

final createCommentUseCaseProvider = Provider<CreateCommentUseCase>((ref) {
  return CreateCommentUseCase(
    repository: ref.watch(commentRepositoryProvider),
  );
});

final getCommentByIdUseCaseProvider = Provider<GetCommentByIdUseCase>((ref) {
  return GetCommentByIdUseCase(
    repository: ref.watch(commentRepositoryProvider),
  );
});

final getCommentRepliesUseCaseProvider =
    Provider<GetCommentRepliesUseCase>((ref) {
  return GetCommentRepliesUseCase(
    repository: ref.watch(commentRepositoryProvider),
  );
});

final updateCommentUseCaseProvider = Provider<UpdateCommentUseCase>((ref) {
  return UpdateCommentUseCase(
    repository: ref.watch(commentRepositoryProvider),
  );
});

final deleteCommentUseCaseProvider = Provider<DeleteCommentUseCase>((ref) {
  return DeleteCommentUseCase(
    repository: ref.watch(commentRepositoryProvider),
  );
});

final reactToCommentUseCaseProvider = Provider<ReactToCommentUseCase>((ref) {
  return ReactToCommentUseCase(
    repository: ref.watch(commentRepositoryProvider),
  );
});

final pinCommentUseCaseProvider = Provider<PinCommentUseCase>((ref) {
  return PinCommentUseCase(
    repository: ref.watch(commentRepositoryProvider),
  );
});

final uploadCommentMediaUseCaseProvider =
    Provider<UploadCommentMediaUseCase>((ref) {
  return UploadCommentMediaUseCase(
    repository: ref.watch(commentRepositoryProvider),
  );
});

final commentNotifierProvider =
    StateNotifierProvider.autoDispose<CommentNotifier, CommentState>((ref) {
  return CommentNotifier(
    getCommentsUseCase: ref.watch(getCommentsUseCaseProvider),
    createCommentUseCase: ref.watch(createCommentUseCaseProvider),
    getCommentByIdUseCase: ref.watch(getCommentByIdUseCaseProvider),
    getCommentRepliesUseCase: ref.watch(getCommentRepliesUseCaseProvider),
    updateCommentUseCase: ref.watch(updateCommentUseCaseProvider),
    deleteCommentUseCase: ref.watch(deleteCommentUseCaseProvider),
    reactToCommentUseCase: ref.watch(reactToCommentUseCaseProvider),
    pinCommentUseCase: ref.watch(pinCommentUseCaseProvider),
    uploadCommentMediaUseCase: ref.watch(uploadCommentMediaUseCaseProvider),
  );
});

final postCommentsNotifierProvider = StateNotifierProvider.autoDispose
    .family<CommentNotifier, CommentState, String>((ref, postId) {
  return CommentNotifier(
    postId: postId,
    getCommentsUseCase: ref.watch(getCommentsUseCaseProvider),
    createCommentUseCase: ref.watch(createCommentUseCaseProvider),
    getCommentByIdUseCase: ref.watch(getCommentByIdUseCaseProvider),
    getCommentRepliesUseCase: ref.watch(getCommentRepliesUseCaseProvider),
    updateCommentUseCase: ref.watch(updateCommentUseCaseProvider),
    deleteCommentUseCase: ref.watch(deleteCommentUseCaseProvider),
    reactToCommentUseCase: ref.watch(reactToCommentUseCaseProvider),
    pinCommentUseCase: ref.watch(pinCommentUseCaseProvider),
    uploadCommentMediaUseCase: ref.watch(uploadCommentMediaUseCaseProvider),
  );
});
