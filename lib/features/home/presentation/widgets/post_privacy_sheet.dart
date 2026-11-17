import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lotus_connect/app/theme/app_size.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

/// Modal bottom sheet allowing users to pick post visibility
/// (Public, Friends, Only Me).
class PostPrivacySheet extends StatelessWidget {
  const PostPrivacySheet({
    required this.currentVisibility,
    required this.onSelect,
    super.key,
  });

  final String currentVisibility;
  final ValueChanged<String> onSelect;

  static Future<String?> show(BuildContext context, String current) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PostPrivacySheet(
        currentVisibility: current,
        onSelect: (v) => Navigator.of(context).pop(v),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white60 : Colors.black54;
    final loc = AppLocalizations.of(context);

    final options = [
      _PrivacyOption(
        value: 'public',
        title: loc?.visibilityPublic ?? 'Public',
        subtitle: loc?.postAudiencePublicSubtitle ??
            'Anyone on or off Lotus Connect can see this post',
        icon: CupertinoIcons.globe,
        color: const Color(0xFF2196F3),
      ),
      _PrivacyOption(
        value: 'friends',
        title: loc?.visibilityFriends ?? 'Friends',
        subtitle: loc?.postAudienceFriendsSubtitle ??
            'Only people in your accepted friends list',
        icon: CupertinoIcons.person_2_fill,
        color: const Color(0xFF4CAF50),
      ),
      _PrivacyOption(
        value: 'private',
        title: loc?.visibilityPrivate ?? 'Only me',
        subtitle: loc?.postAudiencePrivateSubtitle ??
            'Only you can see this post in your timeline',
        icon: CupertinoIcons.lock_fill,
        color: const Color(0xFFFF9800),
      ),
    ];

    return Material(
      color: theme.scaffoldBackgroundColor,
      borderRadius: AppRadius.bottomSheetTop,
      child: Padding(
        padding: EdgeInsets.only(
          top: AppSize.md,
          bottom: MediaQuery.of(context).padding.bottom + AppSize.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: AppSize.sheetHandleWidth,
              height: AppSize.sheetHandleHeight,
              decoration: BoxDecoration(
                color: theme.dividerColor.withValues(alpha: 0.3),
                borderRadius: AppRadius.full,
              ),
            ),
            AppGap.vLg,
            Padding(
              padding: AppPadding.hXl,
              child: Row(
                children: [
                  Text(
                    loc?.postAudience ?? 'Post Audience',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: primaryTextColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: AppSize.iconSm),
                    splashRadius: AppSize.iconSm,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            AppGap.vSm,
            Divider(
              height: AppSize.dividerThickness,
              thickness: AppSize.borderHairline,
              color: theme.dividerColor.withValues(alpha: 0.15),
            ),
            AppGap.vSm,
            ...options.map((opt) {
              final isSelected = opt.value == currentVisibility;
              return InkWell(
                onTap: () => onSelect(opt.value),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSize.xl,
                    vertical: AppSize.md,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: AppSize.buttonHeightMd,
                        height: AppSize.buttonHeightMd,
                        decoration: BoxDecoration(
                          color: opt.color.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          opt.icon,
                          color: opt.color,
                          size: AppSize.iconMd,
                        ),
                      ),
                      AppGap.hMd,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              opt.title,
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w600,
                                color: primaryTextColor,
                              ),
                            ),
                            AppGap.vXxs,
                            Text(
                              opt.subtitle,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: subtextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppGap.hMd,
                      Container(
                        width: AppSize.iconMd,
                        height: AppSize.iconMd,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: AppBorder.all(
                            isSelected
                                ? theme.colorScheme.primary
                                : subtextColor.withValues(alpha: 0.5),
                            width: isSelected ? 6 : AppSize.borderMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _PrivacyOption {
  const _PrivacyOption({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String value;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}
