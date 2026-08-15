import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/services/api/chat_api_service.dart';
import 'package:lotus_connect/core/services/callkit/callkit_service.dart';
import 'package:lotus_connect/firebase_options.dart';
import 'package:uuid/uuid.dart';

const AndroidNotificationChannel _kHighImportanceChannel =
    AndroidNotificationChannel(
  'lotus_connect_high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notification alerts.',
  importance: Importance.max,
);

final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundEntryPoint(
  RemoteMessage message,
) async {
  debugPrint('FCM: Background entry point message ${message.messageId}');
  try {
    if (Firebase.apps.isEmpty) {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        try {
          await Firebase.initializeApp();
        } catch (_) {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
        }
      } else {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
    }
  } on Object catch (e) {
    debugPrint('FCM Background entry point initialization note: $e');
  }

  final data = message.data;
  final type = data['type'] as String? ?? '';

  debugPrint('====================================================');
  debugPrint('[FCM BACKGROUND/TERMINATED PUSH RECEIVED]');
  debugPrint('Message ID: ${message.messageId}');
  debugPrint('Data Payload: $data');
  debugPrint('Notification Title: ${message.notification?.title}');
  debugPrint('Notification Body: ${message.notification?.body}');
  debugPrint('Parsed Event Type: "$type"');
  debugPrint('====================================================');

  if (type == 'call_invite') {
    final callId = data['callId'] as String? ?? const Uuid().v4();
    final callerName = data['callerName'] as String? ?? 'Incoming Call';
    final isVideo = data['isVideo'] == 'true';

    debugPrint(
      '[FCM Background] Triggering CallKit Incoming UI for callId: $callId, caller: $callerName',
    );
    await CallKitService.showCallkitIncoming(
      callId: callId,
      callerName: callerName,
      isVideo: isVideo,
      extra: data,
    );
  } else {
    // Show local notification for general chat messages in background
    final notification = message.notification;
    final title = notification?.title ??
        data['title'] as String? ??
        data['senderName'] as String? ??
        'LotusConnect';
    final body = notification?.body ??
        data['body'] as String? ??
        data['content'] as String? ??
        'New message received';

    debugPrint(
      '[FCM Background] Displaying Chat Banner -> Title: "$title", Body: "$body"',
    );
    await _showLocalNotificationBanner(
      id: message.messageId.hashCode,
      title: title,
      body: body,
      payload: data.toString(),
    );
  }
}

