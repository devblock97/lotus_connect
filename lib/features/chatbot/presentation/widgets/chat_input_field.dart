import 'package:flutter/material.dart';

/// Bottom chat input field widget matching modern ChatGPT / Telegram styling.
class ChatInputField extends StatefulWidget {
  const ChatInputField({
    required this.onSend,
    required this.isGenerating,
    required this.onStop,
    this.initialText = '',
    this.onChanged,
    this.hintText = 'Message Neural AI...',
    this.showAiDisclaimer = true,
    super.key,
  });

  final ValueChanged<String> onSend;
  final bool isGenerating;
  final VoidCallback onStop;
  final String initialText;
  final ValueChanged<String>? onChanged;
  final String hintText;
  final bool showAiDisclaimer;

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void didUpdateWidget(covariant ChatInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialText != oldWidget.initialText &&
        _controller.text != widget.initialText) {
      _controller.text = widget.initialText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSend(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 5,
                      onChanged: widget.onChanged,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleSend(),
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        hintStyle: TextStyle(
                          color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.5),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 8,
                      right: 8,
                      bottom: 8,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.image_outlined, size: 22),
                          onPressed: () {},
                          tooltip: 'Attach Image',
                        ),
                        IconButton(
                          icon: const Icon(Icons.mic_none_rounded, size: 22),
                          onPressed: () {},
                          tooltip: 'Voice Input',
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, size: 22),
                          onPressed: () {},
                          tooltip: 'Add Attachment',
                        ),
                        const Spacer(),
                        if (widget.isGenerating)
                          IconButton.filled(
                            onPressed: widget.onStop,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.stop_rounded, size: 20),
                          )
                        else
                          IconButton.filled(
                            onPressed: _handleSend,
                            style: IconButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(
                              Icons.arrow_upward_rounded,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (widget.showAiDisclaimer) ...[
              const SizedBox(height: 6),
              Text(
                'AI MAY PROVIDE INACCURATE DATA. VERIFY CRITICAL INFO.',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color:
                      theme.textTheme.bodySmall?.color?.withValues(alpha: 0.4),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
