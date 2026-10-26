import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
      bottom: isVisible ? 36.0 : -90.0,
      left: 0,
      right: 0,
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
                width: isOverTrash ? 64 : 52,
                height: isOverTrash ? 64 : 52,
                decoration: BoxDecoration(
                  color: isOverTrash
                      ? const Color(0xFFFF2D55)
                      : Colors.black.withValues(alpha: 0.65),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isOverTrash ? Colors.white : Colors.white30,
                    width: isOverTrash ? 2.5 : 1.5,
                  ),
                  boxShadow: isOverTrash
                      ? [
                          BoxShadow(
                            color:
                                const Color(0xFFFF2D55).withValues(alpha: 0.6),
                            blurRadius: 18,
                            spreadRadius: 4,
                          ),
                        ]
                      : const [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                ),
                child: Icon(
                  isOverTrash
                      ? CupertinoIcons.trash_fill
                      : CupertinoIcons.trash,
                  color: Colors.white,
                  size: isOverTrash ? 30 : 24,
                ),
              ),
              const SizedBox(height: 6),
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
