import 'package:flutter/material.dart';
import 'package:lotus_connect/app/theme/app_theme_mode.dart';
import 'package:lotus_connect/app/theme/theme_extensions.dart';

@immutable
class AppModeColor {
  const AppModeColor({
    required this.light,
    required this.dark,
    required this.sepia,
  });
  const AppModeColor.all(Color color)
      : light = color,
        dark = color,
        sepia = color;

  final Color light;
  final Color dark;
  final Color sepia;

  Color byMode(AppThemeMode mode) => switch (mode) {
        AppThemeMode.light => light,
        AppThemeMode.dark => dark,
        AppThemeMode.sepia => sepia,
      };

  Color of(BuildContext context) => byMode(AppColor.modeOf(context));
}

class AppColor {
  const AppColor._();

  static AppThemeMode modeOf(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeModeExtension>();
    if (ext != null) return ext.mode;
    return theme.brightness == Brightness.dark
        ? AppThemeMode.dark
        : AppThemeMode.light;
  }

  // ---------------------------------------------------------------------------
  // Material 3 Core ColorScheme Tokens
  // ---------------------------------------------------------------------------

  static const AppModeColor primary = AppModeColor(
    light: Color(0xFF6F5B40),
    dark: Color(0xFFDEC08F),
    sepia: Color(0xFF8A5A2B),
  );

  static const AppModeColor onPrimary = AppModeColor(
    light: Color(0xFFFFFFFF),
    dark: Color(0xFF3D2E15),
    sepia: Color(0xFFFFFFFF),
  );

  static const AppModeColor primaryContainer = AppModeColor(
    light: Color(0xFFFBDEB9),
    dark: Color(0xFF57432A),
    sepia: Color(0xFFF0D3A6),
  );

  static const AppModeColor onPrimaryContainer = AppModeColor(
    light: Color(0xFF271905),
    dark: Color(0xFFFBDEB9),
    sepia: Color(0xFF2E1B03),
  );

  static const AppModeColor secondary = AppModeColor(
    light: Color(0xFF6D5D4E),
    dark: Color(0xFFDAC3AC),
    sepia: Color(0xFF7A6A50),
  );

  static const AppModeColor onSecondary = AppModeColor(
    light: Color(0xFFFFFFFF),
    dark: Color(0xFF3B2E20),
    sepia: Color(0xFFFFFFFF),
  );

  static const AppModeColor secondaryContainer = AppModeColor(
    light: Color(0xFFF7DFC7),
    dark: Color(0xFF534435),
    sepia: Color(0xFFE9D9BE),
  );

  static const AppModeColor onSecondaryContainer = AppModeColor(
    light: Color(0xFF251A0D),
    dark: Color(0xFFF7DFC7),
    sepia: Color(0xFF2A2010),
  );

  static const AppModeColor tertiary = AppModeColor(
    light: Color(0xFF51643F),
    dark: Color(0xFFB7CEA0),
    sepia: Color(0xFF6B7A4F),
  );

  static const AppModeColor onTertiary = AppModeColor(
    light: Color(0xFFFFFFFF),
    dark: Color(0xFF243516),
    sepia: Color(0xFFFFFFFF),
  );

  static const AppModeColor tertiaryContainer = AppModeColor(
    light: Color(0xFFD3EABB),
    dark: Color(0xFF3A4C2B),
    sepia: Color(0xFFDCE7C4),
  );

  static const AppModeColor onTertiaryContainer = AppModeColor(
    light: Color(0xFF101F03),
    dark: Color(0xFFD3EABB),
    sepia: Color(0xFF1D2809),
  );

  static const AppModeColor error = AppModeColor(
    light: Color(0xFFBA1A1A),
    dark: Color(0xFFFFB4AB),
    sepia: Color(0xFF9A3412),
  );

  static const AppModeColor onError = AppModeColor(
    light: Color(0xFFFFFFFF),
    dark: Color(0xFF690005),
    sepia: Color(0xFFFFFFFF),
  );

  static const AppModeColor surface = AppModeColor(
    light: Color(0xFFFFF8F3),
    dark: Color(0xFF17130E),
    sepia: Color(0xFFF4ECD8),
  );

  static const AppModeColor onSurface = AppModeColor(
    light: Color(0xFF1F1B16),
    dark: Color(0xFFEAE1D9),
    sepia: Color(0xFF3B2F1E),
  );

  static const AppModeColor surfaceContainerHighest = AppModeColor(
    light: Color(0xFFF0E0CF),
    dark: Color(0xFF4F4539),
    sepia: Color(0xFFE6D8BC),
  );

  static const AppModeColor onSurfaceVariant = AppModeColor(
    light: Color(0xFF4F4539),
    dark: Color(0xFFD3C4B4),
    sepia: Color(0xFF5C4E39),
  );

  static const AppModeColor outline = AppModeColor(
    light: Color(0xFF817567),
    dark: Color(0xFF9C8F80),
    sepia: Color(0xFF8A7A5F),
  );

  static const AppModeColor outlineVariant = AppModeColor(
    light: Color(0xFFD3C4B4),
    dark: Color(0xFF4F4539),
    sepia: Color(0xFFD8C7A5),
  );

  // ---------------------------------------------------------------------------
  // Brand & Chat Extension Tokens
  // ---------------------------------------------------------------------------

