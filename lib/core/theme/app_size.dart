import 'package:flutter/material.dart';

/// Centralized dimension tokens for Lotus Connect.
///
/// Built on a 4dp spatial grid to keep padding, margins, border strokes,
/// border radii, icon/avatar sizes, touch targets, and layout constraints
/// consistent across the entire app.
class AppSize {
  const AppSize._();

  // ---------------------------------------------------------------------------
  // Base Spacing Scale (4dp grid)
  // ---------------------------------------------------------------------------

  /// `0.0` — Zero spacing.
  static const double none = 0;

  /// `2.0` — Micro spacing (badge offsets, hairline separations).
  static const double xxs = 2;

  /// `4.0` — Extra small spacing (tight inline icon-to-label gaps).
  static const double xs = 4;

  /// `8.0` — Small spacing (compact element gaps, chip groups).
  static const double sm = 8;

  /// `12.0` — Medium spacing (compact card padding, list gaps).
  static const double md = 12;

  /// `16.0` — Large spacing (default screen padding, standard card padding).
  static const double lg = 16;

  /// `20.0` — Extra large spacing (sheet padding, relaxed containers).
  static const double xl = 20;

  /// `24.0` — 2x extra large spacing (section gaps, dialog padding).
  static const double xxl = 24;

  /// `32.0` — 3x extra large spacing (major vertical rhythm).
  static const double xxxl = 32;

  /// `40.0` — Huge spacing (hero blocks, empty-state spacing).
  static const double huge = 40;

  /// `48.0` — Massive spacing (onboarding/auth vertical breathing room).
  static const double massive = 48;

  /// `64.0` — Giant spacing (large header/footer offsets).
  static const double giant = 64;

  // ---------------------------------------------------------------------------
  // Semantic Padding & Margin Tokens
  // ---------------------------------------------------------------------------

  /// `16.0` — Default screen horizontal/body padding.
  static const double screenPadding = lg;

  /// `12.0` — Compact screen padding for dense feeds or small viewports.
  static const double screenPaddingCompact = md;

  /// `24.0` — Expanded screen padding for tablet/desktop viewports.
  static const double screenPaddingWide = xxl;

  /// `16.0` — Standard card internal padding.
  static const double cardPadding = lg;

  /// `12.0` — Compact card internal padding.
  static const double cardPaddingCompact = md;

  /// `24.0` — Modal dialog content padding.
  static const double dialogPadding = xxl;

  /// `20.0` — Bottom sheet content padding.
  static const double sheetPadding = xl;

  /// `16.0` — Horizontal padding inside list tiles and rows.
  static const double listTileHorizontal = lg;

  /// `12.0` — Vertical padding inside list tiles and rows.
  static const double listTileVertical = md;

  /// `16.0` — Horizontal padding inside text fields.
  static const double inputHorizontal = lg;

  /// `12.0` — Vertical padding inside text fields.
  static const double inputVertical = md;

  /// `20.0` — Horizontal padding inside standard buttons.
  static const double buttonHorizontal = xl;

  /// `12.0` — Vertical padding inside standard buttons.
  static const double buttonVertical = md;

  /// `12.0` — Horizontal padding inside compact/small buttons.
  static const double buttonCompactHorizontal = md;

  /// `8.0` — Vertical padding inside compact/small buttons.
  static const double buttonCompactVertical = sm;

  /// `12.0` — Horizontal padding inside chips and filter pills.
  static const double chipHorizontal = md;

  /// `6.0` — Vertical padding inside chips and filter pills.
  static const double chipVertical = 6;

  /// `6.0` — Horizontal padding inside count/status badges.
  static const double badgeHorizontal = 6;

  /// `2.0` — Vertical padding inside count/status badges.
  static const double badgeVertical = xxs;

  /// `14.0` — Horizontal padding inside chat message bubbles.
  static const double bubbleHorizontal = 14;

  /// `10.0` — Vertical padding inside chat message bubbles.
  static const double bubbleVertical = 10;

  /// `4.0` — Gap between tightly coupled inline elements (icon & count).
  static const double inlineGap = xs;

  /// `8.0` — Gap between sibling controls or list items.
  static const double itemGap = sm;

