import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:lotus_connect/features/livestream/application/go_live_notifier.dart';
import 'package:lotus_connect/features/livestream/application/livestream_feed_notifier.dart';
import 'package:lotus_connect/features/livestream/presentation/views/livestream_player_screen.dart';

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
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title for your live stream'),
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
            'Failed to start live stream';
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
            content: Text('Failed to go live: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                            size: 64,
                            color: Colors.white24,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Camera initializing...',
                            style:
                                TextStyle(color: Colors.white38, fontSize: 13),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        tooltip: 'Flip Camera',
                        onPressed: _flipCamera,
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Setup Card at Bottom
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161823).withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
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
                          hintText: 'Add a title to attract viewers...',
                          hintStyle: const TextStyle(
                            color: Colors.white54,
                            fontSize: 15,
                          ),
                          prefixIcon: const Icon(
                            CupertinoIcons.pencil,
                            color: Color(0xFFFF0844),
                            size: 20,
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          const Text(
                            'Privacy:',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildPrivacyChip('public', '🌍 Public'),
                          const SizedBox(width: 6),
                          _buildPrivacyChip('friends', '👥 Friends'),
                          const SizedBox(width: 6),
                          _buildPrivacyChip('private', '🔒 Private'),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Ingest RTMP tip for OBS creators
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.cast_connected,
                              color: Color(0xFF64D2FF),
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Supports mobile camera & desktop OBS/Streamlabs RTMP ingest',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // GO LIVE vibrant button
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: isCreating ? null : _startLiveStream,
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF0844), Color(0xFFFF4E50)],
                              ),
                              borderRadius: BorderRadius.circular(26),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF0844)
                                      .withValues(alpha: 0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: isCreating
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.sensors,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'GO LIVE NOW',
                                          style: TextStyle(
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
                const SizedBox(height: 20),
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFF0844).withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF0844) : Colors.transparent,
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
