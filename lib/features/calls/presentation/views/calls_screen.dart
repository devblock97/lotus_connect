import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:intl/intl.dart';
import 'package:lotus_connect/core/services/webrtc/signaling_service.dart';
import 'package:lotus_connect/core/utils/utils.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/calls/application/call_history_notifier.dart';
import 'package:lotus_connect/features/calls/presentation/widgets/ripple_animation.dart';
import 'package:lotus_connect/features/chat/application/presence_notifier.dart';
import 'package:lotus_connect/features/chat/application/private_conversation_list_notifier.dart';
import 'package:lotus_connect/features/chatbot/application/providers.dart';
import 'package:lotus_connect/features/chatbot/application/settings_notifier.dart';
import 'package:lotus_connect/features/contacts/application/contacts_notifier.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

enum CallStatus {
  idle,
  ringingOut, // We are calling someone else
  ringingIn, // Someone else is calling us
  connected, // Active WebRTC session
}

class CallsScreen extends ConsumerStatefulWidget {
  const CallsScreen({super.key});

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

  bool _showFriendsTab = true;
  String _searchQuery = '';

  final List<String> _consoleLogs = [];
  Timer? _callTimer;
  int _secondsElapsed = 0;

  StreamSubscription? _inviteSub;
  StreamSubscription? _acceptSub;
  StreamSubscription? _endSub;
  StreamSubscription? _sdpSub;
  StreamSubscription? _iceSub;
  StreamSubscription? _inviteAckSub;

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
    _initRenderers();
    _subscribeSignaling();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(contactsProvider.notifier).loadFriends();
      ref.read(callHistoryProvider.notifier).loadCallHistory();
    });
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  @override
  void dispose() {
    _stopTimer();
    try {
      FlutterRingtonePlayer().stop();
    } catch (_) {}
    _inviteSub?.cancel();
    _acceptSub?.cancel();
    _endSub?.cancel();
    _sdpSub?.cancel();
    _iceSub?.cancel();
    _inviteAckSub?.cancel();
    _peerIdController.dispose();
    _searchController.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _cleanWebRTC();
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

  void _updateStatus(CallStatus newStatus) {
    if (!mounted) return;
    setState(() {
      _status = newStatus;
    });

    if (newStatus == CallStatus.ringingIn) {
      _log('Starting incoming call ringtone...');
      try {
        FlutterRingtonePlayer().playRingtone();
      } catch (e) {
        _log('Error playing ringtone: $e');
      }
    } else {
      try {
        FlutterRingtonePlayer().stop();
      } catch (_) {}
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
      _log(
        'Incoming call invite! ID: ${invite.callId} from Peer: ${invite.senderId}',
      );
      setState(() {
        _activeCallId = invite.callId;
        _activePeerId = invite.senderId;
        _isVideo = invite.isVideo;
      });
      _updateStatus(CallStatus.ringingIn);
    });

    _acceptSub = signaling.acceptStream.listen((payload) async {
      _log('Call accepted by peer: ${payload['senderId']}');
      _updateStatus(CallStatus.connected);
      _startTimer();

      // We are the caller (host). Let's establish peer connection and send offer.
      await _createPeerConnection();
      if (_peerConnection != null) {
        final offer = await _peerConnection!.createOffer({
          'offerToReceiveAudio': true,
          'offerToReceiveVideo': _isVideo,
        });
        await _peerConnection!.setLocalDescription(offer);
        signaling.sendSdp(
          recipientId: _activePeerId!,
          sdpType: 'offer',
          sdpDescription: offer.sdp!,
        );
      }
    });

    _endSub = signaling.endStream.listen((payload) {
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
          // If receiver already clicked accept and connection is ready, configure the remote offer description immediately
          if (_status == CallStatus.connected && _peerConnection != null) {
            final currentRemoteDesc =
                await _peerConnection!.getRemoteDescription();
            if (currentRemoteDesc == null) {
              await _peerConnection!
                  .setRemoteDescription(_remoteOfferDescription!);
              final answer = await _peerConnection!.createAnswer({
                'offerToReceiveAudio': true,
                'offerToReceiveVideo': _isVideo,
              });
              await _peerConnection!.setLocalDescription(answer);

              signaling.sendSdp(
                recipientId: _activePeerId!,
                sdpType: 'answer',
                sdpDescription: answer.sdp!,
              );

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
      } catch (e) {
        _log('Error in _sdpSub: $e');
      }
    });

    _iceSub = signaling.iceStream.listen((payload) async {
      final candidateData = payload['candidate'];
      if (candidateData != null) {
        final cand = RTCIceCandidate(
          candidateData['candidate'] as String? ?? '',
          candidateData['sdpMid'] as String? ?? '0',
          candidateData['sdpMLineIndex'] as int? ?? 0,
        );
        _log('ICE Candidate received: ...${cand.candidate?.split(' ').first}');

        if (_peerConnection != null &&
            await _peerConnection!.getRemoteDescription() != null) {
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
        if (event.streams.isNotEmpty) {
          setState(() {
            _remoteRenderer.srcObject = event.streams[0];
          });
        }
      }
      ..onAddStream = (stream) {
        _log('Remote stream received (legacy)');
        setState(() {
          _remoteRenderer.srcObject = stream;
        });
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
      _localStream = stream;
      setState(() {
        _localRenderer.srcObject = stream;
      });

      stream.getTracks().forEach((track) {
        pc.addTrack(track, stream);
      });
    } catch (e) {
      _log('User media failed: $e');
    }

    _peerConnection = pc;
  }

  void _resetCallState() {
    _stopTimer();
    _cleanWebRTC();
    setState(() {
      _activeCallId = null;
      _activePeerId = null;
    });
    _updateStatus(CallStatus.idle);
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

    ref.read(webrtcSignalingServiceProvider).sendInvite(
          recipientId: peerId,
          channelId: channelId,
          isVideo: isVideo,
        );
  }

  Future<void> _acceptIncomingCall() async {
    if (_activeCallId == null || _activePeerId == null) return;
    _log('Accepting call: $_activeCallId');
    _updateStatus(CallStatus.connected);
    _startTimer();

    ref.read(webrtcSignalingServiceProvider).acceptCall(
          callId: _activeCallId!,
          recipientId: _activePeerId!,
        );

    try {
      await _createPeerConnection();

      if (_remoteOfferDescription != null && _peerConnection != null) {
        final currentRemoteDesc = await _peerConnection!.getRemoteDescription();
        if (currentRemoteDesc == null) {
          await _peerConnection!.setRemoteDescription(_remoteOfferDescription!);
          final answer = await _peerConnection!.createAnswer({
            'offerToReceiveAudio': true,
            'offerToReceiveVideo': _isVideo,
          });
          await _peerConnection!.setLocalDescription(answer);

          ref.read(webrtcSignalingServiceProvider).sendSdp(
                recipientId: _activePeerId!,
                sdpType: 'answer',
                sdpDescription: answer.sdp!,
              );

          // Drain ice candidates queue
          for (final cand in _remoteIceCandidatesQueue) {
            await _peerConnection!.addCandidate(cand);
          }
          _remoteIceCandidatesQueue.clear();
        }
      }
    } catch (e) {
      _log('Error during call acceptance: $e');
    }
  }

  void _declineCall() {
    if (_activeCallId == null || _activePeerId == null) return;
    _log('Declining call: $_activeCallId');

    ref.read(webrtcSignalingServiceProvider).endCall(
          callId: _activeCallId!,
          recipientId: _activePeerId!,
        );
    _resetCallState();
  }

  void _hangUp() {
    if (_activeCallId == null || _activePeerId == null) return;
    _log('Hanging up call');

    ref.read(webrtcSignalingServiceProvider).endCall(
          callId: _activeCallId!,
          recipientId: _activePeerId!,
        );
    _resetCallState();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CallRequest?>(callRequestProvider, (prev, next) {
      if (next != null) {
        _peerIdController.text = next.recipientId;
        WidgetsBinding.instance.addPostFrameCallback((_) {
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
      return _buildConnectedUI();
    }
    return _buildIdleUI();
  }

  String _getPresenceStatusText(String peerId) {
    final presenceMap = ref.watch(presenceProvider);
    final peerPresence = presenceMap[peerId];
    final isOnline = peerPresence?.isOnline ?? false;
    final lastSeen = peerPresence?.lastSeen ?? DateTime.now();
    if (isOnline) {
      return 'Online';
    } else {
      return formatLastSeen(isOnline, lastSeen);
    }
  }

  Color _getPresenceColor(String peerId) {
    final presenceMap = ref.watch(presenceProvider);
    final peerPresence = presenceMap[peerId];
    final isOnline = peerPresence?.isOnline ?? false;
    if (isOnline) return Colors.green;
    return Colors.grey;
  }

  String _resolvePeerId(CallLog log) {
    final currentUserId = ref.read(settingsProvider).userId;
    if (log.hostId != currentUserId) {
      return log.hostId;
    }
    if (log.conversationId != null) {
      final conversations =
          ref.read(privateConversationListProvider).conversations;
      for (final c in conversations) {
        if (c.id == log.conversationId && c.isUserToUser) {
          return c.peerId;
        }
      }
    }
    return '';
  }

  String _resolvePeerName(CallLog log, List<User> friends) {
    final targetId = _resolvePeerId(log);
    if (targetId.isNotEmpty) {
      for (final f in friends) {
        if (f.id == targetId) {
          return f.fullName ?? f.username;
        }
      }
      return 'User ${targetId.substring(0, 8)}';
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
            const Icon(Icons.terminal, color: Colors.blue),
            const SizedBox(width: 8),
            Text(loc.signalingEventLogs),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          height: 350,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: _consoleLogs.isEmpty
              ? Center(
                  child: Text(
                    loc.noEventsLoggedYet,
                    style: const TextStyle(
                      color: Colors.white30,
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _consoleLogs.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      _consoleLogs[index],
                      style: const TextStyle(
                        color: Colors.greenAccent,
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
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
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
    final currentUserId = ref.read(settingsProvider).userId;

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
        titleSpacing: 8,
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
                    const Icon(Icons.terminal, size: 18),
                    const SizedBox(width: 8),
                    Text(loc.viewSignalingLogs),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    const Icon(Icons.refresh, size: 18),
                    const SizedBox(width: 8),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
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
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: _showFriendsTab
                                ? [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.05),
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
                                  ? Colors.black
                                  : Colors.grey.shade600,
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
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: !_showFriendsTab
                                ? [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.05),
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
                                  ? Colors.black
                                  : Colors.grey.shade600,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                fillColor: Colors.grey.shade100,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
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
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_call),
        label: Text(loc.startNewCall),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
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
            Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              loc.noFriendsFound,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final friend = friends[index];
        final presenceText = _getPresenceStatusText(friend.id);
        final presenceColor = _getPresenceColor(friend.id);
        final displayName = friend.fullName ?? friend.username;
        final initials = displayName.isNotEmpty
            ? displayName.substring(0, 1).toUpperCase()
            : '?';

        return Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade100),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            leading: Stack(
              children: [
                CircleAvatar(
                  backgroundColor: presenceColor.withValues(alpha: 0.1),
                  child: Text(
                    initials,
                    style: TextStyle(
                      color: presenceColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: presenceColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            title: Text(
              displayName,
              style: theme.textTheme.titleMedium,
            ),
            subtitle: Text(
              presenceText,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.chat_bubble_outline,
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                  onPressed: () => _startPrivateChat(friend),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.phone_outlined,
                    color: Colors.blue,
                    size: 22,
                  ),
                  onPressed: () {
                    _peerIdController.text = friend.id;
                    _startCall(isVideo: false);
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.videocam_outlined,
                    color: Colors.green,
                    size: 22,
                  ),
                  onPressed: () {
                    _peerIdController.text = friend.id;
                    _startCall(isVideo: true);
                  },
                ),
              ],
            ),
          ),
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
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              loc.noCallHistoryLogs,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        if (today.isNotEmpty) ...[
          _buildHistorySectionHeader(loc.today),
          ...today.map((log) => _buildHistoryItem(log, friends, theme)),
          const SizedBox(height: 12),
        ],
        if (yesterday.isNotEmpty) ...[
          _buildHistorySectionHeader(loc.yesterday),
          ...yesterday.map((log) => _buildHistoryItem(log, friends, theme)),
          const SizedBox(height: 12),
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
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
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
    final nameColor = isMissed ? Colors.red : Colors.black;
    final timeText = DateFormat('h:mm a').format(log.createdAt);

    // Call icon badge overlay
    IconData badgeIcon;
    Color badgeColor;
    if (isMissed) {
      badgeIcon = Icons.close;
      badgeColor = Colors.red;
    } else {
      final currentUserId = ref.read(settingsProvider).userId;
      final isOutgoing = log.hostId == currentUserId;
      badgeIcon = isOutgoing ? Icons.arrow_upward : Icons.arrow_downward;
      badgeColor = isOutgoing ? Colors.blue : Colors.green;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor:
                  isMissed ? Colors.red.shade50 : Colors.grey.shade100,
              child: Text(
                initials,
                style: TextStyle(
                  color: isMissed ? Colors.red : Colors.grey.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(badgeIcon, size: 10, color: Colors.white),
              ),
            ),
          ],
        ),
        title: Text(
          peerName,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Row(
          children: [
            Icon(
              log.isVideo ? Icons.videocam_outlined : Icons.phone_outlined,
              size: 14,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              log.isVideo ? loc.videoCall : loc.voiceCall,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            if (log.durationSeconds > 0) ...[
              const SizedBox(width: 8),
              const Icon(Icons.circle, size: 4, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                _formatDurationText(log.durationSeconds),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              timeText,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade100,
              child: IconButton(
                icon: Icon(
                  log.isVideo ? Icons.videocam : Icons.phone,
                  size: 16,
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
    final friend = ref
        .read(contactsProvider)
        .friends
        .where((f) => f.id == _activePeerId)
        .firstOrNull;
    final displayName = friend != null
        ? (friend.fullName ?? friend.username)
        : (_activePeerId?.substring(0, 8) ?? 'User');
    final initialName = displayName.substring(0, 1);

    return Scaffold(
      body: Container(
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
                    _isVideo
                        ? '${loc.incomingCall.toUpperCase()} (${loc.video.toUpperCase()})'
                        : '${loc.incomingCall.toUpperCase()} (${loc.voice.toUpperCase()})',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black54,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),

              // Option Buttons (Remind Me / Message)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTextActionButton(Icons.alarm, loc.remindMe),
                    _buildTextActionButton(Icons.chat_bubble, loc.message),
                  ],
                ),
              ),

              // Decline / Accept Buttons
              Padding(
                padding: const EdgeInsets.only(bottom: 48, left: 40, right: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Decline
                    Column(
                      children: [
                        IconButton(
                          onPressed: _declineCall,
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
                        const SizedBox(height: 10),
                        Text(
                          loc.decline,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    // Accept
                    Column(
                      children: [
                        IconButton(
                          onPressed: _acceptIncomingCall,
                          iconSize: 32,
                          padding: const EdgeInsets.all(18),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF34C759),
                            foregroundColor: Colors.white,
                            shape: const CircleBorder(),
                            elevation: 4,
                          ),
                          icon: Icon(_isVideo ? Icons.videocam : Icons.call),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          loc.accept,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
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

  Widget _buildRingingOutUI() {
    final loc = AppLocalizations.of(context)!;
    final friend = ref
        .read(contactsProvider)
        .friends
        .where((f) => f.id == _activePeerId)
        .firstOrNull;
    final displayName = friend != null
        ? (friend.fullName ?? friend.username)
        : (_activePeerId?.substring(0, 8) ?? 'User');
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
                    _isVideo
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
                      onPressed: _hangUp,
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

  Widget _buildConnectedUI() {
    final loc = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final friend = ref
        .read(contactsProvider)
        .friends
        .where((f) => f.id == _activePeerId)
        .firstOrNull;
    final displayName = friend != null
        ? (friend.fullName ?? friend.username)
        : (_activePeerId?.substring(0, 8) ?? 'User');
    final initialName = displayName.substring(0, 1);

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
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
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
                        border: Border.all(color: Colors.white24, width: 2),
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
                    const SizedBox(height: 18),
                    Text(
                      displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.voiceConnected,
                      style: const TextStyle(
                        color: Colors.white70,
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
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back/Dismiss Icon
                GestureDetector(
                  onTap: _hangUp,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),

                // Encryption Pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lock,
                        color: Color(0xFF34C759),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        loc.endToEndEncrypted.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formatDuration(_secondsElapsed),
                    style: const TextStyle(
                      color: Colors.white,
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
            right: 16,
            bottom: size.height * 0.22,
            child: Column(
              children: [
                _buildFloatingSideButton(Icons.chat_bubble, () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.chatScreenOverlayOpened)),
                  );
                }),
                const SizedBox(height: 16),
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
              top: MediaQuery.of(context).padding.top + 80,
              right: 16,
              child: Container(
                width: 105,
                height: 155,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: RTCVideoView(
                        _localRenderer,
                        mirror: true,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          loc.you.toUpperCase(),
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
              ),
            ),

          // Bottom Control Overlay Pill
          Positioned(
            left: 20,
            right: 20,
            bottom: 32,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(36),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
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
                    color: Colors.white,
                    style: IconButton.styleFrom(
                      backgroundColor:
                          _isMuted ? Colors.white24 : Colors.transparent,
                      padding: const EdgeInsets.all(12),
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
                      color: Colors.white,
                      style: IconButton.styleFrom(
                        backgroundColor:
                            _isVideoOff ? Colors.white24 : Colors.transparent,
                        padding: const EdgeInsets.all(12),
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
                    color: Colors.white,
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(12),
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
                    color: Colors.white,
                    style: IconButton.styleFrom(
                      backgroundColor:
                          _isSpeakerOn ? Colors.white24 : Colors.transparent,
                      padding: const EdgeInsets.all(12),
                    ),
                  ),

                  // End Call Button
                  IconButton(
                    onPressed: _hangUp,
                    icon: const Icon(Icons.call_end),
                    color: Colors.white,
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFD63A2F),
                      padding: const EdgeInsets.all(12),
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
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          ),
          child: Icon(icon, color: Colors.black87, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
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
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class CallsSearchResultsScreen extends ConsumerStatefulWidget {
  const CallsSearchResultsScreen({
    required this.initialQuery,
    required this.onStartCall,
    super.key,
  });

  final String initialQuery;
  final void Function(String peerId, bool isVideo) onStartCall;

  @override
  ConsumerState<CallsSearchResultsScreen> createState() =>
      _CallsSearchResultsScreenState();
}

class _CallsSearchResultsScreenState
    extends ConsumerState<CallsSearchResultsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery;
    _searchQuery = widget.initialQuery;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(contactsProvider.notifier).searchUsers(widget.initialQuery);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contactsState = ref.watch(contactsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        titleSpacing: 0,
      ),
      body: contactsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : contactsState.searchResults.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: contactsState.searchResults.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final user = contactsState.searchResults[index];
                    final isFriend =
                        contactsState.friends.any((f) => f.id == user.id);
                    return _buildSearchResultItem(theme, user, isFriend);
                  },
                ),
    );
  }

  Widget _buildSearchResultItem(ThemeData theme, User user, bool isFriend) {
    final displayName = user.fullName ?? user.username;
    final initials = displayName.isNotEmpty
        ? displayName.substring(0, 1).toUpperCase()
        : '?';
    final avatarColor =
        Colors.primaries[user.username.hashCode % Colors.primaries.length];

    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: avatarColor.withValues(alpha: 0.15),
                  child: Text(
                    initials,
                    style: TextStyle(
                      color: avatarColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@${user.username}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isFriend)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check,
                          size: 12,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Friend',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (!isFriend) ...[
                  if (user.friendshipStatus == 'pending') ...[
                    if (user.friendshipSenderId ==
                        ref.watch(settingsProvider).userId)
                      _buildActionButton(
                        icon: Icons.hourglass_empty_outlined,
                        label: 'Requested',
                        color: Colors.amber.shade800,
                        onTap: () {},
                      )
                    else ...[
                      _buildActionButton(
                        icon: Icons.check,
                        label: 'Accept',
                        color: Colors.green,
                        onTap: () async {
                          final success = await ref
                              .read(contactsProvider.notifier)
                              .acceptFriendRequest(user.id);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Friend request accepted!'
                                      : 'Failed to accept request',
                                ),
                                backgroundColor:
                                    success ? Colors.green : Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                      _buildActionButton(
                        icon: Icons.close,
                        label: 'Reject',
                        color: Colors.red,
                        onTap: () async {
                          final success = await ref
                              .read(contactsProvider.notifier)
                              .rejectFriendRequest(user.id);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Friend request rejected!'
                                      : 'Failed to reject request',
                                ),
                                backgroundColor:
                                    success ? Colors.green : Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ] else ...[
                    _buildActionButton(
                      icon: Icons.person_add_alt_1,
                      label: 'Add Friend',
                      color: theme.colorScheme.primary,
                      onTap: () async {
                        final success = await ref
                            .read(contactsProvider.notifier)
                            .sendFriendRequest(user.username);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Friend request sent to @${user.username}'
                                    : 'Failed to send request',
                              ),
                              backgroundColor:
                                  success ? Colors.green : Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ],
                // Send Message Action
                _buildActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: 'Message',
                  color: Colors.grey.shade700,
                  onTap: () async {
                    final currentContext = context;
                    final conv = await ref
                        .read(privateConversationListProvider.notifier)
                        .createNewPrivateChat(
                          friendId: user.id,
                          title: user.fullName ?? user.username,
                        );
                    if (conv != null && currentContext.mounted) {
                      ref.read(shellIndexProvider.notifier).state =
                          1; // Switch to Chats tab
                      Navigator.of(currentContext)
                          .popUntil((route) => route.isFirst);
                    }
                  },
                ),
                // Voice Call Action
                _buildActionButton(
                  icon: Icons.phone_outlined,
                  label: 'Voice',
                  color: Colors.blue,
                  onTap: () {
                    widget.onStartCall(user.id, false);
                    Navigator.pop(context); // Go back to Call screen
                  },
                ),
                // Video Call Action
                _buildActionButton(
                  icon: Icons.videocam_outlined,
                  label: 'Video',
                  color: Colors.green,
                  onTap: () {
                    widget.onStartCall(user.id, true);
                    Navigator.pop(context); // Go back to Call screen
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No matching users',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'We couldn\'t find any users matching "$_searchQuery".',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