  /// `16.0` — Vertical gap between form fields or cards.
  static const double fieldGap = lg;

  /// `24.0` — Vertical gap between distinct screen sections.
  static const double sectionGap = xxl;

  /// `32.0` — Vertical gap between major layout groups.
  static const double groupGap = xxxl;

  // ---------------------------------------------------------------------------
  // Border Stroke & Divider Tokens
  // ---------------------------------------------------------------------------

  /// `0.0` — No border stroke.
  static const double borderNone = 0;

  /// `0.5` — Hairline stroke for subtle dividers and bubble outlines.
  static const double borderHairline = 0.5;

  /// `1.0` — Default border stroke for inputs, cards, and dividers.
  static const double borderThin = 1;

  /// `1.5` — Medium stroke for focused inputs and active tabs.
  static const double borderMedium = 1.5;

  /// `2.0` — Thick stroke for selected states, focus rings, avatar cutouts.
  static const double borderThick = 2;

  /// `3.0` — Heavy stroke for story rings and active call indicators.
  static const double borderHeavy = 3;

  /// `1.0` — Standard horizontal/vertical divider thickness.
  static const double dividerThickness = borderThin;

  /// `16.0` — Standard divider leading/trailing indent.
  static const double dividerIndent = lg;

  // ---------------------------------------------------------------------------
  // Border Radius Scale & Semantic Radii
  // ---------------------------------------------------------------------------

  /// `0.0` — Sharp corners.
  static const double radiusNone = 0;

  /// `4.0` — Extra small radius (tags, inline code, progress bars, tail).
  static const double radiusXs = 4;

  /// `8.0` — Small radius (chips, compact buttons, tooltips, snackbars).
  static const double radiusSm = 8;

  /// `12.0` — Medium radius (inputs, standard buttons, menus, media thumbs).
  static const double radiusMd = 12;

  /// `16.0` — Large radius (cards, chat bubbles, containers).
  static const double radiusLg = 16;

  /// `20.0` — Extra large radius (search bars, segmented controls).
  static const double radiusXl = 20;

  /// `24.0` — 2x extra large radius (bottom sheets, floating bars).
  static const double radiusXxl = 24;

  /// `28.0` — 3x extra large radius (Material 3 dialogs, large sheets).
  static const double radiusXxxl = 28;

  /// `999.0` — Full capsule/pill radius.
  static const double radiusFull = 999;

  /// `12.0` — Default radius for buttons.
  static const double radiusButton = radiusMd;

  /// `12.0` — Default radius for input fields.
  static const double radiusInput = radiusMd;

  /// `16.0` — Default radius for cards.
  static const double radiusCard = radiusLg;

  /// `8.0` — Default radius for chips and filter tags.
  static const double radiusChip = radiusSm;

  /// `28.0` — Default radius for Material 3 dialogs.
  static const double radiusDialog = radiusXxxl;

  /// `24.0` — Default top corner radius for modal bottom sheets.
  static const double radiusBottomSheet = radiusXxl;

  /// `16.0` — Default radius for chat message bubbles.
  static const double radiusChatBubble = radiusLg;

  /// `4.0` — Corner radius on the trailing/leading tail side of a chat bubble.
  static const double radiusChatBubbleTail = radiusXs;

  /// `12.0` — Default radius for image/video attachments in feeds and chats.
  static const double radiusMedia = radiusMd;

  // ---------------------------------------------------------------------------
  // Icon Sizes
  // ---------------------------------------------------------------------------

  /// `12.0` — Micro status icons (read receipts, tiny indicators).
  static const double iconXxs = 12;

  /// `16.0` — Extra small icons (metadata, timestamps, chip icons).
  static const double iconXs = 16;

  /// `20.0` — Small icons (input prefix/suffix, compact icon buttons).
  static const double iconSm = 20;

  /// `24.0` — Medium icons (standard AppBar, NavigationBar, ListTile).
  static const double iconMd = 24;

  /// `28.0` — Large icons (prominent navigation/action triggers).
  static const double iconLg = 28;

  /// `32.0` — Extra large icons (call controls, media player overlays).
  static const double iconXl = 32;

  /// `48.0` — 2x extra large icons (avatar fallbacks, feature badges).
  static const double iconXxl = 48;

