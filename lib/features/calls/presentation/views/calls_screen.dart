import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:intl/intl.dart';
import 'package:lotus_connect/app/theme/app_color.dart';
import 'package:lotus_connect/app/theme/app_size.dart';
import 'package:lotus_connect/core/services/webrtc/signaling_service.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/calls/application/active_call_notifier.dart';
import 'package:lotus_connect/features/calls/application/call_history_notifier.dart';
import 'package:lotus_connect/features/calls/data/models/call_request.dart';
import 'package:lotus_connect/features/calls/domain/entities/call_log.dart';
import 'package:lotus_connect/features/calls/domain/entities/call_session.dart';
import 'package:lotus_connect/features/calls/presentation/utils/call_peer_display.dart';
import 'package:lotus_connect/features/calls/presentation/widgets/connected_screen.dart';
import 'package:lotus_connect/features/calls/presentation/widgets/ripple_animation.dart';
import 'package:lotus_connect/features/chat/application/conversation_list_notifier.dart';
import 'package:lotus_connect/features/contacts/application/contacts_notifier.dart';
import 'package:lotus_connect/features/contacts/presentation/widgets/contact_card.dart';
import 'package:lotus_connect/features/settings/application/settings_notifier.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';
import 'package:lotus_connect/main_shell_screen.dart';

enum CallStatus {
  idle,
  ringingOut, // We are calling someone else
  ringingIn, // Someone else is calling us
  connected, // Active WebRTC session
}

class CallsScreen extends ConsumerStatefulWidget {
  const CallsScreen({
    this.callRequest = const CallRequest(recipientId: '', isVideo: false),
    this.incomingInvitation,
    super.key,
  });

  final CallRequest callRequest;
  final WebRTCCallInvitation? incomingInvitation;

  static int _openInstances = 0;

  /// Whether at least one [CallsScreen] instance is currently mounted.
  static bool get isCurrentlyOpen => _openInstances > 0;

