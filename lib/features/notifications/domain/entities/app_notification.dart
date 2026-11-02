/// Categories of notifications for Facebook-style filtering and badging.
enum NotificationKind {
  like,
  love,
  comment,
  mention,
  friendRequest,
  friendAccept,
  missedCall,
  call,
  chat,
  livestream,
  post,
  story,
  system,
}

/// Top-level filter tabs in the Notifications screen.
enum NotificationFilter {
  all,
  unread,
  social,
  requests,
  callsAndChats,
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      data: json['data'] as Map<String, dynamic>?,
      isRead: json['isRead'] as bool? ?? json['is_read'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : json['created_at'] != null
              ? DateTime.tryParse(json['created_at'] as String) ??
                  DateTime.now()
              : DateTime.now(),
    );
  }

  final String id;
  final String userId;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  /// Resolves the semantic [NotificationKind] from `data['type']` or text.
  NotificationKind get kind {
    final rawType =
        (data?['type'] ?? data?['event'] ?? '').toString().toLowerCase();
    final combinedText = '$title $body'.toLowerCase();

    if (rawType.contains('missed_call') ||
        rawType == 'missedcall' ||
        combinedText.contains('missed call') ||
        combinedText.contains('missed voice call') ||
        combinedText.contains('missed video call')) {
      return NotificationKind.missedCall;
    }
    if (rawType.contains('call')) {
      return NotificationKind.call;
    }
    if (rawType == 'friend_request' ||
        rawType == 'friendrequest' ||
        combinedText.contains('friend request') ||
        combinedText.contains('sent you a request')) {
      return NotificationKind.friendRequest;
    }
    if (rawType == 'friend_accept' ||
        rawType == 'friendaccept' ||
        combinedText.contains('accepted your friend request') ||
        combinedText.contains('are now friends')) {
      return NotificationKind.friendAccept;
    }
    if (rawType == 'love' || rawType == 'heart') {
      return NotificationKind.love;
    }
    if (rawType.contains('like') ||
        rawType.contains('reaction') ||
        combinedText.contains('liked your') ||
        combinedText.contains('reacted to your')) {
      return NotificationKind.like;
    }
    if (rawType.contains('mention') ||
        rawType.contains('tag') ||
        combinedText.contains('mentioned you') ||
        combinedText.contains('tagged you')) {
      return NotificationKind.mention;
    }
    if (rawType.contains('comment') ||
        rawType.contains('reply') ||
        combinedText.contains('commented on') ||
        combinedText.contains('replied to')) {
      return NotificationKind.comment;
    }
    if (rawType.contains('live') ||
        rawType.contains('stream') ||
        combinedText.contains('is live') ||
        combinedText.contains('started a live')) {
      return NotificationKind.livestream;
    }
    if (rawType.contains('story')) {
      return NotificationKind.story;
    }
    if (rawType.contains('post')) {
      return NotificationKind.post;
    }
    if (rawType.contains('chat') ||
        rawType.contains('message') ||
        combinedText.contains('sent you a message') ||
        combinedText.contains('new message')) {
      return NotificationKind.chat;
    }
    return NotificationKind.system;
  }

  /// Checks whether this notification matches the given [filter].
  bool matchesFilter(NotificationFilter filter) {
    switch (filter) {
      case NotificationFilter.all:
        return true;
      case NotificationFilter.unread:
        return !isRead;
      case NotificationFilter.social:
        return kind == NotificationKind.like ||
            kind == NotificationKind.love ||
            kind == NotificationKind.comment ||
            kind == NotificationKind.mention ||
            kind == NotificationKind.post ||
            kind == NotificationKind.story ||
            kind == NotificationKind.livestream;
      case NotificationFilter.requests:
        return kind == NotificationKind.friendRequest ||
            kind == NotificationKind.friendAccept;
      case NotificationFilter.callsAndChats:
        return kind == NotificationKind.missedCall ||
            kind == NotificationKind.call ||
            kind == NotificationKind.chat;
    }
  }

  /// Optional actor name extracted from notification payload.
  String? get actorName {
    final raw = data?['senderName'] ??
        data?['actorName'] ??
        data?['callerName'] ??
        data?['fullName'] ??
        data?['username'] ??
        data?['sender_name'] ??
        data?['actor_name'];
    if (raw is String && raw.trim().isNotEmpty) {
      return raw.trim();
    }
    return null;
  }

  /// Optional actor avatar URL extracted from notification payload.
  String? get actorAvatarUrl {
    final raw = data?['senderAvatar'] ??
        data?['avatarUrl'] ??
        data?['actorAvatar'] ??
        data?['userAvatar'] ??
        data?['sender_avatar'] ??
        data?['avatar_url'];
    if (raw is String && raw.trim().isNotEmpty) {
      return raw.trim();
    }
    return null;
  }

  /// Optional actor user ID extracted from notification payload.
  String? get actorId {
    final raw = data?['senderId'] ??
        data?['actorId'] ??
        data?['callerId'] ??
        data?['fromUserId'] ??
        data?['sender_id'] ??
        data?['actor_id'];
    if (raw is String && raw.trim().isNotEmpty) {
      return raw.trim();
    }
    return null;
  }

  /// Optional conversation ID for chat notifications.
  String? get conversationId {
    final raw = data?['conversationId'] ?? data?['conversation_id'];
    if (raw is String && raw.trim().isNotEmpty) {
      return raw.trim();
    }
    return null;
  }

  /// Optional preview thumbnail URL (e.g., for post/story notifications).
  String? get previewImageUrl {
    final raw = data?['thumbnailUrl'] ??
        data?['imageUrl'] ??
        data?['mediaUrl'] ??
        data?['thumbnail_url'];
    if (raw is String && raw.trim().isNotEmpty) {
      return raw.trim();
    }
    return null;
  }

  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    bool? isRead,
    Map<String, dynamic>? data,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
