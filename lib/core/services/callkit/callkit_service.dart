import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Centralized service to manage native iOS CallKit & Android CallKit incoming/outgoing UI,
/// full-screen intent permissions, and call event stream listeners.
class CallKitService {
  CallKitService();

  static const MethodChannel _foregroundChannel =
      MethodChannel('devblock.tech.lotus_connect/foreground');

  String? currentCallId;

  /// Requests Full Intent Permission for Android 14+ devices.
  static Future<void> requestFullIntentPermission() async {
    try {
      await FlutterCallkitIncoming.requestFullIntentPermission();
    } catch (e) {
      debugPrint('CallKitService requestFullIntentPermission error: $e');
    }
  }

  /// Displays full-screen native CallKit incoming call UI (Lock Screen & Background).
  static Future<void> showCallkitIncoming({
    required String callId,
    required String callerName,
    bool isVideo = false,
    String? avatar,
    String? handle,
    Map<String, dynamic>? extra,
  }) async {
    try {
      final params = CallKitParams(
        id: callId,
        nameCaller: callerName,
        appName: 'LotusConnect',
        avatar: avatar ??
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500',
        handle: handle ?? callerName,
        type: isVideo ? 1 : 0, // 0: Voice, 1: Video
        duration: 30000,
        missedCallNotification: const NotificationParams(
          showNotification: true,
          isShowCallback: true,
          subtitle: 'Missed call',
          callbackText: 'Call back',
        ),
        extra: extra ??
            <String, dynamic>{
              'callId': callId,
              'callerName': callerName,
              'isVideo': isVideo,
            },
        headers: <String, dynamic>{'platform': defaultTargetPlatform.name},
        android: const AndroidParams(
          isCustomNotification: true,
          isShowLogo: true,
          ringtonePath: 'system_ringtone_default',
          backgroundColor: '#095D40',
          actionColor: '#4CAF50',
          textColor: '#ffffff',
        ),
        ios: const IOSParams(
          iconName: 'CallKitIcon',
          handleType: 'generic',
          supportsVideo: true,
          maximumCallGroups: 1,
          maximumCallsPerCallGroup: 1,
          audioSessionMode: 'default',
          audioSessionActive: true,
          audioSessionPreferredSampleRate: 44100,
          audioSessionPreferredIOBufferDuration: 0.005,
          supportsDTMF: true,
          supportsHolding: true,
          supportsGrouping: false,
          supportsUngrouping: false,
          ringtonePath: 'system_ringtone_default',
        ),
      );

      await FlutterCallkitIncoming.showCallkitIncoming(params);
    } catch (e) {
      debugPrint('CallKitService showCallkitIncoming error: $e');
    }
  }

  /// Triggers native CallKit outgoing call UI.
  Future<void> startCall({
    required String callId,
    required String callerName,
    bool isVideo = false,
    Map<String, dynamic>? extra,
  }) async {
    try {
      currentCallId = callId;
      final params = CallKitParams(
        id: callId,
        nameCaller: callerName,
        handle: callerName,
        type: isVideo ? 1 : 0,
        extra: extra,
      );
      await FlutterCallkitIncoming.startCall(params);
    } catch (e) {
      debugPrint('CallKitService startCall error: $e');
    }
  }

  /// Ends a native CallKit call session by callId.
  Future<void> endCall(String callId) async {
    try {
      await FlutterCallkitIncoming.endCall(callId);
      if (currentCallId == callId) {
        currentCallId = null;
      }
    } catch (e) {
      debugPrint('CallKitService endCall error: $e');
    }
  }

  /// Ends all active native CallKit sessions.
  Future<void> endAllCalls() async {
    try {
      await FlutterCallkitIncoming.endAllCalls();
      currentCallId = null;
    } catch (e) {
      debugPrint('CallKitService endAllCalls error: $e');
    }
  }

  /// Brings LotusConnect app window to the foreground via native platform channel.
  Future<void> bringAppToForeground() async {
    try {
      await _foregroundChannel.invokeMethod('bringToForeground');
    } catch (e) {
      debugPrint('CallKitService bringAppToForeground error: $e');
    }
  }

  /// Listens to CallKit stream events (Accept, Decline, Timeout, Callback).
  void initializeCallKitListeners({
    required void Function(Map<String, dynamic> extra) onCallAccepted,
    void Function(Map<String, dynamic> extra)? onCallDeclined,
  }) {
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
      if (event == null) return;

      if (event is CallEventActionCallAccept) {
        debugPrint('CallKitService: Call accepted by user');
        await bringAppToForeground();
        final extra = event.callKitParams.extra ?? <String, dynamic>{};
        onCallAccepted(extra);
      } else if (event is CallEventActionCallDecline) {
        debugPrint('CallKitService: Call declined by user');
        final extra = event.callKitParams.extra ?? <String, dynamic>{};
        onCallDeclined?.call(extra);
      } else if (event is CallEventActionCallCallback) {
        debugPrint('CallKitService: Call callback tapped');
        await bringAppToForeground();
      }
    });
  }

  /// Retrieves current active call params if app was opened from background or cold start.
  Future<CallKitParams?> getCurrentCall() async {
    try {
      final calls = await FlutterCallkitIncoming.activeCalls();
      if (calls.isNotEmpty) {
        final firstCall = Map<String, dynamic>.from(calls.first as Map);
        final isAccepted = firstCall['isAccepted'] == true;
        if (isAccepted) {
          currentCallId = firstCall['id'] as String? ?? '';
          return CallKitParams.fromJson(firstCall);
        }
      }
      currentCallId = null;
      return null;
    } catch (e) {
      debugPrint('CallKitService getCurrentCall error: $e');
      currentCallId = null;
      return null;
    }
  }

  /// Fetches iOS VoIP Push Device Token.
  Future<String?> getDevicePushTokenVoIP() async {
    try {
      return await FlutterCallkitIncoming.getDevicePushTokenVoIP();
    } catch (e) {
      debugPrint('CallKitService getDevicePushTokenVoIP error: $e');
      return null;
    }
  }
}

/// Riverpod provider for CallKitService.
final callKitServiceProvider = Provider<CallKitService>((ref) {
  return CallKitService();
});
