import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/conversation.dart';

abstract class PrivateChatRepository {
  /// Calls remote REST endpoint to create private chat conversation,
  /// and saves it locally inside Drift SQLite.
  FutureResult<Conversation> createPrivateChat({
    required String friendId,
    required String title,
  });
}
