import 'package:flutter/cupertino.dart';
import 'package:lotus_connect/features/chat/presentation/widgets/message_render_context.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';

abstract class MessageBodyStrategy {
  /// Priority order: higher priority strategies are checked list
  int get priority => 0;

  /// Returns true if this strategy handles the given message
  bool canRender(Message message);

  /// Builds the body content widget
  Widget buildBody(
    BuildContext context, {
    required Message message,
    required MessageRenderContext renderContext,
  });
}
