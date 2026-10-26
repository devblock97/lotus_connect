import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:lotus_connect/core/services/webrtc/signaling_service.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/livestream/application/livestream_feed_notifier.dart';
import 'package:lotus_connect/features/livestream/application/livestream_room_notifier.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_stream.dart';
import 'package:lotus_connect/features/livestream/presentation/views/livestream_ended_dialog.dart';
import 'package:lotus_connect/features/livestream/presentation/widgets/floating_hearts_overlay.dart';
import 'package:lotus_connect/features/livestream/presentation/widgets/gift_animation_overlay.dart';
import 'package:lotus_connect/features/livestream/presentation/widgets/gift_sheet.dart';
import 'package:lotus_connect/features/livestream/presentation/widgets/leaderboard_sheet.dart';
import 'package:lotus_connect/features/livestream/presentation/widgets/live_badge.dart';
import 'package:lotus_connect/features/livestream/presentation/widgets/live_chat_overlay.dart';
import 'package:lotus_connect/features/livestream/presentation/widgets/viewers_sheet.dart';
import 'package:lotus_connect/features/settings/application/settings_notifier.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

/// Full-screen TikTok / Facebook / YouTube style Live Stream Player.
class LiveStreamPlayerScreen extends ConsumerStatefulWidget {
  const LiveStreamPlayerScreen({
    required this.initialStream,
    super.key,
  });

  final LiveStream initialStream;

  @override
  ConsumerState<LiveStreamPlayerScreen> createState() =>
      _LiveStreamPlayerScreenState();
}