  static const AppModeColor brandAccent = AppModeColor(
    light: Color(0xFF6200EE),
    dark: Color(0xFFBB86FC),
    sepia: Color(0xFF8D6E63),
  );

  static const AppModeColor background = AppModeColor(
    light: Color(0xFFF8F9FA),
    dark: Color(0xFF121214),
    sepia: Color(0xFFF4ECD8),
  );

  static const AppModeColor cardSurface = AppModeColor(
    light: Color(0xFFFFFFFF),
    dark: Color(0xFF1E1E22),
    sepia: Color(0xFFEAE0C8),
  );

  static const AppModeColor textPrimary = AppModeColor(
    light: Color(0xFF1C1B1F),
    dark: Color(0xFFE6E1E5),
    sepia: Color(0xFF4A3B32),
  );

  static const AppModeColor textSecondary = AppModeColor(
    light: Color(0xFF757575),
    dark: Color(0xFFA0A0A5),
    sepia: Color(0xFF796556),
  );

  static const AppModeColor userBubbleBg = AppModeColor(
    light: Color(0xFF1C1B1F),
    dark: Color(0xFF2B2B30),
    sepia: Color(0xFF5D4037),
  );

  static const AppModeColor userBubbleFg = AppModeColor(
    light: Color(0xFFFFFFFF),
    dark: Color(0xFFE6E1E5),
    sepia: Color(0xFFFFFFFF),
  );

  static const AppModeColor aiBubbleBg = AppModeColor(
    light: Color(0xFFF0F4F9),
    dark: Color(0xFF1A1D24),
    sepia: Color(0xFFE4D9C0),
  );

  static const AppModeColor aiBubbleFg = AppModeColor(
    light: Color(0xFF1C1B1F),
    dark: Color(0xFFE6E1E5),
    sepia: Color(0xFF4A3B32),
  );

  static const AppModeColor codeBlockBg = AppModeColor(
    light: Color(0xFF1E1E2E),
    dark: Color(0xFF18181E),
    sepia: Color(0xFF3E2723),
  );

  static const AppModeColor codeBlockHeaderBg = AppModeColor(
    light: Color(0xFF181825),
    dark: Color(0xFF121216),
    sepia: Color(0xFF2C1D18),
  );

  static const AppModeColor codeBlockCanvas = AppModeColor(
    light: Color(0xFF11111B),
    dark: Color(0xFF11111B),
    sepia: Color(0xFF241713),
  );

  // ---------------------------------------------------------------------------
  // Base Neutrals, Ink & Dividers
  // ---------------------------------------------------------------------------

  static const AppModeColor transparent = AppModeColor.all(Colors.transparent);
  static const AppModeColor white = AppModeColor.all(Colors.white);
  static const AppModeColor black = AppModeColor.all(Colors.black);

  static const AppModeColor inkPrimary = AppModeColor(
    light: Colors.black87,
    dark: Colors.white,
    sepia: Color(0xFF3B2F1E),
  );

  static const AppModeColor inkSolid = AppModeColor(
    light: Colors.black,
    dark: Colors.white,
    sepia: Color(0xFF3B2F1E),
  );

  static const AppModeColor inkSecondary = AppModeColor(
    light: Colors.black54,
    dark: Colors.white60,
    sepia: Color(0xFF5C4E39),
  );

  static const AppModeColor inkTertiary = AppModeColor(
    light: Colors.black45,
    dark: Colors.white54,
    sepia: Color(0xFF796556),
  );

  static const AppModeColor inkMuted = AppModeColor(
    light: Colors.grey,
    dark: Color(0xFFA0A0A5),
    sepia: Color(0xFF796556),
  );

  static const AppModeColor inkMutedStrong = AppModeColor(
    light: Color(0xFF424242),
    dark: Color(0xFFD1D5DB),
    sepia: Color(0xFF4A3B32),
  );

  static const AppModeColor inkMutedDark = AppModeColor(
    light: Color(0xFF616161),
    dark: Color(0xFF9CA3AF),
    sepia: Color(0xFF5C4E39),
  );

  static const AppModeColor inkMutedMedium = AppModeColor(
    light: Color(0xFF757575),
    dark: Color(0xFFA0A0A5),
    sepia: Color(0xFF796556),
  );

  static const AppModeColor inkSubtle = AppModeColor(
    light: Color(0xFFBDBDBD),
    dark: Color(0xFF71717A),
    sepia: Color(0xFF9C8972),
  );

  static const AppModeColor dividerSubtle = AppModeColor(
    light: Colors.black12,
    dark: Colors.white12,
    sepia: Color(0x264A3B32),
  );

  static const AppModeColor borderFaint = AppModeColor(
    light: Color(0x0D000000),
    dark: Color(0x14FFFFFF),
    sepia: Color(0x1F4A3B32),
  );

  static const AppModeColor shadow = AppModeColor(
    light: Color(0x14000000),
    dark: Color(0x4D000000),
    sepia: Color(0x1F3B2F1E),
  );

  static const AppModeColor scrim = AppModeColor(
    light: Colors.black54,
    dark: Colors.black54,
    sepia: Color(0x8A2C1D18),
  );

  // ---------------------------------------------------------------------------
  // Surfaces, Cards, Inputs, Skeletons & Auth
  // ---------------------------------------------------------------------------

