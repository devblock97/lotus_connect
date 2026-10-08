import 'package:flutter/material.dart';

class FeelingItem {
  const FeelingItem({required this.label, required this.emoji});
  final String label;
  final String emoji;
}

const List<FeelingItem> kFeelingsList = [
  FeelingItem(label: 'happy', emoji: '😊'),
  FeelingItem(label: 'blessed', emoji: '✨'),
  FeelingItem(label: 'excited', emoji: '🚀'),
  FeelingItem(label: 'loved', emoji: '❤️'),
  FeelingItem(label: 'traveling', emoji: '✈️'),
  FeelingItem(label: 'celebrating', emoji: '🎉'),
  FeelingItem(label: 'chilling', emoji: '☕'),
  FeelingItem(label: 'grateful', emoji: '🙏'),
  FeelingItem(label: 'creative', emoji: '🎨'),
  FeelingItem(label: 'motivated', emoji: '💪'),
  FeelingItem(label: 'cozy', emoji: '🛋️'),
  FeelingItem(label: 'curious', emoji: '🧐'),
  FeelingItem(label: 'peaceful', emoji: '🌸'),
  FeelingItem(label: 'cool', emoji: '😎'),
  FeelingItem(label: 'inspired', emoji: '💡'),
  FeelingItem(label: 'eating', emoji: '🍜'),
];

class PostFeelingSheet extends StatefulWidget {
  const PostFeelingSheet({
    required this.onSelect,
    super.key,
    this.currentFeeling,
  });

  final String? currentFeeling;
  final void Function(String feeling, String emoji) onSelect;

  static Future<FeelingItem?> show(BuildContext context, {String? current}) {
    return showModalBottomSheet<FeelingItem>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PostFeelingSheet(
        currentFeeling: current,
        onSelect: (f, e) => Navigator.of(context).pop(
          FeelingItem(label: f, emoji: e),
        ),
      ),
    );
  }

  @override
  State<PostFeelingSheet> createState() => _PostFeelingSheetState();
}

class _PostFeelingSheetState extends State<PostFeelingSheet> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white60 : Colors.black54;

    final filtered = kFeelingsList.where((item) {
      if (_searchQuery.isEmpty) return true;
      return item.label.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
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
                  'How are you feeling?',
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search feelings...',
                hintStyle: TextStyle(color: subtextColor, fontSize: 14),
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3.2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];
                final isSelected = item.label == widget.currentFeeling;

                return InkWell(
                  onTap: () => widget.onSelect(item.label, item.emoji),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primaryContainer
                          : theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.dividerColor.withValues(alpha: 0.1),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Text(
                          item.emoji,
                          style: const TextStyle(fontSize: 22),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: primaryTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
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
