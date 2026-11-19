import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/calls/domain/entities/call_log.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/conversation.dart';

/// Resolves a safe, non-empty display name and initial for a call peer.
({String displayName, String initial}) resolveCallPeerDisplay({
  required List<User> friends,
  required String? peerId,
}) {
  final friend = peerId == null || peerId.isEmpty
      ? null
      : friends.where((f) => f.id == peerId).firstOrNull;

  final fullName = friend?.fullName?.trim();
  final username = friend?.username.trim();

  final String displayName;
  if (fullName != null && fullName.isNotEmpty) {
    displayName = fullName;
  } else if (username != null && username.isNotEmpty) {
    displayName = username;
  } else if (peerId != null && peerId.isNotEmpty) {
    displayName = peerId.length > 8 ? peerId.substring(0, 8) : peerId;
  } else {
    displayName = 'User';
  }

  final initial = displayName.substring(0, 1).toUpperCase();
  return (displayName: displayName, initial: initial);
}

/// Resolves the remote peer's user ID from a [CallLog] record.
String resolveCallLogPeerId({
  required CallLog log,
  required String currentUserId,
  required List<User> friends,
  List<Conversation>? conversations,
  String? currentUsername,
  String? currentFullName,
}) {
  if (log.hostId.isNotEmpty && log.hostId != currentUserId) {
    return log.hostId;
  }
  if (log.peerId != null && log.peerId!.isNotEmpty) {
    return log.peerId!;
  }
  if (log.conversationId != null && conversations != null) {
    for (final c in conversations) {
      if (c.id == log.conversationId && c.isUserToUser && c.peerId.isNotEmpty) {
        return c.peerId;
      }
    }
  }
  final username = log.username?.trim();
  if (username != null && username.isNotEmpty && username != currentUsername) {
    for (final f in friends) {
      if (f.username == username && f.id.isNotEmpty) {
        return f.id;
      }
    }
  }
  final hostName = log.hostName?.trim();
  if (hostName != null &&
      hostName.isNotEmpty &&
      hostName != currentFullName &&
      hostName != currentUsername) {
    for (final f in friends) {
      if ((f.fullName == hostName || f.username == hostName) &&
          f.id.isNotEmpty) {
        return f.id;
      }
    }
  }
  return '';
}
