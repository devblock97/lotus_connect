import 'dart:io';

import 'package:lotus_connect/features/chat/domain/entities/media_entity.dart';

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

bool isVideoMedia(MediaEntity media) {
  final mime = media.mimeType?.toLowerCase() ?? '';
  if (mime.isNotEmpty) {
    if (mime.contains('video') ||
        mime == 'application/x-mpegurl' ||
        mime == 'application/vnd.apple.mpegurl') {
      return true;
    }
    if (mime.startsWith('image/')) {
      return false;
    }
  }

  final String pathToCheck;
  if (isNetworkUrl(media.url)) {
    pathToCheck = Uri.tryParse(media.url)?.path ?? media.url;
  } else {
    final uri = Uri.tryParse(media.url);
    pathToCheck =
        (uri != null && uri.scheme == 'file') ? uri.toFilePath() : media.url;
  }

  final lowerPath = pathToCheck.toLowerCase();
  return lowerPath.endsWith('.mp4') ||
      lowerPath.endsWith('.mov') ||
      lowerPath.endsWith('.m4v') ||
      lowerPath.endsWith('.webm') ||
      lowerPath.endsWith('.avi') ||
      lowerPath.endsWith('.mkv') ||
      lowerPath.endsWith('.3gp') ||
      lowerPath.endsWith('.m3u8');
}

bool isNetworkUrl(String url) {
  final uri = Uri.tryParse(url);
  return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
}

File resolveLocalFile(String path) {
  final uri = Uri.tryParse(path);
  if (uri != null && uri.scheme == 'file') {
    return File.fromUri(uri);
  }
  return File(path);
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
