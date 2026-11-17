import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:lotus_connect/app/theme/app_size.dart';
import 'package:lotus_connect/features/livestream/application/go_live_notifier.dart';
import 'package:lotus_connect/features/livestream/application/livestream_feed_notifier.dart';
import 'package:lotus_connect/features/livestream/presentation/views/livestream_player_screen.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

/// Screen allowing users to setup and start broadcasting their live stream.
class GoLiveScreen extends ConsumerStatefulWidget {
  const GoLiveScreen({super.key});

  @override
  ConsumerState<GoLiveScreen> createState() => _GoLiveScreenState();
}

class _GoLiveScreenState extends ConsumerState<GoLiveScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _privacy = 'public';
  bool _isCreating = false;
  bool _isCameraFront = true;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  MediaStream? _localStream;
  bool _isCameraReady = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      await _localRenderer.initialize();
      final stream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {
          'facingMode': _isCameraFront ? 'user' : 'environment',
          'width': {'ideal': 1280},
          'height': {'ideal': 720},
        },
      });
      _localStream = stream;
      _localRenderer.srcObject = stream;
      if (mounted) {
        setState(() => _isCameraReady = true);
      }
    } on Object catch (_) {
      if (mounted) {
        setState(() => _isCameraReady = false);
      }
    }
  }

  Future<void> _flipCamera() async {
    if (_localStream != null) {
      final videoTrack = _localStream!.getVideoTracks().firstOrNull;
      if (videoTrack != null) {
        try {
          await Helper.switchCamera(videoTrack);
          if (mounted) {
            setState(() => _isCameraFront = !_isCameraFront);
          }
          return;
        } on Object catch (_) {}
      }
    }

    // Fallback: re-acquire media stream
    _isCameraFront = !_isCameraFront;
    _localStream?.getTracks().forEach((track) => track.stop());
    await _localStream?.dispose();
    await _initCamera();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _localStream?.getTracks().forEach((track) => track.stop());
    _localStream?.dispose();
    _localRenderer.dispose();
    super.dispose();
  }

  Future<void> _startLiveStream() async {
    final loc = AppLocalizations.of(context);
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc?.pleaseEnterStreamTitle ??
                'Please enter a title for your live stream',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final notifier = ref.read(goLiveNotifierProvider.notifier);
      final liveStream = await notifier.goLive(
        title: title,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        privacy: _privacy,
      );

      if (!mounted) return;

      if (liveStream == null) {
        setState(() => _isCreating = false);
        final error = ref.read(goLiveNotifierProvider).error ??
            (loc?.failedToStartLiveStream ?? 'Failed to start live stream');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Refresh explore feed in background
      unawaited(ref.read(liveStreamFeedProvider.notifier).refresh());

      setState(() => _isCreating = false);
      // Navigate to live room as host
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => LiveStreamPlayerScreen(
            initialStream: liveStream.copyWith(isHost: true),
          ),
        ),
      );
    } on Object catch (e) {
      if (mounted) {
        setState(() => _isCreating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              loc?.failedToGoLive(e.toString()) ?? 'Failed to go live: $e',
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final goLiveState = ref.watch(goLiveNotifierProvider);
    final isCreating = _isCreating || goLiveState.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF10121D),
      body: Stack(
        children: [
          // Real camera viewfinder background with fallback
          Positioned.fill(
            child: _isCameraReady && _localRenderer.srcObject != null
                ? RTCVideoView(
                    _localRenderer,
                    mirror: _isCameraFront,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  )
                : Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF1E2238),
                          Color(0xFF141624),
                          Color(0xFF0B0D17),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isCameraFront
                                ? Icons.camera_front
                                : Icons.camera_rear,
                            size: AppSize.iconHero,
                            color: Colors.white24,
                          ),
                          AppGap.vMd,
                          Text(
                            loc?.cameraInitializing ?? 'Camera initializing...',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top header bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSize.lg,
                    vertical: AppSize.sm,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.flip_camera_ios,
                          color: Colors.white,
                        ),
                        tooltip: loc?.flipCamera ?? 'Flip Camera',
                        onPressed: _flipCamera,
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Setup Card at Bottom
                Container(
                  margin: AppPadding.hLg,
                  padding: AppPadding.xl,
                  decoration: BoxDecoration(
                    color: const Color(0xFF161823).withValues(alpha: 0.95),
                    borderRadius: AppRadius.xxl,
                    border: AppBorder.all(Colors.white12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: AppSize.xl,
                        offset: const Offset(0, AppSize.sm),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _titleController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: loc?.streamTitleHint ??
                              'Add a title to attract viewers...',
                          hintStyle: const TextStyle(
                            color: Colors.white54,
                            fontSize: 15,
                          ),
                          prefixIcon: const Icon(
                            CupertinoIcons.pencil,
                            color: Color(0xFFFF0844),
                            size: AppSize.iconSm,
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          border: const OutlineInputBorder(
                            borderRadius: AppRadius.lg,
                            borderSide: AppBorder.none,
                          ),
                        ),
                      ),
                      AppGap.vMd,

                      Row(
                        children: [
                          Text(
                            loc?.privacyLabel ?? 'Privacy:',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AppGap.hSm,
                          _buildPrivacyChip(
                            'public',
                            '🌍 ${loc?.visibilityPublic ?? 'Public'}',
                          ),
                          AppGap.hXs,
                          _buildPrivacyChip(
                            'friends',
                            '👥 ${loc?.visibilityFriends ?? 'Friends'}',
                          ),
                          AppGap.hXs,
                          _buildPrivacyChip(
                            'private',
                            '🔒 ${loc?.privacyPrivate ?? 'Private'}',
                          ),
                        ],
                      ),
                      AppGap.vLg,

                      // Ingest RTMP tip for OBS creators
                      Container(
                        padding: AppPadding.md,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: AppRadius.md,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.cast_connected,
                              color: Color(0xFF64D2FF),
                              size: AppSize.iconSm,
                            ),
                            AppGap.hSm,
                            Expanded(
                              child: Text(
                                loc?.rtmpIngestTip ??
                                    'Supports mobile camera & desktop OBS/Streamlabs RTMP ingest',
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppGap.vXl,

                      // GO LIVE vibrant button
                      SizedBox(
                        height: AppSize.buttonHeightLg,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: AppBorder.rounded(
                              radius: AppSize.radiusXxxl,
                            ),
                            padding: AppPadding.zero,
                          ),
                          onPressed: isCreating ? null : _startLiveStream,
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF0844), Color(0xFFFF4E50)],
                              ),
                              borderRadius: AppRadius.xxxl,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF0844)
                                      .withValues(alpha: 0.4),
                                  blurRadius: AppSize.lg,
                                  offset: const Offset(0, AppSize.xs),
                                ),
                              ],
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: isCreating
                                  ? const SizedBox(
                                      width: AppSize.loaderSizeMd,
                                      height: AppSize.loaderSizeMd,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: AppSize.loaderStrokeWidth,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.sensors,
                                          color: Colors.white,
                                        ),
                                        AppGap.hSm,
                                        Text(
                                          loc?.goLiveNow ?? 'GO LIVE NOW',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AppGap.vXl,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyChip(String key, String label) {
    final isSelected = _privacy == key;
    return GestureDetector(
      onTap: () => setState(() => _privacy = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: AppPadding.chip,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFF0844).withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: AppRadius.lg,
          border: AppBorder.all(
            isSelected ? const Color(0xFFFF0844) : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFFFF0844) : Colors.white60,
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