  static const AppModeColor surfaceElevated = AppModeColor(
    light: Color(0xFFFFFFFF),
    dark: Color(0xFF26262B),
    sepia: Color(0xFFEFE6D0),
  );

  static const AppModeColor surfaceSheet = AppModeColor(
    light: Color(0xFFFFFFFF),
    dark: Color(0xFF1E1E24),
    sepia: Color(0xFFF4ECD8),
  );

  static const AppModeColor surfaceCard = AppModeColor(
    light: Color(0xFFFFFFFF),
    dark: Color(0xFF242526),
    sepia: Color(0xFFEAE0C8),
  );

  static const AppModeColor surfaceMuted = AppModeColor(
    light: Color(0xFFF1F3F5),
    dark: Color(0xFF2A2A36),
    sepia: Color(0xFFE6DAC0),
  );

  static const AppModeColor surfaceTrack = AppModeColor(
    light: Color(0xFFF5F5F5),
    dark: Color(0xFF212121),
    sepia: Color(0xFFE6D8BC),
  );

  static const AppModeColor surfacePill = AppModeColor(
    light: Color(0xFFEEEEEE),
    dark: Color(0xFF303030),
    sepia: Color(0xFFE0D2B5),
  );

  static const AppModeColor feedBackground = AppModeColor(
    light: Color(0xFFF0F2F5),
    dark: Color(0xFF18191A),
    sepia: Color(0xFFEDE3CC),
  );

  static const AppModeColor secondaryControlBg = AppModeColor(
    light: Color(0xFFE4E6EB),
    dark: Color(0xFF3A3B3C),
    sepia: Color(0xFFE0D2B5),
  );

  static const AppModeColor storyCardEmptyBg = AppModeColor(
    light: Color(0xFFE2E4E9),
    dark: Color(0xFF2A2A36),
    sepia: Color(0xFFE2D6BC),
  );

  static const AppModeColor skeletonBase = AppModeColor(
    light: Color(0xFFE4E4E8),
    dark: Color(0xFF1E1E24),
    sepia: Color(0xFFE2D6BC),
  );

  static const AppModeColor skeletonHighlight = AppModeColor(
    light: Color(0xFFF4F4F8),
    dark: Color(0xFF2E2E38),
    sepia: Color(0xFFEDE3CC),
  );

  static const AppModeColor mediaPlaceholder = AppModeColor(
    light: Color(0xFFF0F0F0),
    dark: Color(0xFF1E1E22),
    sepia: Color(0xFFE4D9C0),
  );

  static const AppModeColor mediaTileBg = AppModeColor(
    light: Color(0xFFECEEF2),
    dark: Color(0xFF26262B),
    sepia: Color(0xFFE4D9C0),
  );

  static const AppModeColor mediaGradientStart = AppModeColor(
    light: Color(0xFFE2E8F0),
    dark: Color(0xFF2A2B36),
    sepia: Color(0xFFE6D8BC),
  );

  static const AppModeColor mediaGradientEnd = AppModeColor(
    light: Color(0xFFCBD5E1),
    dark: Color(0xFF1A1B22),
    sepia: Color(0xFFD8C7A5),
  );

  static const AppModeColor postAttachmentGradientStart = AppModeColor(
    light: Color(0xFFF4F6F8),
    dark: Color(0xFF2C2C34),
    sepia: Color(0xFFEDE3CC),
  );

  static const AppModeColor postAttachmentGradientEnd = AppModeColor(
    light: Color(0xFFE5E9EE),
    dark: Color(0xFF1B1B20),
    sepia: Color(0xFFE2D4B7),
  );

  static const AppModeColor authBackground = AppModeColor(
    light: Color(0xFFF9FAFB),
    dark: Color(0xFF121214),
    sepia: Color(0xFFF4ECD8),
  );

  static const AppModeColor authInk = AppModeColor(
    light: Color(0xFF222222),
    dark: Color(0xFFE6E1E5),
    sepia: Color(0xFF3B2F1E),
  );

  static const AppModeColor authDivider = AppModeColor(
    light: Color(0xFFEEEEEE),
    dark: Color(0xFF2E2E38),
    sepia: Color(0xFFD8C7A5),
  );

  static const AppModeColor authBorder = AppModeColor(
    light: Color(0xFFE0E0E0),
    dark: Color(0xFF3A3B3C),
    sepia: Color(0xFFD8C7A5),
  );

  static const AppModeColor authCtaBg = AppModeColor(
    light: Colors.black,
    dark: Color(0xFFDEC08F),
    sepia: Color(0xFF5D4037),
  );

  static const AppModeColor authCtaFg = AppModeColor(
    light: Colors.white,
    dark: Color(0xFF1F1B16),
    sepia: Colors.white,
  );

  // ---------------------------------------------------------------------------
  // Semantic Status & Social Action Colors
  // ---------------------------------------------------------------------------

  static const AppModeColor socialBlue = AppModeColor(
    light: Color(0xFF1877F2),
    dark: Color(0xFF3B82F6),
    sepia: Color(0xFF2563EB),
  );

  static const AppModeColor socialBlueTint = AppModeColor(
    light: Color(0xFFE7F3FF),
    dark: Color(0x2E1877F2),
    sepia: Color(0x242563EB),
  );

