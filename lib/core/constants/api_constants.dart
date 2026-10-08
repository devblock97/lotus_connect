/// Network and API constants for Lotus Connect.
class ApiConstants {
  const ApiConstants._();

  /// Default API base URL for Lotus Connect backend services.
  static const String baseUrl =
      'https://70f2-112-197-241-28.ngrok-free.app/api/v1';

  /// Gemini API base URL. Use stable v1 endpoint.
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1';

  /// Stories endpoints
  static const String storiesTray = '/stories/tray';
  static const String stories = '/stories';
  static String markStoryViewed(String storyId) => '/stories/$storyId/view';
  static String storyReactions(String storyId) => '/stories/$storyId/reactions';
  static String replyToStory(String storyId) => '/stories/$storyId/reply';

  /// Feed and Posts endpoints
  static const String feed = '/feed';
  static const String exploreFeed = '/feed/explore';
  static const String posts = '/posts';
  static String postById(String postId) => '/posts/$postId';
  static String postReactions(String postId) => '/posts/$postId/reactions';
  static String postComments(String postId) => '/posts/$postId/comments';

  /// Upload endpoints
  static const String uploadMultiple = '/uploads/multiple';
  static const String upload = '/uploads';

  /// Default connection timeout in milliseconds.
  static const Duration connectTimeout = Duration(seconds: 15);

  /// Default receive timeout in milliseconds.
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Max retries for failed network operations.
  static const int maxRetries = 3;
}
