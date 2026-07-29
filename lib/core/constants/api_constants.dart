/// Network and API constants for Lotus Connect.
class ApiConstants {
  const ApiConstants._();

  /// Default API base URL for Lotus Connect backend services.
  static const String baseUrl = 'https://6efb-2001-ee0-1b35-c5cc-bc4a-743c-f92d-1969.ngrok-free.app/ap/v1';

  /// Gemini API base URL. Use stable v1 endpoint.
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1';

  /// Default connection timeout in milliseconds.
  static const Duration connectTimeout = Duration(seconds: 15);

  /// Default receive timeout in milliseconds.
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Max retries for failed network operations.
  static const int maxRetries = 3;
}