  static const AppModeColor actionBlue = AppModeColor(
    light: Color(0xFF0095F6),
    dark: Color(0xFF38BDF8),
    sepia: Color(0xFF0284C7),
  );

  static const AppModeColor infoBlue = AppModeColor(
    light: Color(0xFF2196F3),
    dark: Color(0xFF60A5FA),
    sepia: Color(0xFF1D4ED8),
  );

  static const AppModeColor blueAccent = AppModeColor(
    light: Colors.blueAccent,
    dark: Color(0xFF60A5FA),
    sepia: Color(0xFF2563EB),
  );

  static const AppModeColor blueStrong = AppModeColor(
    light: Color(0xFF1E88E5),
    dark: Color(0xFF60A5FA),
    sepia: Color(0xFF1D4ED8),
  );

  static const AppModeColor danger = AppModeColor(
    light: Colors.red,
    dark: Color(0xFFF87171),
    sepia: Color(0xFFB91C1C),
  );

  static const AppModeColor dangerAccent = AppModeColor(
    light: Colors.redAccent,
    dark: Color(0xFFFF6B6B),
    sepia: Color(0xFFC83E3B),
  );

  static const AppModeColor dangerSoft = AppModeColor(
    light: Color(0xFFFFEBEE),
    dark: Color(0x29F87171),
    sepia: Color(0x26B91C1C),
  );

  static const AppModeColor likeRed = AppModeColor(
    light: Color(0xFFED4956),
    dark: Color(0xFFFF5A67),
    sepia: Color(0xFFC93B47),
  );

  static const AppModeColor badgeRed = AppModeColor(
    light: Color(0xFFE41E3F),
    dark: Color(0xFFFF4B66),
    sepia: Color(0xFFC82333),
  );

  static const AppModeColor success = AppModeColor(
    light: Color(0xFF16A34A),
    dark: Color(0xFF34C759),
    sepia: Color(0xFF2E7D32),
  );

  static const AppModeColor successGreen = AppModeColor(
    light: Colors.green,
    dark: Color(0xFF4ADE80),
    sepia: Color(0xFF2E7D32),
  );

  static const AppModeColor successBright = AppModeColor(
    light: Color(0xFF10B981),
    dark: Color(0xFF34D399),
    sepia: Color(0xFF2F855A),
  );

  static const AppModeColor onlineGreen = AppModeColor(
    light: Color(0xFF22C55E),
    dark: Color(0xFF4ADE80),
    sepia: Color(0xFF38A169),
  );

  static const AppModeColor terminalGreen = AppModeColor(
    light: Colors.greenAccent,
    dark: Colors.greenAccent,
    sepia: Color(0xFF69F0AE),
  );

  static const AppModeColor postPhotoGreen = AppModeColor(
    light: Color(0xFF4CAF50),
    dark: Color(0xFF66BB6A),
    sepia: Color(0xFF388E3C),
  );

  static const AppModeColor postDocumentGreenStart = AppModeColor(
    light: Color(0xFF2E7D32),
    dark: Color(0xFF2E7D32),
    sepia: Color(0xFF33691E),
  );

  static const AppModeColor postDocumentGreenEnd = AppModeColor(
    light: Color(0xFF1B5E20),
    dark: Color(0xFF1B5E20),
    sepia: Color(0xFF1B5E20),
  );

  static const AppModeColor warning = AppModeColor(
    light: Color(0xFFFFB300),
    dark: Color(0xFFFBBF24),
    sepia: Color(0xFFD97706),
  );

  static const AppModeColor amber = AppModeColor(
    light: Colors.amber,
    dark: Color(0xFFFBBF24),
    sepia: Color(0xFFD97706),
  );

  static const AppModeColor amberStrong = AppModeColor(
    light: Color(0xFFFF8F00),
    dark: Color(0xFFF59E0B),
    sepia: Color(0xFFB45309),
  );

  static const AppModeColor warningSoft = AppModeColor(
    light: Color(0xFFFFF8E1),
    dark: Color(0x29FBBF24),
    sepia: Color(0x26D97706),
  );

  static const AppModeColor warningBorder = AppModeColor(
    light: Color(0xFFFFE082),
    dark: Color(0x59FBBF24),
    sepia: Color(0x4DD97706),
  );

  static const AppModeColor warningYellow = AppModeColor(
    light: Color(0xFFFBC02D),
    dark: Color(0xFFFACC15),
    sepia: Color(0xFFCA8A04),
  );

  static const AppModeColor orange = AppModeColor(
    light: Colors.orange,
    dark: Color(0xFFFB923C),
    sepia: Color(0xFFC2410C),
  );

  static const AppModeColor deepOrange = AppModeColor(
    light: Colors.deepOrange,
    dark: Color(0xFFFF7043),
    sepia: Color(0xFFBF360C),
  );

  static const AppModeColor reactionPink = AppModeColor(
    light: Color(0xFFE91E63),
    dark: Color(0xFFF472B6),
    sepia: Color(0xFFBE185D),
  );

  static const AppModeColor purpleAccent = AppModeColor(
    light: Color(0xFF9C27B0),
    dark: Color(0xFFA855F7),
    sepia: Color(0xFF7E22CE),
  );

