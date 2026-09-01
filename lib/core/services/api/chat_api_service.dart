import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/errors/exception.dart';
import 'package:lotus_connect/core/network/dio_client.dart';
import 'package:lotus_connect/features/chatbot/application/providers.dart';

/// REST client service managing friends, file uploads, push notifications, and private chats.
class ChatApiService {
  ChatApiService({required this.dioClient});

  final DioClient dioClient;

  /// Fetches call logs history for the authenticated user.
  Future<List<Map<String, dynamic>>> getCallHistory() async {
    try {
      final response = await dioClient.get('/calls/history');
      final list = response.data as List<dynamic>;
      return list.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      throw ServerException('Failed to fetch call history: $e');
    }
  }
}

/// Global provider for ChatApiService REST client.
final chatApiServiceProvider = Provider<ChatApiService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ChatApiService(dioClient: dioClient);
});
