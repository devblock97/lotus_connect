import 'package:lotus_connect/app/config/app_config.dart';

/// Network and API constants for Lotus Connect.
class ApiConstants {
  const ApiConstants._();

  /// Default API base URL for Lotus Connect backend services.
  static const String baseUrl = AppConfig.defaultServerHost;

  // ---------------------------------------------------------------------------
  // Auth endpoints
  // ---------------------------------------------------------------------------
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';

  // ---------------------------------------------------------------------------
  // Contacts & Friends endpoints
  // ---------------------------------------------------------------------------
  static const String friends = '/users/friends';
  static const String acceptFriend = '/users/friends/accept';
  static const String rejectFriend = '/users/friends/reject';
  static String deleteFriend(String friendId) => '/users/friends/$friendId';
  static const String friendRequests = '/users/friends/requests';
  static const String searchUsers = '/users/search';
  static const String closeFriends = '/users/close-friends';
  static String removeCloseFriend(String friendId) =>
      '/users/close-friends/$friendId';

  // ---------------------------------------------------------------------------
  // Profile endpoints
  // ---------------------------------------------------------------------------
  static const String myProfile = '/users/me';
  static const String updateMyProfile = '/users/me';
  static const String uploadAvatar = '/users/avatar';
  static const String uploadCover = '/users/cover';
  static const String myPosts = '/users/me/posts';
  static const String myMedia = '/users/me/media';
  static String userProfile(String userId) => '/users/$userId';
  static String userProfileByUsername(String username) =>
      '/users/username/$username';
  static String userPosts(String userId) => '/users/$userId/posts';
  static String userMedia(String userId) => '/users/$userId/media';
  static String userFriends(String userId) => '/users/$userId/friends';

  // ---------------------------------------------------------------------------
  // Notifications & Devices endpoints
  // ---------------------------------------------------------------------------
  static const String notifications = '/users/notifications';
  static const String markAllNotificationsRead = '/users/notifications/read';
  static const String devices = '/users/devices';
  static String readNotification(String notificationId) =>
      '/users/notifications/$notificationId/read';

  // ---------------------------------------------------------------------------
  // Chat & Messages endpoints
  // ---------------------------------------------------------------------------
  static const String chats = '/chats';
  static const String createPrivateChat = '/chats/private';
  static String chatMessages(String conversationId) =>
      '/chats/$conversationId/messages';
  static String chatMessageById(String messageId) =>
      '/chats/messages/$messageId';
  static String chatMessageReactions(String messageId) =>
      '/chats/messages/$messageId/reactions';

  // ---------------------------------------------------------------------------
  // Calls endpoints
  // ---------------------------------------------------------------------------
  static const String callHistory = '/calls/history';

  // ---------------------------------------------------------------------------
  // Stories endpoints
  // ---------------------------------------------------------------------------
  static const String storiesTray = '/stories/tray';
  static const String stories = '/stories';
  static String markStoryViewed(String storyId) => '/stories/$storyId/view';
  static String storyReactions(String storyId) => '/stories/$storyId/reactions';
  static String replyToStory(String storyId) => '/stories/$storyId/reply';

  // ---------------------------------------------------------------------------
  // Feed and Posts endpoints
  // ---------------------------------------------------------------------------
  static const String feed = '/feed';
  static const String exploreFeed = '/feed/explore';
  static const String posts = '/posts';
  static String postById(String postId) => '/posts/$postId';
  static String postReactions(String postId) => '/posts/$postId/reactions';
  static String postComments(String postId) => '/posts/$postId/comments';
  static String postCommentById(String postId, String commentId) =>
      '/posts/$postId/comments/$commentId';
  static String postCommentReplies(String postId, String commentId) =>
      '/posts/$postId/comments/$commentId/replies';
  static String postCommentReactions(String postId, String commentId) =>
      '/posts/$postId/comments/$commentId/reactions';
  static String postCommentPin(String postId, String commentId) =>
      '/posts/$postId/comments/$commentId/pin';

  // ---------------------------------------------------------------------------
  // Upload endpoints
  // ---------------------------------------------------------------------------
  static const String uploadMultiple = '/uploads/multiple';
  static const String upload = '/uploads';

  // ---------------------------------------------------------------------------
  // Live stream endpoints
  // ---------------------------------------------------------------------------
  static const String livestreams = '/livestreams';
  static const String livestreamsMe = '/livestreams/me';
  static String livestreamById(String streamId) => '/livestreams/$streamId';
  static String livestreamStart(String streamId) =>
      '/livestreams/$streamId/start';
  static String livestreamEnd(String streamId) => '/livestreams/$streamId/end';
  static String livestreamJoin(String streamId) =>
      '/livestreams/$streamId/join';
  static String livestreamLeave(String streamId) =>
      '/livestreams/$streamId/leave';
  static String livestreamViewers(String streamId) =>
      '/livestreams/$streamId/viewers';
  static String livestreamComments(String streamId) =>
      '/livestreams/$streamId/comments';
  static String livestreamPinComment(String streamId, String commentId) =>
      '/livestreams/$streamId/comments/$commentId/pin';
  static String livestreamReactions(String streamId) =>
      '/livestreams/$streamId/reactions';
  static String livestreamGifts(String streamId) =>
      '/livestreams/$streamId/gifts';
  static String livestreamLeaderboard(String streamId) =>
      '/livestreams/$streamId/leaderboard';
  static String livestreamCohosts(String streamId) =>
      '/livestreams/$streamId/cohosts';
  static String livestreamCohostRequest(String streamId) =>
      '/livestreams/$streamId/cohost/request';
  static String livestreamCohostRespond(String streamId) =>
      '/livestreams/$streamId/cohost/respond';
  static String livestreamCohostLeave(String streamId) =>
      '/livestreams/$streamId/cohost/leave';

  // ---------------------------------------------------------------------------
  // Network configurations
  // ---------------------------------------------------------------------------
  /// Default connection timeout in milliseconds.
  static const Duration connectTimeout = Duration(seconds: 15);

  /// Default receive timeout in milliseconds.
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Max retries for failed network operations.
  static const int maxRetries = 3;
}
