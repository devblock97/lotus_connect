import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
              const SizedBox(height: 32),
              Column(
                children: [
                  RippleAnimation(
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
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
                  const SizedBox(height: 32),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                padding: const EdgeInsets.only(bottom: 64),
                child: Column(
                  children: [
                    IconButton(
                      onPressed: widget.hangUp,
                      iconSize: 32,
                      padding: const EdgeInsets.all(18),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFD63A2F),
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(),
                        elevation: 4,
                      ),
                      icon: const Icon(Icons.call_end),
                    ),
                    const SizedBox(height: 12),
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
