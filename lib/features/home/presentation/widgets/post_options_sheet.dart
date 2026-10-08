import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';

/// Modal bottom sheet providing Facebook & Instagram style post options.
class PostOptionsSheet extends StatelessWidget {
  const PostOptionsSheet({
    required this.post,
    required this.isAuthor,
    super.key,
    this.onEdit,
    this.onDelete,
    this.onChangePrivacy,
  });

  final PostItem post;
  final bool isAuthor;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onChangePrivacy;

  static Future<void> show(
    BuildContext context, {
    required PostItem post,
    required bool isAuthor,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
    VoidCallback? onChangePrivacy,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PostOptionsSheet(
        post: post,
        isAuthor: isAuthor,
        onEdit: onEdit,
        onDelete: onDelete,
        onChangePrivacy: onChangePrivacy,
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete post?'),
        content: const Text(
          'Are you sure you want to delete this post? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      HapticFeedback.mediumImpact().ignore();
      onDelete?.call();
    }
  }

  void _copyLink(BuildContext context) {
    Navigator.of(context).pop();
    Clipboard.setData(
      ClipboardData(text: 'https://lotusconnect.app/posts/${post.id}'),
    );
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.link, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Link copied to clipboard'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white60 : Colors.black54;

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
          const SizedBox(height: 14),

          // Author / Post snippet header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Post Options',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        post.content.isNotEmpty
                            ? (post.content.length > 35
                                ? '${post.content.substring(0, 35)}...'
                                : post.content)
                            : '${post.mediaItems.length} photos / videos',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: subtextColor,
                        ),
                      ),
                    ],
                  ),
                ),
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
          const SizedBox(height: 6),

          // Action Items
          if (isAuthor) ...[
            // Edit Post
            _OptionTile(
              icon: Icons.edit_outlined,
              label: 'Edit post',
              color: primaryTextColor,
              onTap: () {
                Navigator.of(context).pop();
                onEdit?.call();
              },
            ),

            // Edit Audience
            _OptionTile(
              icon: CupertinoIcons.person_2,
              label: 'Edit audience (${post.visibility})',
              color: primaryTextColor,
              onTap: () {
                Navigator.of(context).pop();
                onChangePrivacy?.call();
              },
            ),

            // Delete Post (Destructive)
            _OptionTile(
              icon: Icons.delete_outline_rounded,
              label: 'Delete post',
              color: Colors.redAccent,
              onTap: () => _confirmDelete(context),
            ),
          ] else ...[
            // Save Post
            _OptionTile(
              icon: Icons.bookmark_border_rounded,
              label: 'Save post',
              color: primaryTextColor,
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Post saved to collection')),
                );
              },
            ),

            // Hide Post
            _OptionTile(
              icon: Icons.visibility_off_outlined,
              label: 'Hide post',
              color: primaryTextColor,
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Post hidden from feed')),
                );
              },
            ),

            // Report Post
            _OptionTile(
              icon: Icons.report_problem_outlined,
              label: 'Report post',
              color: Colors.redAccent,
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Thank you for reporting')),
                );
              },
            ),
          ],

          // Copy Link
          _OptionTile(
            icon: Icons.link_rounded,
            label: 'Copy link to post',
            color: primaryTextColor,
            onTap: () => _copyLink(context),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