  static const AppModeColor purpleSoft = AppModeColor(
    light: Color(0xFFA855F7),
    dark: Color(0xFFC084FC),
    sepia: Color(0xFF7E22CE),
  );

  static const AppModeColor blueGrey = AppModeColor(
    light: Colors.blueGrey,
    dark: Color(0xFF94A3B8),
    sepia: Color(0xFF78716C),
  );

  // ---------------------------------------------------------------------------
  // Calls & Ringing Colors
  // ---------------------------------------------------------------------------

  static const AppModeColor callRingingBgStart = AppModeColor(
    light: Color(0xFFE8E5E0),
    dark: Color(0xFF1E293B),
    sepia: Color(0xFFE6D8BC),
  );

  static const AppModeColor callRingingBgEnd = AppModeColor(
    light: Color(0xFFF7F5F2),
    dark: Color(0xFF0F172A),
    sepia: Color(0xFFF4ECD8),
  );

  static const AppModeColor callRipple = AppModeColor(
    light: Color(0xFF8B857B),
    dark: Color(0xFF94A3B8),
    sepia: Color(0xFF8A7A5F),
  );

  static const AppModeColor callConnectedBgStart = AppModeColor(
    light: Color(0xFF1E293B),
    dark: Color(0xFF1E293B),
    sepia: Color(0xFF2C1D18),
  );

  static const AppModeColor callConnectedBgEnd = AppModeColor(
    light: Color(0xFF0F172A),
    dark: Color(0xFF0F172A),
    sepia: Color(0xFF1A110D),
  );

  static const AppModeColor callControlBarBg = AppModeColor(
    light: Color(0xFF1E293B),
    dark: Color(0xFF1E293B),
    sepia: Color(0xFF2C1D18),
  );

  static const AppModeColor callAcceptGreen = AppModeColor(
    light: Color(0xFF34C759),
    dark: Color(0xFF34C759),
    sepia: Color(0xFF2E7D32),
  );

  static const AppModeColor callDeclineRed = AppModeColor(
    light: Color(0xFFD63A2F),
    dark: Color(0xFFD63A2F),
    sepia: Color(0xFFB91C1C),
  );

  // ---------------------------------------------------------------------------
  // Media, Video Player & Story Overlay Colors
  // ---------------------------------------------------------------------------

  static const AppModeColor mediaBackdrop = AppModeColor.all(Colors.black);
  static const AppModeColor mediaScrim87 = AppModeColor.all(Colors.black87);
  static const AppModeColor mediaScrim54 = AppModeColor.all(Colors.black54);
  static const AppModeColor mediaScrim45 = AppModeColor.all(Colors.black45);
  static const AppModeColor mediaScrim38 = AppModeColor.all(Colors.black38);
  static const AppModeColor mediaScrim26 = AppModeColor.all(Colors.black26);
  static const AppModeColor mediaScrim12 = AppModeColor.all(Colors.black12);

  static const AppModeColor onMedia = AppModeColor.all(Colors.white);
  static const AppModeColor onMedia70 = AppModeColor.all(Colors.white70);
  static const AppModeColor onMedia60 = AppModeColor.all(Colors.white60);
  static const AppModeColor onMedia54 = AppModeColor.all(Colors.white54);
  static const AppModeColor onMedia38 = AppModeColor.all(Colors.white38);
  static const AppModeColor onMedia30 = AppModeColor.all(Colors.white30);
  static const AppModeColor onMedia24 = AppModeColor.all(Colors.white24);
  static const AppModeColor onMedia12 = AppModeColor.all(Colors.white12);
  static const AppModeColor onMedia10 = AppModeColor.all(Colors.white10);

  static const AppModeColor mediaDarkSurface = AppModeColor(
    light: Color(0xFF1E1E24),
    dark: Color(0xFF1E1E24),
    sepia: Color(0xFF2A1E17),
  );

  static const AppModeColor mediaDarkSurfaceDeep = AppModeColor(
    light: Color(0xFF0F0F12),
    dark: Color(0xFF0F0F12),
    sepia: Color(0xFF1B130F),
  );

  static const AppModeColor mediaDarkCard = AppModeColor(
    light: Color(0xFF262626),
    dark: Color(0xFF262626),
    sepia: Color(0xFF33241C),
  );

  static const AppModeColor mediaDarkField = AppModeColor(
    light: Color(0xFF24242A),
    dark: Color(0xFF24242A),
    sepia: Color(0xFF2E2019),
  );

  static const AppModeColor mediaDarkIconBg = AppModeColor(
    light: Color(0xFF3E3E48),
    dark: Color(0xFF3E3E48),
    sepia: Color(0xFF4A372B),
  );

  static const AppModeColor mediaDarkTrack = AppModeColor(
    light: Color(0xFF4A4A58),
    dark: Color(0xFF4A4A58),
    sepia: Color(0xFF5A4538),
  );

  static const AppModeColor videoFallbackStart = AppModeColor(
    light: Color(0xFF263238),
    dark: Color(0xFF263238),
    sepia: Color(0xFF3E2723),
  );

  static const AppModeColor videoFallbackEnd = AppModeColor(
    light: Color(0xFF102027),
    dark: Color(0xFF102027),
    sepia: Color(0xFF1E130F),
  );

  static const AppModeColor mediaLoaderBg = AppModeColor(
    light: Color(0xFF212121),
    dark: Color(0xFF212121),
    sepia: Color(0xFF2C1D18),
  );

