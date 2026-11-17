import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lotus_connect/app/theme/app_size.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

const List<String> kPopularLocations = [
  'Da Nang, Vietnam',
  'Ho Chi Minh City, Vietnam',
  'Hanoi, Vietnam',
  'Tokyo, Japan',
  'Seoul, South Korea',
  'Singapore',
  'Bangkok, Thailand',
  'Paris, France',
  'New York, NY',
  'London, United Kingdom',
  'San Francisco, CA',
  'Sydney, Australia',
];

class PostLocationSheet extends StatefulWidget {
  const PostLocationSheet({
    required this.onSelect,
    super.key,
    this.currentLocation,
  });

  final String? currentLocation;
  final ValueChanged<String> onSelect;

  static Future<String?> show(BuildContext context, {String? current}) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PostLocationSheet(
        currentLocation: current,
        onSelect: (loc) => Navigator.of(context).pop(loc),
      ),
    );
  }

  @override
  State<PostLocationSheet> createState() => _PostLocationSheetState();
}

class _PostLocationSheetState extends State<PostLocationSheet> {
  final TextEditingController _controller = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white60 : Colors.black54;
    final loc = AppLocalizations.of(context);

    final filtered = kPopularLocations.where((location) {
      if (_searchQuery.isEmpty) return true;
      return location.toLowerCase().contains(_searchQuery.toLowerCase());
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
                    loc?.addLocation ?? 'Add Location',
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
                controller: _controller,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: loc?.whereAreYou ?? 'Where are you?',
                  hintStyle: TextStyle(color: subtextColor, fontSize: 14),
                  prefixIcon: const Icon(
                    CupertinoIcons.location_solid,
                    size: AppSize.iconSm,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: AppSize.iconSm),
                          onPressed: () {
                            _controller.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
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
            if (_searchQuery.isNotEmpty && !filtered.contains(_searchQuery))
              ListTile(
                leading: Container(
                  width: AppSize.buttonHeightSm,
                  height: AppSize.buttonHeightSm,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_location_alt_outlined,
                    color: theme.colorScheme.primary,
                    size: AppSize.iconSm,
                  ),
                ),
                title: Text(
                  loc?.useLocation(_searchQuery) ?? 'Use "$_searchQuery"',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                onTap: () => widget.onSelect(_searchQuery),
              ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSize.lg,
                  vertical: AppSize.xs,
                ),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => Divider(
                  height: AppSize.dividerThickness,
                  thickness: AppSize.borderHairline,
                  color: theme.dividerColor.withValues(alpha: 0.1),
                ),
                itemBuilder: (context, index) {
                  final loc = filtered[index];
                  final isSelected = loc == widget.currentLocation;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSize.sm,
                      vertical: AppSize.xxs,
                    ),
                    leading: Container(
                      width: AppSize.avatarMd,
                      height: AppSize.avatarMd,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE91E63).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.place,
                        color: Color(0xFFE91E63),
                        size: AppSize.iconSm,
                      ),
                    ),
                    title: Text(
                      loc,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: primaryTextColor,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                            size: AppSize.iconSm,
                          )
                        : null,
                    onTap: () => widget.onSelect(loc),
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
