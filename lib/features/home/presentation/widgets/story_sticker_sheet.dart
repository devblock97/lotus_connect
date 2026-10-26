import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lotus_connect/features/home/presentation/models/story_sticker_item.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

class StoryStickerSheet extends StatefulWidget {
  const StoryStickerSheet({super.key});

  static Future<StoryStickerItem?> show(BuildContext context) {
    return showModalBottomSheet<StoryStickerItem>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const StoryStickerSheet(),
    );
  }

  @override
  State<StoryStickerSheet> createState() => _StoryStickerSheetState();
}

class _StoryStickerSheetState extends State<StoryStickerSheet> {
  final TextEditingController _customController = TextEditingController();
  final _uuid = const Uuid();

  static const List<String> _kLocations = [
    'Saigon',
    'Hanoi',
    'Da Nang',
    'Tokyo',
    'Paris',
    'New York',
  ];

  static const List<String> _kEmojis = [
    '🔥',
    '❤️',
    '😍',
    '✨',
    '🎉',
    '💯',
    '👏',
    '🙌',
    '🚀',
    '🥹',
    '🤩',
    '🥳',
    '🥰',
    '🌸',
    '☕️',
    '🌟',
  ];

  static const List<String> _kMoodTags = [
    'Good Vibes ✨',
    'Weekend Mode 🌴',
    'Coffee Time ☕️',
    'Lotus Connect 🪷',
    'Night Owl 🦉',
    'Coding Life 💻',
  ];

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _selectSticker(StoryStickerType type, String text) {
    final item = StoryStickerItem(
      id: _uuid.v4(),
      type: type,
      text: text,
      offset: const Offset(0.5, 0.4),
    );
    Navigator.of(context).pop(item);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final now = DateTime.now();
    final currentTimeStr = DateFormat('hh:mm a').format(now);
    final loc = AppLocalizations.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E24) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 38,
              height: 4.5,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc?.stickers ?? 'Stickers',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                // Top Quick Interactive Badges (Location & Time & Mention)
                Row(
                  children: [
                    // Live Time Badge
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectSticker(
                          StoryStickerType.time,
                          currentTimeStr,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2A2A36)
                                : const Color(0xFFF1F3F5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white10
                                  : Colors.black.withValues(alpha: 0.05),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                CupertinoIcons.time,
                                color: Color(0xFF0095F6),
                                size: 26,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                currentTimeStr,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Mention Badge
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _promptCustomText(
                          title: loc?.mentionSomeone ?? 'Mention Someone',
                          hint: loc?.mentionHint ?? '@username',
                          type: StoryStickerType.mention,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2A2A36)
                                : const Color(0xFFF1F3F5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white10
                                  : Colors.black.withValues(alpha: 0.05),
                            ),
                          ),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.at,
                                color: Color(0xFFFF2D55),
                                size: 26,
                              ),
                              SizedBox(height: 6),
                              Text(
                                '@MENTION',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Location Chips
                Text(
                  loc?.locations ?? 'Locations',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._kLocations.map(
                      (locationName) => ActionChip(
                        avatar: const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Color(0xFFFF3B30),
                        ),
                        label: Text(locationName),
                        onPressed: () => _selectSticker(
                          StoryStickerType.location,
                          locationName,
                        ),
                      ),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 16),
                      label: Text(loc?.customLocation ?? 'Custom...'),
                      onPressed: () => _promptCustomText(
                        title: loc?.addLocation ?? 'Add Location',
                        hint: loc?.cityOrVenueHint ?? 'City or venue',
                        type: StoryStickerType.location,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Mood / Status Tags
                Text(
                  loc?.statusAndVibes ?? 'Status & Vibes',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _kMoodTags
                      .map(
                        (tag) => ActionChip(
                          label: Text(tag),
                          onPressed: () => _selectSticker(
                            StoryStickerType.tag,
                            tag,
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 20),

                // Popular Emojis
                Text(
                  loc?.emojis ?? 'Emojis',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _kEmojis.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    final emoji = _kEmojis[index];
                    return GestureDetector(
                      onTap: () => _selectSticker(
                        StoryStickerType.emoji,
                        emoji,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2A2A36)
                              : const Color(0xFFF1F3F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _promptCustomText({
    required String title,
    required String hint,
    required StoryStickerType type,
  }) {
    final loc = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: _customController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(loc?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final text = _customController.text.trim();
              Navigator.of(dialogCtx).pop();
              if (text.isNotEmpty) {
                _selectSticker(type, text);
              }
            },
            child: Text(loc?.add ?? 'Add'),
          ),
        ],
      ),
    );
  }
}