  @override
  ConsumerState<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends ConsumerState<CallsScreen> {
  final _peerIdController = TextEditingController();
  final _searchController = TextEditingController();
  CallStatus _status = CallStatus.idle;
  String? _activeCallId;
  String? _activePeerId;
  bool _isVideo = false;
  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _isSpeakerOn = false;
  bool _isPopping = false;

  bool _showFriendsTab = true;
  String _searchQuery = '';

  final List<String> _consoleLogs = [];
  Timer? _callTimer;
  int _secondsElapsed = 0;

  StreamSubscription<WebRTCCallInvitation>? _inviteSub;
  StreamSubscription<Map<String, dynamic>>? _acceptSub;
  StreamSubscription<Map<String, dynamic>>? _endSub;
  StreamSubscription<Map<String, dynamic>>? _sdpSub;
  StreamSubscription<Map<String, dynamic>>? _iceSub;
  StreamSubscription<Map<String, dynamic>>? _inviteAckSub;

  // WebRTC components
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  RTCSessionDescription? _remoteOfferDescription;
  final List<RTCIceCandidate> _remoteIceCandidatesQueue = [];

  @override
  void initState() {
    super.initState();
    CallsScreen._openInstances++;
    final incoming = widget.incomingInvitation;
    if (incoming != null) {
      _activeCallId = incoming.callId;
      _activePeerId = incoming.senderId;
      _isVideo = incoming.isVideo;
      _status = CallStatus.ringingIn;
    } else if (widget.callRequest.recipientId.isNotEmpty) {
      _peerIdController.text = widget.callRequest.recipientId;
      _activePeerId = widget.callRequest.recipientId;
      _activeCallId = 'call-${DateTime.now().millisecondsSinceEpoch}';
      _isVideo = widget.callRequest.isVideo;
      _status = CallStatus.ringingOut;
    }
    _initRenderers();
    _subscribeSignaling();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(contactsProvider.notifier).loadFriends();
      ref.read(callHistoryProvider.notifier).loadCallHistory();
      if (widget.incomingInvitation != null) {
        _log(
          'Incoming call invite! ID: ${widget.incomingInvitation!.callId} '
          'from Peer: ${widget.incomingInvitation!.senderId}',
        );
        _startRingtone();
      } else if (widget.callRequest.recipientId.isNotEmpty) {
        _startCall(isVideo: widget.callRequest.isVideo);
      }
    });
  }

  Future<void> _initRenderers() async {
    try {
      await _localRenderer.initialize();
      await _remoteRenderer.initialize();
    } on Object catch (e) {
      _log('Renderer initialization note: $e');
    }
  }

  @override
  void dispose() {
    CallsScreen._openInstances = (CallsScreen._openInstances - 1).clamp(0, 999);
    _stopTimer();
    _stopRingtone();
    _inviteSub?.cancel();
    _acceptSub?.cancel();
    _endSub?.cancel();
    _sdpSub?.cancel();
    _iceSub?.cancel();
    _inviteAckSub?.cancel();
    _peerIdController.dispose();
    _searchController.dispose();
    _cleanWebRTC();
    try {
      _localRenderer.dispose();
      _remoteRenderer.dispose();
    } on Object catch (_) {}
    super.dispose();
  }

  void _log(String text) {
    if (mounted) {
      setState(() {
        _consoleLogs.insert(
          0,
          '${DateTime.now().toIso8601String().split('T').last.substring(0, 8)} | $text',
        );
      });
    }
  }

  void _startRingtone() {
    _log('Starting incoming call ringtone...');
    try {
      FlutterRingtonePlayer().playRingtone();
    } on Object catch (e) {
      _log('Error playing ringtone: $e');
    }
  }

  void _stopRingtone() {
    try {
      FlutterRingtonePlayer().stop();
    } on Object catch (_) {}
  }

  void _updateStatus(CallStatus newStatus) {
    if (!mounted) return;
    setState(() {
      _status = newStatus;
    });

    if (newStatus == CallStatus.ringingIn) {
      _startRingtone();
    } else {
      _stopRingtone();
    }
  }

  void _startTimer() {
    _callTimer?.cancel();
    _secondsElapsed = 0;
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  void _stopTimer() {
    _callTimer?.cancel();
    _callTimer = null;
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _subscribeSignaling() {
    final signaling = ref.read(webrtcSignalingServiceProvider);

    _inviteSub = signaling.invitationStream.listen((invite) {
      if (!mounted || _status != CallStatus.idle) return;
      _log(
        'Incoming call invite! ID: ${invite.callId} '
        'from Peer: ${invite.senderId}',
      );
      setState(() {
        _activeCallId = invite.callId;
        _activePeerId = invite.senderId;
        _isVideo = invite.isVideo;
      });
      _updateStatus(CallStatus.ringingIn);
    });

    _acceptSub = signaling.acceptStream.listen((payload) async {
      if (!mounted || _status == CallStatus.idle) return;
      final senderId = payload['senderId'] as String?;
      if (senderId != null &&
          _activePeerId != null &&
          senderId != _activePeerId) {
        return;
      }

      _log('Call accepted by peer: $senderId');
      _updateStatus(CallStatus.connected);
      _startTimer();

      // We are the caller (host).
      // Let's establish peer connection and send offer.
      await _createPeerConnection();
      final peerId = _activePeerId;
      if (!mounted ||
          peerId == null ||
          _status != CallStatus.connected ||
          _peerConnection == null) {
        return;
      }

      final offer = await _peerConnection!.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': _isVideo,
      });
      if (!mounted || _peerConnection == null) return;
      await _peerConnection!.setLocalDescription(offer);
      signaling.sendSdp(
        recipientId: peerId,
        sdpType: 'offer',
        sdpDescription: offer.sdp!,
      );
    });

    _endSub = signaling.endStream.listen((payload) {
      if (!mounted || _status == CallStatus.idle) return;
      _log('Call ended/rejected by peer');
      _resetCallState();
    });

    _inviteAckSub = signaling.inviteAckStream.listen((payload) {
      final ackCallId = payload['callId'] as String?;
      _log('Call invite acknowledged. Assigned Server UUID: $ackCallId');
      if (mounted) {
        setState(() {
          _activeCallId = ackCallId;
        });
      }
    });

    _sdpSub = signaling.sdpStream.listen((payload) async {
      try {
        final type = payload['type'] as String;
        String sdp;
        final rawSdp = payload['sdp'];
        if (rawSdp is Map) {
          sdp = rawSdp['sdp'] as String;
        } else {
          sdp = rawSdp as String;
        }
        _log('WebRTC SDP $type received from Peer: ${payload['senderId']}');

        if (type == 'offer') {
          _remoteOfferDescription = RTCSessionDescription(sdp, type);
          // If receiver already clicked accept and connection is ready,
          // configure the remote offer description immediately
          if (_status == CallStatus.connected && _peerConnection != null) {
            final currentRemoteDesc =
                await _peerConnection!.getRemoteDescription();
            if (!mounted || _peerConnection == null) return;
            if (currentRemoteDesc == null) {
              await _peerConnection!
                  .setRemoteDescription(_remoteOfferDescription!);
              if (!mounted || _peerConnection == null) return;
              final answer = await _peerConnection!.createAnswer({
                'offerToReceiveAudio': true,
                'offerToReceiveVideo': _isVideo,
              });
              if (!mounted || _peerConnection == null) return;
              await _peerConnection!.setLocalDescription(answer);

              final peerId = _activePeerId;
              if (peerId != null) {
                signaling.sendSdp(
                  recipientId: peerId,
                  sdpType: 'answer',
                  sdpDescription: answer.sdp!,
                );
              }

              // Drain ice candidates queue
              for (final cand in _remoteIceCandidatesQueue) {
                await _peerConnection!.addCandidate(cand);
              }
              _remoteIceCandidatesQueue.clear();
            }
          }
        } else if (type == 'answer') {
          if (_peerConnection != null) {
            final currentRemoteDesc =
                await _peerConnection!.getRemoteDescription();
            if (!mounted || _peerConnection == null) return;
            if (currentRemoteDesc == null) {
              await _peerConnection!
                  .setRemoteDescription(RTCSessionDescription(sdp, type));
              // Drain ice candidates queue
              for (final cand in _remoteIceCandidatesQueue) {
                await _peerConnection!.addCandidate(cand);
              }
              _remoteIceCandidatesQueue.clear();
            }
          }
        }
      } on Object catch (e) {
        _log('Error in _sdpSub: $e');
      }
    });

    _iceSub = signaling.iceStream.listen((payload) async {
      final rawCandidate = payload['candidate'];
      if (rawCandidate is Map) {
        final candidateData = Map<String, dynamic>.from(rawCandidate);
        final cand = RTCIceCandidate(
          candidateData['candidate'] as String? ?? '',
          candidateData['sdpMid'] as String? ?? '0',
          (candidateData['sdpMLineIndex'] as num?)?.toInt() ?? 0,
        );
        _log('ICE Candidate received: ...${cand.candidate?.split(' ').first}');

        if (_peerConnection != null &&
            await _peerConnection!.getRemoteDescription() != null) {
          if (!mounted || _peerConnection == null) return;
          await _peerConnection!.addCandidate(cand);
        } else {
          _remoteIceCandidatesQueue.add(cand);
        }
      }
    });
  }

  void _cleanWebRTC() {
    _localStream?.getTracks().forEach((track) => track.stop());
    _localStream?.dispose();
    _localStream = null;
    _peerConnection?.close();
    _peerConnection?.dispose();
    _peerConnection = null;
    _remoteOfferDescription = null;
    _remoteIceCandidatesQueue.clear();
    try {
      _localRenderer.srcObject = null;
      _remoteRenderer.srcObject = null;
    } on Object catch (_) {}
  }

  Future<void> _createPeerConnection() async {
    if (_peerConnection != null) return;
    _isSpeakerOn = _isVideo;

    _log('Creating RTCPeerConnection...');
    final pc = await createPeerConnection({
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
    }, {
      'mandatory': <dynamic, dynamic>{},
      'optional': [
        {'DtlsSrtpKeyAgreement': true},
      ],
    });

    if (!mounted) {
      await pc.close();
      await pc.dispose();
      return;
    }

    pc
      ..onIceConnectionState = (state) {
        _log('ICE Connection State: $state');
      }
      ..onSignalingState = (state) {
        _log('Signaling State: $state');
      }
      ..onIceCandidate = (candidate) {
        if (candidate.candidate != null && _activePeerId != null) {
          ref.read(webrtcSignalingServiceProvider).sendIceCandidate(
                recipientId: _activePeerId!,
                candidate: candidate.candidate!,
                sdpMid: candidate.sdpMid ?? '0',
                sdpMLineIndex: candidate.sdpMLineIndex ?? 0,
              );
        }
      }
      ..onTrack = (event) {
        _log('Remote track received');
        if (event.streams.isNotEmpty && mounted) {
          setState(() {
            _remoteRenderer.srcObject = event.streams[0];
          });
        }
      }
      ..onAddStream = (stream) {
        _log('Remote stream received (legacy)');
        if (mounted) {
          setState(() {
            _remoteRenderer.srcObject = stream;
          });
        }
      };

    final constraints = {
      'audio': true,
      'video': _isVideo
          ? {
              'facingMode': 'user',
              'width': '640',
              'height': '480',
            }
          : false,
    };

    try {
      _log('Accessing user media devices...');
      final stream = await navigator.mediaDevices.getUserMedia(constraints);
      if (!mounted) {
        stream.getTracks().forEach((track) => track.stop());
        await stream.dispose();
        await pc.close();
        await pc.dispose();
        return;
      }
      _localStream = stream;
      setState(() {
        _localRenderer.srcObject = stream;
      });

      stream.getTracks().forEach((track) {
        pc.addTrack(track, stream);
      });
    } on Object catch (e) {
      _log('User media failed: $e');
    }

    _peerConnection = pc;
  }

  void _resetCallState({bool popIfLaunchedForCall = true}) {
    _stopTimer();
    _stopRingtone();
    _cleanWebRTC();
    if (!mounted) return;
    unawaited(ref.read(callHistoryProvider.notifier).loadCallHistory());
    setState(() {
      _activeCallId = null;
      _activePeerId = null;
    });
    _updateStatus(CallStatus.idle);

    final launchedForSingleCall = widget.callRequest.recipientId.isNotEmpty ||
        widget.incomingInvitation != null;
    if (popIfLaunchedForCall &&
        launchedForSingleCall &&
        !_isPopping &&
        Navigator.of(context).canPop()) {
      _isPopping = true;
      Navigator.of(context).pop();
    }
  }

  Future<void> _startCall({required bool isVideo}) async {
    final peerId = _peerIdController.text.trim();
    if (peerId.isEmpty) {
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.pleaseEnterRecipientPeerId)),
      );
      return;
    }

    final channelId = 'room-${DateTime.now().millisecondsSinceEpoch}';
    _log('Ringing peer: $peerId over channel: $channelId');

    setState(() {
      _activePeerId = peerId;
      _activeCallId = 'call-${DateTime.now().millisecondsSinceEpoch}';
      _isVideo = isVideo;
    });
    _updateStatus(CallStatus.ringingOut);

    await ref.read(activeCallProvider.notifier).startCall(
          peerId: peerId,
          channelId: channelId,
          isVideo: isVideo,
        );
    if (!mounted) return;
    final session = ref.read(activeCallProvider);
    if (session.state == CallState.ended && session.errorMessage != null) {
      _log('Failed to initiate call: ${session.errorMessage}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(session.errorMessage!)),
      );
      _resetCallState();
    }
  }

  Future<void> _acceptIncomingCall() async {
    if (_activeCallId == null || _activePeerId == null) return;
    _log('Accepting call: $_activeCallId');
    _updateStatus(CallStatus.connected);
    _startTimer();

    unawaited(
      ref
          .read(activeCallProvider.notifier)
          .acceptCall(_activeCallId!, _activePeerId!),
    );

    try {
      await _createPeerConnection();
      if (!mounted || _peerConnection == null) return;

      if (_remoteOfferDescription != null) {
        final currentRemoteDesc = await _peerConnection!.getRemoteDescription();
        if (!mounted || _peerConnection == null) return;
        if (currentRemoteDesc == null) {
          await _peerConnection!.setRemoteDescription(_remoteOfferDescription!);
          if (!mounted || _peerConnection == null) return;
          final answer = await _peerConnection!.createAnswer({
            'offerToReceiveAudio': true,
            'offerToReceiveVideo': _isVideo,
          });
          if (!mounted || _peerConnection == null) return;
          await _peerConnection!.setLocalDescription(answer);

          final peerId = _activePeerId;
          if (peerId != null) {
            unawaited(
              ref
                  .read(activeCallProvider.notifier)
                  .sendSdp(peerId, 'answer', answer.sdp!),
            );
          }

          // Drain ice candidates queue
          for (final cand in _remoteIceCandidatesQueue) {
            await _peerConnection!.addCandidate(cand);
          }
          _remoteIceCandidatesQueue.clear();
        }
      }
    } on Object catch (e) {
      _log('Error during call acceptance: $e');
    }
  }

  void _declineCall() {
    if (_activeCallId == null || _activePeerId == null) return;
    _log('Declining call: $_activeCallId');

    unawaited(
      ref
          .read(activeCallProvider.notifier)
          .endCall(_activeCallId!, _activePeerId!),
    );

    _resetCallState();
  }

  void _hangUp() {
    if (_activeCallId == null || _activePeerId == null) return;
    _log('Hanging up call');

    unawaited(
      ref
          .read(activeCallProvider.notifier)
          .endCall(_activeCallId!, _activePeerId!),
    );

    _resetCallState();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CallRequest?>(callRequestProvider, (prev, next) {
      if (next != null) {
        _peerIdController.text = next.recipientId;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ref.read(callRequestProvider.notifier).state = null;
        });
        _startCall(isVideo: next.isVideo);
      }
    });

    if (_status == CallStatus.ringingIn) {
      return _buildRingingInUI();
    }
    if (_status == CallStatus.ringingOut) {
      return _buildRingingOutUI();
    }
    if (_status == CallStatus.connected) {
      return ConnectedScreen(
        activePeerId: _activePeerId ?? '',
        isVideo: _isVideo,
        remoteRenderer: _remoteRenderer,
        localRenderer: _localRenderer,
        duration: _formatDuration(_secondsElapsed),
        isMuted: _isMuted,
        hangUp: _hangUp,
        localStream: _localStream,
      );
    }
    return _buildIdleUI();
  }

  String _resolvePeerId(CallLog log) {
    final settings = ref.read(settingsNotifierProvider).settings;
    final friends = ref.read(contactsProvider).friends;
    final conversations = log.conversationId != null
        ? ref.read(privateConversationListProvider).conversations
        : null;
    return resolveCallLogPeerId(
      log: log,
      currentUserId: settings.userId,
      friends: friends,
      conversations: conversations,
      currentUsername: settings.username,
      currentFullName: settings.fullName,
    );
  }

  String _resolvePeerName(CallLog log, List<User> friends) {
    final targetId = _resolvePeerId(log);
    if (targetId.isNotEmpty) {
      for (final f in friends) {
        if (f.id == targetId) {
          final fullName = f.fullName?.trim();
          return (fullName != null && fullName.isNotEmpty)
              ? fullName
              : f.username;
        }
      }
      final shortId = targetId.length > 8 ? targetId.substring(0, 8) : targetId;
      return 'User $shortId';
    }
    return 'Unknown User';
  }

  String _formatDurationText(int seconds) {
    if (seconds <= 0) {
      final loc = AppLocalizations.of(context)!;
      return loc.missed;
    }
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m > 0) {
      return '${m}m ${s}s';
    }
    return '${s}s';
  }

  void _showLogsDialog() {
    final loc = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.terminal, color: AppColor.infoBlue.of(context)),
            AppGap.hSm,
            Text(loc.signalingEventLogs),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          height: 350,
          padding: AppPadding.md,
          decoration: BoxDecoration(
            color: AppColor.mediaBackdrop.of(context),
            borderRadius: AppRadius.md,
            border: AppBorder.all(AppColor.onMedia10.of(context)),
          ),
          child: _consoleLogs.isEmpty
              ? Center(
                  child: Text(
                    loc.noEventsLoggedYet,
                    style: TextStyle(
                      color: AppColor.onMedia30.of(context),
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _consoleLogs.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSize.xxs),
                    child: Text(
                      _consoleLogs[index],
                      style: TextStyle(
                        color: AppColor.terminalGreen.of(context),
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(_consoleLogs.clear);
              Navigator.pop(context);
            },
            child: Text(loc.clearLogs),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.close),
          ),
        ],
      ),
    );
  }

  void _showStartNewCallManualDialog() {
    final loc = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.startNewCall),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.enterUserAddressToPlaceCall,
              style: TextStyle(
                fontSize: 13,
                color: AppColor.inkMuted.of(context),
              ),
            ),
            AppGap.vMd,
            TextField(
              controller: _peerIdController,
              decoration: const InputDecoration(
                hintText: 'e.g. friend-uuid-v7',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _startCall(isVideo: false);
            },
            icon: const Icon(Icons.phone),
            label: Text(loc.voice),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _startCall(isVideo: true);
            },
            icon: const Icon(Icons.videocam),
            label: Text(loc.video),
          ),
        ],
      ),
    );
  }

  Widget _buildIdleUI() {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final friendsState = ref.watch(contactsProvider);
    final historyState = ref.watch(callHistoryProvider);
    final currentUserId = ref.read(settingsNotifierProvider).settings.userId;

    final filteredFriends = friendsState.friends.where((f) {
      final name = (f.fullName ?? '').toLowerCase();
      final username = f.username.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || username.contains(query);
    }).toList();

    final todayLogs = <CallLog>[];
    final yesterdayLogs = <CallLog>[];
    final olderLogs = <CallLog>[];

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final yesterdayStart = todayStart.subtract(const Duration(days: 1));

    for (final log in historyState.history) {
      final peerName = _resolvePeerName(log, friendsState.friends);
      if (_searchQuery.isNotEmpty &&
          !peerName.toLowerCase().contains(_searchQuery.toLowerCase())) {
        continue;
      }

      final localCreatedAt = log.createdAt.toLocal();
      final logDate = DateTime(
        localCreatedAt.year,
        localCreatedAt.month,
        localCreatedAt.day,
      );
      if (logDate.isAtSameMomentAs(todayStart)) {
        todayLogs.add(log);
      } else if (logDate.isAtSameMomentAs(yesterdayStart)) {
        yesterdayLogs.add(log);
      } else {
        olderLogs.add(log);
      }
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSize.sm,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (val) {
              if (val == 'logs') {
                _showLogsDialog();
              } else if (val == 'clear') {
                ref.read(callHistoryProvider.notifier).loadCallHistory();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logs',
                child: Row(
                  children: [
                    const Icon(Icons.terminal, size: AppSize.iconSm),
                    AppGap.hSm,
                    Text(loc.viewSignalingLogs),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    const Icon(Icons.refresh, size: AppSize.iconSm),
                    AppGap.hSm,
                    Text(loc.refreshHistory),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSize.screenPadding,
              vertical: AppSize.sm,
            ),
            child: Container(
              height: AppSize.tabBarHeight,
              decoration: BoxDecoration(
                color: AppColor.surfaceTrack.of(context),
                borderRadius: AppRadius.xxl,
              ),
              child: Padding(
                padding: AppPadding.xs,
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _showFriendsTab = true;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _showFriendsTab
                                ? AppColor.surfaceElevated.of(context)
                                : AppColor.transparent.of(context),
                            borderRadius: AppRadius.xl,
                            boxShadow: _showFriendsTab
                                ? [
                                    BoxShadow(
                                      color: AppColor.black
                                          .of(context)
                                          .withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            loc.friends,
                            style: TextStyle(
                              fontWeight: _showFriendsTab
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: _showFriendsTab
                                  ? AppColor.inkSolid.of(context)
                                  : AppColor.inkMutedMedium.of(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _showFriendsTab = false;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: !_showFriendsTab
                                ? AppColor.surfaceElevated.of(context)
                                : AppColor.transparent.of(context),
                            borderRadius: AppRadius.xl,
                            boxShadow: !_showFriendsTab
                                ? [
                                    BoxShadow(
                                      color: AppColor.black
                                          .of(context)
                                          .withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            loc.history,
                            style: TextStyle(
                              fontWeight: !_showFriendsTab
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: !_showFriendsTab
                                  ? AppColor.inkSolid.of(context)
                                  : AppColor.inkMutedMedium.of(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSize.screenPadding,
              vertical: AppSize.xs,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: loc.searchFriendsOrCalls,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColor.surfaceTrack.of(context),
                contentPadding: AppPadding.zero,
                border: const OutlineInputBorder(
                  borderRadius: AppRadius.lg,
                  borderSide: AppBorder.none,
                ),
              ),
            ),
          ),

          // Main View Content
          Expanded(
            child: _showFriendsTab
                ? _buildFriendsView(filteredFriends, theme)
                : _buildHistoryView(
                    todayLogs,
                    yesterdayLogs,
                    olderLogs,
                    friendsState.friends,
                    theme,
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: _showStartNewCallManualDialog,
        backgroundColor: AppColor.inkSolid.of(context),
        foregroundColor: AppColor.surfaceElevated.of(context),
        icon: const Icon(Icons.add_call),
        label: Text(loc.startNewCall),
        shape: AppBorder.rounded(radius: AppSize.radiusXxxl),
      ),
    );
  }

  Widget _buildFriendsView(List<User> friends, ThemeData theme) {
    final loc = AppLocalizations.of(context)!;
    if (friends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: AppSize.iconHero,
              color: Colors.grey.shade400,
            ),
            AppGap.vLg,
            Text(
              loc.noFriendsFound,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColor.inkMutedDark.of(context),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSize.screenPadding,
        vertical: AppSize.sm,
      ),
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final friend = friends[index];

        return ContactCard(
          friend: friend,
          voiceCall: () {
            _peerIdController.text = friend.id;
            _startCall(isVideo: false);
          },
          videoCall: () {
            _peerIdController.text = friend.id;
            _startCall(isVideo: true);
          },
        );
      },
    );
  }

  Widget _buildHistoryView(
    List<CallLog> today,
    List<CallLog> yesterday,
    List<CallLog> older,
    List<User> friends,
    ThemeData theme,
  ) {
    final loc = AppLocalizations.of(context)!;
    if (today.isEmpty && yesterday.isEmpty && older.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.call_missed_outgoing,
              size: AppSize.iconHero,
              color: AppColor.inkSubtle.of(context),
            ),
            AppGap.vLg,
            Text(
              loc.noCallHistoryLogs,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColor.inkMutedDark.of(context),
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSize.screenPadding,
        vertical: AppSize.sm,
      ),
      children: [
        if (today.isNotEmpty) ...[
          _buildHistorySectionHeader(loc.today),
          ...today.map((log) => _buildHistoryItem(log, friends, theme)),
          AppGap.vMd,
        ],
        if (yesterday.isNotEmpty) ...[
          _buildHistorySectionHeader(loc.yesterday),
          ...yesterday.map((log) => _buildHistoryItem(log, friends, theme)),
          AppGap.vMd,
        ],
        if (older.isNotEmpty) ...[
          _buildHistorySectionHeader(loc.older),
          ...older.map((log) => _buildHistoryItem(log, friends, theme)),
        ],
      ],
    );
  }

  Widget _buildHistorySectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSize.sm,
        horizontal: AppSize.xs,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColor.inkMuted.of(context),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildHistoryItem(CallLog log, List<User> friends, ThemeData theme) {
    final loc = AppLocalizations.of(context)!;
    final peerName = _resolvePeerName(log, friends);
    final initials =
        peerName.isNotEmpty ? peerName.substring(0, 1).toUpperCase() : '?';

    final isMissed = log.status == 'missed' || log.status == 'rejected';
    final nameColor =
        isMissed ? AppColor.danger.of(context) : AppColor.inkSolid.of(context);
    final timeText = DateFormat('h:mm a').format(log.createdAt);

    // Call icon badge overlay
    IconData badgeIcon;
    Color badgeColor;
    if (isMissed) {
      badgeIcon = Icons.close;
      badgeColor = AppColor.danger.of(context);
    } else {
      final currentUserId = ref.read(settingsNotifierProvider).settings.userId;
      final isOutgoing = log.hostId == currentUserId;
      badgeIcon = isOutgoing ? Icons.arrow_upward : Icons.arrow_downward;
      badgeColor = isOutgoing
          ? AppColor.infoBlue.of(context)
          : AppColor.successGreen.of(context);
    }

    return Card(
      elevation: AppSize.elevationNone,
      margin: const EdgeInsets.symmetric(vertical: AppSize.xs),
      shape: AppBorder.rounded(
        color: AppColor.surfaceTrack.of(context),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSize.md,
          vertical: AppSize.xs,
        ),
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: isMissed
                  ? AppColor.dangerSoft.of(context)
                  : AppColor.surfaceTrack.of(context),
              child: Text(
                initials,
                style: TextStyle(
                  color: isMissed
                      ? AppColor.danger.of(context)
                      : AppColor.inkMutedStrong.of(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              bottom: AppSize.none,
              right: AppSize.none,
              child: Container(
                width: AppSize.avatarBadgeSm,
                height: AppSize.avatarBadgeSm,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                  border: AppBorder.all(
                    AppColor.surfaceElevated.of(context),
                    width: AppSize.borderThick,
                  ),
                ),
                child: Icon(
                  badgeIcon,
                  size: AppSize.iconXxs,
                  color: AppColor.onMedia.of(context),
                ),
              ),
            ),
          ],
        ),
        title: Text(
          peerName,
          style: theme.textTheme.titleMedium?.copyWith(color: nameColor),
        ),
        subtitle: Row(
          children: [
            Icon(
              log.isVideo ? Icons.videocam_outlined : Icons.phone_outlined,
              size: AppSize.iconXs,
              color: AppColor.inkMutedMedium.of(context),
            ),
            AppGap.hXs,
            Text(
              log.isVideo ? loc.videoCall : loc.voiceCall,
              style: TextStyle(
                color: AppColor.inkMutedMedium.of(context),
                fontSize: 13,
              ),
            ),
            if (log.durationSeconds > 0) ...[
              AppGap.hSm,
              const Icon(Icons.circle, size: AppSize.xs, color: Colors.grey),
              AppGap.hSm,
              Text(
                _formatDurationText(log.durationSeconds),
                style: TextStyle(
                  color: AppColor.inkMutedMedium.of(context),
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              timeText,
              style: TextStyle(
                color: AppColor.inkMuted.of(context),
                fontSize: 12,
              ),
            ),
            AppGap.hMd,
            CircleAvatar(
              radius: AppSize.avatarMd / 2,
              backgroundColor: Colors.grey.shade100,
              child: IconButton(
                icon: Icon(
                  log.isVideo ? Icons.videocam : Icons.phone,
                  size: AppSize.iconXs,
                  color: Colors.black87,
                ),
                onPressed: () {
                  final targetPeerId = _resolvePeerId(log);
                  if (targetPeerId.isNotEmpty) {
                    _peerIdController.text = targetPeerId;
                    _startCall(isVideo: log.isVideo);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startPrivateChat(User friend) async {
    final conv = await ref
        .read(privateConversationListProvider.notifier)
        .createNewPrivateChat(
          friendId: friend.id,
          title: friend.fullName ?? friend.username,
        );

    if (conv != null) {
      ref.read(shellIndexProvider.notifier).state = 1; // Switch to Chats tab
    }
  }

  Widget _buildRingingInUI() {
    final loc = AppLocalizations.of(context)!;
    final friends = ref.watch(contactsProvider).friends;
    final peer = resolveCallPeerDisplay(
      friends: friends,
      peerId: _activePeerId,
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
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
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
                          _isVideo
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

                    // Option Buttons (Remind Me / Message)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSize.huge,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildTextActionButton(Icons.alarm, loc.remindMe),
                          _buildTextActionButton(
                            Icons.chat_bubble,
                            loc.message,
                          ),
                        ],
                      ),
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
                                onPressed: _declineCall,
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
                                onPressed: _acceptIncomingCall,
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
                                  _isVideo ? Icons.videocam : Icons.call,
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
          ),
        ),
      ),
    );
  }

  Widget _buildRingingOutUI() {
    final loc = AppLocalizations.of(context)!;
    final friends = ref.watch(contactsProvider).friends;
    final peer = resolveCallPeerDisplay(
      friends: friends,
      peerId: _activePeerId,
    );
    final displayName = peer.displayName;
    final initialName = peer.initial;

    return Scaffold(
      body: Container(
        width: double.maxFinite,
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
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
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
                          _isVideo
                              ? '${loc.calling.toUpperCase()} (${loc.video.toUpperCase()})'
                              : '${loc.calling.toUpperCase()} (${loc.voice.toUpperCase()})',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColor.inkSecondary.of(context),
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
                            onPressed: _hangUp,
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
                            loc.cancel,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColor.inkPrimary.of(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConnectedUI() {
    final loc = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final friends = ref.watch(contactsProvider).friends;
    final peer = resolveCallPeerDisplay(
      friends: friends,
      peerId: _activePeerId,
    );
    final displayName = peer.displayName;
    final initialName = peer.initial;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background - Remote Stream View or dark space for Audio
          if (_isVideo)
            RTCVideoView(
              _remoteRenderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            )
          else
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColor.callConnectedBgStart.of(context),
                    AppColor.callConnectedBgEnd.of(context),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: AppBorder.all(
                          Colors.white24,
                          width: AppSize.borderThick,
                        ),
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
                    AppGap.vLg,
                    Text(
                      displayName,
                      style: TextStyle(
                        color: AppColor.onMedia.of(context),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppGap.vSm,
                    Text(
                      loc.voiceConnected,
                      style: TextStyle(
                        color: AppColor.onMedia70.of(context),
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Header Row (Dismiss, Encryption Status, Duration)
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSize.lg,
            left: AppSize.lg,
            right: AppSize.lg,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back/Dismiss Icon
                GestureDetector(
                  onTap: _hangUp,
                  child: Container(
                    padding: AppPadding.sm,
                    decoration: BoxDecoration(
                      color: AppColor.black.of(context).withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chevron_left,
                      size: AppSize.iconMd,
                      color: AppColor.onMedia.of(context),
                    ),
                  ),
                ),

                // Encryption Pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSize.sm,
                    horizontal: AppSize.lg,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.xl,
                    color: AppColor.black.of(context).withValues(alpha: 0.4),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock,
                        size: AppSize.iconXs,
                        color: AppColor.callAcceptGreen.of(context),
                      ),
                      AppGap.hXs,
                      Text(
                        loc.endToEndEncrypted.toUpperCase(),
                        style: TextStyle(
                          color: AppColor.onMedia.of(context),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Call Duration Counter
                Container(
                  padding: AppPadding.chip,
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.md,
                    color: AppColor.black.of(context).withValues(alpha: 0.4),
                  ),
                  child: Text(
                    _formatDuration(_secondsElapsed),
                    style: TextStyle(
                      color: AppColor.onMedia.of(context),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Right Side floating control options
          Positioned(
            right: AppSize.lg,
            bottom: size.height * 0.22,
            child: Column(
              children: [
                _buildFloatingSideButton(Icons.chat_bubble, () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.chatScreenOverlayOpened)),
                  );
                }),
                AppGap.vLg,
                _buildFloatingSideButton(Icons.more_horiz, () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.moreWithOptionsOpened)),
                  );
                }),
              ],
            ),
          ),

          // Picture in Picture View (YOU)
          if (_isVideo)
            Positioned(
              top: MediaQuery.of(context).padding.top + AppSize.avatarXxl,
              right: AppSize.lg,
              child: Container(
                width: 105,
                height: 155,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.lg,
                  border: AppBorder.all(
                    AppColor.onMedia24.of(context),
                    width: AppSize.borderMedium,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.black.of(context).withValues(alpha: 0.25),
                      blurRadius: AppSize.md,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: AppRadius.lg,
                      child: RTCVideoView(
                        _localRenderer,
                        mirror: true,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      ),
                    ),
                    Positioned(
                      bottom: AppSize.sm,
                      left: AppSize.sm,
                      child: Container(
                        padding: AppPadding.badge,
                        decoration: BoxDecoration(
                          borderRadius: AppRadius.xs,
                          color:
                              AppColor.black.of(context).withValues(alpha: 0.5),
                        ),
                        child: Text(
                          loc.you.toUpperCase(),
                          style: TextStyle(
                            color: AppColor.onMedia.of(context),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom Control Overlay Pill
          Positioned(
            left: AppSize.xl,
            right: AppSize.xl,
            bottom: AppSize.xxxl,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: AppSize.md,
                horizontal: AppSize.xl,
              ),
              decoration: BoxDecoration(
                borderRadius: AppRadius.full,
                boxShadow: [
                  BoxShadow(
                    blurRadius: AppSize.xl,
                    offset: const Offset(0, AppSize.sm),
                    color: AppColor.callControlBarBg
                        .of(context)
                        .withValues(alpha: 0.85),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Microphone Toggle
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isMuted = !_isMuted;
                        _localStream?.getAudioTracks().forEach((track) {
                          track.enabled = !_isMuted;
                        });
                      });
                      _log(
                        _isMuted ? 'Muted microphone' : 'Unmuted microphone',
                      );
                    },
                    icon: Icon(_isMuted ? Icons.mic_off : Icons.mic),
                    color: AppColor.onMedia.of(context),
                    style: IconButton.styleFrom(
                      backgroundColor: _isMuted
                          ? AppColor.onMedia24.of(context)
                          : AppColor.transparent.of(context),
                      padding: AppPadding.md,
                    ),
                  ),

                  // Camera Toggle
                  if (_isVideo)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isVideoOff = !_isVideoOff;
                          _localStream?.getVideoTracks().forEach((track) {
                            track.enabled = !_isVideoOff;
                          });
                        });
                        _log(
                          _isVideoOff
                              ? 'Disabled local video'
                              : 'Enabled local video',
                        );
                      },
                      icon: Icon(
                        _isVideoOff ? Icons.videocam_off : Icons.videocam,
                      ),
                      color: AppColor.onMedia.of(context),
                      style: IconButton.styleFrom(
                        backgroundColor: _isVideoOff
                            ? AppColor.onMedia24.of(context)
                            : AppColor.transparent.of(context),
                        padding: AppPadding.md,
                      ),
                    ),

                  // Share/Screen Cast Button
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(loc.screenSharingSimulation),
                        ),
                      );
                    },
                    icon: const Icon(Icons.ios_share),
                    color: AppColor.onMedia.of(context),
                    style: IconButton.styleFrom(
                      padding: AppPadding.md,
                    ),
                  ),

                  // Speaker Toggle
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isSpeakerOn = !_isSpeakerOn;
                        Helper.setSpeakerphoneOn(_isSpeakerOn);
                      });
                      _log(_isSpeakerOn ? 'Speaker ON' : 'Speaker OFF');
                    },
                    icon: Icon(
                      _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                    ),
                    color: AppColor.onMedia.of(context),
                    style: IconButton.styleFrom(
                      backgroundColor: _isSpeakerOn
                          ? AppColor.onMedia24.of(context)
                          : AppColor.transparent.of(context),
                      padding: AppPadding.md,
                    ),
                  ),

                  // End Call Button
                  IconButton(
                    onPressed: _hangUp,
                    icon: const Icon(Icons.call_end),
                    color: AppColor.onMedia.of(context),
                    style: IconButton.styleFrom(
                      padding: AppPadding.md,
                      backgroundColor: AppColor.callDeclineRed.of(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextActionButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: AppPadding.sm,
          decoration: BoxDecoration(
            color: AppColor.onMedia.of(context).withValues(alpha: 0.6),
            shape: BoxShape.circle,
            border: AppBorder.all(
              AppColor.black.of(context).withValues(alpha: 0.05),
            ),
          ),
          child: Icon(
            icon,
            color: AppColor.inkPrimary.of(context),
            size: AppSize.iconMd,
          ),
        ),
        AppGap.vSm,
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColor.inkSecondary.of(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingSideButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppPadding.sm,
        decoration: BoxDecoration(
          color: AppColor.black.of(context).withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: AppColor.onMedia.of(context),
          size: AppSize.iconMd,
        ),
      ),
    );
  }
}