  /// `64.0` — Hero icons (empty states, onboarding, error illustrations).
  static const double iconHero = 64;

  // ---------------------------------------------------------------------------
  // Avatar, Status Indicator & Story Sizes
  // ---------------------------------------------------------------------------

  /// `24.0` — Extra small avatar diameter (reaction stacks, mention pills).
  static const double avatarXs = 24;

  /// `32.0` — Small avatar diameter (comment replies, compact headers).
  static const double avatarSm = 32;

  /// `40.0` — Medium avatar diameter (chat messages, standard list rows).
  static const double avatarMd = 40;

  /// `48.0` — Large avatar diameter (conversation tiles, contact rows).
  static const double avatarLg = 48;

  /// `56.0` — Extra large avatar diameter (notification tiles, story tray).
  static const double avatarXl = 56;

  /// `80.0` — 2x extra large avatar diameter (settings header, active call).
  static const double avatarXxl = 80;

  /// `96.0` — Full profile avatar diameter.
  static const double avatarProfile = 96;

  /// `16.0` — Small overlapping badge on avatars (verified, mute).
  static const double avatarBadgeSm = 16;

  /// `24.0` — Medium overlapping badge on avatars (notification type icon).
  static const double avatarBadgeMd = 24;

  /// `8.0` — Small dot indicator (unread dot, typing indicator dot).
  static const double statusDotSm = 8;

  /// `12.0` — Online/away presence dot.
  static const double statusDotMd = 12;

  /// `104.0` — Width of a story tray preview card.
  static const double storyCardWidth = 104;

  /// `176.0` — Height of a story tray preview card.
  static const double storyCardHeight = 176;

  /// `3.0` — Inner gap between story avatar and its gradient ring.
  static const double storyRingPadding = 3;

  // ---------------------------------------------------------------------------
  // Interactive Controls & Touch Targets
  // ---------------------------------------------------------------------------

  /// `48.0` — Minimum accessible tap target size (Material / WCAG).
  static const double minTouchTarget = 48;

  /// `36.0` — Small button height.
  static const double buttonHeightSm = 36;

  /// `44.0` — Standard button height.
  static const double buttonHeightMd = 44;

  /// `52.0` — Large primary CTA button height.
  static const double buttonHeightLg = 52;

  /// `32.0` — Small circular/square icon button size.
  static const double iconButtonSm = 32;

  /// `40.0` — Standard icon button size.
  static const double iconButtonMd = 40;

  /// `48.0` — Large icon button size (meets minimum touch target).
  static const double iconButtonLg = 48;

  /// `40.0` — Compact text input height.
  static const double inputHeightSm = 40;

  /// `48.0` — Standard text input height.
  static const double inputHeightMd = 48;

  /// `56.0` — Large text input height.
  static const double inputHeightLg = 56;

  /// `44.0` — Search bar height.
  static const double searchBarHeight = 44;

  /// `32.0` — Standard chip height.
  static const double chipHeight = 32;

  /// `18.0` — Minimum size for numeric unread count badges.
  static const double badgeCountMinSize = 18;

  // ---------------------------------------------------------------------------
  // Navigation, Bars, Chrome & Indicators
  // ---------------------------------------------------------------------------

  /// `56.0` — Standard AppBar height.
  static const double appBarHeight = 56;

  /// `64.0` — Bottom navigation bar height.
  static const double bottomNavHeight = 64;

  /// `48.0` — TabBar height.
  static const double tabBarHeight = 48;

  /// `40.0` — Small FloatingActionButton size.
  static const double fabSizeSm = 40;

  /// `56.0` — Standard FloatingActionButton size.
  static const double fabSizeMd = 56;

  /// `96.0` — Large FloatingActionButton size.
  static const double fabSizeLg = 96;

  /// `36.0` — Modal bottom sheet drag handle width.
  static const double sheetHandleWidth = 36;

  /// `4.0` — Modal bottom sheet drag handle height.
  static const double sheetHandleHeight = 4;

  /// `4.0` — Standard linear progress bar height.
  static const double progressBarHeight = 4;

  /// `8.0` — Prominent linear progress bar height.
  static const double progressBarHeightLg = 8;

