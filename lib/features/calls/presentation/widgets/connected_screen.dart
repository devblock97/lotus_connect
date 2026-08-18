import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:lotus_connect/features/contacts/application/contacts_notifier.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

class ConnectedScreen extends ConsumerStatefulWidget {
  const ConnectedScreen({
    required this.activePeerId,
    required this.isVideo,
    required this.remoteRenderer,
    required this.localRenderer,
    required this.duration,
    this.isMuted = false,
    this.hangUp,
    this.localStream,
    super.key,
  });

  final String activePeerId;
  final bool isVideo;
  final RTCVideoRenderer remoteRenderer;
  final RTCVideoRenderer localRenderer;
  final VoidCallback? hangUp;
  final String duration;
  final bool isMuted;
  final MediaStream? localStream;

  @override
  ConsumerState<ConnectedScreen> createState() => _ConnectedScreenState();
}

class _ConnectedScreenState extends ConsumerState<ConnectedScreen> {
  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _isSpeakerOn = true;

  @override
  void initState() {
    _isMuted = widget.isMuted;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background - Remote Stream View or dark space for Audio
          if (widget.isVideo)
            RTCVideoView(
              widget.remoteRenderer,
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
                  onTap: widget.hangUp,
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
                    widget.duration,
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
          // Positioned(
          //   right: 16,
          //   bottom: size.height * 0.22,
          //   child: Column(
          //     children: [
          //       _buildFloatingSideButton(Icons.chat_bubble, () {
          //         ScaffoldMessenger.of(context).showSnackBar(
          //           SnackBar(content: Text(loc.chatScreenOverlayOpened)),
          //         );
          //       }),
          //       const SizedBox(height: 16),
          //       _buildFloatingSideButton(Icons.more_horiz, () {
          //         ScaffoldMessenger.of(context).showSnackBar(
          //           SnackBar(content: Text(loc.moreWithOptionsOpened)),
          //         );
          //       }),
          //     ],
          //   ),
          // ),

          // Picture in Picture View (YOU)
          if (widget.isVideo)
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
                        widget.localRenderer,
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
                        widget.localStream?.getAudioTracks().forEach((track) {
                          track.enabled = !_isMuted;
                        });
                      });
                      // _log(
                      //   _isMuted ? 'Muted microphone' : 'Unmuted microphone',
                      // );
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
                  if (widget.isVideo)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isVideoOff = !_isVideoOff;
                          widget.localStream?.getVideoTracks().forEach((track) {
                            track.enabled = !_isVideoOff;
                          });
                        });
                        // _log(
                        //   _isVideoOff
                        //       ? 'Disabled local video'
                        //       : 'Enabled local video',
                        // );
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
                      // _log(_isSpeakerOn ? 'Speaker ON' : 'Speaker OFF');
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
                    onPressed: widget.hangUp,
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
}
