import 'package:flutter/material.dart';
import 'package:lotus_connect/features/chat/presentation/widgets/media_message_strategy.dart';
import 'package:lotus_connect/features/chat/presentation/widgets/message_body_strategy.dart';
import 'package:lotus_connect/features/chat/presentation/widgets/message_render_context.dart';
import 'package:lotus_connect/features/chat/presentation/widgets/text_media_message_strategy.dart';
import 'package:lotus_connect/features/chat/presentation/widgets/text_message_strategy.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';

class MessageBodyFactory {
  MessageBodyFactory({List<MessageBodyStrategy>? customStrategies})
      : _strategies = customStrategies ??
            [
              TextMessage(),
              MediaMessage(),
              TextMediaMessage(),
            ] {
    _strategies.sort((a, b) => b.priority.compareTo(a.priority));
  }

  final List<MessageBodyStrategy> _strategies;

  Widget createBody(
    BuildContext context, {
    required Message message,
    required MessageRenderContext renderContext,
  }) {
    for (final strategy in _strategies) {
      if (strategy.canRender(message)) {
        return strategy.buildBody(
          context,
          message: message,
          renderContext: renderContext,
        );
      }
    }
    return const SizedBox.shrink();
  }
}
