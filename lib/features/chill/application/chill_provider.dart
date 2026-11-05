import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/network/dio_client.dart';
import 'package:lotus_connect/features/chill/chill.dart';

final chillRemoteDataSourceProvider = Provider<ChillRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return ChillRemoteDataSourceImpl(dioClient: dio);
});

final chillRepositoryProvider = Provider<ChillRepository>((ref) {
  final remoteDataSource = ref.watch(chillRemoteDataSourceProvider);
  return ChillRepositoryImpl(remoteDataSource: remoteDataSource);
});

final getChillFeedUseCaseProvider = Provider<GetChillFeedUseCase>((ref) {
  return GetChillFeedUseCase(repository: ref.watch(chillRepositoryProvider));
});

final getExploreChillsUseCaseProvider =
    Provider<GetExploreChillsUseCase>((ref) {
  return GetExploreChillsUseCase(
    repository: ref.watch(chillRepositoryProvider),
  );
});

final getChillByIdUseCaseProvider = Provider<GetChillByIdUseCase>((ref) {
  return GetChillByIdUseCase(repository: ref.watch(chillRepositoryProvider));
});

final getUserChillsUseCaseProvider = Provider<GetUserChillsUseCase>((ref) {
  return GetUserChillsUseCase(repository: ref.watch(chillRepositoryProvider));
});

final getMyChillsUseCaseProvider = Provider<GetMyChillsUseCase>((ref) {
  return GetMyChillsUseCase(repository: ref.watch(chillRepositoryProvider));
});

final createChillUseCaseProvider = Provider<CreateChillUseCase>((ref) {
  return CreateChillUseCase(repository: ref.watch(chillRepositoryProvider));
});

final updateChillUseCaseProvider = Provider<UpdateChillUseCase>((ref) {
  return UpdateChillUseCase(repository: ref.watch(chillRepositoryProvider));
});

final deleteChillUseCaseProvider = Provider<DeleteChillUseCase>((ref) {
  return DeleteChillUseCase(repository: ref.watch(chillRepositoryProvider));
});

final toggleLikeChillUseCaseProvider = Provider<ToggleLikeChillUseCase>((ref) {
  return ToggleLikeChillUseCase(repository: ref.watch(chillRepositoryProvider));
});

final toggleSaveChillUseCaseProvider = Provider<ToggleSaveChillUseCase>((ref) {
  return ToggleSaveChillUseCase(repository: ref.watch(chillRepositoryProvider));
});

final recordChillViewUseCaseProvider = Provider<RecordChillViewUseCase>((ref) {
  return RecordChillViewUseCase(repository: ref.watch(chillRepositoryProvider));
});

final shareChillUseCaseProvider = Provider<ShareChillUseCase>((ref) {
  return ShareChillUseCase(repository: ref.watch(chillRepositoryProvider));
});

final uploadChillVideoUseCaseProvider =
    Provider<UploadChillVideoUseCase>((ref) {
  return UploadChillVideoUseCase(
    repository: ref.watch(chillRepositoryProvider),
  );
});

final chillNotifierProvider =
    StateNotifierProvider.autoDispose<ChillNotifier, ChillState>((ref) {
  return ChillNotifier(
    getChillFeedUseCase: ref.watch(getChillFeedUseCaseProvider),
    toggleLikeChillUseCase: ref.watch(toggleLikeChillUseCaseProvider),
    toggleSaveChillUseCase: ref.watch(toggleSaveChillUseCaseProvider),
    shareChillUseCase: ref.watch(shareChillUseCaseProvider),
    recordChillViewUseCase: ref.watch(recordChillViewUseCaseProvider),
    deleteChillUseCase: ref.watch(deleteChillUseCaseProvider),
    createChillUseCase: ref.watch(createChillUseCaseProvider),
    updateChillUseCase: ref.watch(updateChillUseCaseProvider),
  );
});
