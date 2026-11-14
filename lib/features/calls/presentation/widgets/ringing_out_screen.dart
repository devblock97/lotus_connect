import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/theme/app_size.dart';
import 'package:lotus_connect/features/calls/presentation/widgets/ripple_animation.dart';
import 'package:lotus_connect/features/contacts/application/contacts_notifier.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

class RingingOutScreen extends ConsumerStatefulWidget {
  const RingingOutScreen({
    required this.activePeerId,
    required this.isVideo,
    this.hangUp,
    super.key,
  });

  final String activePeerId;
  final bool isVideo;
  final VoidCallback? hangUp;

  @override
  ConsumerState<RingingOutScreen> createState() => _RingingOutScreenState();
}

class _RingingOutScreenState extends ConsumerState<RingingOutScreen> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final friend = ref
        .read(contactsProvider)
        .friends
        .where((f) => f.id == widget.activePeerId)
        .firstOrNull;
    final displayName = friend != null
        ? (friend.fullName ?? friend.username)
        : (widget.activePeerId.substring(0, 8));
    final initialName = displayName.substring(0, 1);

    return Scaffold(
      body: Container(
        width: double.maxFinite,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8E5E0),
              Color(0xFFF7F5F2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppGap.vXxxl,
              Column(
                children: [
                  RippleAnimation(
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: AppBorder.all(
                          Colors.white,
                          width: AppSize.xs,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: AppSize.xl,
                            offset: const Offset(0, AppSize.sm),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        backgroundColor: Colors.grey.withValues(alpha: 0.1),
                        child: Text(
                          initialName,
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge!
                              .copyWith(
                                fontSize: 45,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
                  ),
                  AppGap.vXxxl,
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                  AppGap.vSm,
                  Text(
                    widget.isVideo
                        ? '${loc.calling.toUpperCase()} (${loc.video.toUpperCase()})'
                        : '${loc.calling.toUpperCase()} (${loc.voice.toUpperCase()})',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black54,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: AppSize.giant),
                child: Column(
                  children: [
                    IconButton(
                      onPressed: widget.hangUp,
                      iconSize: AppSize.iconXl,
                      padding: AppPadding.xl,
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFD63A2F),
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(),
                        elevation: AppSize.elevationMd,
                      ),
                      icon: const Icon(Icons.call_end),
                    ),
                    AppGap.vMd,
                    Text(
                      loc.cancel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
