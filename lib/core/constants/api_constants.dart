/// Network and API constants for Lotus Connect.
class ApiConstants {
  const ApiConstants._();

  /// Default API base URL for Lotus Connect backend services.
  static const String baseUrl =
      'https://56bf-2001-ee0-192-c669-502a-5600-4ab7-98a3.ngrok-free.app/api/v1';

  /// Gemini API base URL. Use stable v1 endpoint.
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1';

  /// Stories endpoints
  static const String storiesTray = '/stories/tray';
  static const String stories = '/stories';
  static String markStoryViewed(String storyId) => '/stories/$storyId/view';
  static String storyReactions(String storyId) => '/stories/$storyId/reactions';
  static String replyToStory(String storyId) => '/stories/$storyId/reply';

  /// Default connection timeout in milliseconds.
  static const Duration connectTimeout = Duration(seconds: 15);

  /// Default receive timeout in milliseconds.
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Max retries for failed network operations.
  static const int maxRetries = 3;
}
