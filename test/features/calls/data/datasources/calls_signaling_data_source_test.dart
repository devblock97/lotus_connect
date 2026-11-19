import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lotus_connect/core/errors/exception.dart';
import 'package:lotus_connect/core/services/webrtc/signaling_service.dart';
import 'package:lotus_connect/features/calls/data/datasources/calls_signaling_data_source.dart';
import 'package:mocktail/mocktail.dart';

class _MockSignalingService extends Mock implements WebRTCSignalingService {}

void main() {
  late _MockSignalingService mockSignaling;
  late StreamController<WebRTCCallInvitation> invitationController;
  late StreamController<Map<String, dynamic>> endController;
  late CallsSignalingDataSourceImpl dataSource;

  setUp(() {
    mockSignaling = _MockSignalingService();
    invitationController = StreamController<WebRTCCallInvitation>.broadcast();
    endController = StreamController<Map<String, dynamic>>.broadcast();

    when(() => mockSignaling.invitationStream)
        .thenAnswer((_) => invitationController.stream);
    when(() => mockSignaling.endStream).thenAnswer((_) => endController.stream);

    dataSource = CallsSignalingDataSourceImpl(signalingService: mockSignaling);
  });

  tearDown(() async {
    dataSource.dispose();
    await invitationController.close();
    await endController.close();
  });

  group('CallsSignalingDataSourceImpl', () {
    test('sendInvite checks connection and forwards channelId', () async {
      when(() => mockSignaling.ensureConnected()).thenAnswer((_) async => true);
      when(
        () => mockSignaling.sendInvite(
          recipientId: any(named: 'recipientId'),
          channelId: any(named: 'channelId'),
          isVideo: any(named: 'isVideo'),
          conversationId: any(named: 'conversationId'),
        ),
      ).thenReturn(null);

      await dataSource.sendInvite(
        targetUserId: 'peer-123',
        isVideo: true,
        channelId: 'room-42',
      );

      verify(() => mockSignaling.ensureConnected()).called(1);
      verify(
        () => mockSignaling.sendInvite(
          recipientId: 'peer-123',
          channelId: 'room-42',
          isVideo: true,
        ),
      ).called(1);
    });

    test('sendInvite throws NetworkException when WebSocket cannot connect',
        () async {
      when(() => mockSignaling.ensureConnected())
          .thenAnswer((_) async => false);

      await expectLater(
        () => dataSource.sendInvite(
          targetUserId: 'peer-123',
          isVideo: false,
          channelId: 'room-42',
        ),
        throwsA(isA<NetworkException>()),
      );

      verifyNever(
        () => mockSignaling.sendInvite(
          recipientId: any(named: 'recipientId'),
          channelId: any(named: 'channelId'),
          isVideo: any(named: 'isVideo'),
          conversationId: any(named: 'conversationId'),
        ),
      );
    });

    test('acceptCall throws NetworkException when WebSocket cannot connect',
        () async {
      when(() => mockSignaling.ensureConnected())
          .thenAnswer((_) async => false);

      await expectLater(
        () => dataSource.acceptCall(
          callId: 'call-1',
          targetUserId: 'peer-123',
        ),
        throwsA(isA<NetworkException>()),
      );

      verifyNever(
        () => mockSignaling.acceptCall(
          callId: any(named: 'callId'),
          recipientId: any(named: 'recipientId'),
        ),
      );
    });
  });
}
