import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/network/dio_client.dart';
import 'package:lotus_connect/features/livestream/data/datasources/livestream_remote_data_source.dart';
import 'package:lotus_connect/features/livestream/data/repositories/livestream_repository_impl.dart';
import 'package:lotus_connect/features/livestream/domain/repositories/livestream_repository.dart';
import 'package:lotus_connect/features/livestream/domain/usecases/create_stream_use_case.dart';
import 'package:lotus_connect/features/livestream/domain/usecases/get_streams_use_case.dart';
import 'package:lotus_connect/features/livestream/domain/usecases/start_stream_use_case.dart';

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
