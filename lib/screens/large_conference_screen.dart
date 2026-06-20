import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:livekit_client/livekit_client.dart';
import '../config/app_config.dart';
import '../theme/colors.dart';

/// Large conference screen using LiveKit SFU — supports 100+ participants.
class LargeConferenceScreen extends StatefulWidget {
  final String meetingId;
  final String meetingName;
  final String userId;
  final String userName;
  final String? userEmail;
  final bool isHost;

  const LargeConferenceScreen({
    super.key,
    required this.meetingId,
    required this.meetingName,
    required this.userId,
    required this.userName,
    this.userEmail,
    this.isHost = false,
  });

  @override
  State<LargeConferenceScreen> createState() => _LargeConferenceScreenState();
}

class _LargeConferenceScreenState extends State<LargeConferenceScreen> {
  Room? _room;
  EventsListener<RoomEvent>? _roomListener;

  bool _micOn = true;
  bool _camOn = true;
  bool _speakerOn = true;
  bool _loading = true;
  String? _error;

  // Remote participants snapshot — rebuilt on room events
  List<RemoteParticipant> _remoteParticipants = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _roomListener?.dispose();
    _room?.disconnect();
    _room?.dispose();
    super.dispose();
  }

  // ── Token fetch ────────────────────────────────────────────────────────────

  Future<String?> _fetchToken() async {
    try {
      final uri = Uri.parse(
        '${AppConfig.livekitTokenServerUrl}/livekit-token'
        '?room=${Uri.encodeComponent(widget.meetingId)}'
        '&identity=${Uri.encodeComponent(widget.userId)}'
        '&name=${Uri.encodeComponent(widget.userName)}',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return data['token'] as String?;
      }
      _log('Token server returned ${res.statusCode}: ${res.body}');
    } catch (e) {
      _log('Token fetch error: $e');
    }
    return null;
  }

  // ── Init ───────────────────────────────────────────────────────────────────

  Future<void> _init() async {
    await [Permission.camera, Permission.microphone].request();

    final token = await _fetchToken();
    if (token == null) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Impossible d\'obtenir un token de connexion.\n\n'
              'Vérifiez que le serveur de tokens est actif:\n'
              '${AppConfig.livekitTokenServerUrl}';
        });
      }
      return;
    }

    try {
      final room = Room(
        roomOptions: const RoomOptions(
          defaultVideoPublishOptions: VideoPublishOptions(simulcast: true),
          defaultAudioPublishOptions: AudioPublishOptions(dtx: true),
        ),
      );

      _roomListener = room.createListener();
      _roomListener!
        ..on<RoomConnectedEvent>((_) => _refreshParticipants())
        ..on<ParticipantConnectedEvent>((_) => _refreshParticipants())
        ..on<ParticipantDisconnectedEvent>((_) => _refreshParticipants())
        ..on<TrackPublishedEvent>((_) => _refreshParticipants())
        ..on<TrackUnpublishedEvent>((_) => _refreshParticipants())
        ..on<TrackSubscribedEvent>((_) => _refreshParticipants())
        ..on<TrackUnsubscribedEvent>((_) => _refreshParticipants())
        ..on<RoomDisconnectedEvent>((event) {
          if (mounted) {
            final reason = event.reason;
            if (reason != DisconnectReason.clientInitiated) {
              setState(() => _error = 'Déconnecté: ${reason?.name ?? "inconnu"}');
            }
          }
        });

      await room.connect(
        AppConfig.livekitUrl,
        token,
        connectOptions: const ConnectOptions(autoSubscribe: true),
      );

      _room = room;

      await room.localParticipant?.setCameraEnabled(_camOn);
      await room.localParticipant?.setMicrophoneEnabled(_micOn);

      if (mounted) {
        setState(() {
          _loading = false;
          _remoteParticipants = room.remoteParticipants.values.toList();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Connexion LiveKit échouée:\n$e';
        });
      }
    }
  }

  void _refreshParticipants() {
    if (mounted && _room != null) {
      setState(() {
        _remoteParticipants = _room!.remoteParticipants.values.toList();
        _loading = false;
      });
    }
  }

  void _log(String msg) {
    // ignore: avoid_print
    print('[LargeConference] $msg');
  }

  // ── Controls ───────────────────────────────────────────────────────────────

  Future<void> _toggleMic() async {
    _micOn = !_micOn;
    await _room?.localParticipant?.setMicrophoneEnabled(_micOn);
    setState(() {});
  }

  Future<void> _toggleCam() async {
    _camOn = !_camOn;
    await _room?.localParticipant?.setCameraEnabled(_camOn);
    setState(() {});
  }

  Future<void> _toggleSpeaker() async {
    _speakerOn = !_speakerOn;
    try {
      await Hardware.instance.setSpeakerphoneOn(_speakerOn);
    } catch (_) {}
    setState(() {});
  }

  Future<void> _switchCamera() async {
    await _room?.localParticipant?.switchCamera();
  }

  Future<void> _leave() async {
    await _room?.disconnect();
    if (mounted) Navigator.pop(context);
  }

  // ── Video widgets ──────────────────────────────────────────────────────────

  Widget _buildLocalVideo() {
    final local = _room?.localParticipant;
    if (!_camOn || local == null) {
      return _buildAvatar(widget.userName, seed: widget.userId.hashCode);
    }
    return ParticipantWidget.widgetFor(local);
  }

  Widget _buildRemoteVideo(RemoteParticipant p) {
    final hasVideo = p.videoTrackPublications.values
        .any((pub) => pub.track is VideoTrack);
    if (!hasVideo) {
      return _buildAvatar(p.name ?? p.identity, seed: p.identity.hashCode);
    }
    return ParticipantWidget.widgetFor(p);
  }

  Widget _buildAvatar(String name, {int seed = 0}) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final palette = [
      [const Color(0xFF6A1B9A), const Color(0xFF1565C0)],
      [const Color(0xFFB71C1C), const Color(0xFF880E4F)],
      [const Color(0xFF1B5E20), const Color(0xFF1565C0)],
      [const Color(0xFFE65100), const Color(0xFFB71C1C)],
    ];
    final idx = seed.abs() % palette.length;
    return Container(
      color: const Color(0xFF1A1529),
      child: Center(
        child: Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: palette[idx],
            ),
          ),
          child: Center(
            child: Text(initial, style: GoogleFonts.poppins(
              color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
          ),
        ),
      ),
    );
  }

  // ── Layout ─────────────────────────────────────────────────────────────────

  Widget _buildVideoGrid() {
    final total = 1 + _remoteParticipants.length;

    if (total == 1) {
      return Positioned.fill(child: _buildLocalVideo());
    }

    if (total == 2) {
      return Stack(children: [
        Positioned.fill(child: _buildRemoteVideo(_remoteParticipants.first)),
        Positioned(
          top: 80, right: 12, width: 100, height: 140,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _buildLocalVideo(),
          ),
        ),
      ]);
    }

    final crossCount = total <= 4 ? 2 : 3;
    final allWidgets = <Widget>[
      // Local first
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(fit: StackFit.expand, children: [
          _buildLocalVideo(),
          Positioned(
            bottom: 6, left: 6,
            child: _nameTag(widget.userName, isLocal: true),
          ),
        ]),
      ),
      // Remotes
      ..._remoteParticipants.map((p) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(fit: StackFit.expand, children: [
          _buildRemoteVideo(p),
          Positioned(
            bottom: 6, left: 6,
            child: _nameTag(p.name ?? p.identity),
          ),
        ]),
      )),
    ];

    return Positioned.fill(
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(4, 60, 4, 90),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossCount,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: 3 / 4,
        ),
        itemCount: allWidgets.length,
        itemBuilder: (_, i) => allWidgets[i],
      ),
    );
  }

  Widget _nameTag(String name, {bool isLocal = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isLocal ? '$name (moi)' : name,
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 10),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _loading
            ? _buildLoading()
            : _error != null
                ? _buildErrorScreen()
                : _buildCall(),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const CircularProgressIndicator(color: AppColors.primary),
        const SizedBox(height: 16),
        Text('Connexion à la réunion...',
            style: GoogleFonts.poppins(color: Colors.white70)),
      ]),
    );
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 56),
          const SizedBox(height: 16),
          Text(_error!,
              style: GoogleFonts.poppins(
                  color: Colors.white, fontSize: 14, height: 1.6),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('Retour',
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              setState(() { _loading = true; _error = null; });
              _init();
            },
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text('Réessayer',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white12,
                foregroundColor: Colors.white),
          ),
        ]),
      ),
    );
  }

  Widget _buildCall() {
    final total = 1 + _remoteParticipants.length;
    return Stack(children: [
      _buildVideoGrid(),

      // Top bar
      Positioned(
        top: 0, left: 0, right: 0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Colors.black87, Colors.transparent],
            ),
          ),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.meetingName,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
                Row(children: [
                  Text(
                    '${widget.meetingId} • $total participant${total > 1 ? 's' : ''}',
                    style: GoogleFonts.poppins(color: Colors.white60, fontSize: 11)),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('LiveKit',
                        style: GoogleFonts.poppins(
                            color: Colors.greenAccent,
                            fontSize: 9,
                            fontWeight: FontWeight.w600)),
                  ),
                ]),
              ]),
            ),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: widget.meetingId));
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ID copié'), duration: Duration(seconds: 2)));
              },
              child: const Icon(Icons.copy_rounded, color: Colors.white54, size: 18),
            ),
          ]),
        ),
      ),

      // Bottom controls
      Positioned(
        bottom: 0, left: 0, right: 0,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter, end: Alignment.topCenter,
              colors: [Colors.black87, Colors.transparent],
            ),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _ControlBtn(
              icon: _micOn ? Icons.mic_rounded : Icons.mic_off_rounded,
              label: _micOn ? 'Micro' : 'Muet',
              active: _micOn,
              onTap: _toggleMic,
            ),
            _ControlBtn(
              icon: _camOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
              label: _camOn ? 'Caméra' : 'Off',
              active: _camOn,
              onTap: _toggleCam,
            ),
            _ControlBtn(
              icon: Icons.flip_camera_android_rounded,
              label: 'Retourner',
              active: true,
              onTap: _switchCamera,
            ),
            _ControlBtn(
              icon: _speakerOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              label: _speakerOn ? 'HP' : 'HP off',
              active: _speakerOn,
              onTap: _toggleSpeaker,
            ),
            GestureDetector(
              onTap: _leave,
              child: Container(
                width: 56, height: 56,
                decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle),
                child: const Icon(Icons.call_end_rounded,
                    color: Colors.white, size: 28),
              ),
            ),
          ]),
        ),
      ),
    ]);
  }
}

// ── Participant video widget ────────────────────────────────────────────────

class ParticipantWidget extends StatelessWidget {
  final Participant participant;
  const ParticipantWidget._({required this.participant});

  static Widget widgetFor(Participant participant) =>
      ParticipantWidget._(participant: participant);

  VideoTrack? get _videoTrack {
    for (final pub in participant.videoTrackPublications.values) {
      final track = pub.track;
      if (track is VideoTrack) return track;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final track = _videoTrack;
    if (track == null) return const SizedBox.shrink();
    return VideoTrackRenderer(track);
  }
}

// ── Control button ─────────────────────────────────────────────────────────

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ControlBtn({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: active
                ? Colors.white.withOpacity(0.15)
                : Colors.red.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(icon,
              color: active ? Colors.white : Colors.red, size: 22),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: GoogleFonts.poppins(color: Colors.white60, fontSize: 9)),
      ]),
    );
  }
}