  /// `16.0` — Small inline loading spinner size.
  static const double loaderSizeSm = 16;

  /// `24.0` — Standard loading spinner size.
  static const double loaderSizeMd = 24;

  /// `36.0` — Large full-section loading spinner size.
  static const double loaderSizeLg = 36;

  /// `2.5` — Standard CircularProgressIndicator stroke width.
  static const double loaderStrokeWidth = 2.5;

  // ---------------------------------------------------------------------------
  // Elevation (Material Shadow Depth)
  // ---------------------------------------------------------------------------

  /// `0.0` — Flat surface, no shadow.
  static const double elevationNone = 0;

  /// `1.0` — Subtle elevation for cards and tiles.
  static const double elevationXs = 1;

  /// `2.0` — Raised surfaces and sticky bars.
  static const double elevationSm = 2;

  /// `4.0` — Floating controls and app bars on scroll.
  static const double elevationMd = 4;

  /// `8.0` — Dropdowns, menus, and bottom sheets.
  static const double elevationLg = 8;

  /// `12.0` — Modal dialogs and top overlays.
  static const double elevationXl = 12;

  // ---------------------------------------------------------------------------
  // Layout Constraints & Responsive Breakpoints
  // ---------------------------------------------------------------------------

  /// `600.0` — Compact viewport upper bound (phones).
  static const double breakpointCompact = 600;

  /// `840.0` — Medium viewport upper bound (tablets / foldables).
  static const double breakpointMedium = 840;

  /// `1200.0` — Expanded viewport threshold (desktop / wide layouts).
  static const double breakpointExpanded = 1200;

  /// `400.0` — Maximum width for modal dialogs.
  static const double maxDialogWidth = 400;

  /// `480.0` — Maximum width for auth and settings forms.
  static const double maxFormWidth = 480;

  /// `640.0` — Maximum width for feed posts and chat timelines.
  static const double maxFeedWidth = 640;

  /// `720.0` — Maximum width for general readable content.
  static const double maxContentWidth = 720;

  /// `320.0` — Maximum width for sidebars / navigation drawers.
  static const double maxSidebarWidth = 320;

  /// `0.78` — Maximum chat bubble width as a fraction of viewport width.
  static const double maxChatBubbleWidthRatio = 0.78;

  // ---------------------------------------------------------------------------
  // Skeleton / Shimmer Dimensions
  // ---------------------------------------------------------------------------

  /// `10.0` — Skeleton caption/timestamp line height.
  static const double skeletonLineXs = 10;

  /// `12.0` — Skeleton secondary text line height.
  static const double skeletonLineSm = 12;

  /// `14.0` — Skeleton primary body line height.
  static const double skeletonLineMd = 14;

  /// `18.0` — Skeleton subtitle line height.
  static const double skeletonLineLg = 18;

  /// `22.0` — Skeleton heading line height.
  static const double skeletonTitle = 22;

  /// `180.0` — Skeleton media attachment placeholder height.
  static const double skeletonMediaHeight = 180;

  // ---------------------------------------------------------------------------
  // Responsive Helpers
  // ---------------------------------------------------------------------------

  /// Returns `true` when [width] is within mobile/compact bounds (< 600).
  static bool isCompact(double width) => width < breakpointCompact;

  /// Returns `true` when [width] is within tablet/medium bounds (600..839).
  static bool isMedium(double width) =>
      width >= breakpointCompact && width < breakpointMedium;

  /// Returns `true` when [width] is within desktop/expanded bounds (>= 840).
  static bool isExpanded(double width) => width >= breakpointMedium;

  /// Returns horizontal screen padding scaled to viewport [width].
  static double responsiveHorizontalPadding(double width) {
    if (width < breakpointCompact) return screenPadding;
    if (width < breakpointMedium) return xl;
    return screenPaddingWide;
  }
}

/// Pre-built `const EdgeInsets` padding tokens for consistent widget spacing.
class AppPadding {
  const AppPadding._();

  // ---------------------------------------------------------------------------
  // Uniform All-Side Padding
  // ---------------------------------------------------------------------------

