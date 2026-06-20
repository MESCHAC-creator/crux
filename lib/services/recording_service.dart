import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

/// Service pour enregistrer les réunions
/// Enregistrement local sur device + upload vers Firebase Storage
class RecordingService {
  static final RecordingService _instance = RecordingService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _log = Logger();

  bool _isRecording = false;
  String? _recordingPath;
  DateTime? _recordingStartTime;

  factory RecordingService() => _instance;
  RecordingService._internal();

  /// Démarrer l'enregistrement d'une réunion
  Future<bool> startRecording(String meetingId) async {
    try {
      if (_isRecording) {
        _log.w('Recording already active');
        return false;
      }

      // Obtenir le répertoire temporaire
      final tempDir = await getTemporaryDirectory();
      final fileName = '${meetingId}_${DateTime.now().millisecondsSinceEpoch}.mp4';
      _recordingPath = '${tempDir.path}/$fileName';

      _isRecording = true;
      _recordingStartTime = DateTime.now();

      // Enregistrer l'état dans Firestore
      await _firestore.collection('meetings').doc(meetingId).update({
        'isRecording': true,
        'recordingStartedAt': FieldValue.serverTimestamp(),
      });

      _log.i('✅ Enregistrement démarré: $_recordingPath');
      return true;
    } catch (e) {
      _log.e('startRecording failed: $e');
      return false;
    }
  }

  /// Arrêter l'enregistrement et uploader
  Future<String?> stopRecording(String meetingId) async {
    try {
      if (!_isRecording || _recordingPath == null) {
        _log.w('No active recording');
        return null;
      }

      _isRecording = false;
      final duration = DateTime.now().difference(_recordingStartTime ?? DateTime.now());

      // Mettre à jour Firestore
      await _firestore.collection('meetings').doc(meetingId).update({
        'isRecording': false,
        'recordingEndedAt': FieldValue.serverTimestamp(),
        'recordingDuration': duration.inSeconds,
      });

      // Upload vers Firebase Storage
      final downloadUrl = await _uploadRecording(meetingId, _recordingPath!);
      
      // Enregistrer le lien dans Firestore
      if (downloadUrl != null) {
        await _firestore.collection('meetings').doc(meetingId)
            .collection('recordings').add({
          'url': downloadUrl,
          'fileName': _recordingPath!.split('/').last,
          'uploadedAt': FieldValue.serverTimestamp(),
          'duration': duration.inSeconds,
          'size': await File(_recordingPath!).length(),
        });
      }

      _log.i('✅ Enregistrement arrêté et uploadé');
      return downloadUrl;
    } catch (e) {
      _log.e('stopRecording failed: $e');
      return null;
    }
  }

  /// Uploader le fichier vers Firebase Storage
  Future<String?> _uploadRecording(String meetingId, String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        _log.w('Recording file not found: $filePath');
        return null;
      }

      final fileName = filePath.split('/').last;
      final ref = _storage.ref().child('recordings/$meetingId/$fileName');

      // Uploader avec progress tracking
      final uploadTask = ref.putFile(file);
      
      uploadTask.snapshotEvents.listen((event) {
        final progress = (event.bytesTransferred / event.totalBytes) * 100;
        _log.i('Upload progress: ${progress.toStringAsFixed(2)}%');
      });

      await uploadTask;
      final downloadUrl = await ref.getDownloadURL();
      
      _log.i('✅ Fichier uploadé: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      _log.e('_uploadRecording failed: $e');
      return null;
    }
  }

  /// Récupérer les enregistrements d'une réunion
  Stream<List<Map<String, dynamic>>> getRecordings(String meetingId) {
    return _firestore.collection('meetings').doc(meetingId)
        .collection('recordings')
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  /// Supprimer un enregistrement
  Future<void> deleteRecording(String meetingId, String fileName) async {
    try {
      final ref = _storage.ref().child('recordings/$meetingId/$fileName');
      await ref.delete();
      _log.i('✅ Enregistrement supprimé: $fileName');
    } catch (e) {
      _log.e('deleteRecording failed: $e');
    }
  }

  bool get isRecording => _isRecording;
  String? get recordingPath => _recordingPath;
  Duration get recordingDuration =>
      DateTime.now().difference(_recordingStartTime ?? DateTime.now());
}