  static const AppModeColor storyDurationStart =
      AppModeColor.all(Color(0xFFFF2D55));
  static const AppModeColor storyDurationEnd =
      AppModeColor.all(Color(0xFFFF9500));
  static const AppModeColor storyDeleteRed =
      AppModeColor.all(Color(0xFFFF3B30));

  // ---------------------------------------------------------------------------
  // Livestream & Chill Tokens
  // ---------------------------------------------------------------------------

  static const AppModeColor livePink = AppModeColor(
    light: Color(0xFFFF0844),
    dark: Color(0xFFFF0844),
    sepia: Color(0xFFD91E48),
  );

  static const AppModeColor livePinkGlow = AppModeColor(
    light: Color(0x66FF0844),
    dark: Color(0x66FF0844),
    sepia: Color(0x66D91E48),
  );

  static const AppModeColor liveCoral = AppModeColor(
    light: Color(0xFFFF4E50),
    dark: Color(0xFFFF4E50),
    sepia: Color(0xFFE05252),
  );

  static const AppModeColor livePeach = AppModeColor.all(Color(0xFFFFB199));
  static const AppModeColor liveCrimson = AppModeColor.all(Color(0xFFFF2D55));
  static const AppModeColor liveOrange = AppModeColor.all(Color(0xFFFF5E3A));
  static const AppModeColor liveCyan = AppModeColor.all(Color(0xFF64D2FF));

  static const AppModeColor liveSurfaceDark = AppModeColor(
    light: Color(0xFF161823),
    dark: Color(0xFF161823),
    sepia: Color(0xFF241A15),
  );

  static const AppModeColor liveBgTop = AppModeColor(
    light: Color(0xFF1E2238),
    dark: Color(0xFF1E2238),
    sepia: Color(0xFF2E221B),
  );

  static const AppModeColor liveBgMid = AppModeColor(
    light: Color(0xFF141624),
    dark: Color(0xFF141624),
    sepia: Color(0xFF221813),
  );

  static const AppModeColor liveBgBottom = AppModeColor(
    light: Color(0xFF0B0D17),
    dark: Color(0xFF0B0D17),
    sepia: Color(0xFF17100D),
  );

  static const AppModeColor liveScaffoldDark = AppModeColor(
    light: Color(0xFF10121D),
    dark: Color(0xFF10121D),
    sepia: Color(0xFF1B1410),
  );

  static const AppModeColor liveCardSelected = AppModeColor(
    light: Color(0xFF2E3244),
    dark: Color(0xFF2E3244),
    sepia: Color(0xFF3E3027),
  );

  static const AppModeColor liveGradientGrayStart = AppModeColor(
    light: Color(0xFF232526),
    dark: Color(0xFF232526),
    sepia: Color(0xFF3A2E27),
  );

  static const AppModeColor liveGradientGrayEnd = AppModeColor(
    light: Color(0xFF414345),
    dark: Color(0xFF414345),
    sepia: Color(0xFF544339),
  );

  static const AppModeColor liveAltBgStart = AppModeColor(
    light: Color(0xFF1F1C2C),
    dark: Color(0xFF1F1C2C),
    sepia: Color(0xFF2C221E),
  );

  static const AppModeColor liveAltBgMid = AppModeColor(
    light: Color(0xFF928DAB),
    dark: Color(0xFF928DAB),
    sepia: Color(0xFF8C7A6B),
  );

  static const AppModeColor liveAltBgEnd = AppModeColor(
    light: Color(0xFF141E30),
    dark: Color(0xFF141E30),
    sepia: Color(0xFF221814),
  );

  static const AppModeColor liveGold = AppModeColor.all(Color(0xFFFFD700));
  static const AppModeColor liveSilver = AppModeColor.all(Color(0xFFC0C0C0));
  static const AppModeColor liveBronze = AppModeColor.all(Color(0xFFCD7F32));
  static const AppModeColor liveTeal = AppModeColor.all(Color(0xFF00C7BE));
  static const AppModeColor liveGlowOrange =
      AppModeColor.all(Color(0xFFFF8C00));

  // ---------------------------------------------------------------------------
  // Profile & Contacts Gradient Tokens
  // ---------------------------------------------------------------------------

  static const AppModeColor profileCoverStart = AppModeColor(
    light: Color(0xFF2563EB),
    dark: Color(0xFF1E3A8A),
    sepia: Color(0xFF7C4D2B),
  );

  static const AppModeColor profileCoverMid = AppModeColor(
    light: Color(0xFF4F46E5),
    dark: Color(0xFF312E81),
    sepia: Color(0xFF8A5A2B),
  );

  static const AppModeColor profileCoverEnd = AppModeColor(
    light: Color(0xFF7C3AED),
    dark: Color(0xFF4C1D95),
    sepia: Color(0xFF5D4037),
  );

  static const AppModeColor contactsBannerStart = AppModeColor(
    light: Color(0xFF6F5B40),
    dark: Color(0xFFDEC08F),
    sepia: Color(0xFF8A5A2B),
  );

  static const AppModeColor contactsBannerMid = AppModeColor(
    light: Color(0xFFC07F39),
    dark: Color(0xFFF7D9A4),
    sepia: Color(0xFFC07F39),
  );

