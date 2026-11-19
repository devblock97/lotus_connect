import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/app/theme/app_color.dart';
import 'package:lotus_connect/app/theme/app_size.dart';
import 'package:lotus_connect/features/calls/presentation/utils/call_peer_display.dart';
import 'package:lotus_connect/features/calls/presentation/widgets/ripple_animation.dart';
import 'package:lotus_connect/features/contacts/application/contacts_notifier.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

class RingingInScreen extends ConsumerStatefulWidget {
  const RingingInScreen({
    required this.activePeerId,
    required this.isVideo,
    this.onAccept,
    this.onDecline,
    super.key,
  });

  final String activePeerId;
  final bool isVideo;
  final VoidCallback? onDecline;
  final VoidCallback? onAccept;

  @override
  ConsumerState<RingingInScreen> createState() => _RingingInScreenState();
}

class _RingingInScreenState extends ConsumerState<RingingInScreen> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final friends = ref.watch(contactsProvider).friends;
    final peer = resolveCallPeerDisplay(
      friends: friends,
      peerId: widget.activePeerId,
    );
    final displayName = peer.displayName;
    final initialName = peer.initial;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColor.callRingingBgStart.of(context),
              AppColor.callRingingBgEnd.of(context),
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
                          AppColor.onMedia.of(context),
                          width: AppSize.xs,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.black
                                .of(context)
                                .withValues(alpha: 0.15),
                            blurRadius: AppSize.xl,
                            offset: const Offset(0, AppSize.sm),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        backgroundColor: AppColor.inkMuted
                            .of(context)
                            .withValues(alpha: 0.1),
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
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColor.inkPrimary.of(context),
                      letterSpacing: 0.5,
                    ),
                  ),
                  AppGap.vSm,
                  Text(
                    widget.isVideo
                        ? '${loc.incomingCall.toUpperCase()} (${loc.video.toUpperCase()})'
                        : '${loc.incomingCall.toUpperCase()} (${loc.voice.toUpperCase()})',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColor.inkSecondary.of(context),
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),

              // Decline / Accept Buttons
              Padding(
                padding: const EdgeInsets.only(
                  bottom: AppSize.massive,
                  left: AppSize.huge,
                  right: AppSize.huge,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Decline
                    Column(
                      children: [
                        IconButton(
                          onPressed: widget.onDecline,
                          iconSize: AppSize.iconXl,
                          padding: AppPadding.xl,
                          style: IconButton.styleFrom(
                            backgroundColor: AppColor.callDeclineRed.of(
                              context,
                            ),
                            foregroundColor: AppColor.onMedia.of(context),
                            shape: const CircleBorder(),
                            elevation: AppSize.elevationMd,
                          ),
                          icon: const Icon(Icons.call_end),
                        ),
                        AppGap.vMd,
                        Text(
                          loc.decline,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColor.inkPrimary.of(context),
                          ),
                        ),
                      ],
                    ),
                    // Accept
                    Column(
                      children: [
                        IconButton(
                          onPressed: widget.onAccept,
                          iconSize: AppSize.iconXl,
                          padding: AppPadding.xl,
                          style: IconButton.styleFrom(
                            backgroundColor: AppColor.callAcceptGreen.of(
                              context,
                            ),
                            foregroundColor: AppColor.onMedia.of(context),
                            shape: const CircleBorder(),
                            elevation: AppSize.elevationMd,
                          ),
                          icon: Icon(
                            widget.isVideo ? Icons.videocam : Icons.call,
                          ),
                        ),
                        AppGap.vMd,
                        Text(
                          loc.accept,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColor.inkPrimary.of(context),
                          ),
                        ),
                      ],
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
