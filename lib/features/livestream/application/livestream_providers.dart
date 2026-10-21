import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/network/dio_client.dart';
import 'package:lotus_connect/features/livestream/data/datasources/livestream_remote_data_source.dart';
import 'package:lotus_connect/features/livestream/data/repositories/livestream_repository_impl.dart';
import 'package:lotus_connect/features/livestream/domain/repositories/livestream_repository.dart';
import 'package:lotus_connect/features/livestream/domain/usecases/create_stream_use_case.dart';
import 'package:lotus_connect/features/livestream/domain/usecases/end_stream_use_case.dart';
import 'package:lotus_connect/features/livestream/domain/usecases/get_leader_board_use_case.dart';
import 'package:lotus_connect/features/livestream/domain/usecases/get_list_comment_use_case.dart';
import 'package:lotus_connect/features/livestream/domain/usecases/get_list_viewers_use_case.dart';
import 'package:lotus_connect/features/livestream/domain/usecases/get_streams_use_case.dart';
import 'package:lotus_connect/features/livestream/domain/usecases/join_stream_use_case.dart';
import 'package:lotus_connect/features/livestream/domain/usecases/leave_stream_use_case.dart';
import 'package:lotus_connect/features/livestream/domain/usecases/pin_comment_use_case.dart';
import 'package:lotus_connect/features/livestream/domain/usecases/send_comment_use_case.dart';
import 'package:lotus_connect/features/livestream/domain/usecases/send_gift_use_case.dart';
import 'package:lotus_connect/features/livestream/domain/usecases/send_reaction_use_case.dart';
import 'package:lotus_connect/features/livestream/domain/usecases/start_stream_use_case.dart';
import 'package:lotus_connect/features/livestream/domain/usecases/upstream_use_case.dart';

final liveStreamRemoteDataSourceProvider =
    Provider<LiveStreamRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return LiveStreamRemoteDataSourceImpl(dioClient: dioClient);
});

final liveStreamRepositoryProvider = Provider<LiveStreamRepository>((ref) {
  final remoteDataSource = ref.watch(liveStreamRemoteDataSourceProvider);
  return LiveStreamRepositoryImpl(remoteDataSource: remoteDataSource);
});

final getStreamUseCaseProvider = Provider<GetStreamUseCase>((ref) {
  return GetStreamUseCase(ref.watch(liveStreamRepositoryProvider));
});

final createStreamUseCaseProvider = Provider<CreateStreamUseCase>((ref) {
  return CreateStreamUseCase(ref.watch(liveStreamRepositoryProvider));
});

final startStreamUseCaseProvider = Provider<StartStreamUseCase>((ref) {
  return StartStreamUseCase(ref.watch(liveStreamRepositoryProvider));
});

final upstreamUseCaseProvider = Provider<UpstreamUseCase>((ref) {
  return UpstreamUseCase(ref.watch(liveStreamRepositoryProvider));
});

final endStreamUseCaseProvider = Provider<EndStreamUseCase>((ref) {
  return EndStreamUseCase(ref.watch(liveStreamRepositoryProvider));
});

final sendGiftUseCaseProvider = Provider<SendGiftUseCase>((ref) {
  return SendGiftUseCase(ref.watch(liveStreamRepositoryProvider));
});

final joinStreamUseCaseProvider = Provider<JoinStreamUseCase>((ref) {
  return JoinStreamUseCase(ref.watch(liveStreamRepositoryProvider));
});

final leaveStreamUseCaseProvider = Provider<LeaveStreamUseCase>((ref) {
  return LeaveStreamUseCase(ref.watch(liveStreamRepositoryProvider));
});

final getListCommentUseCaseProvider = Provider<GetListCommentUseCase>((ref) {
  return GetListCommentUseCase(ref.watch(liveStreamRepositoryProvider));
});

final getListViewersUseCaseProvider = Provider<GetListViewersUseCase>((ref) {
  return GetListViewersUseCase(ref.watch(liveStreamRepositoryProvider));
});

final sendCommentUseCaseProvider = Provider<SendCommentUseCase>((ref) {
  return SendCommentUseCase(ref.watch(liveStreamRepositoryProvider));
});

final pinCommentUseCaseProvider = Provider<PinCommentUseCase>((ref) {
  return PinCommentUseCase(ref.watch(liveStreamRepositoryProvider));
});

final getLeaderBoardUseCaseProvider = Provider<GetLeaderBoardUseCase>((ref) {
  return GetLeaderBoardUseCase(ref.watch(liveStreamRepositoryProvider));
});

final sendReactionUseCaseProvider = Provider<SendReactionUseCase>((ref) {
  return SendReactionUseCase(ref.watch(liveStreamRepositoryProvider));
});
