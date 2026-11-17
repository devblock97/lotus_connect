import 'package:flutter/material.dart';
import 'package:lotus_connect/app/theme/app_size.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

class StoryAudienceSheet extends StatelessWidget {
  const StoryAudienceSheet({
    required this.currentVisibility,
    super.key,
  });

  final String currentVisibility;

  static Future<String?> show(BuildContext context, String currentVisibility) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StoryAudienceSheet(currentVisibility: currentVisibility),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);

    return Material(
      color: isDark ? const Color(0xFF1E1E24) : Colors.white,
      borderRadius: AppRadius.bottomSheetTop,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: AppPadding.vXl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: AppSize.sheetHandleWidth,
                  height: AppSize.sheetHandleHeight,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: AppRadius.full,
                  ),
                ),
              ),
              AppGap.vLg,
              Padding(
                padding: AppPadding.hXl,
                child: Text(
                  loc?.storyAudience ?? 'Story Audience',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              AppGap.vMd,
              _buildOption(
                context: context,
                value: 'public',
                title: loc?.yourStory ?? 'Your Story',
                subtitle: loc?.storyAudiencePublicSubtitle ??
                    'Anyone on Lotus Connect can view',
                icon: Icons.public,
                iconColor: const Color(0xFF0095F6),
              ),
              _buildOption(
                context: context,
                value: 'close_friends',
                title: loc?.closeFriends ?? 'Close Friends',
                subtitle: loc?.storyAudienceCloseFriendsSubtitle ??
                    'Only people in your Close Friends list',
                icon: Icons.star,
                iconColor: const Color(0xFF10B981),
              ),
              _buildOption(
                context: context,
                value: 'friends',
                title: loc?.visibilityFriends ?? 'Friends',
                subtitle: loc?.storyAudienceFriendsSubtitle ??
                    'Visible only to accepted friends',
                icon: Icons.group,
                iconColor: const Color(0xFFA855F7),
              ),
              AppGap.vMd,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    final isSelected = currentVisibility == value;
    return ListTile(
      leading: Container(
        padding: AppPadding.sm,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: AppSize.iconMd),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12.5, color: Colors.grey),
      ),
      trailing: isSelected
          ? const Icon(
              Icons.check_circle,
              color: Color(0xFF0095F6),
              size: AppSize.iconMd,
            )
          : const Icon(
              Icons.circle_outlined,
              color: Colors.grey,
              size: AppSize.iconMd,
            ),
      onTap: () => Navigator.of(context).pop(value),
    );
  }
}
