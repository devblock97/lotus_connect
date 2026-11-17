import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lotus_connect/app/theme/app_size.dart';
import 'package:lotus_connect/features/home/presentation/models/comment_ui_model.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

const List<String> kQuickCommentEmojis = [
  '❤️',
  '🙌',
  '🔥',
  '👏',
  '😂',
  '😍',
  '😮',
  '🎉',
];

/// Rich bottom input bar for submitting comments and threaded replies.
class CommentInputBar extends StatefulWidget {
  const CommentInputBar({
    required this.onSubmit,
    super.key,
    this.replyingTo,
    this.onCancelReply,
    this.currentUserAvatarUrl,
    this.currentUsername = 'you',
    this.isSubmitting = false,
    this.focusNode,
  });

  final CommentUiModel? replyingTo;
  final VoidCallback? onCancelReply;
  final String? currentUserAvatarUrl;
  final String currentUsername;
  final bool isSubmitting;
  final FocusNode? focusNode;

  /// Callback when user submits comment:
  /// provides text content, parent ID if replying, and attached media URL.
  final void Function(
    String content, {
    String? parentCommentId,
    String? mediaUrl,
  }) onSubmit;

  @override
  State<CommentInputBar> createState() => _CommentInputBarState();
}

class _CommentInputBarState extends State<CommentInputBar> {
  late final TextEditingController _textController;
  late final FocusNode _internalFocusNode;
  final ImagePicker _imagePicker = ImagePicker();

  String? _selectedMediaUrl;
  bool _canSubmit = false;
  bool _showStickerTray = false;