Future<void> _showLocalNotificationBanner({
  required int id,
  required String title,
  required String body,
  String? payload,
}) async {
  const androidDetails = AndroidNotificationDetails(
    'lotus_connect_high_importance_channel',
    'High Importance Notifications',
    channelDescription:
        'This channel is used for important notification alerts.',
    importance: Importance.max,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  const darwinDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  const notificationDetails = NotificationDetails(
    android: androidDetails,
    iOS: darwinDetails,
    macOS: darwinDetails,
  );

  await _localNotificationsPlugin.show(
    id: id,
    title: title,
    body: body,
    notificationDetails: notificationDetails,
    payload: payload,
  );
}

class PushNotificationService {
  PushNotificationService({
    required this.chatApiService,
    required this.callKitService,
  });

  final ChatApiService chatApiService;
  final CallKitService callKitService;

  Future<void> initialize({
    void Function(Map<String, dynamic> data)? onNotificationTap,
    void Function(Map<String, dynamic> extra)? onCallAccepted,
  }) async {
    await _initializeFirebaseSafely();

    await _requestPermissions();

    await _setupLocalNotifications(onNotificationTap: onNotificationTap);

    if (onCallAccepted != null) {
      callKitService.initializeCallKitListeners(
        onCallAccepted: onCallAccepted,
      );
    }

    // Register FCM background message handler
    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundEntryPoint,
    );

    // Register foreground message listener
    _setupForegroundMessageListener();

    // Handle notification click interaction (background & terminated states)
    await _setupNotificationInteractionHandlers(
      onNotificationTap: onNotificationTap,
    );

    await syncDeviceToken();

    // 8. Listen to token refreshes
    FirebaseMessaging.instance.onTokenRefresh.listen(_registerTokenToBackend);
  }

  Future<void> _initializeFirebaseSafely() async {
    try {
      if (Firebase.apps.isEmpty) {
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          try {
            await Firebase.initializeApp();
          } on Object catch (_) {
            await Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform,
            );
          }
        } else {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
        }
      }
    } on Object catch (e) {
      debugPrint('PushNotificationService Firebase init note: $e');
    }
  }

  Future<void> _requestPermissions() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission();
      debugPrint(
        'PushNotificationService Permission status: ${settings.authorizationStatus}',
      );
    } on Object catch (e) {
      debugPrint('PushNotificationService Permission error: $e');
    }
  }

  Future<void> _setupLocalNotifications({
    void Function(Map<String, dynamic> data)? onNotificationTap,
  }) async {
    try {
      final androidImplementation =
          _localNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation
            .createNotificationChannel(_kHighImportanceChannel);
        await androidImplementation.requestNotificationsPermission();
      }

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinInit = DarwinInitializationSettings();
      const initSettings = InitializationSettings(
        android: androidInit,
        iOS: darwinInit,
        macOS: darwinInit,
      );

      await _localNotificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) async {
          debugPrint(
            'PushNotificationService Local Notification Tapped: ${response.payload}',
          );
          await callKitService.bringAppToForeground();
        },
      );
    } on Object catch (e) {
      debugPrint('PushNotificationService Local Notifications setup error: $e');
    }
  }

  void _setupForegroundMessageListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final data = message.data;
      final type = data['type'] as String? ?? '';

      debugPrint('====================================================');
      debugPrint('[FCM FOREGROUND PUSH RECEIVED]');
      debugPrint('Message ID: ${message.messageId}');
      debugPrint('Data Payload: $data');
      debugPrint('Notification Title: ${message.notification?.title}');
      debugPrint('Notification Body: ${message.notification?.body}');
      debugPrint('Parsed Event Type: "$type"');
      debugPrint('====================================================');

      if (type == 'call_invite') {
        final callId = data['callId'] as String? ?? const Uuid().v4();
        final callerName = data['callerName'] as String? ?? 'Incoming Call';
        final isVideo = data['isVideo'] == 'true';

        debugPrint(
          '[FCM Foreground] Launching CallKit Overlay for callId: $callId',
        );
        await CallKitService.showCallkitIncoming(
          callId: callId,
          callerName: callerName,
          isVideo: isVideo,
          extra: data,
        );
      } else {
        final notification = message.notification;
        final title = notification?.title ??
            data['title'] as String? ??
            data['senderName'] as String? ??
            'LotusConnect';
        final body = notification?.body ??
            data['body'] as String? ??
            data['content'] as String? ??
            'New message received';

        debugPrint(
          '[FCM Foreground] Displaying Local Banner -> Title: "$title", Body: "$body"',
        );
        await _showLocalNotificationBanner(
          id: message.messageId.hashCode,
          title: title,
          body: body,
          payload: data.toString(),
        );
      }
    });
  }

  Future<void> _setupNotificationInteractionHandlers({
    void Function(Map<String, dynamic> data)? onNotificationTap,
  }) async {
    // App opened from background state by tapping notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      debugPrint(
        '[FCM Notification Tapped] Opened App from Background -> Data: ${message.data}',
      );
      await callKitService.bringAppToForeground();
      onNotificationTap?.call(message.data);
    });

    // App opened from terminated cold start state by tapping notification
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint(
        '[FCM Initial Notification Tapped] Cold Start from Terminated State -> Data: ${initialMessage.data}',
      );
      await callKitService.bringAppToForeground();
      onNotificationTap?.call(initialMessage.data);
    }
  }

  /// Syncs current FCM token to backend database.
  Future<void> syncDeviceToken() async {
    try {
      debugPrint('[FCM Token Sync] Fetching FCM device token...');
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        debugPrint('[FCM Token Sync] Retrieved token: $token');
        await _registerTokenToBackend(token);
      } else {
        debugPrint('[FCM Token Sync] Token is null or empty');
      }
    } on Object catch (e) {
      debugPrint('[FCM Token Sync Error]: $e');
    }
  }

  Future<void> _registerTokenToBackend(String token) async {
    try {
      final platform = defaultTargetPlatform.name;
      debugPrint(
        '[FCM Token Sync] Registering token with backend POST /users/devices ($platform)...',
      );
      await chatApiService.registerDeviceToken(
        token: token,
        platform: platform,
      );
      debugPrint(
        '[FCM Token Sync Success] Token registered to backend ($platform)',
      );
    } on Object catch (e) {
      debugPrint(
        '[FCM Token Sync Deferred] User not authenticated or server error: $e',
      );
    }
  }

  Future<void> unregisterDeviceToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        debugPrint(
          '[FCM Token Unregister] Unregistering token from backend...',
        );
        await chatApiService.unregisterDeviceToken(token: token);
        debugPrint(
          '[FCM Token Unregister Success] Token unregistered from backend',
        );
      }
    } on Object catch (e) {
      debugPrint('[FCM Token Unregister Error]: $e');
    }
  }
}

final pushNotificationServiceProvider =
    Provider<PushNotificationService>((ref) {
  final chatApiService = ref.watch(chatApiServiceProvider);
  final callKitService = ref.watch(callKitServiceProvider);
  return PushNotificationService(
    chatApiService: chatApiService,
    callKitService: callKitService,
  );
});
