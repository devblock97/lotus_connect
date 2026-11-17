import 'package:flutter/material.dart';
import 'package:lotus_connect/app/theme/app_size.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_gift.dart';

/// Modal bottom sheet allowing viewers to pick and send virtual gifts
/// (TikTok Gifts / Facebook Stars style).
class GiftSheet extends StatefulWidget {
  const GiftSheet({
    required this.onSendGift,
    super.key,
  });

  final void Function(LiveGiftType gift, int count) onSendGift;

  static Future<void> show(
    BuildContext context, {
    required void Function(LiveGiftType gift, int count) onSendGift,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => GiftSheet(onSendGift: onSendGift),
    );
  }

  @override
  State<GiftSheet> createState() => _GiftSheetState();
}

class _GiftSheetState extends State<GiftSheet> {
  LiveGiftType _selectedGift = LiveGiftType.all.first;
  int _selectedCount = 1;
  final int _userCoins = 2450; // Mock current balance

  final List<int> _countOptions = [1, 5, 10, 50];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF161823),
        borderRadius: AppRadius.bottomSheetTop,
      ),
      padding: EdgeInsets.only(
        top: AppSize.md,
        left: AppSize.lg,
        right: AppSize.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSize.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: AppSize.sheetHandleWidth,
              height: AppSize.sheetHandleHeight,
              decoration: const BoxDecoration(
                color: Colors.white24,
                borderRadius: AppRadius.full,
              ),
            ),
          ),
          AppGap.vMd,

          // Header with Balance & Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Send Gift',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSize.md,
                  vertical: AppSize.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: AppRadius.lg,
                  border: AppBorder.all(Colors.white12),
                ),
                child: Row(
                  children: [
                    const Text('🪙 ', style: TextStyle(fontSize: 14)),
                    Text(
                      '$_userCoins',
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    AppGap.hXs,
                    const Text(
                      'Recharge',
                      style: TextStyle(
                        color: Color(0xFF00C7BE),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppGap.vLg,

          // Gift Items Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: LiveGiftType.all.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: AppSize.md,
              crossAxisSpacing: AppSize.md,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (context, index) {
              final gift = LiveGiftType.all[index];
              final isSelected = gift.id == _selectedGift.id;

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedGift = gift);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2E3244)
                        : Colors.white.withValues(alpha: 0.04),
                    borderRadius: AppRadius.md,
                    border: AppBorder.all(
                      isSelected
                          ? gift.gradientColors.first
                          : Colors.transparent,
                      width: AppSize.borderMedium,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: gift.gradientColors.first
                                  .withValues(alpha: 0.3),
                              blurRadius: AppSize.md,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        gift.icon,
                        style: const TextStyle(fontSize: 32),
                      ),
                      AppGap.vXs,
                      Text(
                        gift.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AppGap.vXxs,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🪙 ', style: TextStyle(fontSize: 10)),
                          Text(
                            '${gift.coins}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          AppGap.vLg,

          // Bottom Bar: Count selector + Send Button
          Row(
            children: [
              // Count combo buttons
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: AppRadius.xl,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSize.xs,
                  vertical: AppSize.xxs,
                ),
                child: Row(
                  children: _countOptions.map((count) {
                    final isChosen = count == _selectedCount;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCount = count),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSize.md,
                          vertical: AppSize.chipVertical,
                        ),
                        decoration: BoxDecoration(
                          color: isChosen
                              ? const Color(0xFFFF2D55)
                              : Colors.transparent,
                          borderRadius: AppRadius.lg,
                        ),
                        child: Text(
                          'x$count',
                          style: TextStyle(
                            color: isChosen ? Colors.white : Colors.white60,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Spacer(),

              // Send button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF2D55),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSize.xxl,
                    vertical: AppSize.md,
                  ),
                  shape: AppBorder.rounded(radius: AppSize.radiusXxl),
                  elevation: AppSize.elevationLg,
                  shadowColor: const Color(0xFFFF2D55).withValues(alpha: 0.5),
                ),
                onPressed: () {
                  widget.onSendGift(_selectedGift, _selectedCount);
                  Navigator.of(context).pop();
                },
                child: Row(
                  children: [
                    const Icon(Icons.card_giftcard, size: AppSize.iconSm),
                    AppGap.hXs,
                    Text(
                      'Send (${_selectedGift.coins * _selectedCount})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
