import 'package:flutter/material.dart';

class MessageRenderContext {
  const MessageRenderContext({
    required this.isMine,
    required this.foreground,
    required this.background,
    required this.theme,
    required this.onLongPress,
    this.isMediaLoading = false,
    this.mediaLength = 0,
    this.onSelectReaction,
  });

  final bool isMine;
  final Color foreground;
  final Color background;
  final ThemeData theme;
  final VoidCallback onLongPress;
  final bool isMediaLoading;
  final int mediaLength;
  final void Function(String)? onSelectReaction;

  BorderRadius get bubbleBorderRadius => BorderRadius.only(
        topLeft: const Radius.circular(18),
        topRight: const Radius.circular(18),
        bottomLeft: Radius.circular(isMine ? 18 : 4),
        bottomRight: Radius.circular(isMine ? 4 : 18),
      );
}
