import 'package:intl/intl.dart';

String formatLastSeen(bool isOnline, DateTime lastSeen) {
  if (isOnline) {
    return 'Online';
  } else {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inSeconds < 60) {
      return 'active just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return 'active $minutes minute${minutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return 'active $hours hour${hours == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 30) {
      final days = difference.inDays;
      return 'active $days day${days == 1 ? '' : 's'} ago';
    } else {
      return 'active on ${DateFormat('MMM d, yyyy').format(lastSeen)}';
    }
  }
}
