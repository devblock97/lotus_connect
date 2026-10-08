import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lotus_connect/features/home/presentation/view/create_post_screen.dart';
import 'package:lotus_connect/features/settings/application/settings_notifier.dart';

/// Facebook-style "What's on your mind?" feed bar with quick action buttons.
class CreatePostBar extends ConsumerWidget {
  const CreatePostBar({super.key});

  Future<void> _openCreatePost(
    BuildContext context, {
    List<String> initialMedia = const [],
  }) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CreatePostScreen(
          initialMediaPaths: initialMedia,
        ),
      ),
    );
  }

  Future<void> _pickGallery(BuildContext context) async {
    final picker = ImagePicker();
    try {
      final medias = await picker.pickMultipleMedia();
      if (medias.isNotEmpty && context.mounted) {
        await _openCreatePost(
          context,
          initialMedia: medias.map((m) => m.path).toList(),
        );
      }
    } on Object catch (_) {}
  }

  Future<void> _pickCamera(BuildContext context) async {
    final picker = ImagePicker();
    try {
      final photo = await picker.pickImage(source: ImageSource.camera);
      if (photo != null && context.mounted) {
        await _openCreatePost(
          context,
          initialMedia: [photo.path],
        );
      }
    } on Object catch (_) {}
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white60 : Colors.black54;

    final settings = ref.watch(settingsNotifierProvider).settings;
    final displayName = settings.fullName.isNotEmpty
        ? settings.fullName
        : (settings.username.isNotEmpty ? settings.username : 'friend');
    final firstName = displayName.split(' ').first;
    final avatarUrl = settings.avatarUrl;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Input Row (Avatar + Hint Container)
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: theme.colorScheme.primaryContainer,
                backgroundImage: avatarUrl.isNotEmpty
                    ? CachedNetworkImageProvider(avatarUrl)
                    : null,
                child: avatarUrl.isEmpty
                    ? Text(
                        firstName.isNotEmpty ? firstName[0].toUpperCase() : '?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => _openCreatePost(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Text(
                      "What's on your mind, $firstName?",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: subtextColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Divider(
            height: 1,
            thickness: 0.5,
            color: theme.dividerColor.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 6),

          // Bottom Quick Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Photo
              _QuickActionButton(
                icon: Icons.photo_library_rounded,
                iconColor: const Color(0xFF4CAF50),
                label: 'Photo',
                textColor: primaryTextColor,
                onTap: () => _pickGallery(context),
              ),

              // Camera
              _QuickActionButton(
                icon: Icons.camera_alt_rounded,
                iconColor: const Color(0xFF2196F3),
                label: 'Camera',
                textColor: primaryTextColor,
                onTap: () => _pickCamera(context),
              ),

              // Feeling
              _QuickActionButton(
                icon: Icons.emoji_emotions_rounded,
                iconColor: const Color(0xFFFFB300),
                label: 'Feeling',
                textColor: primaryTextColor,
                onTap: () => _openCreatePost(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.textColor,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
