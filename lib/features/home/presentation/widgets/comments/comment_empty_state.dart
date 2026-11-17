import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lotus_connect/app/theme/app_size.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

/// Clean, beautiful empty state displayed when there are no comments yet.
class CommentEmptyState extends StatelessWidget {
  const CommentEmptyState({
    super.key,
    this.onStartCommentTap,
  });

  final VoidCallback? onStartCommentTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white54 : Colors.black45;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSize.xxxl,
          vertical: AppSize.huge,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Elegant badge / icon with subtle glow
            Container(
              width: AppSize.avatarXxl,
              height: AppSize.avatarXxl,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.primaryColor.withValues(alpha: 0.18),
                    theme.colorScheme.secondary.withValues(alpha: 0.08),
                  ],
                ),
                border: AppBorder.all(
                  theme.primaryColor.withValues(alpha: 0.25),
                  width: AppSize.borderMedium,
                ),
              ),
              child: Icon(
                CupertinoIcons.chat_bubble_2,
                size: AppSize.iconXl,
                color: theme.primaryColor,
              ),
            ),
            AppGap.vLg,

            Text(
              loc?.noCommentsYet ?? 'No comments yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: primaryTextColor,
                letterSpacing: -0.3,
              ),
            ),
            AppGap.vXs,

            Text(
              loc?.startConversationPrompt ??
                  'Start the conversation and share what you think!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: subtextColor,
                height: 1.35,
              ),
            ),
            AppGap.vLg,

            if (onStartCommentTap != null)
              OutlinedButton.icon(
                onPressed: onStartCommentTap,
                style: OutlinedButton.styleFrom(
                  side: AppBorder.thin(
                    theme.primaryColor.withValues(alpha: 0.4),
                  ),
                  shape: AppBorder.rounded(radius: AppSize.radiusXl),
                  padding: AppPadding.buttonCompact,
                ),
                icon: Icon(
                  Icons.edit_outlined,
                  size: AppSize.iconXs,
                  color: theme.primaryColor,
                ),
                label: Text(
                  loc?.saySomethingNice ?? 'Say something nice',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
