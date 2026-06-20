import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

/// Service pour gérer les contrôles des participants
/// Fonctionnalités: mute/unmute, kick, promote co-host, waiting room
class ParticipantManagementService {
  static final ParticipantManagementService _instance = 
      ParticipantManagementService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _log = Logger();

  factory ParticipantManagementService() => _instance;
  ParticipantManagementService._internal();

  /// Mute/Unmute un participant
  Future<void> setParticipantMute(
    String meetingId,
    String participantId,
    bool muted,
  ) async {
    try {
      await _firestore.collection('meetings').doc(meetingId)
          .collection('presence').doc(participantId).update({
        'micOn': !muted,
      });
      _log.i('✅ Participant ${muted ? 'muted' : 'unmuted'}: $participantId');
    } catch (e) {
      _log.e('setParticipantMute failed: $e');
    }
  }

  /// Mute tous les participants sauf l'host
  Future<void> muteAllParticipants(String meetingId, String hostId) async {
    try {
      final presenceSnap = await _firestore.collection('meetings').doc(meetingId)
          .collection('presence').get();

      for (final doc in presenceSnap.docs) {
        if (doc.id != hostId) {
          await doc.reference.update({'micOn': false});
        }
      }

      // Signaler à Firestore que "mute all" a été déclenché
      await _firestore.collection('meetings').doc(meetingId).update({
        'muteAllCount': FieldValue.increment(1),
      });

      _log.i('✅ Tous les participants ont été muets');
    } catch (e) {
      _log.e('muteAllParticipants failed: $e');
    }
  }

  /// Retirer un participant de la réunion
  Future<void> removeParticipant(String meetingId, String participantId) async {
    try {
      await _firestore.collection('meetings').doc(meetingId)
          .collection('presence').doc(participantId).delete();

      await _firestore.collection('meetings').doc(meetingId).update({
        'participants': FieldValue.arrayRemove([participantId]),
      });

      _log.i('✅ Participant retiré: $participantId');
    } catch (e) {
      _log.e('removeParticipant failed: $e');
    }
  }

  /// Promouvoir un participant en co-host
  Future<void> promoteToCoHost(String meetingId, String participantId) async {
    try {
      await _firestore.collection('meetings').doc(meetingId).update({
        'coHosts': FieldValue.arrayUnion([participantId]),
      });

      await _firestore.collection('meetings').doc(meetingId)
          .collection('presence').doc(participantId).update({
        'isCoHost': true,
      });

      _log.i('✅ Participant promu en co-host: $participantId');
    } catch (e) {
      _log.e('promoteToCoHost failed: $e');
    }
  }

  /// Rétrograder un co-host
  Future<void> demoteCoHost(String meetingId, String participantId) async {
    try {
      await _firestore.collection('meetings').doc(meetingId).update({
        'coHosts': FieldValue.arrayRemove([participantId]),
      });

      await _firestore.collection('meetings').doc(meetingId)
          .collection('presence').doc(participantId).update({
        'isCoHost': false,
      });

      _log.i('✅ Co-host rétrogradé: $participantId');
    } catch (e) {
      _log.e('demoteCoHost failed: $e');
    }
  }

  /// Activer/Désactiver la caméra d'un participant
  Future<void> setParticipantCamera(
    String meetingId,
    String participantId,
    bool cameraOn,
  ) async {
    try {
      await _firestore.collection('meetings').doc(meetingId)
          .collection('presence').doc(participantId).update({
        'camOn': cameraOn,
      });
      _log.i('✅ Caméra ${cameraOn ? 'activée' : 'désactivée'} pour: $participantId');
    } catch (e) {
      _log.e('setParticipantCamera failed: $e');
    }
  }

  /// Verrouiller la réunion (pas de nouveaux participants)
  Future<void> lockMeeting(String meetingId, bool locked) async {
    try {
      await _firestore.collection('meetings').doc(meetingId).update({
        'isLocked': locked,
      });
      _log.i('✅ Réunion ${locked ? 'verrouillée' : 'déverrouillée'}');
    } catch (e) {
      _log.e('lockMeeting failed: $e');
    }
  }

  /// Ajouter un participant à la salle d'attente (waiting room)
  Future<void> addToWaitingRoom(
    String meetingId,
    String userId,
    String userName,
    String? userEmail,
  ) async {
    try {
      await _firestore.collection('meetings').doc(meetingId)
          .collection('waiting_room').doc(userId).set({
        'userId': userId,
        'userName': userName,
        'userEmail': userEmail,
        'joinedWaitingAt': FieldValue.serverTimestamp(),
      });

      _log.i('✅ Participant ajouté à la salle d\'attente: $userName');
    } catch (e) {
      _log.e('addToWaitingRoom failed: $e');
    }
  }

  /// Approuver un participant dans la salle d'attente
  Future<void> approveFromWaitingRoom(String meetingId, String userId) async {
    try {
      await _firestore.collection('meetings').doc(meetingId)
          .collection('waiting_room').doc(userId).delete();

      _log.i('✅ Participant approuvé: $userId');
    } catch (e) {
      _log.e('approveFromWaitingRoom failed: $e');
    }
  }

  /// Rejeter un participant de la salle d'attente
  Future<void> rejectFromWaitingRoom(String meetingId, String userId) async {
    try {
      await _firestore.collection('meetings').doc(meetingId)
          .collection('waiting_room').doc(userId).delete();

      _log.i('✅ Participant rejeté: $userId');
    } catch (e) {
      _log.e('rejectFromWaitingRoom failed: $e');
    }
  }

  /// Stream de la salle d'attente
  Stream<List<Map<String, dynamic>>> streamWaitingRoom(String meetingId) {
    return _firestore.collection('meetings').doc(meetingId)
        .collection('waiting_room')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => {...d.data(), 'id': d.id})
            .toList());
  }

  /// Stream de tous les participants
  Stream<List<Map<String, dynamic>>> streamParticipants(String meetingId) {
    return _firestore.collection('meetings').doc(meetingId)
        .collection('presence')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => {...d.data(), 'id': d.id})
            .toList());
  }
}
