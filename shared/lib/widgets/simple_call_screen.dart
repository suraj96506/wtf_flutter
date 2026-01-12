import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared/services/call_service.dart';

/// Minimal in-call UI for 100ms join/leave and basic track rendering.
class SimpleCallScreen extends StatefulWidget {
  const SimpleCallScreen({
    super.key,
    required this.roomId,
    required this.userId,
    required this.role,
    required this.callService,
  });

  final String roomId;
  final String userId;
  final String role;
  final CallService callService;

  @override
  State<SimpleCallScreen> createState() => _SimpleCallScreenState();
}

class _SimpleCallScreenState extends State<SimpleCallScreen> {
  bool _muted = false;
  bool _videoEnabled = true;
  bool _joining = true;
  late final StreamSubscription<List<HMSVideoTrack>> _tracksSubscription;
  List<HMSVideoTrack> _videoTracks = [];

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    final granted = await _ensurePermissions();
    if (!granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera & mic permissions required.')),
        );
        Navigator.of(context).pop();
      }
      return;
    }

    _tracksSubscription = widget.callService.videoTracks.listen((tracks) {
      if (mounted) setState(() => _videoTracks = tracks);
    });

    try {
      await widget.callService.joinRoom(
        widget.roomId,
        widget.userId,
        widget.role,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Join failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  Future<bool> _ensurePermissions() async {
    final statuses = await [Permission.camera, Permission.microphone].request();
    final cam = statuses[Permission.camera] ?? PermissionStatus.denied;
    final mic = statuses[Permission.microphone] ?? PermissionStatus.denied;
    if (cam.isPermanentlyDenied || mic.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }
    return cam.isGranted && mic.isGranted;
  }

  @override
  void dispose() {
    _tracksSubscription.cancel();
    widget.callService.leaveRoom();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Video Call'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: _joining
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : _videoTracks.isEmpty
                ? const Center(
                    child: Text(
                      'Waiting for video...',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                    itemCount: _videoTracks.length,
                    itemBuilder: (context, index) {
                      final track = _videoTracks[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: HMSVideoView(track: track, matchParent: true),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _roundButton(
                  icon: _muted ? Icons.mic_off : Icons.mic,
                  color: _muted ? Colors.red : Colors.white,
                  onTap: () async {
                    await widget.callService.toggleMicMuteState();
                    setState(() => _muted = !_muted);
                  },
                ),
                _roundButton(
                  icon: _videoEnabled ? Icons.videocam : Icons.videocam_off,
                  color: _videoEnabled ? Colors.white : Colors.red,
                  onTap: () async {
                    await widget.callService.toggleCameraMuteState();
                    setState(() => _videoEnabled = !_videoEnabled);
                  },
                ),
                _roundButton(
                  icon: Icons.call_end,
                  color: Colors.red,
                  onTap: () async {
                    await widget.callService.leaveRoom();
                    if (mounted) Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkResponse(
      onTap: onTap,
      radius: 32,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color),
      ),
    );
  }
}
