import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lotus_connect/core/theme/app_size.dart';
import 'package:lotus_connect/features/profile/domain/entities/user_profile.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

class ProfileIntroSection extends StatelessWidget {
  const ProfileIntroSection({
    required this.profile,
    super.key,
    this.onEditDetailsTap,
  });

  final UserProfile profile;
  final VoidCallback? onEditDetailsTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black87;
    final iconColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final loc = AppLocalizations.of(context);

    final hasLocation =
        profile.location != null && profile.location!.trim().isNotEmpty;
    final hasWebsite =
        profile.website != null && profile.website!.trim().isNotEmpty;
    final joinedStr = profile.createdAt != null
        ? DateFormat('MMMM yyyy').format(profile.createdAt!)
        : null;

    return Container(
      color: theme.cardColor,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSize.screenPadding,
        vertical: AppSize.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc?.detailsSectionTitle ?? 'Details',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: primaryColor,
            ),
          ),
          AppGap.vMd,

          // Location
          if (hasLocation)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSize.sm),
              child: Row(
                children: [
                  Icon(
                    Icons.home_rounded,
                    size: AppSize.iconSm,
                    color: iconColor,
                  ),
                  AppGap.hMd,
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 14.5, color: primaryColor),
                        children: [
                          TextSpan(text: loc?.livesInPrefix ?? 'Lives in '),
                          TextSpan(
                            text: profile.location!.trim(),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Website
          if (hasWebsite)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSize.sm),
              child: InkWell(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(text: profile.website!.trim()),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        loc?.linkCopiedToClipboard ??
                            'Link copied to clipboard',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                borderRadius: AppRadius.xs,
                child: Row(
                  children: [
                    Icon(
                      Icons.link_rounded,
                      size: AppSize.iconSm,
                      color: iconColor,
                    ),
                    AppGap.hMd,
                    Expanded(
                      child: Text(
                        profile.website!.trim(),
                        style: const TextStyle(
                          fontSize: 14.5,
                          color: Color(0xFF1877F2),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Joined Date
          if (joinedStr != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSize.sm),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_filled_rounded,
                    size: AppSize.iconSm,
                    color: iconColor,
                  ),
                  AppGap.hMd,
                  Text(
                    loc?.joinedDate(joinedStr) ?? 'Joined $joinedStr',
                    style: TextStyle(fontSize: 14.5, color: primaryColor),
                  ),
                ],
              ),
            ),

          // Username handle
          Row(
            children: [
              Icon(
                Icons.alternate_email_rounded,
                size: AppSize.iconSm,
                color: iconColor,
              ),
              AppGap.hMd,
              Text(
                profile.username,
                style: TextStyle(fontSize: 14.5, color: primaryColor),
              ),
            ],
          ),

          // Edit Public Details button for own profile
          if (profile.isSelf && onEditDetailsTap != null) ...[
            AppGap.vLg,
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onEditDetailsTap,
                style: FilledButton.styleFrom(
                  backgroundColor: isDark
                      ? const Color(0xFF1877F2).withValues(alpha: 0.18)
                      : const Color(0xFFE7F3FF),
                  foregroundColor: const Color(0xFF1877F2),
                  elevation: AppSize.elevationNone,
                  padding: AppPadding.vMd,
                  shape: AppBorder.rounded(radius: AppSize.radiusChip),
                ),
                child: Text(
                  loc?.editPublicDetails ?? 'Edit public details',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
