import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lotus_connect/core/logging/app_logger.dart';
import 'package:lotus_connect/core/theme/app_size.dart';
import 'package:video_player/video_player.dart';

class MediaVideoThumbnail extends StatefulWidget {
  const MediaVideoThumbnail({required this.url, super.key});

  final String url;

  @override
  State<MediaVideoThumbnail> createState() => MediaVideoThumbnailState();
}

class MediaVideoThumbnailState extends State<MediaVideoThumbnail> {
  late final VideoPlayerController _controller;
  bool _isInitialized = false;

  bool get _isNetworkUrl {
    final uri = Uri.tryParse(widget.url);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  @override
  void initState() {
    super.initState();
    _controller = _isNetworkUrl
        ? VideoPlayerController.networkUrl(Uri.parse(widget.url))
        : VideoPlayerController.file(File(widget.url));

    _controller.initialize().then((_) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }).catchError((Object error) {
      AppLogger.error('Failed to initialize video: $error');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = _controller.value.size;
    final hasValidSize = size.width > 0 && size.height > 0;

    return Container(
      decoration: const BoxDecoration(
        borderRadius: AppRadius.media,
        color: Colors.black12,
      ),
      clipBehavior: Clip.antiAlias,
      child: _isInitialized
          ? Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                if (hasValidSize)
                  FittedBox(
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: size.width,
                      height: size.height,
                      child: VideoPlayer(_controller),
                    ),
                  )
                else
                  Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                Center(
                  child: Container(
                    padding: AppPadding.xs,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: AppSize.iconSm,
                    ),
                  ),
                ),
              ],
            )
          : const Center(
              child: SizedBox(
                width: AppSize.loaderSizeSm,
                height: AppSize.loaderSizeSm,
                child: CircularProgressIndicator(
                  strokeWidth: AppSize.borderThick,
                ),
              ),
            ),
    );
  }
}