  static const EdgeInsets zero = EdgeInsets.zero;
  static const EdgeInsets xxs = EdgeInsets.all(AppSize.xxs);
  static const EdgeInsets xs = EdgeInsets.all(AppSize.xs);
  static const EdgeInsets sm = EdgeInsets.all(AppSize.sm);
  static const EdgeInsets md = EdgeInsets.all(AppSize.md);
  static const EdgeInsets lg = EdgeInsets.all(AppSize.lg);
  static const EdgeInsets xl = EdgeInsets.all(AppSize.xl);
  static const EdgeInsets xxl = EdgeInsets.all(AppSize.xxl);
  static const EdgeInsets xxxl = EdgeInsets.all(AppSize.xxxl);

  // ---------------------------------------------------------------------------
  // Symmetric Horizontal Padding
  // ---------------------------------------------------------------------------

  static const EdgeInsets hXs = EdgeInsets.symmetric(horizontal: AppSize.xs);
  static const EdgeInsets hSm = EdgeInsets.symmetric(horizontal: AppSize.sm);
  static const EdgeInsets hMd = EdgeInsets.symmetric(horizontal: AppSize.md);
  static const EdgeInsets hLg = EdgeInsets.symmetric(horizontal: AppSize.lg);
  static const EdgeInsets hXl = EdgeInsets.symmetric(horizontal: AppSize.xl);
  static const EdgeInsets hXxl = EdgeInsets.symmetric(horizontal: AppSize.xxl);

  // ---------------------------------------------------------------------------
  // Symmetric Vertical Padding
  // ---------------------------------------------------------------------------

  static const EdgeInsets vXs = EdgeInsets.symmetric(vertical: AppSize.xs);
  static const EdgeInsets vSm = EdgeInsets.symmetric(vertical: AppSize.sm);
  static const EdgeInsets vMd = EdgeInsets.symmetric(vertical: AppSize.md);
  static const EdgeInsets vLg = EdgeInsets.symmetric(vertical: AppSize.lg);
  static const EdgeInsets vXl = EdgeInsets.symmetric(vertical: AppSize.xl);
  static const EdgeInsets vXxl = EdgeInsets.symmetric(vertical: AppSize.xxl);

  // ---------------------------------------------------------------------------
  // Semantic Component Padding
  // ---------------------------------------------------------------------------

  /// Standard all-around screen body padding (`16.0`).
  static const EdgeInsets screen = EdgeInsets.all(AppSize.screenPadding);

  /// Standard horizontal screen padding (`16.0` left/right).
  static const EdgeInsets screenHorizontal = EdgeInsets.symmetric(
    horizontal: AppSize.screenPadding,
  );

  /// Compact screen padding (`12.0`).
  static const EdgeInsets screenCompact = EdgeInsets.all(
    AppSize.screenPaddingCompact,
  );

  /// Standard card content padding (`16.0`).
  static const EdgeInsets card = EdgeInsets.all(AppSize.cardPadding);

  /// Compact card content padding (`12.0`).
  static const EdgeInsets cardCompact = EdgeInsets.all(
    AppSize.cardPaddingCompact,
  );

  /// Modal dialog content padding (`24.0`).
  static const EdgeInsets dialog = EdgeInsets.all(AppSize.dialogPadding);

  /// Bottom sheet content padding (`20.0`).
  static const EdgeInsets bottomSheet = EdgeInsets.all(AppSize.sheetPadding);

  /// Standard list tile padding (`16.0` H, `12.0` V).
  static const EdgeInsets listTile = EdgeInsets.symmetric(
    horizontal: AppSize.listTileHorizontal,
    vertical: AppSize.listTileVertical,
  );

  /// Standard input field content padding (`16.0` H, `12.0` V).
  static const EdgeInsets input = EdgeInsets.symmetric(
    horizontal: AppSize.inputHorizontal,
    vertical: AppSize.inputVertical,
  );

  /// Standard button padding (`20.0` H, `12.0` V).
  static const EdgeInsets button = EdgeInsets.symmetric(
    horizontal: AppSize.buttonHorizontal,
    vertical: AppSize.buttonVertical,
  );

  /// Compact button padding (`12.0` H, `8.0` V).
  static const EdgeInsets buttonCompact = EdgeInsets.symmetric(
    horizontal: AppSize.buttonCompactHorizontal,
    vertical: AppSize.buttonCompactVertical,
  );

