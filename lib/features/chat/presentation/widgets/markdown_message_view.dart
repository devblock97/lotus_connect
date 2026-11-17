import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/theme_map.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lotus_connect/app/theme/app_color.dart';
import 'package:lotus_connect/app/theme/app_size.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';
import 'package:markdown/markdown.dart' as md;

/// Renders Markdown text with syntax highlighted code blocks and copy button.
class MarkdownMessageView extends StatelessWidget {
  const MarkdownMessageView({
    required this.content,
    required this.textColor,
    super.key,
  });

  final String content;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final codeBlockBg = AppColor.codeBlockBg.of(context);
    final codeBlockHeaderBg = AppColor.codeBlockHeaderBg.of(context);
    final codeBlockCanvas = AppColor.codeBlockCanvas.of(context);
    final codeBlockBorder = AppColor.white.of(context).withValues(alpha: 0.1);
    final mutedColor = AppColor.inkMuted.of(context);

    return MarkdownBody(
      data: content,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(color: textColor, fontSize: 15, height: 1.45),
        listBullet: TextStyle(color: textColor, fontSize: 15),
        strong: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        code: TextStyle(
          color: textColor,
          backgroundColor: AppColor.black.of(context).withValues(alpha: 0.15),
          fontFamily: 'monospace',
          fontSize: 13.5,
        ),
        codeblockDecoration: BoxDecoration(
          color: codeBlockBg,
          borderRadius: AppRadius.md,
        ),
      ),
      builders: {
        'code': CodeElementBuilder(
          copyLabel: loc?.copy ?? 'Copy',
          containerBg: codeBlockHeaderBg,
          headerBg: codeBlockCanvas,
          borderColor: codeBlockBorder,
          mutedColor: mutedColor,
        ),
      },
    );
  }
}

/// Custom code block element builder supporting syntax highlighting.
class CodeElementBuilder extends MarkdownElementBuilder {
  CodeElementBuilder({
    required this.containerBg,
    required this.headerBg,
    required this.borderColor,
    required this.mutedColor,
    this.copyLabel = 'Copy',
  });

  final String copyLabel;
  final Color containerBg;
  final Color headerBg;
  final Color borderColor;
  final Color mutedColor;

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final language =
        element.attributes['class']?.replaceFirst('language-', '') ?? 'dart';
    final code = element.textContent.trimRight();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSize.sm),
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: AppRadius.md,
        border: AppBorder.all(borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with language tag and Copy button
          Container(
            padding: AppPadding.chip,
            decoration: BoxDecoration(
              color: headerBg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSize.radiusMd - AppSize.borderThin),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  language,
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: code));
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.copy_rounded,
                        size: AppSize.iconXs,
                        color: mutedColor,
                      ),
                      AppGap.hXs,
                      Text(
                        copyLabel,
                        style: TextStyle(
                          color: mutedColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Highlighted code snippet
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: AppPadding.md,
            child: HighlightView(
              code,
              language: language,
              theme: themeMap['atom-one-dark']!,
              textStyle: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
