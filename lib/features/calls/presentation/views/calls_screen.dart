import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/services/webrtc/signaling_service.dart';

enum CallStatus {
  idle,
  ringingOut, // We are calling someone else
  ringingIn,  // Someone else is calling us
  connected,  // Active WebRTC session
}

/// Dynamic Calls Dashboard & signaling console.
class CallsScreen extends ConsumerStatefulWidget {
  const CallsScreen({super.key});

  @override
  ConsumerState<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends ConsumerState<CallsScreen> {
  final _peerIdController = TextEditingController();
  CallStatus _status = CallStatus.idle;
  String? _activeCallId;
  String? _activePeerId;
  bool _isVideo = false;
  bool _isMuted = false;
  bool _isSpeakerOn = false;

  final List<String> _consoleLogs = [];

  StreamSubscription? _inviteSub;
  StreamSubscription? _acceptSub;
  StreamSubscription? _endSub;
  StreamSubscription? _sdpSub;
  StreamSubscription? _iceSub;

  @override
  void initState() {
    super.initState();
    _subscribeSignaling();
  }

  @override
  void dispose() {
    _inviteSub?.cancel();
    _acceptSub?.cancel();
    _endSub?.cancel();
    _sdpSub?.cancel();
    _iceSub?.cancel();
    _peerIdController.dispose();
    super.dispose();
  }

  void _log(String text) {
    if (mounted) {
      setState(() {
        _consoleLogs.insert(0, '${DateTime.now().toIso8601String().split('T').last.substring(0, 8)} | $text');
      });
    }
  }

  void _subscribeSignaling() {
    final signaling = ref.read(webrtcSignalingServiceProvider);

    // 1. Listen for call invitations (incoming calls)
    _inviteSub = signaling.invitationStream.listen((invite) {
      _log('☎️ Incoming call invite! ID: ${invite.callId} from Peer: ${invite.senderId}');
      setState(() {
        _status = CallStatus.ringingIn;
        _activeCallId = invite.callId;
        _activePeerId = invite.senderId;
        _isVideo = invite.isVideo;
      });
    });

    // 2. Listen for acceptances
    _acceptSub = signaling.acceptStream.listen((payload) {
      _log('✅ Call accepted by peer: ${payload['senderId']}');
      setState(() {
        _status = CallStatus.connected;
      });
      // Start simulated SDP / ICE candidate loop
      _startSimulatedSignalingExchange();
    });

    // 3. Listen for ended calls
    _endSub = signaling.endStream.listen((payload) {
      _log('❌ Call ended/rejected by peer');
      _resetCallState();
    });

    // 4. Listen for SDP negotiations
    _sdpSub = signaling.sdpStream.listen((payload) {
      _log('📡 WebRTC SDP ${payload['type']} received from Peer: ${payload['senderId']}');
    });

    // 5. Listen for ICE candidates
    _iceSub = signaling.iceStream.listen((payload) {
      final candidate = payload['candidate']?['candidate'] ?? 'unknown';
      _log('❄️ ICE Candidate received: ...${candidate.toString().split(' ').first}');
    });
  }

  void _resetCallState() {
    setState(() {
      _status = CallStatus.idle;
      _activeCallId = null;
      _activePeerId = null;
    });
  }

  void _startCall({required bool isVideo}) {
    final peerId = _peerIdController.text.trim();
    if (peerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a recipient Peer ID')),
      );
      return;
    }

    final channelId = 'room-${DateTime.now().millisecondsSinceEpoch}';
    _log('📞 Ringing peer: $peerId over channel: $channelId');

    setState(() {
      _status = CallStatus.ringingOut;
      _activePeerId = peerId;
      _activeCallId = 'call-${DateTime.now().millisecondsSinceEpoch}';
      _isVideo = isVideo;
    });

    ref.read(webrtcSignalingServiceProvider).sendInvite(
          recipientId: peerId,
          channelId: channelId,
          isVideo: isVideo,
        );
  }

  void _acceptIncomingCall() {
    if (_activeCallId == null || _activePeerId == null) return;
    _log('👍 Accepting call: $_activeCallId');
    setState(() {
      _status = CallStatus.connected;
    });

    ref.read(webrtcSignalingServiceProvider).acceptCall(
          callId: _activeCallId!,
          recipientId: _activePeerId!,
        );

    // Send answer SDP
    _log('📡 Negotiating WebRTC SDP Offer...');
    ref.read(webrtcSignalingServiceProvider).sendSdp(
          recipientId: _activePeerId!,
          sdpType: 'offer',
          sdpDescription: 'v=0\r\no=- 52627 2 IN IP4 127.0.0.1...',
        );
  }

  void _declineCall() {
    if (_activeCallId == null || _activePeerId == null) return;
    _log('👎 Declining call: $_activeCallId');

    ref.read(webrtcSignalingServiceProvider).endCall(
          callId: _activeCallId!,
          recipientId: _activePeerId!,
        );
    _resetCallState();
  }

