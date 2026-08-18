import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/services/webrtc/signaling_service.dart';
import 'package:lotus_connect/features/calls/data/data_sources/calls_remote_data_source.dart';
import 'package:lotus_connect/features/calls/data/data_sources/calls_signaling_data_source.dart';
import 'package:lotus_connect/features/calls/data/repositories/calls_repository_impl.dart';
import 'package:lotus_connect/features/calls/domain/repositories/calls_repository.dart';
import 'package:lotus_connect/features/calls/domain/usecases/accept_call_usecase.dart';
import 'package:lotus_connect/features/calls/domain/usecases/end_call_usecase.dart';
import 'package:lotus_connect/features/calls/domain/usecases/get_call_history_usecase.dart';
import 'package:lotus_connect/features/calls/domain/usecases/initiate_call_usecase.dart';
import 'package:lotus_connect/features/calls/domain/usecases/send_sdp_usecase.dart';
import 'package:lotus_connect/features/chatbot/application/providers.dart';

/// Provider for CallsRemoteDataSource.
final callsRemoteDataSourceProvider = Provider<CallsRemoteDataSource>((ref) {
  return CallsRemoteDataSourceImpl(
    dioClient: ref.watch(dioClientProvider),
  );
});

/// Provider for CallsSignalingDataSource.
final callsSignalingDataSourceProvider =
    Provider<CallsSignalingDataSource>((ref) {
  return CallsSignalingDataSourceImpl(
    signalingService: ref.watch(webrtcSignalingServiceProvider),
  );
});

/// Provider for CallsRepository.
final callsRepositoryProvider = Provider<CallsRepository>((ref) {
  return CallsRepositoryImpl(
    remoteDataSource: ref.watch(callsRemoteDataSourceProvider),
    signalingDataSource: ref.watch(callsSignalingDataSourceProvider),
  );
});

/// Provider for GetCallHistoryUseCase.
final getCallHistoryUseCaseProvider = Provider<GetCallHistoryUseCase>((ref) {
  return GetCallHistoryUseCase(ref.watch(callsRepositoryProvider));
});

/// Provider for InitiateCallUseCase.
final initiateCallUseCaseProvider = Provider<InitiateCallUseCase>((ref) {
  return InitiateCallUseCase(ref.watch(callsRepositoryProvider));
});

/// Provider for AcceptCallUseCase.
final acceptCallUseCaseProvider = Provider<AcceptCallUseCase>((ref) {
  return AcceptCallUseCase(ref.watch(callsRepositoryProvider));
});

/// Provider for EndCallUseCase.
final endCallUseCaseProvider = Provider<EndCallUseCase>((ref) {
  return EndCallUseCase(ref.watch(callsRepositoryProvider));
});

/// Provider for SendSdpUseCase.
final sendSdpUseCaseProvider = Provider<SendSdpUseSase>((ref) {
  return SendSdpUseSase(repository: ref.watch(callsRepositoryProvider));
});