class _LiveStreamPlayerScreenState
    extends ConsumerState<LiveStreamPlayerScreen> {
  static const Map<String, dynamic> _rtcIceConfiguration = {
    'iceServers': [
      {
        'urls': 'stun:stun.relay.metered.ca:80',
      },
      {
        'urls': 'turn:global.relay.metered.ca:80',
        'username': 'acd85cccc8fcb9b021c2232c',
        'credential': '7UUjeLhQO9xU+HxT',
      },
      {
        'urls': 'turn:global.relay.metered.ca:80?transport=tcp',
        'username': 'acd85cccc8fcb9b021c2232c',
        'credential': '7UUjeLhQO9xU+HxT',
      },
      {
        'urls': 'turn:global.relay.metered.ca:443',
        'username': 'acd85cccc8fcb9b021c2232c',
        'credential': '7UUjeLhQO9xU+HxT',
      },
      {
        'urls': 'turns:global.relay.metered.ca:443?transport=tcp',
        'username': 'acd85cccc8fcb9b021c2232c',
        'credential': '7UUjeLhQO9xU+HxT',
      },
    ],
    'sdpSemantics': 'unified-plan',
  };

  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  bool _isCommentInputActive = false;
  VideoPlayerController? _videoController;
  Timer? _durationTimer;
  int _streamElapsedSeconds = 0;

  final RTCVideoRenderer _hostCameraRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteHostRenderer = RTCVideoRenderer();

  MediaStream? _hostCameraStream;
  MediaStream? _remoteStream;

  bool _isHostCameraReady = false;
  bool _hasRemoteHostVideo = false;
  bool _isCameraFront = true;
  bool _isMicMuted = false;
  bool _hasShownEndedDialog = false;
  bool _isExiting = false;

  // WebRTC Signaling & Connection State
  StreamSubscription<dynamic>? _sdpSub;
  StreamSubscription<dynamic>? _iceSub;

  // Viewer state
  String? _viewerSessionId;
  RTCPeerConnection? _viewerPeerConnection;
  final List<RTCIceCandidate> _viewerQueuedIceCandidates = [];

  // Host state
  final Map<String, RTCPeerConnection> _hostPeerConnections = {};
  final Map<String, List<RTCIceCandidate>> _hostQueuedIceCandidates = {};

  void _exitPlayerScreen() {
    if (_isExiting || !mounted) return;
    _isExiting = true;
    ref.read(liveStreamFeedProvider.notifier).refresh();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  bool get _isHost {
    final currentUserId = ref.read(settingsNotifierProvider).settings.userId;
    return widget.initialStream.isHost ||
        (widget.initialStream.host.id.isNotEmpty &&
            currentUserId.isNotEmpty &&
            widget.initialStream.host.id == currentUserId);
  }

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();
    _startDurationTimer();
    _initRenderers().then((_) {
      if (!mounted) return;
      _subscribeSignaling();
      if (_isHost) {
        _initHostCamera();
      } else {
        _initViewerWebRTC();
      }
    });
  }

  Future<void> _initRenderers() async {
    await _hostCameraRenderer.initialize();
    await _remoteHostRenderer.initialize();
  }

  void _subscribeSignaling() {
    final signaling = ref.read(webrtcSignalingServiceProvider);

    _sdpSub = signaling.sdpStream.listen((event) async {
      final type = event['type'] as String?;
      final senderId = event['senderId'] as String?;
      final sessionId = event['sessionId'] as String? ?? senderId;
      final sdp = (event['sdp'] as Map<String, dynamic>?)?['sdp'] as String?;

      if (sdp == null || senderId == null) return;

      if (_isHost && type == 'offer' && sessionId != null) {
        await _handleHostIncomingOffer(
          senderId: senderId,
          sessionId: sessionId,
          sdp: sdp,
        );
      } else if (!_isHost && type == 'answer') {
        final incomingSessionId = event['sessionId'] as String?;
        if (incomingSessionId == null ||
            incomingSessionId == _viewerSessionId) {
          if (_viewerPeerConnection != null) {
            await _viewerPeerConnection!.setRemoteDescription(
              RTCSessionDescription(sdp, 'answer'),
            );
            for (final cand in _viewerQueuedIceCandidates) {
              await _viewerPeerConnection!.addCandidate(cand);
            }
            _viewerQueuedIceCandidates.clear();
          }
        }
      }
    });

    _iceSub = signaling.iceStream.listen((payload) async {
      final candidateData = payload['candidate'] as Map<String, dynamic>?;
      if (candidateData == null) return;

      final cand = RTCIceCandidate(
        candidateData['candidate'] as String? ?? '',
        candidateData['sdpMid'] as String? ?? '0',
        candidateData['sdpMLineIndex'] as int? ?? 0,
      );
      final sessionId =
          payload['sessionId'] as String? ?? payload['senderId'] as String?;

      if (_isHost) {
        if (sessionId != null) {
          final pc = _hostPeerConnections[sessionId];
          if (pc != null && await pc.getRemoteDescription() != null) {
            await pc.addCandidate(cand);
          } else {
            _hostQueuedIceCandidates.putIfAbsent(sessionId, () => []).add(cand);
          }
        }
      } else {
        final pc = _viewerPeerConnection;
        if (pc != null && await pc.getRemoteDescription() != null) {
          await pc.addCandidate(cand);
        } else {
          _viewerQueuedIceCandidates.add(cand);
        }
      }
    });
  }

  Future<void> _initViewerWebRTC() async {
    _viewerSessionId = const Uuid().v4();
    final signaling = ref.read(webrtcSignalingServiceProvider);

    try {
      final pc = await createPeerConnection(_rtcIceConfiguration, {
        'mandatory': <dynamic, dynamic>{},
        'optional': [
          {'DtlsSrtpKeyAgreement': true},
        ],
      });
      _viewerPeerConnection = pc;

      // Viewer is audience only: receive audio and video from host only
      await pc.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
        init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly),
      );
      await pc.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
        init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly),
      );

      pc
        ..onTrack = (event) {
          if (event.streams.isNotEmpty && mounted) {
            setState(() {
              _remoteHostRenderer.srcObject = event.streams[0];
              _hasRemoteHostVideo = true;
            });
          } else if (event.track.kind == 'video' && mounted) {
            if (_remoteStream == null) {
              createLocalMediaStream('remote_host_stream').then((stream) {
                _remoteStream = stream;
                stream.addTrack(event.track);
                if (mounted) {
                  setState(() {
                    _remoteHostRenderer.srcObject = stream;
                    _hasRemoteHostVideo = true;
                  });
                }
              });
            } else {
              _remoteStream!.addTrack(event.track);
              if (mounted) {
                setState(() => _hasRemoteHostVideo = true);
              }
            }
          }
        }
        ..onConnectionState = (state) {
          debugPrint('Viewer WebRTC Connection State: $state');
        }
        ..onAddStream = (stream) {
          if (mounted) {
            setState(() {
              _remoteHostRenderer.srcObject = stream;
              _hasRemoteHostVideo = true;
            });
          }
        }
        ..onIceCandidate = (candidate) {
          if (candidate.candidate != null) {
            signaling.sendIceCandidate(
              recipientId: widget.initialStream.host.id,
              candidate: candidate.candidate!,
              sdpMid: candidate.sdpMid ?? '0',
              sdpMLineIndex: candidate.sdpMLineIndex ?? 0,
              sessionId: _viewerSessionId,
            );
          }
        };

      final offer = await pc.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': true,
      });
      await pc.setLocalDescription(offer);

      signaling.sendSdp(
        recipientId: widget.initialStream.host.id,
        sdpType: 'offer',
        sdpDescription: offer.sdp!,
        sessionId: _viewerSessionId,
      );
    } on Object catch (e) {
      debugPrint('Error initViewerWebRTC: $e');
    }
  }

  Future<void> _handleHostIncomingOffer({
    required String senderId,
    required String sessionId,
    required String sdp,
  }) async {
    final signaling = ref.read(webrtcSignalingServiceProvider);
    try {
      if (_hostCameraStream == null && !_isHostCameraReady) {
        await _initHostCamera();
      }

      var pc = _hostPeerConnections[sessionId];
      if (pc == null) {
        pc = await createPeerConnection(_rtcIceConfiguration, {
          'mandatory': <dynamic, dynamic>{},
          'optional': [
            {'DtlsSrtpKeyAgreement': true},
          ],
        });
        _hostPeerConnections[sessionId] = pc;

        pc.onIceCandidate = (candidate) {
          if (candidate.candidate != null) {
            signaling.sendIceCandidate(
              recipientId: senderId,
              candidate: candidate.candidate!,
              sdpMid: candidate.sdpMid ?? '0',
              sdpMLineIndex: candidate.sdpMLineIndex ?? 0,
              sessionId: sessionId,
            );
          }
        };

        if (_hostCameraStream != null) {
          for (final track in _hostCameraStream!.getTracks()) {
            await pc.addTrack(track, _hostCameraStream!);
          }
        }
      }

      await pc.setRemoteDescription(RTCSessionDescription(sdp, 'offer'));

      final queued = _hostQueuedIceCandidates.remove(sessionId);
      if (queued != null) {
        for (final cand in queued) {
          await pc.addCandidate(cand);
        }
      }

      final answer = await pc.createAnswer();
      await pc.setLocalDescription(answer);

      signaling.sendSdp(
        recipientId: senderId,
        sdpType: 'answer',
        sdpDescription: answer.sdp!,
        sessionId: sessionId,
      );
    } on Object catch (e) {
      debugPrint('Error handleHostIncomingOffer: $e');
    }
  }

  Future<void> _initHostCamera() async {
    try {
      final stream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {
          'facingMode': _isCameraFront ? 'user' : 'environment',
          'width': {'ideal': 1280},
          'height': {'ideal': 720},
        },
      });
      _hostCameraStream = stream;
      _hostCameraRenderer.srcObject = stream;
      if (mounted) {
        setState(() => _isHostCameraReady = true);
      }
      for (final pc in _hostPeerConnections.values) {
        for (final track in stream.getTracks()) {
          await pc.addTrack(track, stream);
        }
      }
    } on Object catch (_) {
      if (mounted) {
        setState(() => _isHostCameraReady = false);
      }
    }
  }

  Future<void> _flipHostCamera() async {
    if (_hostCameraStream != null) {
      final videoTrack = _hostCameraStream!.getVideoTracks().firstOrNull;
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

    _isCameraFront = !_isCameraFront;
    _hostCameraStream?.getTracks().forEach((track) => track.stop());
    await _hostCameraStream?.dispose();
    await _initHostCamera();
  }

  void _toggleMic() {
    setState(() {
      _isMicMuted = !_isMicMuted;
      final audioTracks = _hostCameraStream?.getAudioTracks();
      if (audioTracks != null) {
        for (final track in audioTracks) {
          track.enabled = !_isMicMuted;
        }
      }
    });
  }

  void _startDurationTimer() {
    _streamElapsedSeconds = widget.initialStream.durationSeconds;
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _streamElapsedSeconds++);
      }
    });
  }

  void _initVideoPlayer() {
    final playbackUrl = widget.initialStream.playbackUrl;
    if (playbackUrl != null && playbackUrl.isNotEmpty) {
      final uri = Uri.tryParse(playbackUrl);
      if (uri != null) {
        _videoController = VideoPlayerController.networkUrl(uri)
          ..initialize().then((_) {
            if (mounted) {
              _videoController?.play();
              _videoController?.setLooping(true);
              setState(() {});
            }
          }).catchError((dynamic err) {
            // Non-fatal if playback URL is offline;
            // video will fall back to backdrop
          });
      }
    }
  }

  void _cleanWebRTC() {
    _sdpSub?.cancel();
    _sdpSub = null;
    _iceSub?.cancel();
    _iceSub = null;

    _hostCameraStream?.getTracks().forEach((track) => track.stop());
    _hostCameraStream?.dispose();
    _hostCameraStream = null;

    _remoteStream?.getTracks().forEach((track) => track.stop());
    _remoteStream?.dispose();
    _remoteStream = null;

    _viewerPeerConnection?.close();
    _viewerPeerConnection?.dispose();
    _viewerPeerConnection = null;

    for (final pc in _hostPeerConnections.values) {
      pc
        ..close()
        ..dispose();
    }
    _hostPeerConnections.clear();
    _hostQueuedIceCandidates.clear();
    _viewerQueuedIceCandidates.clear();

    try {
      _hostCameraRenderer.srcObject = null;
      _remoteHostRenderer.srcObject = null;
    } on Object catch (_) {}
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _videoController?.dispose();
    _commentController.dispose();
    _commentFocusNode.dispose();
    _cleanWebRTC();
    _hostCameraRenderer.dispose();
    _remoteHostRenderer.dispose();
    super.dispose();
  }

  String _formatTimer(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final roomState = ref.watch(liveStreamRoomProvider(widget.initialStream));
    final roomNotifier =
        ref.read(liveStreamRoomProvider(widget.initialStream).notifier);
    final isHost = _isHost;

    // Listen for ended event
    ref.listen(
      liveStreamRoomProvider(widget.initialStream).select((s) => s.endedEvent),
      (prev, next) {
        if (next != null && !_hasShownEndedDialog) {
          _hasShownEndedDialog = true;
          LiveStreamEndedDialog.show(
            context,
            stream: roomState.stream,
            endedEvent: next,
            onDone: _exitPlayerScreen,
          ).then((_) {
            _exitPlayerScreen();
          });
        }
      },
    );

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (_isCommentInputActive) {
            _commentFocusNode.unfocus();
            setState(() => _isCommentInputActive = false);
          } else {
            // Rapid tap to like
            HapticFeedback.lightImpact();
            roomNotifier.sendReactionBurst();
          }
        },
        child: Stack(
          children: [
            // Video or Ambient Visual Backdrop (Host Camera or Video player)
            Positioned.fill(
              child: _buildVideoOrBackdrop(roomState.stream, isHost),
            ),

            // Top and Bottom Gradient Scrims for perfect readability
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 180,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black87,
                      Colors.black45,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 300,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black87,
                      Colors.black45,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Floating Hearts Particle System (Bottom Right)
            Positioned(
              bottom: 60,
              right: 12,
              child: FloatingHeartsOverlay(
                burstTick: roomState.reactionBurstTick,
              ),
            ),

            // Celebratory Gift Animation Banner (Top / Middle Left)
            if (roomState.activeGift != null)
              Positioned(
                top: 130,
                left: 0,
                child: GiftAnimationOverlay(
                  giftEvent: roomState.activeGift!,
                ),
              ),

            // Safe Area Overlays
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Navigation & Stream Header
                  _buildTopHeader(roomState, roomNotifier, isHost),

                  const Spacer(),

                  // Bottom Left: Real-Time Chat & Pinned Banner
                  LiveChatOverlay(
                    comments: roomState.comments,
                    pinnedComment: roomState.pinnedComment,
                    hostId: roomState.stream.host.id,
                    isHost: isHost,
                    onPinComment: roomNotifier.pinComment,
                    onUnpinComment: roomNotifier.unpinComment,
                  ),

                  const SizedBox(height: 10),

                  // Bottom Action Bar or Text Input
                  if (_isCommentInputActive)
                    _buildCommentInputField(roomNotifier)
                  else
                    _buildBottomControlBar(roomState, roomNotifier, isHost),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoOrBackdrop(LiveStream stream, bool isHost) {
    // If broadcaster/host is streaming live, show their real camera feed full-screen
    if (isHost) {
      if (_isHostCameraReady && _hostCameraRenderer.srcObject != null) {
        return RTCVideoView(
          _hostCameraRenderer,
          mirror: _isCameraFront,
          objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
        );
      }
      return Container(
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
                _isCameraFront ? Icons.camera_front : Icons.camera_rear,
                size: 64,
                color: Colors.white24,
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)?.cameraInitializing ??
                    'Camera initializing...',
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    // Viewer: if WebRTC stream from host is active,
    // display host's face full-screen
    if (_hasRemoteHostVideo && _remoteHostRenderer.srcObject != null) {
      return RTCVideoView(
        _remoteHostRenderer,
        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
      );
    }

    if (_videoController != null && _videoController!.value.isInitialized) {
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _videoController!.value.size.width,
          height: _videoController!.value.size.height,
          child: VideoPlayer(_videoController!),
        ),
      );
    }

    // High aesthetic fallback backdrop
    return Stack(
      fit: StackFit.expand,
      children: [
        if (stream.thumbnailUrl != null && stream.thumbnailUrl!.isNotEmpty)
          CachedNetworkImage(
            imageUrl: stream.thumbnailUrl!,
            fit: BoxFit.cover,
            errorWidget: (_, __, dynamic ___) => _buildFallbackGradient(stream),
          )
        else
          _buildFallbackGradient(stream),

        // Ambient dark blur overlay
        Container(color: Colors.black.withValues(alpha: 0.35)),
      ],
    );
  }

  Widget _buildFallbackGradient(LiveStream stream) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1F1C2C),
            Color(0xFF928DAB),
            Color(0xFF141E30),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 2),
              ),
              clipBehavior: Clip.antiAlias,
              child: stream.host.avatarUrl != null &&
                      stream.host.avatarUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: stream.host.avatarUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, dynamic ___) => Center(
                        child: Text(
                          stream.host.initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        stream.host.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            Text(
              stream.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const LiveBadge(isCompact: true),
                const SizedBox(width: 8),
                Text(
                  _formatTimer(_streamElapsedSeconds),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader(
    LiveStreamRoomState roomState,
    LiveStreamRoomNotifier roomNotifier,
    bool isHost,
  ) {
    final host = roomState.stream.host;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Streamer Profile Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAvatar(host, 34),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      (host.fullName?.isNotEmpty ?? false)
                          ? host.fullName!
                          : host.username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                    Row(
                      children: [
                        const LiveBadge(isCompact: true),
                        const SizedBox(width: 4),
                        Text(
                          _formatTimer(_streamElapsedSeconds),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (!isHost) ...[
                  const SizedBox(width: 8),
                  Container(
                    height: 26,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF0844), Color(0xFFFF4E50)],
                      ),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Text(
                      AppLocalizations.of(context)?.follow ?? 'Follow',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Spacer(),

          // Active Viewers counter & Avatar row
          GestureDetector(
            onTap: () => ViewersSheet.show(
              context,
              viewers: roomState.viewers,
              totalCount: roomState.stream.viewerCount,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.remove_red_eye_rounded,
                    color: Colors.white70,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${roomState.stream.viewerCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Exit / Close button
          GestureDetector(
            onTap: () => _handleExit(isHost, roomNotifier),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white12),
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControlBar(
    LiveStreamRoomState roomState,
    LiveStreamRoomNotifier roomNotifier,
    bool isHost,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          // "Add comment" rounded pill button
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _isCommentInputActive = true);
                _commentFocusNode.requestFocus();
              },
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(21),
                  border: Border.all(color: Colors.white12),
                ),
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context)?.addCommentHint ??
                      'Add a comment...',
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Viewers only: Gift & Like buttons
          if (!isHost) ...[
            _buildCircleActionButton(
              icon: Icons.card_giftcard,
              gradientColors: const [Color(0xFFFF0844), Color(0xFFFFB199)],
              onTap: () {
                GiftSheet.show(
                  context,
                  onSendGift: (gift, count) {
                    roomNotifier.sendGift(gift.id, count);
                  },
                );
              },
            ),
            const SizedBox(width: 8),

            // Like Button
            _buildCircleActionButton(
              icon: Icons.favorite,
              gradientColors: const [Color(0xFFFF2D55), Color(0xFFFF5E3A)],
              badgeText: roomState.stream.likeCount > 0
                  ? '${roomState.stream.likeCount}'
                  : null,
              onTap: () {
                HapticFeedback.lightImpact();
                roomNotifier.sendReactionBurst(count: 5);
              },
            ),
            const SizedBox(width: 8),
          ],

          _buildCircleActionButton(
            icon: Icons.emoji_events_outlined,
            backgroundColor: Colors.black.withValues(alpha: 0.5),
            onTap: () {
              LeaderboardSheet.show(
                context,
                supporters: roomState.leaderboard,
              );
            },
          ),

          // Host broadcast controls (Mic mute, Flip camera)
          if (isHost) ...[
            const SizedBox(width: 8),
            _buildCircleActionButton(
              icon: _isMicMuted ? Icons.mic_off : Icons.mic,
              backgroundColor: _isMicMuted
                  ? const Color(0xFFFF0844)
                  : Colors.black.withValues(alpha: 0.5),
              onTap: _toggleMic,
            ),
            const SizedBox(width: 8),
            _buildCircleActionButton(
              icon: Icons.flip_camera_ios,
              backgroundColor: Colors.black.withValues(alpha: 0.5),
              onTap: () {
                _flipHostCamera();
                roomNotifier.toggleCamera();
              },
            ),
          ] else ...[
            const SizedBox(width: 8),
            _buildCircleActionButton(
              icon: Icons.share_outlined,
              backgroundColor: Colors.black.withValues(alpha: 0.5),
              onTap: () {
                HapticFeedback.lightImpact();
                Clipboard.setData(
                  ClipboardData(
                    text: 'https://lotus.app/live/${widget.initialStream.id}',
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)?.streamLinkCopied ??
                          'Stream link copied to clipboard!',
                    ),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCircleActionButton({
    required IconData icon,
    required VoidCallback onTap,
    List<Color>? gradientColors,
    Color? backgroundColor,
    String? badgeText,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor,
              gradient: gradientColors != null
                  ? LinearGradient(colors: gradientColors)
                  : null,
              border: Border.all(color: Colors.white12),
              boxShadow: gradientColors != null
                  ? [
                      BoxShadow(
                        color: gradientColors.first.withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          if (badgeText != null)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF0844),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 1.5),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentInputField(LiveStreamRoomNotifier roomNotifier) {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              focusNode: _commentFocusNode,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)?.saySomethingNice ??
                    'Say something nice...',
                hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.1),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (text) {
                if (text.trim().isNotEmpty) {
                  roomNotifier.sendComment(text.trim());
                  _commentController.clear();
                }
                _commentFocusNode.unfocus();
                setState(() => _isCommentInputActive = false);
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send_rounded, color: Color(0xFFFF0844)),
            onPressed: () {
              final text = _commentController.text.trim();
              if (text.isNotEmpty) {
                roomNotifier.sendComment(text);
                _commentController.clear();
              }
              _commentFocusNode.unfocus();
              setState(() => _isCommentInputActive = false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(PostAuthor user, double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white24,
      ),
      clipBehavior: Clip.antiAlias,
      child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: user.avatarUrl!,
              fit: BoxFit.cover,
              errorWidget: (_, __, dynamic ___) => Center(
                child: Text(
                  user.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                user.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
    );
  }

  void _handleExit(bool isHost, LiveStreamRoomNotifier roomNotifier) {
    final loc = AppLocalizations.of(context);
    if (isHost) {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF161823),
          title: Text(
            loc?.endLiveStreamTitle ?? 'End Live Stream?',
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            loc?.endLiveStreamConfirm ??
                'Are you sure you want to conclude this live stream?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                loc?.cancel ?? 'Cancel',
                style: const TextStyle(color: Colors.white60),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF0844),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                roomNotifier.endStream();
              },
              child: Text(
                loc?.endStream ?? 'End Stream',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }
}
