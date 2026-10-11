import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/home/presentation/models/comment_ui_model.dart';

/// Modal bottom sheet listing users who reacted to a comment.
class CommentReactionsSheet extends StatefulWidget {
  const CommentReactionsSheet({
    required this.comment,
    required this.reactions,
    super.key,
  });

  final CommentUiModel comment;
  final List<CommentReactionUiModel> reactions;

  static Future<void> show(
    BuildContext context, {
    required CommentUiModel comment,
    List<CommentReactionUiModel>? reactions,
  }) {
    // Generate fallback sample reactions if empty for rich preview
    final resolvedReactions = (reactions != null && reactions.isNotEmpty)
        ? reactions
        : (comment.userHasLiked
            ? [
                CommentReactionUiModel(
                  id: 'rx_current',
                  commentId: comment.id,
                  user: const PostAuthor(
                    id: 'current_user',
                    username: 'you',
                    fullName: 'You',
                  ),
                  reaction: comment.userReaction ?? '❤️',
                  createdAt: DateTime.now(),
                ),
              ]
            : <CommentReactionUiModel>[]);

    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => CommentReactionsSheet(
        comment: comment,
        reactions: resolvedReactions,
      ),
    );
  }

  @override
  State<CommentReactionsSheet> createState() => _CommentReactionsSheetState();
}

class _CommentReactionsSheetState extends State<CommentReactionsSheet> {
  String _selectedTab = 'all';

  Map<String, int> get _reactionCounts {
    final counts = <String, int>{'all': widget.reactions.length};
    for (final rx in widget.reactions) {
      counts[rx.reaction] = (counts[rx.reaction] ?? 0) + 1;
    }
    return counts;
  }

  List<CommentReactionUiModel> get _filteredReactions {
    if (_selectedTab == 'all') return widget.reactions;
    return widget.reactions.where((rx) => rx.reaction == _selectedTab).toList();
  }

  Widget _buildAvatar(PostAuthor user) {
    if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: user.avatarUrl!,
        fit: BoxFit.cover,
        placeholder: (_, __) => _buildInitials(user),
        errorWidget: (_, __, dynamic ___) => _buildInitials(user),
      );
    }
    return _buildInitials(user);
  }

  Widget _buildInitials(PostAuthor user) {
    return Container(
      color: Colors.blueGrey,
      alignment: Alignment.center,
      child: Text(
        user.initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
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

    final counts = _reactionCounts;
    final tabs = counts.keys.toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: theme.dividerColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reactions (${widget.reactions.length})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: primaryTextColor,
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

          // Tabs row if multiple reactions
          if (tabs.length > 2) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: tabs.map((tab) {
                  final isSelected = _selectedTab == tab;
                  final count = counts[tab] ?? 0;
                  final label = tab == 'all' ? 'All ($count)' : '$tab $count';
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedTab = tab),
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                      selectedColor: theme.primaryColor,
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Divider(
              height: 1,
              thickness: 0.5,
              color: theme.dividerColor.withValues(alpha: 0.15),
            ),
          ],

          // Users list
          Flexible(
            child: _filteredReactions.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'No reactions in this category',
                      style: TextStyle(color: subtextColor),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredReactions.length,
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemBuilder: (context, index) {
                      final item = _filteredReactions[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            // Avatar with reaction badge
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                SizedBox(
                                  width: 42,
                                  height: 42,
                                  child: ClipOval(
                                    child: _buildAvatar(item.user),
                                  ),
                                ),
                                Positioned(
                                  right: -2,
                                  bottom: -2,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: theme.scaffoldBackgroundColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      item.reaction,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 14),

                            // Name & Username
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.user.fullName ?? item.user.username,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: primaryTextColor,
                                    ),
                                  ),
                                  Text(
                                    '@${item.user.username}',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: subtextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Action button
                            OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                side: BorderSide(
                                  color:
                                      theme.dividerColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: const Text(
                                'View',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
