import 'package:flutter/material.dart';

/// Custom ThemeExtension to support tailored chat UI colors across themes.
class AppChatTheme extends ThemeExtension<AppChatTheme> {
  const AppChatTheme({
    required this.userBubbleBg,
    required this.userBubbleFg,
    required this.aiBubbleBg,
    required this.aiBubbleFg,
    required this.codeBlockBg,
    required this.codeBlockHeaderBg,
  });

  final Color userBubbleBg;
  final Color userBubbleFg;
  final Color aiBubbleBg;
  final Color aiBubbleFg;
  final Color codeBlockBg;
  final Color codeBlockHeaderBg;

  @override
  AppChatTheme copyWith({
    Color? userBubbleBg,
    Color? userBubbleFg,
    Color? aiBubbleBg,
    Color? aiBubbleFg,
    Color? codeBlockBg,
    Color? codeBlockHeaderBg,
  }) {
    return AppChatTheme(
      userBubbleBg: userBubbleBg ?? this.userBubbleBg,
      userBubbleFg: userBubbleFg ?? this.userBubbleFg,
      aiBubbleBg: aiBubbleBg ?? this.aiBubbleBg,
      aiBubbleFg: aiBubbleFg ?? this.aiBubbleFg,
      codeBlockBg: codeBlockBg ?? this.codeBlockBg,
      codeBlockHeaderBg: codeBlockHeaderBg ?? this.codeBlockHeaderBg,
    );
  }

  @override
  AppChatTheme lerp(ThemeExtension<AppChatTheme>? other, double t) {
    if (other is! AppChatTheme) return this;
    return AppChatTheme(
      userBubbleBg: Color.lerp(userBubbleBg, other.userBubbleBg, t)!,
      userBubbleFg: Color.lerp(userBubbleFg, other.userBubbleFg, t)!,
      aiBubbleBg: Color.lerp(aiBubbleBg, other.aiBubbleBg, t)!,
      aiBubbleFg: Color.lerp(aiBubbleFg, other.aiBubbleFg, t)!,
      codeBlockBg: Color.lerp(codeBlockBg, other.codeBlockBg, t)!,
      codeBlockHeaderBg:
          Color.lerp(codeBlockHeaderBg, other.codeBlockHeaderBg, t)!,
    );
  }
}