  static const AppModeColor contactsBannerEnd = AppModeColor(
    light: Color(0xFFE29F52),
    dark: Color(0xFFB7CEA0),
    sepia: Color(0xFFD4A373),
  );

  static const AppModeColor contactsTabLabel = AppModeColor(
    light: Colors.white,
    dark: Color(0xFF271905),
    sepia: Colors.white,
  );

  static const AppModeColor contactsSelectedTabBg = AppModeColor(
    light: Color(0xFF6F5B40),
    dark: Color(0xFFDEC08F),
    sepia: Color(0xFF8A5A2B),
  );

  // ---------------------------------------------------------------------------
  // Story & Post Gradients + Gift Gradients + Palettes
  // ---------------------------------------------------------------------------

  static const AppModeColor storySunset1 = AppModeColor.all(Color(0xFF8A2387));
  static const AppModeColor storySunset2 = AppModeColor.all(Color(0xFFE94057));
  static const AppModeColor storySunset3 = AppModeColor.all(Color(0xFFF27121));

  static const AppModeColor storySignature1 =
      AppModeColor.all(Color(0xFFFBAA47));
  static const AppModeColor storySignature2 =
      AppModeColor.all(Color(0xFFD91A46));
  static const AppModeColor storySignature3 =
      AppModeColor.all(Color(0xFFA60F93));

  static const AppModeColor storyMidnight1 =
      AppModeColor.all(Color(0xFF0F0C29));
  static const AppModeColor storyMidnight2 =
      AppModeColor.all(Color(0xFF302B63));
  static const AppModeColor storyMidnight3 =
      AppModeColor.all(Color(0xFF24243E));

  static const AppModeColor storyEmerald1 = AppModeColor.all(Color(0xFF10B981));
  static const AppModeColor storyEmerald2 = AppModeColor.all(Color(0xFF047857));
  static const AppModeColor storyEmerald3 = AppModeColor.all(Color(0xFF064E3B));

  static const AppModeColor storyEmeraldAltEnd =
      AppModeColor.all(Color(0xFF059669));

  static const AppModeColor storyOcean1 = AppModeColor.all(Color(0xFF2193B0));
  static const AppModeColor storyOcean2 = AppModeColor.all(Color(0xFF6DD5ED));

  static const AppModeColor storyLavender1 =
      AppModeColor.all(Color(0xFF654EA3));
  static const AppModeColor storyLavender2 =
      AppModeColor.all(Color(0xFFEAAFC8));

  static const AppModeColor storySolar1 = AppModeColor.all(Color(0xFFFF512F));
  static const AppModeColor storySolar2 = AppModeColor.all(Color(0xFFDD2476));

  static const AppModeColor storyObsidian1 =
      AppModeColor.all(Color(0xFF141418));
  static const AppModeColor storyObsidian2 =
      AppModeColor.all(Color(0xFF0A0A0C));

  static const AppModeColor postCoralStart =
      AppModeColor.all(Color(0xFFFF416C));
  static const AppModeColor postCoralEnd = AppModeColor.all(Color(0xFFFF4B2B));
  static const AppModeColor postMintStart = AppModeColor.all(Color(0xFF11998E));
  static const AppModeColor postMintEnd = AppModeColor.all(Color(0xFF38EF7D));
  static const AppModeColor postPastelStart =
      AppModeColor.all(Color(0xFFB993D6));
  static const AppModeColor postPastelEnd = AppModeColor.all(Color(0xFF8CA6DB));

  static const AppModeColor giftHeartStart =
      AppModeColor.all(Color(0xFFF355A0));
  static const AppModeColor giftHeartEnd = AppModeColor.all(Color(0xFFFF758C));
  static const AppModeColor giftCoffeeStart =
      AppModeColor.all(Color(0xFF8B5A2B));
  static const AppModeColor giftCoffeeEnd = AppModeColor.all(Color(0xFFD4A373));
  static const AppModeColor giftDiamondStart =
      AppModeColor.all(Color(0xFF00C6FF));
  static const AppModeColor giftDiamondEnd =
      AppModeColor.all(Color(0xFF0072FF));
  static const AppModeColor giftFireworkStart =
      AppModeColor.all(Color(0xFFFF9A8B));
  static const AppModeColor giftFireworkEnd =
      AppModeColor.all(Color(0xFFFF6A88));
  static const AppModeColor giftRocketStart =
      AppModeColor.all(Color(0xFF7F00FF));
  static const AppModeColor giftRocketEnd = AppModeColor.all(Color(0xFFE100FF));
  static const AppModeColor giftCrownEnd = AppModeColor.all(Color(0xFFFFA500));