  FocusNode get _effectiveFocusNode => widget.focusNode ?? _internalFocusNode;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _internalFocusNode = FocusNode();
    _textController.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(CommentInputBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When reply target changes, autofocus textfield and prepend
    // @username if empty
    if (widget.replyingTo != null &&
        widget.replyingTo != oldWidget.replyingTo) {
      final mention = '@${widget.replyingTo!.author.username} ';
      if (!_textController.text.startsWith(mention)) {
        _textController.text = mention;
        _textController.selection = TextSelection.fromPosition(
          TextPosition(offset: _textController.text.length),
        );
      }
      _effectiveFocusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _internalFocusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;
    final hasMedia = _selectedMediaUrl != null;
    final canSubmit = hasText || hasMedia;
    if (canSubmit != _canSubmit) {
      setState(() => _canSubmit = canSubmit);
    }
  }

  void _insertEmoji(String emoji) {
    HapticFeedback.lightImpact();
    final text = _textController.text;
    final selection = _textController.selection;
    final newText = (selection.start >= 0)
        ? text.replaceRange(selection.start, selection.end, emoji)
        : '$text$emoji';
    final newOffset = (selection.start >= 0)
        ? selection.start + emoji.length
        : newText.length;

    _textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }

  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedMediaUrl = image.path;
          _showStickerTray = false;
        });
        _onTextChanged();
      }
    } on Exception catch (_) {
      // User cancelled or permissions denied
    }
  }

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isEmpty && _selectedMediaUrl == null) return;
    if (widget.isSubmitting) return;

    HapticFeedback.mediumImpact();
    widget.onSubmit(
      text,
      parentCommentId: widget.replyingTo?.id,
      mediaUrl: _selectedMediaUrl,
    );

    _textController.clear();
    setState(() {
      _selectedMediaUrl = null;
      _showStickerTray = false;
    });
  }

  Widget _buildAvatar(ThemeData theme) {
    final url = widget.currentUserAvatarUrl;
    if (url != null && url.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, __) => _buildInitialsAvatar(theme),
        errorWidget: (_, __, dynamic ___) => _buildInitialsAvatar(theme),
      );
    }
    return _buildInitialsAvatar(theme);
  }

  Widget _buildInitialsAvatar(ThemeData theme) {
    return Container(
      color: theme.primaryColor,
      alignment: Alignment.center,
      child: Text(
        widget.currentUsername.isNotEmpty
            ? widget.currentUsername.substring(0, 1).toUpperCase()
            : 'U',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1E1E22) : Colors.white;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white60 : Colors.black54;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(
          top: AppBorder.hairline(
            theme.dividerColor.withValues(alpha: 0.15),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: AppSize.md,
        right: AppSize.md,
        top: AppSize.sm,
        bottom: MediaQuery.of(context).viewInsets.bottom +
            (MediaQuery.of(context).padding.bottom > 0
                ? MediaQuery.of(context).padding.bottom
                : AppSize.sm),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Replying contextual indicator
          if (widget.replyingTo != null)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: AppSize.sm),
              padding: AppPadding.chip,
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: AppRadius.md,
                border: AppBorder.all(
                  theme.primaryColor.withValues(alpha: 0.25),
                  width: AppSize.borderHairline,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.reply,
                    size: AppSize.iconXxs,
                    color: theme.primaryColor,
                  ),
                  AppGap.hSm,
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 12.5,
                          color: primaryTextColor,
                        ),
                        children: [
                          TextSpan(
                            text: loc?.replyingTo ?? 'Replying to ',
                          ),
                          TextSpan(
                            text: '@${widget.replyingTo!.author.username}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      overflow: const TextSpan(text: '...').style != null
                          ? TextOverflow.ellipsis
                          : TextOverflow.clip,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onCancelReply?.call();
                    },
                    child: Padding(
                      padding: AppPadding.xs,
                      child: Icon(
                        Icons.close,
                        size: AppSize.iconXs,
                        color: subtextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Media attachment preview thumbnail (if attached)
          if (_selectedMediaUrl != null)
            Container(
              margin: const EdgeInsets.only(bottom: AppSize.sm),
              alignment: Alignment.centerLeft,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: AppRadius.md,
                    child: Container(
                      width: AppSize.giant,
                      height: AppSize.giant,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[850] : Colors.grey[200],
                      ),
                      child: _selectedMediaUrl!.startsWith('http')
                          ? CachedNetworkImage(
                              imageUrl: _selectedMediaUrl!,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(_selectedMediaUrl!),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, dynamic ___) => Icon(
                                Icons.image,
                                color: subtextColor,
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    top: AppSize.xs,
                    right: AppSize.xs,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _selectedMediaUrl = null);
                        _onTextChanged();
                      },
                      child: Container(
                        padding: AppPadding.xxs,
                        decoration: const BoxDecoration(
                          color: Colors.black87,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: AppSize.iconSm,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Quick emojis horizontal strip
          SizedBox(
            height: AppSize.chipHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: kQuickCommentEmojis.length,
              separatorBuilder: (_, __) => AppGap.hSm,
              itemBuilder: (context, index) {
                final emoji = kQuickCommentEmojis[index];
                return GestureDetector(
                  onTap: () => _insertEmoji(emoji),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSize.sm,
                      vertical: AppSize.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.04),
                      borderRadius: AppRadius.lg,
                    ),
                    child: Center(
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 17),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          AppGap.vXs,

          // Main input row: [Avatar] [TextField] [MediaButton] [SendButton]
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // User avatar
              Padding(
                padding: const EdgeInsets.only(bottom: AppSize.xs),
                child: SizedBox(
                  width: AppSize.avatarSm,
                  height: AppSize.avatarSm,
                  child: ClipOval(child: _buildAvatar(theme)),
                ),
              ),
              AppGap.hSm,

              // Expandable Text input
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 110),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFF1F3F5),
                    borderRadius: AppRadius.xxl,
                  ),
                  padding: AppPadding.hLg,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          focusNode: _effectiveFocusNode,
                          minLines: 1,
                          maxLines: 4,
                          textCapitalization: TextCapitalization.sentences,
                          style: TextStyle(
                            fontSize: 14.5,
                            color: primaryTextColor,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: widget.replyingTo != null
                                ? (loc?.replyToUserHint(
                                      widget.replyingTo!.author.username,
                                    ) ??
                                    'Reply to '
                                        '@'
                                        '${widget.replyingTo!.author.username}'
                                        '...')
                                : (loc?.addCommentHint ?? 'Add a comment...'),
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: subtextColor,
                            ),
                            border: InputBorder.none,
                            contentPadding: AppPadding.vSm,
                          ),
                          onSubmitted: (_) => _handleSend(),
                        ),
                      ),
                      // Media / Sticker button
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSize.sm),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  _showStickerTray = !_showStickerTray;
                                });
                              },
                              child: Icon(
                                Icons.sentiment_satisfied_alt_outlined,
                                size: AppSize.iconSm,
                                color: _showStickerTray
                                    ? theme.primaryColor
                                    : subtextColor,
                              ),
                            ),
                            AppGap.hSm,
                            GestureDetector(
                              onTap: _pickImage,
                              child: Icon(
                                CupertinoIcons.photo,
                                size: AppSize.iconSm,
                                color: _selectedMediaUrl != null
                                    ? theme.primaryColor
                                    : subtextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AppGap.hSm,

              // Send button
              Padding(
                padding: const EdgeInsets.only(bottom: AppSize.xs),
                child: AnimatedScale(
                  scale: _canSubmit ? 1.05 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: IconButton(
                    onPressed:
                        _canSubmit && !widget.isSubmitting ? _handleSend : null,
                    icon: widget.isSubmitting
                        ? SizedBox(
                            width: AppSize.iconSm,
                            height: AppSize.iconSm,
                            child: CircularProgressIndicator(
                              strokeWidth: AppSize.borderThick,
                              color: theme.primaryColor,
                            ),
                          )
                        : Icon(
                            CupertinoIcons.arrow_up_circle_fill,
                            size: AppSize.iconXl,
                            color: _canSubmit
                                ? theme.primaryColor
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : Colors.black.withValues(alpha: 0.2)),
                          ),
                    padding: AppPadding.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
