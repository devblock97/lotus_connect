import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lotus_connect/features/notfications/application/notifications_notifier.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Alerts',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          if (state.notifications.any((n) => !n.isRead))
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Mark all as read',
              onPressed: () =>
                  ref.read(notificationsProvider.notifier).markAllRead(),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () =>
                ref.read(notificationsProvider.notifier).loadNotifications(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(notificationsProvider.notifier).loadNotifications(),
        child: state.isLoading && state.notifications.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : state.notifications.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.notifications.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final notification = state.notifications[index];
                      return _buildAlertCard(context, ref, theme, notification);
                    },
                  ),
      ),
    );
  }

  Widget _buildAlertCard(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppNotification notification,
  ) {
    final isMissedCall = notification.data?['type'] == 'missed_call';
    final timeText = DateFormat.MMMd().add_jm().format(notification.createdAt);

    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: notification.isRead
              ? Colors.grey.shade100
              : theme.colorScheme.primary.withValues(alpha: 0.15),
          width: notification.isRead ? 1 : 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (!notification.isRead) {
            ref
                .read(notificationsProvider.notifier)
                .readNotification(notification.id);
          }

          final data = notification.data;
          // if (data != null) {
          //   if (data['type'] == 'chat') {
          //     final conversationId = data['conversationId'] as String?;
          //     if (conversationId != null) {
          //       // Select conversation and route to it
          //       ref
          //           .read(privateConversationListProvider.notifier)
          //           .selectConversation(conversationId);
          //       ref.read(shellIndexProvider.notifier).state =
          //           1; // Switch bottom tab to Chats
          //       Navigator.of(context).push(
          //         MaterialPageRoute<void>(
          //           builder: (_) => ChatScreen(conversationId: conversationId),
          //         ),
          //       );
          //     }
          //   } else if (data['type'] == 'missed_call') {
          //     ref.read(shellIndexProvider.notifier).state =
          //         2; // Switch bottom tab to Calls history
          //   }
          // }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: isMissedCall
                    ? Colors.red.shade50
                    : theme.colorScheme.primary.withValues(alpha: 0.1),
                child: Icon(
                  isMissedCall ? Icons.call_missed : Icons.chat_bubble_outline,
                  color: isMissedCall ? Colors.red : theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead
                                  ? FontWeight.w600
                                  : FontWeight.bold,
                              fontSize: 15,
                              color: notification.isRead
                                  ? Colors.black87
                                  : Colors.black,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(
                        color: notification.isRead
                            ? Colors.grey.shade600
                            : Colors.black87,
                        fontSize: 13,
                        fontWeight: notification.isRead
                            ? FontWeight.normal
                            : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      timeText,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'All caught up!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "You don't have any alerts at the moment.",
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