  // Notification badge gradient stops
  static const AppModeColor badgeBlueLight =
      AppModeColor.all(Color(0xFF3B82F6));
  static const AppModeColor badgePinkLight =
      AppModeColor.all(Color(0xFFFF4B72));
  static const AppModeColor badgeMintLight =
      AppModeColor.all(Color(0xFF34D399));
  static const AppModeColor badgeSkyLight = AppModeColor.all(Color(0xFF38BDF8));
  static const AppModeColor badgeSkyDark = AppModeColor.all(Color(0xFF0284C7));
  static const AppModeColor badgeRedLight = AppModeColor.all(Color(0xFFF87171));
  static const AppModeColor badgeRedDark = AppModeColor.all(Color(0xFFDC2626));
  static const AppModeColor badgePurpleLight =
      AppModeColor.all(Color(0xFFA78BFA));
  static const AppModeColor badgeMessengerLight =
      AppModeColor.all(Color(0xFF00B2FF));
  static const AppModeColor badgeMessengerDark =
      AppModeColor.all(Color(0xFF006AFF));
  static const AppModeColor badgeAmberLight =
      AppModeColor.all(Color(0xFFFBBF24));
  static const AppModeColor badgeAmberDark =
      AppModeColor.all(Color(0xFFD97706));
  static const AppModeColor badgeBlueSoft = AppModeColor.all(Color(0xFF60A5FA));

  // ---------------------------------------------------------------------------
  // Shared Palettes (Avatars, Story Text, Floating Hearts, Notifications)
  // ---------------------------------------------------------------------------

  static const List<AppModeColor> avatarPalette = [
    AppModeColor(
      light: Color(0xFF673AB7),
      dark: Color(0xFF7E57C2),
      sepia: Color(0xFF6D4C41),
    ),
    AppModeColor(
      light: Color(0xFF3F51B5),
      dark: Color(0xFF5C6BC0),
      sepia: Color(0xFF5D4037),
    ),
    AppModeColor(
      light: Color(0xFF009688),
      dark: Color(0xFF26A69A),
      sepia: Color(0xFF4E6B50),
    ),
    AppModeColor(
      light: Color(0xFFE91E63),
      dark: Color(0xFFEC407A),
      sepia: Color(0xFFA14A58),
    ),
    AppModeColor(
      light: Color(0xFFFF5722),
      dark: Color(0xFFFF7043),
      sepia: Color(0xFFB85D3B),
    ),
  ];

  static const List<AppModeColor> friendAvatarPalette = [
    AppModeColor(
      light: Color(0xFF4F46E5),
      dark: Color(0xFF6366F1),
      sepia: Color(0xFF5D4037),
    ),
    AppModeColor(
      light: Color(0xFF0891B2),
      dark: Color(0xFF22D3EE),
      sepia: Color(0xFF4E6B50),
    ),
    AppModeColor(
      light: Color(0xFF059669),
      dark: Color(0xFF10B981),
      sepia: Color(0xFF3F6212),
    ),
    AppModeColor(
      light: Color(0xFFD97706),
      dark: Color(0xFFF59E0B),
      sepia: Color(0xFF9A5B13),
    ),
    AppModeColor(
      light: Color(0xFFE11D48),
      dark: Color(0xFFF43F5E),
      sepia: Color(0xFF9F3A47),
    ),
  ];

  static const List<AppModeColor> notificationAvatarPalette = [
    AppModeColor(
      light: Color(0xFF1877F2),
      dark: Color(0xFF3B82F6),
      sepia: Color(0xFF2563EB),
    ),
    AppModeColor(
      light: Color(0xFFE41E3F),
      dark: Color(0xFFFF4B66),
      sepia: Color(0xFFB91C1C),
    ),
    AppModeColor(
      light: Color(0xFF00A400),
      dark: Color(0xFF22C55E),
      sepia: Color(0xFF2E7D32),
    ),
    AppModeColor(
      light: Color(0xFF8B5CF6),
      dark: Color(0xFFA78BFA),
      sepia: Color(0xFF6D4C41),
    ),
    AppModeColor(
      light: Color(0xFFF59E0B),
      dark: Color(0xFFFBBF24),
      sepia: Color(0xFFB45309),
    ),
    AppModeColor(
      light: Color(0xFF0EA5E9),
      dark: Color(0xFF38BDF8),
      sepia: Color(0xFF0284C7),
    ),
    AppModeColor(
      light: Color(0xFFEC4899),
      dark: Color(0xFFF472B6),
      sepia: Color(0xFFBE185D),
    ),
    AppModeColor(
      light: Color(0xFF14B8A6),
      dark: Color(0xFF2DD4BF),
      sepia: Color(0xFF0F766E),
    ),
  ];

  static const List<AppModeColor> storyTextPalette = [
    AppModeColor.all(Colors.white),
    AppModeColor.all(Colors.black),
    AppModeColor.all(Color(0xFFFF2D55)),
    AppModeColor.all(Color(0xFFFF9500)),
    AppModeColor.all(Color(0xFFFFCC00)),
    AppModeColor.all(Color(0xFF34C759)),
    AppModeColor.all(Color(0xFF007AFF)),
    AppModeColor.all(Color(0xFF5856D6)),
    AppModeColor.all(Color(0xFFAF52DE)),
    AppModeColor.all(Color(0xFF00C7BE)),
  ];

  static const List<AppModeColor> floatingHeartPalette = [
    AppModeColor.all(Color(0xFFFF2D55)),
    AppModeColor.all(Color(0xFFFF375F)),
    AppModeColor.all(Color(0xFFFF6482)),
    AppModeColor.all(Color(0xFFFF9500)),
    AppModeColor.all(Color(0xFFFFCC00)),
    AppModeColor.all(Color(0xFFAF52DE)),
    AppModeColor.all(Color(0xFF5856D6)),
    AppModeColor.all(Color(0xFF00C7BE)),
  ];
}
