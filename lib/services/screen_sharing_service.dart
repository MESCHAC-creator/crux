import 'dart:async';
import 'package:logger/logger.dart';

/// Service pour gérer le partage d'écran
/// Coordonne avec Agora/Jitsi pour capturer et broadcaster l'écran
class ScreenSharingService {
  static final ScreenSharingService _instance = ScreenSharingService._internal();
  final _log = Logger();

  StreamController<bool>? _screenShareStateController;
  bool _isScreenSharing = false;
  String? _currentScreenShareUserId;

  factory ScreenSharingService() => _instance;
  ScreenSharingService._internal();

  /// Démarrer le partage d'écran
  /// Retourne un Stream<bool> pour suivre l'état du partage
  Future<bool> startScreenShare(String meetingId, String userId, String userName) async {
    try {
      if (_isScreenSharing) {
        _log.w('Screen share already active');
        return false;
      }

      // Note: Implementation concrète dépend du SDK (Agora/Jitsi)
      // Agora: enableScreenCapture() + startScreenCapture()
      // Jitsi: startScreenShare()
      
      _isScreenSharing = true;
      _currentScreenShareUserId = userId;
      
      _screenShareStateController ??= StreamController<bool>.broadcast();
      _screenShareStateController!.add(true);

      _log.i('✅ Partage d\'écran démarré par $userName');
      return true;
    } catch (e) {
      _log.e('startScreenShare failed: $e');
      return false;
    }
  }

  /// Arrêter le partage d'écran
  Future<void> stopScreenShare() async {
    try {
      _isScreenSharing = false;
      _currentScreenShareUserId = null;
      _screenShareStateController?.add(false);
      _log.i('✅ Partage d\'écran arrêté');
    } catch (e) {
      _log.e('stopScreenShare failed: $e');
    }
  }

  /// Stream de l'état du partage d'écran
  Stream<bool> get screenShareStateStream =>
      _screenShareStateController?.stream ?? Stream.value(false);

  bool get isScreenSharing => _isScreenSharing;
  String? get screenShareUserId => _currentScreenShareUserId;

  void dispose() {
    _screenShareStateController?.close();
    _screenShareStateController = null;
  }
}