  void _hangUp() {
    if (_activeCallId == null || _activePeerId == null) return;
    _log('☎️ Hanging up call');

    ref.read(webrtcSignalingServiceProvider).endCall(
          callId: _activeCallId!,
          recipientId: _activePeerId!,
        );
    _resetCallState();
  }

  void _startSimulatedSignalingExchange() {
    if (_activePeerId == null) return;

    // Send SDP Offer & ICE candidates simulation to test Rust gateway signaling
    Future.delayed(const Duration(seconds: 1), () {
      if (_status == CallStatus.connected) {
        _log('📡 Sending WebRTC SDP Offer...');
        ref.read(webrtcSignalingServiceProvider).sendSdp(
              recipientId: _activePeerId!,
              sdpType: 'offer',
              sdpDescription: 'v=0\r\no=- 234125 2 IN IP4 127.0.0.1...',
            );
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (_status == CallStatus.connected) {
        _log('❄️ Broadcasting local ICE Candidates...');
        ref.read(webrtcSignalingServiceProvider).sendIceCandidate(
              recipientId: _activePeerId!,
              candidate: 'candidate:42700 1 UDP 2122260223 127.0.0.1 53920 typ host',
              sdpMid: '0',
              sdpMLineIndex: 0,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('WebRTC Call Console', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Active Calling Screen States
            if (_status == CallStatus.idle) _buildIdleUI(theme),
            if (_status == CallStatus.ringingOut) _buildRingingOutUI(theme),
            if (_status == CallStatus.ringingIn) _buildRingingInUI(theme),
            if (_status == CallStatus.connected) _buildConnectedUI(theme),

            const SizedBox(height: 20),
            Text(
              'SIGNALING EVENT CONSOLE LOGS',
              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),

            // Live event logger
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: _consoleLogs.isEmpty
                    ? const Center(
                        child: Text(
                          'No events logged. Make or receive a call to see signaling logs.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white30, fontFamily: 'monospace', fontSize: 11),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _consoleLogs.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Text(
                              _consoleLogs[index],
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontFamily: 'monospace',
                                fontSize: 11,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdleUI(ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Make a New Call',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _peerIdController,
              decoration: InputDecoration(
                hintText: "Recipient User ID (e.g. friend-uuid)",
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _startCall(isVideo: false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.call),
                    label: const Text('Voice Call'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _startCall(isVideo: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.videocam),
                    label: const Text('Video Call'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRingingOutUI(ThemeData theme) {
    return Card(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const CircularProgressIndicator(color: Colors.amber),
            const SizedBox(height: 24),
            Text(
              'Ringing Peer...',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Peer ID: $_activePeerId',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 24),
            IconButton.filled(
              onPressed: _hangUp,
              style: IconButton.styleFrom(backgroundColor: Colors.red),
              icon: const Icon(Icons.call_end, size: 28, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRingingInUI(ThemeData theme) {
    return Card(
      color: Colors.amber.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              _isVideo ? Icons.video_camera_back : Icons.call,
              size: 48,
              color: Colors.amber,
            ),
            const SizedBox(height: 16),
            Text(
              'INCOMING CALL',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
            const SizedBox(height: 8),
            Text(
              'From Peer: $_activePeerId',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton.filled(
                  onPressed: _declineCall,
                  style: IconButton.styleFrom(backgroundColor: Colors.red),
                  icon: const Icon(Icons.call_end, color: Colors.white),
                ),
                IconButton.filled(
                  onPressed: _acceptIncomingCall,
                  style: IconButton.styleFrom(backgroundColor: Colors.green),
                  icon: const Icon(Icons.call, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedUI(ThemeData theme) {
    return Card(
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.circle, size: 10, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'ACTIVE SESSION CONNECTED',
                  style: theme.textTheme.titleSmall?.copyWith(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Call Peer: $_activePeerId',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 24),

            // Simulated Local Video / Waveforms placeholder
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.black25,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  _isVideo ? Icons.videocam : Icons.graphic_eq,
                  size: 40,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton.filledTonal(
                  onPressed: () {
                    setState(() {
                      _isMuted = !_isMuted;
                    });
                    _log(_isMuted ? 'Muted microphone' : 'Unmuted microphone');
                  },
                  icon: Icon(_isMuted ? Icons.mic_off : Icons.mic),
                ),
                IconButton.filled(
                  onPressed: _hangUp,
                  style: IconButton.styleFrom(backgroundColor: Colors.red),
                  icon: const Icon(Icons.call_end, color: Colors.white),
                ),
                IconButton.filledTonal(
                  onPressed: () {
                    setState(() {
                      _isSpeakerOn = !_isSpeakerOn;
                    });
                    _log(_isSpeakerOn ? 'Speaker ON' : 'Speaker OFF');
                  },
                  icon: Icon(_isSpeakerOn ? Icons.volume_up : Icons.volume_down),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
