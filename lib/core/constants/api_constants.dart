/// Network and API constants for Lotus Connect.
class ApiConstants {
  const ApiConstants._();

  /// Default API base URL for Lotus Connect backend services.
  static const String baseUrl =
      'https://be10-2001-ee0-1b38-2b4c-2838-129a-ce08-7508.ngrok-free.app/api/v1';

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
