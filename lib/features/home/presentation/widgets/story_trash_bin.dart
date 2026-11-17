import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lotus_connect/app/theme/app_size.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

class StoryTrashBin extends StatelessWidget {
  const StoryTrashBin({
    required this.isVisible,
    required this.isOverTrash,
    super.key,
  });

  final bool isVisible;
  final bool isOverTrash;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      bottom: isVisible ? AppSize.xxxl : -90.0,
      left: AppSize.none,
      right: AppSize.none,
      child: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: isVisible ? 1.0 : 0.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                width: isOverTrash ? AppSize.giant : AppSize.buttonHeightLg,
                height: isOverTrash ? AppSize.giant : AppSize.buttonHeightLg,
                decoration: BoxDecoration(
                  color: isOverTrash
                      ? const Color(0xFFFF2D55)
                      : Colors.black.withValues(alpha: 0.65),
                  shape: BoxShape.circle,
                  border: AppBorder.all(
                    isOverTrash ? Colors.white : Colors.white30,
                    width: isOverTrash
                        ? AppSize.borderThick
                        : AppSize.borderMedium,
                  ),
                  boxShadow: isOverTrash
                      ? [
                          BoxShadow(
                            color:
                                const Color(0xFFFF2D55).withValues(alpha: 0.6),
                            blurRadius: AppSize.xl,
                            spreadRadius: AppSize.xs,
                          ),
                        ]
                      : const [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: AppSize.sm,
                            offset: Offset(AppSize.none, AppSize.xs),
                          ),
                        ],
                ),
                child: Icon(
                  isOverTrash
                      ? CupertinoIcons.trash_fill
                      : CupertinoIcons.trash,
                  color: Colors.white,
                  size: isOverTrash ? AppSize.iconXl : AppSize.iconMd,
                ),
              ),
              AppGap.vXs,
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 150),
                style: TextStyle(
                  color: isOverTrash
                      ? const Color(0xFFFF2D55)
                      : Colors.white.withValues(alpha: 0.8),
                  fontSize: 11.5,
                  fontWeight: isOverTrash ? FontWeight.w800 : FontWeight.w500,
                  shadows: const [
                    Shadow(
                      color: Colors.black87,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  isOverTrash
                      ? (loc?.releaseToRemove ?? 'Release to remove')
                      : (loc?.dragHereToDelete ?? 'Drag here to delete'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
