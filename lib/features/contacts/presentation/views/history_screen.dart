import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/features/calls/application/call_history_notifier.dart';
import 'package:lotus_connect/features/calls/domain/entities/call_log.dart';
import 'package:lotus_connect/features/contacts/application/contacts_notifier.dart';
import 'package:lotus_connect/features/contacts/presentation/widgets/history_card.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

class HistoryScreen extends ConsumerWidget {
  HistoryScreen({super.key});

  final todayLogs = <CallLog>[];
  final yesterdayLogs = <CallLog>[];
  final olderLogs = <CallLog>[];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(callHistoryProvider);
    final friendsState = ref.watch(contactsProvider);

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final yesterdayStart = todayStart.subtract(const Duration(days: 1));

    for (final log in historyState.history) {
      final localCreatedAt = log.createdAt.toLocal();
      final logDate = DateTime(
        localCreatedAt.year,
        localCreatedAt.month,
        localCreatedAt.day,
      );
      if (logDate.isAtSameMomentAs(todayStart)) {
        todayLogs.add(log);
      } else if (logDate.isAtSameMomentAs(yesterdayStart)) {
        yesterdayLogs.add(log);
      } else {
        olderLogs.add(log);
      }
    }

    final loc = AppLocalizations.of(context)!;
    if (todayLogs.isEmpty && yesterdayLogs.isEmpty && olderLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.call_missed_outgoing,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              loc.noCallHistoryLogs,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        if (todayLogs.isNotEmpty) ...[
          _buildHistorySectionHeader(loc.today),
          ...todayLogs.map(
            (log) => HistoryCard(
              log: log,
              friends: friendsState.friends,
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (yesterdayLogs.isNotEmpty) ...[
          _buildHistorySectionHeader(loc.yesterday),
          ...yesterdayLogs.map(
            (log) => HistoryCard(
              log: log,
              friends: friendsState.friends,
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (olderLogs.isNotEmpty) ...[
          _buildHistorySectionHeader(loc.older),
          ...olderLogs.map(
            (log) => HistoryCard(
              log: log,
              friends: friendsState.friends,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHistorySectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
