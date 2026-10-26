import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF161823),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Host Avatar
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFF0844), width: 2),
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
            const SizedBox(height: 12),

            Text(
              loc?.liveStreamEndedTitle ?? 'Live Stream Ended',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
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
            const SizedBox(height: 24),

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
            const SizedBox(height: 28),

            // Done Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF0844),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
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
        Icon(icon, color: Colors.white60, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
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
