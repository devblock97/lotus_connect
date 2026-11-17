import 'package:flutter/material.dart';
import 'package:lotus_connect/app/theme/app_size.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

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
    final loc = AppLocalizations.of(context);

    final filtered = kFeelingsList.where((item) {
      if (_searchQuery.isEmpty) return true;
      return item.label.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.65,
      child: Material(
        color: theme.scaffoldBackgroundColor,
        borderRadius: AppRadius.bottomSheetTop,
        child: Column(
          children: [
            AppGap.vMd,
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
                    loc?.howAreYouFeeling ?? 'How are you feeling?',
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
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSize.lg,
                AppSize.sm,
                AppSize.lg,
                AppSize.md,
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: loc?.searchFeelings ?? 'Search feelings...',
                  hintStyle: TextStyle(color: subtextColor, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, size: AppSize.iconSm),
                  contentPadding: AppPadding.input,
                  filled: true,
                  fillColor: theme.cardColor,
                  border: const OutlineInputBorder(
                    borderRadius: AppRadius.input,
                    borderSide: AppBorder.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSize.lg,
                  vertical: AppSize.sm,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3.2,
                  crossAxisSpacing: AppSize.sm,
                  mainAxisSpacing: AppSize.sm,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  final isSelected = item.label == widget.currentFeeling;

                  return InkWell(
                    onTap: () => widget.onSelect(item.label, item.emoji),
                    borderRadius: AppRadius.md,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primaryContainer
                            : theme.cardColor,
                        borderRadius: AppRadius.md,
                        border: AppBorder.all(
                          isSelected
                              ? theme.colorScheme.primary
                              : theme.dividerColor.withValues(alpha: 0.1),
                        ),
                      ),
                      padding: AppPadding.hMd,
                      child: Row(
                        children: [
                          Text(
                            item.emoji,
                            style: const TextStyle(fontSize: 22),
                          ),
                          AppGap.hSm,
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
      ),
    );
  }
}
