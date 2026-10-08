import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

    final filtered = kPopularLocations.where((loc) {
      if (_searchQuery.isEmpty) return true;
      return loc.toLowerCase().contains(_searchQuery.toLowerCase());
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
                  'Add Location',
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
              controller: _controller,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Where are you?',
                hintStyle: TextStyle(color: subtextColor, fontSize: 14),
                prefixIcon: const Icon(CupertinoIcons.location_solid, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _controller.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
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
          if (_searchQuery.isNotEmpty && !filtered.contains(_searchQuery))
            ListTile(
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_location_alt_outlined,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              title: Text(
                'Use "$_searchQuery"',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
              onTap: () => widget.onSelect(_searchQuery),
            ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                thickness: 0.5,
                color: theme.dividerColor.withValues(alpha: 0.1),
              ),
              itemBuilder: (context, index) {
                final loc = filtered[index];
                final isSelected = loc == widget.currentLocation;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE91E63).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.place,
                      color: Color(0xFFE91E63),
                      size: 20,
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
                          size: 20,
                        )
                      : null,
                  onTap: () => widget.onSelect(loc),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
