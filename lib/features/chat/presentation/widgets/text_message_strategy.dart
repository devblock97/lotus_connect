import 'package:flutter/cupertino.dart';
import 'package:lotus_connect/features/chat/presentation/widgets/message_body_strategy.dart';
import 'package:lotus_connect/features/chat/presentation/widgets/message_render_context.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';

class TextMessage implements MessageBodyStrategy {
  @override
  Widget buildBody(
    BuildContext context, {
    required Message message,
    required MessageRenderContext renderContext,
  }) {
    return GestureDetector(
      onLongPress: renderContext.onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: renderContext.background,
          borderRadius: renderContext.bubbleBorderRadius,
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: renderContext.foreground,
            fontSize: 15,
            height: 1.35,
          ),
        ),
      ),
    );
  }

  @override
  bool canRender(Message message) {
    return message.medias.isEmpty && message.content.isNotEmpty;
  }

  @override
  int get priority => 1;
}
