import 'package:lotus_connect/features/chat_core/data/datasources/chat_core_local_data_source.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/conversation.dart';

abstract class PrivateChatLocalDataSource {
  Future<Conversation> saveLocalConversation({
    required String id,
    required String title,
    required bool isUserToUser,
    required String peerId,
  });
}

class PrivateChatLocalDataSourceImpl implements PrivateChatLocalDataSource {
  PrivateChatLocalDataSourceImpl(this._coreLocalDataSource);

  final ChatCoreLocalDataSource _coreLocalDataSource;

  @override
  Future<Conversation> saveLocalConversation({
    required String id,
    required String title,
    required bool isUserToUser,
    required String peerId,
  }) {
    return _coreLocalDataSource.createConversation(
      id: id,
      title: title,
      isUserToUser: isUserToUser,
      peerId: peerId,
    );
  }
}
