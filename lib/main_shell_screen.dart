import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/app/theme/app_color.dart';
import 'package:lotus_connect/app/theme/app_size.dart';
import 'package:lotus_connect/core/services/webrtc/signaling_service.dart';
import 'package:lotus_connect/core/services/websocket/websocket_service.dart';
import 'package:lotus_connect/core/services/websocket/websocket_sync_coordinator.dart';
import 'package:lotus_connect/features/calls/application/calls_providers.dart';
import 'package:lotus_connect/features/calls/presentation/views/calls_screen.dart';
import 'package:lotus_connect/features/chill/presentation/view/chill_viewer_screen.dart';
import 'package:lotus_connect/features/contacts/presentation/views/contacts_screen.dart';
import 'package:lotus_connect/features/home/presentation/view/home_screen.dart';
import 'package:lotus_connect/features/notifications/application/notifications_notifier.dart';
import 'package:lotus_connect/features/notifications/presentation/view/notifications_screen.dart';
import 'package:lotus_connect/features/profile/presentation/views/profile_screen.dart';
import 'package:lotus_connect/features/settings/application/settings_notifier.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({
    this.pages,
    super.key,
  });

  @visibleForTesting
  final List<Widget>? pages;

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  String? _lastHandledCallId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = ref.read(settingsNotifierProvider).settings.accessToken;
      if (token.isNotEmpty) {
        ref.read(webSocketServiceProvider).connect();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(webSocketSyncCoordinatorProvider);

    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    ref
      ..listen<String>(
        settingsNotifierProvider.select((s) => s.settings.accessToken),
        (prev, next) {
          if (next.isNotEmpty) {
            ref.read(webSocketServiceProvider).connect();
          } else {
            ref.read(webSocketServiceProvider).disconnect();
          }
        },
      )
      // Open CallsScreen on incoming call when no call UI is already active
      ..listen<AsyncValue<WebRTCCallInvitation>>(
        incomingCallProvider,
        (prev, next) {
          final invite = next.valueOrNull;
          if (invite == null || !mounted || CallsScreen.isCurrentlyOpen) {
            return;
          }
          if (invite.callId.isNotEmpty && invite.callId == _lastHandledCallId) {
            return;
          }
          _lastHandledCallId = invite.callId;
          unawaited(
            Navigator.of(context, rootNavigator: true).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => CallsScreen(incomingInvitation: invite),
              ),
            ),
          );
        },
      );

    final shellIndex = ref.watch(shellIndexProvider);
    final unreadNotifications = ref.watch(
      notificationsProvider.select((s) => s.unreadCount),
    );

    final pages = widget.pages ??
        const [
          HomeScreen(),
          ChillViewerScreen(),
          ContactsScreen(),
          NotificationsScreen(),
          ProfileScreen(),
        ];

    return Scaffold(
      body: IndexedStack(
        index: shellIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: shellIndex,
        onDestinationSelected: (index) {
          ref.read(shellIndexProvider.notifier).state = index;
        },
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        indicatorColor: theme.colorScheme.primaryContainer,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_filled),
            label: loc.tabHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.video_camera_back_outlined),
            selectedIcon: const Icon(Icons.video_camera_back),
            label: loc.tabChats,
          ),
          NavigationDestination(
            icon: const Icon(Icons.perm_contact_cal_outlined),
            selectedIcon: const Icon(Icons.perm_contact_cal_sharp),
            label: loc.contacts,
          ),
          NavigationDestination(
            icon: Badge.count(
              count: unreadNotifications,
              isLabelVisible: unreadNotifications > 0,
              backgroundColor: AppColor.badgeRed.of(context),
              textColor: AppColor.white.of(context),
              child: const Icon(Icons.notifications_none_rounded),
            ),
            selectedIcon: Badge.count(
              count: unreadNotifications,
              isLabelVisible: unreadNotifications > 0,
              backgroundColor: AppColor.badgeRed.of(context),
              textColor: AppColor.white.of(context),
              child: const Icon(Icons.notifications),
            ),
            label: loc.tabAlerts,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: loc.tabProfile,
          ),
        ],
      ),
    );
  }
}

class PlaceholderTab extends StatelessWidget {
  const PlaceholderTab({
    required this.title,
    required this.icon,
    super.key,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppSize.iconHero,
              color: AppColor.inkMuted.of(context),
            ),
            AppGap.vLg,
            Text(
              '$title Feature',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            AppGap.vSm,
            Text(
              'This feature will be implemented in future',
              style: TextStyle(color: AppColor.inkMuted.of(context)),
            ),
          ],
        ),
      ),
    );
  }
}

/// StateProvider managing the active tab index inside MainShellScreen.
final shellIndexProvider = StateProvider<int>((ref) => 0);
