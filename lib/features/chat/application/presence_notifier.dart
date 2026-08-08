import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Client-side state model representing a user's presence.
class UserPresence {
  const UserPresence({
    required this.isOnline,
    required this.lastSeen,
  });
  final bool isOnline;
  final DateTime lastSeen;

  UserPresence copyWith({
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return UserPresence(
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}

/// StateNotifier tracking online status maps by user ID.
class PresenceNotifier extends StateNotifier<Map<String, UserPresence>> {
  PresenceNotifier() : super({});

  /// Updates or inserts a user's presence state.
  void updatePresence(String userId, bool isOnline, DateTime lastSeen) {
    state = {
      ...state,
      userId: UserPresence(isOnline: isOnline, lastSeen: lastSeen),
    };
  }
}

/// Provider managing active user presence maps.
final presenceProvider =
    StateNotifierProvider<PresenceNotifier, Map<String, UserPresence>>((ref) {
  return PresenceNotifier();
});