  /// Chip and tag padding (`12.0` H, `6.0` V).
  static const EdgeInsets chip = EdgeInsets.symmetric(
    horizontal: AppSize.chipHorizontal,
    vertical: AppSize.chipVertical,
  );

  /// Count/status badge padding (`6.0` H, `2.0` V).
  static const EdgeInsets badge = EdgeInsets.symmetric(
    horizontal: AppSize.badgeHorizontal,
    vertical: AppSize.badgeVertical,
  );

  /// Chat message bubble internal padding (`14.0` H, `10.0` V).
  static const EdgeInsets chatBubble = EdgeInsets.symmetric(
    horizontal: AppSize.bubbleHorizontal,
    vertical: AppSize.bubbleVertical,
  );
}

/// Pre-built `const EdgeInsets` margin tokens for outer widget spacing.
class AppMargin {
  const AppMargin._();

  static const EdgeInsets zero = EdgeInsets.zero;

  /// Margin around standalone cards in a list (`16.0` H, `6.0` V).
  static const EdgeInsets card = EdgeInsets.symmetric(
    horizontal: AppSize.lg,
    vertical: 6,
  );

  /// Bottom margin between list items (`8.0`).
  static const EdgeInsets listItem = EdgeInsets.only(bottom: AppSize.itemGap);

  /// Bottom margin between form fields (`16.0`).
  static const EdgeInsets fieldBottom = EdgeInsets.only(
    bottom: AppSize.fieldGap,
  );

  /// Bottom margin between major screen sections (`24.0`).
  static const EdgeInsets sectionBottom = EdgeInsets.only(
    bottom: AppSize.sectionGap,
  );

  /// Trailing margin for inline icons/avatars (`8.0`).
  static const EdgeInsets inlineEnd = EdgeInsets.only(right: AppSize.itemGap);
}

/// Pre-built `const SizedBox` gap widgets to replace magic-number `SizedBox`es.
class AppGap {
  const AppGap._();

  /// Zero-sized box placeholder.
  static const SizedBox shrink = SizedBox.shrink();

  // ---------------------------------------------------------------------------
  // Vertical Gaps
  // ---------------------------------------------------------------------------

  static const SizedBox vXxs = SizedBox(height: AppSize.xxs);
  static const SizedBox vXs = SizedBox(height: AppSize.xs);
  static const SizedBox vSm = SizedBox(height: AppSize.sm);
  static const SizedBox vMd = SizedBox(height: AppSize.md);
  static const SizedBox vLg = SizedBox(height: AppSize.lg);
  static const SizedBox vXl = SizedBox(height: AppSize.xl);
  static const SizedBox vXxl = SizedBox(height: AppSize.xxl);
  static const SizedBox vXxxl = SizedBox(height: AppSize.xxxl);
  static const SizedBox vHuge = SizedBox(height: AppSize.huge);
  static const SizedBox vMassive = SizedBox(height: AppSize.massive);

  // ---------------------------------------------------------------------------
  // Horizontal Gaps
  // ---------------------------------------------------------------------------

  static const SizedBox hXxs = SizedBox(width: AppSize.xxs);
  static const SizedBox hXs = SizedBox(width: AppSize.xs);
  static const SizedBox hSm = SizedBox(width: AppSize.sm);
  static const SizedBox hMd = SizedBox(width: AppSize.md);
  static const SizedBox hLg = SizedBox(width: AppSize.lg);
  static const SizedBox hXl = SizedBox(width: AppSize.xl);
  static const SizedBox hXxl = SizedBox(width: AppSize.xxl);
  static const SizedBox hXxxl = SizedBox(width: AppSize.xxxl);
}

/// Pre-built `const BorderRadius` tokens for uniform corner rounding.
class AppRadius {
  const AppRadius._();

