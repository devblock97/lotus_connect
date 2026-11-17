import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lotus_connect/app/theme/app_size.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

class StoryTextEditorResult {
  const StoryTextEditorResult({
    required this.text,
    required this.fontFamily,
    required this.textColor,
    required this.textAlign,
    required this.hasHighlight,
  });

  final String text;
  final String fontFamily;
  final Color textColor;
  final TextAlign textAlign;
  final bool hasHighlight;
}

class StoryTextEditorModal extends StatefulWidget {
  const StoryTextEditorModal({
    super.key,
    this.initialText = '',
    this.initialFontFamily = 'Inter',
    this.initialColor = Colors.white,
    this.initialAlign = TextAlign.center,
    this.initialHighlight = false,
  });

  final String initialText;
  final String initialFontFamily;
  final Color initialColor;
  final TextAlign initialAlign;
  final bool initialHighlight;

  static Future<StoryTextEditorResult?> show(
    BuildContext context, {
    String initialText = '',
    String initialFontFamily = 'Inter',
    Color initialColor = Colors.white,
    TextAlign initialAlign = TextAlign.center,
    bool initialHighlight = false,
  }) {
    return Navigator.of(context).push<StoryTextEditorResult>(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (_, __, ___) => StoryTextEditorModal(
          initialText: initialText,
          initialFontFamily: initialFontFamily,
          initialColor: initialColor,
          initialAlign: initialAlign,
          initialHighlight: initialHighlight,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  State<StoryTextEditorModal> createState() => _StoryTextEditorModalState();
}

class _StoryTextEditorModalState extends State<StoryTextEditorModal> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  late String _fontFamily;
  late Color _textColor;
  late TextAlign _textAlign;
  late bool _hasHighlight;

  static const List<Color> _kColors = [
    Colors.white,
    Colors.black,
    Color(0xFFFF2D55),
    Color(0xFFFF9500),
    Color(0xFFFFCC00),
    Color(0xFF34C759),
    Color(0xFF007AFF),
    Color(0xFF5856D6),
    Color(0xFFAF52DE),
    Color(0xFF00C7BE),
  ];

  static const List<Map<String, String>> _kFonts = [
    {'name': 'Classic', 'key': 'Inter'},
    {'name': 'Modern', 'key': 'RobotoMono'},
    {'name': 'Neon', 'key': 'Caveat'},
    {'name': 'Serif', 'key': 'PlayfairDisplay'},
    {'name': 'Strong', 'key': 'BebasNeue'},
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _focusNode = FocusNode();
    _fontFamily = widget.initialFontFamily;
    _textColor = widget.initialColor;
    _textAlign = widget.initialAlign;
    _hasHighlight = widget.initialHighlight;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  TextStyle _getTextStyle() {
    TextStyle base;
    switch (_fontFamily) {
      case 'RobotoMono':
        base = GoogleFonts.robotoMono();
      case 'Caveat':
        base = GoogleFonts.caveat();
      case 'PlayfairDisplay':
        base = GoogleFonts.playfairDisplay();
      case 'BebasNeue':
        base = GoogleFonts.bebasNeue();
      case 'Inter':
      default:
        base = GoogleFonts.inter();
    }

    return base.copyWith(
      color: _hasHighlight && _textColor == Colors.white
          ? Colors.black
          : _textColor,
      fontSize: _fontFamily == 'Caveat' ? 36 : 28,
      fontWeight: FontWeight.w700,
      letterSpacing: _fontFamily == 'BebasNeue' ? 1.5 : -0.3,
    );
  }

  void _cycleAlignment() {
    setState(() {
      if (_textAlign == TextAlign.center) {
        _textAlign = TextAlign.left;
      } else if (_textAlign == TextAlign.left) {
        _textAlign = TextAlign.right;
      } else {
        _textAlign = TextAlign.center;
      }
    });
  }

  void _finish() {
    Navigator.of(context).pop(
      StoryTextEditorResult(
        text: _controller.text,
        fontFamily: _fontFamily,
        textColor: _textColor,
        textAlign: _textAlign,
        hasHighlight: _hasHighlight,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = _getTextStyle();
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.8),
      body: SafeArea(
        child: Column(
          children: [
            // Top Controls Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSize.lg,
                vertical: AppSize.sm,
              ),
              child: Row(
                children: [
                  // Alignment Toggle
                  IconButton(
                    onPressed: _cycleAlignment,
                    icon: Icon(
                      _textAlign == TextAlign.center
                          ? Icons.format_align_center
                          : _textAlign == TextAlign.left
                              ? Icons.format_align_left
                              : Icons.format_align_right,
                      color: Colors.white,
                      size: AppSize.iconMd,
                    ),
                  ),

                  // Text Highlight Background Pill Toggle (Instagram A*)
                  IconButton(
                    onPressed: () {
                      setState(() => _hasHighlight = !_hasHighlight);
                    },
                    icon: Container(
                      padding: AppPadding.xs,
                      decoration: BoxDecoration(
                        color:
                            _hasHighlight ? Colors.white : Colors.transparent,
                        borderRadius: AppRadius.xs,
                        border: AppBorder.all(
                          Colors.white,
                          width: AppSize.borderMedium,
                        ),
                      ),
                      child: Text(
                        'A*',
                        style: TextStyle(
                          color: _hasHighlight ? Colors.black : Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Done Button
                  FilledButton(
                    onPressed: _finish,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSize.xl,
                        vertical: AppSize.sm,
                      ),
                      shape: AppBorder.rounded(radius: AppSize.radiusXl),
                    ),
                    child: Text(
                      loc?.done ?? 'Done',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Center Text Input Area
            Expanded(
              child: Center(
                child: Padding(
                  padding: AppPadding.hXxl,
                  child: IntrinsicWidth(
                    child: Container(
                      padding:
                          _hasHighlight ? AppPadding.chip : AppPadding.zero,
                      decoration: _hasHighlight
                          ? BoxDecoration(
                              color: _textColor == Colors.white
                                  ? Colors.white
                                  : Colors.black.withValues(alpha: 0.7),
                              borderRadius: AppRadius.md,
                            )
                          : null,
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        textAlign: _textAlign,
                        style: textStyle,
                        maxLines: null,
                        cursorColor: Colors.white,
                        decoration: InputDecoration(
                          hintText: loc?.typeSomething ?? 'Type something...',
                          hintStyle: textStyle.copyWith(
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                          border: InputBorder.none,
                          contentPadding: AppPadding.zero,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Font Selection Bar
            SizedBox(
              height: AppSize.huge,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: AppPadding.hLg,
                itemCount: _kFonts.length,
                separatorBuilder: (_, __) => AppGap.hSm,
                itemBuilder: (context, index) {
                  final font = _kFonts[index];
                  final isSelected = font['key'] == _fontFamily;
                  return ChoiceChip(
                    label: Text(font['name']!),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _fontFamily = font['key']!);
                    },
                    selectedColor: Colors.white,
                    backgroundColor: Colors.black87,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12,
                    ),
                    shape: AppBorder.rounded(),
                    side: AppBorder.none,
                  );
                },
              ),
            ),
            AppGap.vMd,

            // Bottom Color Palette Swatches
            SizedBox(
              height: AppSize.huge,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: AppPadding.hLg,
                itemCount: _kColors.length,
                separatorBuilder: (_, __) => AppGap.hSm,
                itemBuilder: (context, index) {
                  final color = _kColors[index];
                  final isSelected = color == _textColor;
                  return GestureDetector(
                    onTap: () => setState(() => _textColor = color),
                    child: Container(
                      width: AppSize.xxxl,
                      height: AppSize.xxxl,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: AppBorder.all(
                          isSelected ? Colors.white : Colors.white24,
                          width: isSelected
                              ? AppSize.borderHeavy
                              : AppSize.borderMedium,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.6),
                                  blurRadius: AppSize.sm,
                                  spreadRadius: AppSize.xxs,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
            AppGap.vLg,
          ],
        ),
      ),
    );
  }
}
