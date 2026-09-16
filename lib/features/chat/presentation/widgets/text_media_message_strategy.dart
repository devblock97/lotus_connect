import 'package:flutter/material.dart';
import 'package:lotus_connect/features/chat/presentation/widgets/media_message_strategy.dart';
import 'package:lotus_connect/features/chat/presentation/widgets/message_body_strategy.dart';
import 'package:lotus_connect/features/chat/presentation/widgets/message_render_context.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';

class TextMediaMessage implements MessageBodyStrategy {
  final MediaMessage _mediaMessage = MediaMessage();

  @override
  Widget buildBody(
    BuildContext context, {
    required Message message,
    required MessageRenderContext renderContext,
  }) {
    return Column(
      crossAxisAlignment: renderContext.isMine
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (renderContext.isMediaLoading)
          _buildLoadingGrid(renderContext.mediaLength)
        else
          _mediaMessage.buildBody(
            context,
            message: message,
            renderContext: renderContext,
          ),
        const SizedBox(height: 4),
        GestureDetector(
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
        ),
      ],
    );
  }

  @override
  bool canRender(Message message) {
    return message.medias.isNotEmpty && message.content.isNotEmpty;
  }

  @override
  int get priority => 3;

  Widget _buildLoadingGrid(int length) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: length >= 4 ? 4 : length,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
