import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

    const options = [
      _PrivacyOption(
        value: 'public',
        title: 'Public',
        subtitle: 'Anyone on or off Lotus Connect can see this post',
        icon: CupertinoIcons.globe,
        color: Color(0xFF2196F3),
      ),
      _PrivacyOption(
        value: 'friends',
        title: 'Friends',
        subtitle: 'Only people in your accepted friends list',
        icon: CupertinoIcons.person_2_fill,
        color: Color(0xFF4CAF50),
      ),
      _PrivacyOption(
        value: 'private',
        title: 'Only me',
        subtitle: 'Only you can see this post in your timeline',
        icon: CupertinoIcons.lock_fill,
        color: Color(0xFFFF9800),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.dividerColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Post Audience',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: primaryTextColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  splashRadius: 18,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Divider(
            height: 1,
            thickness: 0.5,
            color: theme.dividerColor.withValues(alpha: 0.15),
          ),
          const SizedBox(height: 8),
          ...options.map((opt) {
            final isSelected = opt.value == currentVisibility;
            return InkWell(
              onTap: () => onSelect(opt.value),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: opt.color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(opt.icon, color: opt.color, size: 22),
                    ),
                    const SizedBox(width: 14),
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
                          const SizedBox(height: 2),
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
                    const SizedBox(width: 12),
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : subtextColor.withValues(alpha: 0.5),
                          width: isSelected ? 6 : 1.5,
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
