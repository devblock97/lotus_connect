import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lotus_connect/core/theme/app_size.dart';
import 'package:lotus_connect/core/utils/utils.dart';
import 'package:lotus_connect/features/chat/presentation/widgets/full_screen_media_viewer.dart';
import 'package:lotus_connect/features/chat/presentation/widgets/message_body_strategy.dart';
import 'package:lotus_connect/features/chat/presentation/widgets/message_render_context.dart';
import 'package:lotus_connect/features/chat/presentation/widgets/video_thumbnail.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';

class MediaMessage implements MessageBodyStrategy {
  @override
  Widget buildBody(
    BuildContext context, {
    required Message message,
    required MessageRenderContext renderContext,
  }) {
    return _buildMediaGrid(context, message, renderContext);
  }

  @override
  bool canRender(Message message) {
    return message.medias.isNotEmpty && message.content.isEmpty;
  }

  @override
  int get priority => 2;

  Widget _buildMediaGrid(
    BuildContext context,
    Message message,
    MessageRenderContext renderContext,
  ) {
    return GridView.builder(
      padding: AppPadding.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: message.medias.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: message.medias.length >= 4 ? 4 : message.medias.length,
        crossAxisSpacing: AppSize.xs,
        mainAxisSpacing: AppSize.xs,
      ),
      itemBuilder: (context, index) {
        final media = message.medias[index];
        return GestureDetector(
          onLongPress: renderContext.onLongPress,
          onTap: () {
            FullScreenMediaViewer.show(
              context,
              medias: message.medias,
              initialIndex: index,
            );
          },
          child: isVideo(media.url)
              ? MediaVideoThumbnail(url: media.url)
              : Container(
                  decoration: const BoxDecoration(
                    borderRadius: AppRadius.media,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Hero(
                    tag: media.url,
                    child: CachedNetworkImage(
                      imageUrl: media.url,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const Center(
                        child: SizedBox(
                          width: AppSize.loaderSizeSm,
                          height: AppSize.loaderSizeSm,
                          child: CircularProgressIndicator(
                            strokeWidth: AppSize.borderThick,
                          ),
                        ),
                      ),
                      errorWidget: (_, __, dynamic ___) =>
                          const Icon(Icons.broken_image),
                    ),
                  ),
                ),
        );
      },
    );
  }
}
