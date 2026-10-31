import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lotus_connect/features/chat/domain/entities/media_entity.dart';
import 'package:lotus_connect/features/chat/presentation/widgets/full_screen_media_viewer.dart';
import 'package:lotus_connect/features/profile/domain/entities/profile_media_item.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

class ProfileMediaGrid extends StatelessWidget {
  const ProfileMediaGrid({
    required this.items,
    super.key,
    this.isLoading = false,
    this.emptyTitle,
    this.emptyIcon = Icons.photo_library_outlined,
    this.onItemTap,
  });

  final List<ProfileMediaItem> items;
  final bool isLoading;
  final String? emptyTitle;
  final IconData emptyIcon;
  final ValueChanged<ProfileMediaItem>? onItemTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);

    if (isLoading && items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 64),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                emptyIcon,
                size: 56,
                color: Colors.grey.withValues(alpha: 0.45),
              ),
              const SizedBox(height: 12),
              Text(
                emptyTitle ?? (loc?.noPostsYet ?? 'No media yet'),
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: theme.cardColor,
      padding: const EdgeInsets.all(2),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return _MediaGridTile(
            item: item,
            isDark: isDark,
            onTap: () {
              if (onItemTap != null) {
                onItemTap!(item);
              } else {
                final medias = items
                    .map(
                      (m) => MediaEntity(
                        url: m.url,
                        thumbnailUrl: m.thumbnailUrl,
                        fileName: m.fileName,
                        fileSize: m.fileSize,
                        mimeType: m.mimeType ??
                            (m.isVideo ? 'video/mp4' : 'image/jpeg'),
                      ),
                    )
                    .toList();
                FullScreenMediaViewer.show(
                  context,
                  medias: medias,
                  initialIndex: index,
                );
              }
            },
          );
        },
      ),
    );
  }
}

class _MediaGridTile extends StatelessWidget {
  const _MediaGridTile({
    required this.item,
    required this.isDark,
    required this.onTap,
  });

  final ProfileMediaItem item;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final previewUrl =
        (item.thumbnailUrl != null && item.thumbnailUrl!.isNotEmpty)
            ? item.thumbnailUrl!
            : item.url;
    final canRenderImage = !item.isVideo ||
        (item.thumbnailUrl != null && item.thumbnailUrl!.isNotEmpty);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (canRenderImage && previewUrl.isNotEmpty)
            CachedNetworkImage(
              imageUrl: previewUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => ColoredBox(
                color:
                    isDark ? const Color(0xFF26262B) : const Color(0xFFECEEF2),
              ),
              errorWidget: (_, __, dynamic ___) => _buildFallback(),
            )
          else
            _buildFallback(),

          // Video play badge + duration overlay
          if (item.isVideo) ...[
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.play_fill,
                  color: Colors.white,
                  size: 13,
                ),
              ),
            ),
            if (item.formattedDuration.isNotEmpty)
              Positioned(
                bottom: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.formattedDuration,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildFallback() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF2A2B36), Color(0xFF1A1B22)]
              : const [Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
        ),
      ),
      child: Center(
        child: Icon(
          item.isVideo ? CupertinoIcons.videocam_fill : Icons.image_outlined,
          color: isDark ? Colors.white54 : Colors.black45,
          size: 28,
        ),
      ),
    );
  }
}
