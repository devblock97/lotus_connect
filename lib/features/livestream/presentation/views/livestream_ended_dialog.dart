import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lotus_connect/app/theme/app_size.dart';
import 'package:lotus_connect/features/livestream/data/datasources/livestream_ws_service.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_stream.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

class LiveStreamEndedDialog extends StatelessWidget {
  const LiveStreamEndedDialog({
    required this.stream,
    this.endedEvent,
    this.onDone,
    super.key,
  });

  final LiveStream stream;
  final LiveEndedEvent? endedEvent;
  final VoidCallback? onDone;

  static Future<void> show(
    BuildContext context, {
    required LiveStream stream,
    LiveEndedEvent? endedEvent,
    VoidCallback? onDone,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => LiveStreamEndedDialog(
        stream: stream,
        endedEvent: endedEvent,
        onDone: onDone,
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final host = stream.host;
    final duration = endedEvent?.duration ?? stream.durationSeconds;
    final peakViewers = endedEvent?.peakViewers ?? stream.peakViewers;
    final totalLikes = endedEvent?.totalLikes ?? stream.likeCount;
    final totalViews = endedEvent?.totalViews ?? stream.totalViews;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: AppPadding.hXxl,
      child: Container(
        padding: AppPadding.dialog,
        decoration: BoxDecoration(
          color: const Color(0xFF161823),
          borderRadius: AppRadius.xxl,
          border: AppBorder.all(Colors.white12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: AppSize.xxl,
              offset: const Offset(0, AppSize.sm),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Host Avatar
            Container(
              width: AppSize.avatarXxl,
              height: AppSize.avatarXxl,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: AppBorder.all(
                  const Color(0xFFFF0844),
                  width: AppSize.borderThick,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: host.avatarUrl != null && host.avatarUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: host.avatarUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, dynamic ___) =>
                          Center(child: Text(host.initials)),
                    )
                  : Center(
                      child: Text(
                        host.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
            AppGap.vMd,

            Text(
              loc?.liveStreamEndedTitle ?? 'Live Stream Ended',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppGap.vXs,
            Text(
              stream.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
            AppGap.vXxl,

            // Statistics Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  loc?.streamDuration ?? 'Duration',
                  _formatDuration(duration),
                  Icons.timer_outlined,
                ),
                _buildStatItem(
                  loc?.peakViewers ?? 'Peak Viewers',
                  '$peakViewers',
                  Icons.people_alt_outlined,
                ),
                _buildStatItem(
                  loc?.totalLikes ?? 'Total Likes',
                  '$totalLikes',
                  Icons.favorite_border,
                ),
                _buildStatItem(
                  loc?.totalViews ?? 'Total Views',
                  '$totalViews',
                  Icons.remove_red_eye_outlined,
                ),
              ],
            ),
            AppGap.vXxxl,

            // Done Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF0844),
                  foregroundColor: Colors.white,
                  padding: AppPadding.vMd,
                  shape: AppBorder.rounded(),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Dismiss dialog
                  onDone?.call();
                },
                child: Text(
                  loc?.done ?? 'Done',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white60, size: AppSize.iconSm),
        AppGap.vXs,
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        AppGap.vXxs,
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
