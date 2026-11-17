import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/app/theme/app_color.dart';
import 'package:lotus_connect/app/theme/app_size.dart';
import 'package:lotus_connect/features/calls/application/call_history_notifier.dart';
import 'package:lotus_connect/features/calls/domain/entities/call_log.dart';
import 'package:lotus_connect/features/contacts/application/contacts_notifier.dart';
import 'package:lotus_connect/features/contacts/presentation/widgets/history_card.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayLogs = <CallLog>[];
    final yesterdayLogs = <CallLog>[];
    final olderLogs = <CallLog>[];
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
              size: AppSize.iconHero,
              color: AppColor.inkSubtle.of(context),
            ),
            AppGap.vLg,
            Text(
              loc.noCallHistoryLogs,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColor.inkMutedDark.of(context),
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSize.screenPadding,
        vertical: AppSize.sm,
      ),
      children: [
        if (todayLogs.isNotEmpty) ...[
          _buildHistorySectionHeader(context, loc.today),
          ...todayLogs.map(
            (log) => HistoryCard(
              log: log,
              friends: friendsState.friends,
            ),
          ),
          AppGap.vMd,
        ],
        if (yesterdayLogs.isNotEmpty) ...[
          _buildHistorySectionHeader(context, loc.yesterday),
          ...yesterdayLogs.map(
            (log) => HistoryCard(
              log: log,
              friends: friendsState.friends,
            ),
          ),
          AppGap.vMd,
        ],
        if (olderLogs.isNotEmpty) ...[
          _buildHistorySectionHeader(context, loc.older),
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

  Widget _buildHistorySectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSize.sm,
        horizontal: AppSize.xs,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColor.inkMuted.of(context),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
