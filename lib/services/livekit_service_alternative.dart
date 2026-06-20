import 'package:livekit_client/livekit_client.dart';
import 'package:logger/logger.dart';

/// LiveKit Integration Service (Alternative to Agora)
/// Use this if you want LiveKit instead of Agora + Jitsi hybrid
class LiveKitService {
  static final LiveKitService _instance = LiveKitService._internal();
  final _log = Logger();

  late Room _room;
  late EventsEmitter<RoomEvent> _events;

  factory LiveKitService() => _instance;
  LiveKitService._internal();

  /// Connect to LiveKit Server
  Future<bool> connect({
    required String url,           // e.g., wss://livekit.example.com
    required String token,         // JWT token from backend
    required String participantName,
  }) async {
    try {
      _room = Room();
      _events = _room.createEmitter();

      // Connect to LiveKit
      await _room.connect(
        url,
        token,
        RoomOptions(
          autoSubscribe: true,
          dynacast: true, // Adaptive bitrate
        ),
      );

      _log.i('✅ Connected to LiveKit: $url');
      return true;
    } catch (e) {
      _log.e('LiveKit connect failed: $e');
      return false;
    }
  }

  /// Publish local camera
  Future<LocalTrackPublication?> publishCamera() async {
    try {
      final videoTrack = await LocalVideoTrack.create(
        VideoTrackOptions(
          maxFramerate: 30,
          resolution: VideoParameters(
            width: 1920,
            height: 1080,
          ),
        ),
      );

      final audioTrack = await LocalAudioTrack.create();

      final videoPub = await _room.localParticipant?.publishTrack(videoTrack);
      await _room.localParticipant?.publishTrack(audioTrack);

      _log.i('✅ Camera published');
      return videoPub;
    } catch (e) {
      _log.e('publishCamera failed: $e');
      return null;
    }
  }

  /// Publish screen share
  Future<LocalTrackPublication?> publishScreenShare() async {
    try {
      final screenTrack = await LocalVideoTrack.createScreenShareTrack(
        ScreenShareCaptureOptions(
          maxFramerate: 15,
          resolution: VideoParameters(
            width: 1920,
            height: 1080,
          ),
        ),
      );

      final screenPub = await _room.localParticipant?.publishTrack(screenTrack);
      _log.i('✅ Screen share published');
      return screenPub;
    } catch (e) {
      _log.e('publishScreenShare failed: $e');
      return null;
    }
  }

  /// Get room event stream
  Stream<RoomEvent> get events => _events.stream;

  /// Get remote participants
  List<RemoteParticipant> get remoteParticipants => _room.remoteParticipants;

  /// Get local participant
  LocalParticipant? get localParticipant => _room.localParticipant;

  /// Get room state
  RoomState get state => _room.state;

  /// Mute local audio
  Future<void> muteAudio() async {
    try {
      final audioTrack = _room.localParticipant?.audioTrackPublications.firstOrNull;
      if (audioTrack != null) {
        await _room.localParticipant?.unpublishTrack(audioTrack.track!);
      }
    } catch (e) {
      _log.e('muteAudio failed: $e');
    }
  }

  /// Unmute local audio
  Future<void> unmuteAudio() async {
    try {
      final audioTrack = await LocalAudioTrack.create();
      await _room.localParticipant?.publishTrack(audioTrack);
    } catch (e) {
      _log.e('unmuteAudio failed: $e');
    }
  }

  /// Disconnect from LiveKit
  Future<void> disconnect() async {
    try {
      await _room.disconnect();
      _log.i('✅ Disconnected from LiveKit');
    } catch (e) {
      _log.e('disconnect failed: $e');
    }
  }
}

/// Generate LiveKit token (Backend)
/// 
/// Example using dart_jsonwebtoken:
/// 
/// String generateLiveKitToken({
///   required String apiKey,
///   required String apiSecret,
///   required String roomName,
///   required String participantName,
/// }) {
///   final now = DateTime.now();
///   final exp = now.add(Duration(hours: 24));
///
///   final claims = {
///     'iat': (now.millisecondsSinceEpoch / 1000).floor(),
///     'exp': (exp.millisecondsSinceEpoch / 1000).floor(),
///     'grants': {
///       'roomJoin': true,
///       'room': roomName,
///       'canPublish': true,
///       'canPublishData': true,
///       'canSubscribe': true,
///     },
///     'identity': participantName,
///   };
///
///   final key = SecretKey(apiSecret);
///   final token = JWT(claims).sign(key);
///   return 'Bearer $token';
/// }