  static const BorderRadius zero = BorderRadius.zero;
  static const BorderRadius xs = BorderRadius.all(
    Radius.circular(AppSize.radiusXs),
  );
  static const BorderRadius sm = BorderRadius.all(
    Radius.circular(AppSize.radiusSm),
  );
  static const BorderRadius md = BorderRadius.all(
    Radius.circular(AppSize.radiusMd),
  );
  static const BorderRadius lg = BorderRadius.all(
    Radius.circular(AppSize.radiusLg),
  );
  static const BorderRadius xl = BorderRadius.all(
    Radius.circular(AppSize.radiusXl),
  );
  static const BorderRadius xxl = BorderRadius.all(
    Radius.circular(AppSize.radiusXxl),
  );
  static const BorderRadius xxxl = BorderRadius.all(
    Radius.circular(AppSize.radiusXxxl),
  );
  static const BorderRadius full = BorderRadius.all(
    Radius.circular(AppSize.radiusFull),
  );

  // ---------------------------------------------------------------------------
  // Semantic Component Radii
  // ---------------------------------------------------------------------------

  static const BorderRadius button = md;
  static const BorderRadius input = md;
  static const BorderRadius card = lg;
  static const BorderRadius chip = sm;
  static const BorderRadius dialog = xxxl;
  static const BorderRadius media = md;

  /// Rounded top corners for modal bottom sheets (`24.0`).
  static const BorderRadius bottomSheetTop = BorderRadius.vertical(
    top: Radius.circular(AppSize.radiusBottomSheet),
  );

  /// Rounded top corners (`16.0`).
  static const BorderRadius topLg = BorderRadius.vertical(
    top: Radius.circular(AppSize.radiusLg),
  );

  /// Rounded bottom corners (`16.0`).
  static const BorderRadius bottomLg = BorderRadius.vertical(
    bottom: Radius.circular(AppSize.radiusLg),
  );

  /// Outgoing (current user) chat bubble radius with subtle bottom-right tail.
  static const BorderRadius chatBubbleOwn = BorderRadius.only(
    topLeft: Radius.circular(AppSize.radiusChatBubble),
    topRight: Radius.circular(AppSize.radiusChatBubble),
    bottomLeft: Radius.circular(AppSize.radiusChatBubble),
    bottomRight: Radius.circular(AppSize.radiusChatBubbleTail),
  );

  /// Incoming (peer/AI) chat bubble radius with subtle bottom-left tail.
  static const BorderRadius chatBubbleOther = BorderRadius.only(
    topLeft: Radius.circular(AppSize.radiusChatBubble),
    topRight: Radius.circular(AppSize.radiusChatBubble),
    bottomLeft: Radius.circular(AppSize.radiusChatBubbleTail),
    bottomRight: Radius.circular(AppSize.radiusChatBubble),
  );
}

/// Pre-built border stroke and shape helpers for cards, inputs, and buttons.
class AppBorder {
  const AppBorder._();

  /// Empty border side.
  static const BorderSide none = BorderSide.none;

  /// Hairline (`0.5`) border side.
  static BorderSide hairline(Color color) => BorderSide(
        color: color,
        width: AppSize.borderHairline,
      );

  /// Thin (`1.0`) border side (matches `AppSize.borderThin`).
  static BorderSide thin(Color color) => BorderSide(color: color);

  /// Medium (`1.5`) border side.
  static BorderSide medium(Color color) => BorderSide(
        color: color,
        width: AppSize.borderMedium,
      );

  /// Thick (`2.0`) border side.
  static BorderSide thick(Color color) => BorderSide(
        color: color,
        width: AppSize.borderThick,
      );

  /// Heavy (`3.0`) border side.
  static BorderSide heavy(Color color) => BorderSide(
        color: color,
        width: AppSize.borderHeavy,
      );

  /// Uniform all-side `BoxBorder` with configurable [width].
  static Border all(
    Color color, {
    double width = AppSize.borderThin,
  }) {
    return Border.all(color: color, width: width);
  }

  /// Rounded shape border with consistent radius and optional stroke.
  static RoundedRectangleBorder rounded({
    double radius = AppSize.radiusCard,
    Color? color,
    double width = AppSize.borderThin,
  }) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: color != null
          ? BorderSide(color: color, width: width)
          : BorderSide.none,
    );
  }

  /// Pill/stadium shape border with optional stroke.
  static StadiumBorder pill({
    Color? color,
    double width = AppSize.borderThin,
  }) {
    return StadiumBorder(
      side: color != null
          ? BorderSide(color: color, width: width)
          : BorderSide.none,
    );
  }
}
