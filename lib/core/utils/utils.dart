String formatLastSeen(bool isOnline, DateTime lastSeen) {
  if (isOnline) {
    return 'Online';
  } else {
    return timeAgo(lastSeen);
  }
}

String timeAgo(DateTime? date) {
  if (date == null) return 'recently';
  final diff = DateTime.now().difference(date);
  if (diff.isNegative || diff.inSeconds < 60) {
    return 'Just now';
  }
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes}m ago';
  }
  if (diff.inHours < 24) {
    return '${diff.inHours}h ago';
  }
  if (diff.inDays < 7) {
    return '${diff.inDays}d ago';
  }
  if (diff.inDays < 30) {
    final weeks = (diff.inDays / 7).floor();
    return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
  }
  if (diff.inDays < 365) {
    final months = (diff.inDays / 30).floor();
    return '$months ${months == 1 ? 'month' : 'months'} ago';
  }
  final years = (diff.inDays / 365).floor();
  return '$years ${years == 1 ? 'year' : 'years'} ago';
}

bool isVideo(String path) {
  return path.contains('mp4') || path.contains('mov');
}

/// If optimistic message (not a server UUID), local delete is enough
final uuidRegex = RegExp(
  '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-'
  r'[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
);

bool isValidUrl(String path) {
  final uri = Uri.tryParse(path);
  return uri != null && uri.hasAbsolutePath && uri.host.isNotEmpty;
}
