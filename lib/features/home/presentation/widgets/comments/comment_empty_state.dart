import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    final isDark = theme.brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white54 : Colors.black45;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Elegant badge / icon with subtle glow
            Container(
              width: 76,
              height: 76,
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
                border: Border.all(
                  color: theme.primaryColor.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: Icon(
                CupertinoIcons.chat_bubble_2,
                size: 34,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 18),

            Text(
              'No comments yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: primaryTextColor,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),

            Text(
              'Start the conversation and share what you think!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: subtextColor,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),

            if (onStartCommentTap != null)
              OutlinedButton.icon(
                onPressed: onStartCommentTap,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: theme.primaryColor.withValues(alpha: 0.4),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                ),
                icon: Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: theme.primaryColor,
                ),
                label: Text(
                  'Say something nice',
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
