import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

/// Advanced Meeting Control Service
/// Includes gallery view, waiting room, hand raising, breakout rooms
class AdvancedMeetingControlService {
  static final AdvancedMeetingControlService _instance = 
      AdvancedMeetingControlService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _log = Logger();

  factory AdvancedMeetingControlService() => _instance;
  AdvancedMeetingControlService._internal();

  // ═════════════════════════════════════════════════════════════════════════
  // WAITING ROOM MANAGEMENT
  // ═════════════════════════════════════════════════════════════════════════

  /// Add participant to waiting room
  Future<void> addToWaitingRoom({
    required String meetingId,
    required String userId,
    required String userName,
    String? userEmail,
    String? userPhotoUrl,
  }) async {
    try {
      await _firestore.collection('meetings').doc(meetingId)
          .collection('waiting_room').doc(userId).set({
        'userId': userId,
        'userName': userName,
        'userEmail': userEmail,
        'userPhotoUrl': userPhotoUrl,
        'joinedWaitingAt': FieldValue.serverTimestamp(),
      });
      _log.i('✅ Added to waiting room: $userName');
    } catch (e) {
      _log.e('addToWaitingRoom failed: $e');
    }
  }

  /// Approve participant from waiting room
  Future<void> approveFromWaitingRoom(String meetingId, String userId) async {
    try {
      await _firestore.collection('meetings').doc(meetingId)
          .collection('waiting_room').doc(userId).delete();
      
      await _firestore.collection('meetings').doc(meetingId)
          .collection('presence').doc(userId).set({
        'userId': userId,
        'approved': true,
        'approvedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _log.i('✅ Approved: $userId');
    } catch (e) {
      _log.e('approveFromWaitingRoom failed: $e');
    }
  }

  /// Reject participant from waiting room
  Future<void> rejectFromWaitingRoom(String meetingId, String userId) async {
    try {
      await _firestore.collection('meetings').doc(meetingId)
          .collection('waiting_room').doc(userId).delete();
      _log.i('✅ Rejected: $userId');
    } catch (e) {
      _log.e('rejectFromWaitingRoom failed: $e');
    }
  }

  /// Stream waiting room queue
  Stream<List<WaitingRoomParticipant>> streamWaitingRoom(String meetingId) {
    return _firestore.collection('meetings').doc(meetingId)
        .collection('waiting_room')
        .orderBy('joinedWaitingAt')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) {
              final data = d.data();
              return WaitingRoomParticipant(
                userId: data['userId'],
                userName: data['userName'],
                userEmail: data['userEmail'],
                userPhotoUrl: data['userPhotoUrl'],
              );
            })
            .toList());
  }

  // ═════════════════════════════════════════════════════════════════════════
  // HAND RAISING & ENGAGEMENT
  // ═════════════════════════════════════════════════════════════════════════

  /// Raise hand (request to speak)
  Future<void> raiseHand(String meetingId, String userId) async {
    try {
      await _firestore.collection('meetings').doc(meetingId)
          .collection('presence').doc(userId).update({
        'handRaised': true,
        'handRaisedAt': FieldValue.serverTimestamp(),
      });
      _log.i('✅ Hand raised: $userId');
    } catch (e) {
      _log.e('raiseHand failed: $e');
    }
  }

  /// Lower hand
  Future<void> lowerHand(String meetingId, String userId) async {
    try {
      await _firestore.collection('meetings').doc(meetingId)
          .collection('presence').doc(userId).update({
        'handRaised': false,
      });
      _log.i('✅ Hand lowered: $userId');
    } catch (e) {
      _log.e('lowerHand failed: $e');
    }
  }

  /// Stream hand raise notifications
  Stream<List<Map<String, dynamic>>> streamHandRaisedQueue(String meetingId) {
    return _firestore.collection('meetings').doc(meetingId)
        .collection('presence')
        .where('handRaised', isEqualTo: true)
        .orderBy('handRaisedAt')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => {...d.data(), 'id': d.id})
            .toList());
  }

  // ═════════════════════════════════════════════════════════════════════════
  // GALLERY VIEW LAYOUT
  // ═════════════════════════════════════════════════════════════════════════

  /// Set meeting layout
  Future<void> setMeetingLayout(String meetingId, MeetingLayout layout) async {
    try {
      await _firestore.collection('meetings').doc(meetingId).update({
        'layout': layout.name,
        'layoutChangedAt': FieldValue.serverTimestamp(),
      });
      _log.i('✅ Layout changed: ${layout.name}');
    } catch (e) {
      _log.e('setMeetingLayout failed: $e');
    }
  }

  /// Spotlight participant (pin to all screens)
  Future<void> spotlightParticipant(String meetingId, String userId) async {
    try {
      await _firestore.collection('meetings').doc(meetingId).update({
        'spotlightUserId': userId,
        'spotlightChangedAt': FieldValue.serverTimestamp(),
      });
      _log.i('✅ Spotlight on: $userId');
    } catch (e) {
      _log.e('spotlightParticipant failed: $e');
    }
  }

  /// Remove spotlight
  Future<void> removeSpotlight(String meetingId) async {
    try {
      await _firestore.collection('meetings').doc(meetingId).update({
        'spotlightUserId': null,
      });
      _log.i('✅ Spotlight removed');
    } catch (e) {
      _log.e('removeSpotlight failed: $e');
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // BREAKOUT ROOMS
  // ═════════════════════════════════════════════════════════════════════════

  /// Create breakout room
  Future<String?> createBreakoutRoom({
    required String meetingId,
    required String roomName,
    required int maxParticipants,
  }) async {
    try {
      final docRef = await _firestore.collection('meetings').doc(meetingId)
          .collection('breakout_rooms').add({
        'name': roomName,
        'maxParticipants': maxParticipants,
        'participantCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'open',
      });

      _log.i('✅ Breakout room created: $roomName');
      return docRef.id;
    } catch (e) {
      _log.e('createBreakoutRoom failed: $e');
      return null;
    }
  }

  /// Assign participant to breakout room
  Future<void> assignToBreakoutRoom({
    required String meetingId,
    required String roomId,
    required String userId,
  }) async {
    try {
      // Add to room
      await _firestore.collection('meetings').doc(meetingId)
          .collection('breakout_rooms').doc(roomId)
          .collection('participants').doc(userId).set({
        'userId': userId,
        'joinedAt': FieldValue.serverTimestamp(),
      });

      // Increment room count
      await _firestore.collection('meetings').doc(meetingId)
          .collection('breakout_rooms').doc(roomId).update({
        'participantCount': FieldValue.increment(1),
      });

      _log.i('✅ Assigned to breakout room: $userId');
    } catch (e) {
      _log.e('assignToBreakoutRoom failed: $e');
    }
  }

  /// Get breakout rooms
  Stream<List<BreakoutRoom>> streamBreakoutRooms(String meetingId) {
    return _firestore.collection('meetings').doc(meetingId)
        .collection('breakout_rooms')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) {
              final data = d.data();
              return BreakoutRoom(
                id: d.id,
                name: data['name'],
                maxParticipants: data['maxParticipants'],
                participantCount: data['participantCount'] ?? 0,
                status: data['status'] ?? 'open',
              );
            })
            .toList());
  }

  /// Close breakout room
  Future<void> closeBreakoutRoom(String meetingId, String roomId) async {
    try {
      await _firestore.collection('meetings').doc(meetingId)
          .collection('breakout_rooms').doc(roomId).update({
        'status': 'closed',
        'closedAt': FieldValue.serverTimestamp(),
      });
      _log.i('✅ Breakout room closed: $roomId');
    } catch (e) {
      _log.e('closeBreakoutRoom failed: $e');
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // VIRTUAL BACKGROUNDS
  // ═════════════════════════════════════════════════════════════════════════

  /// Enable virtual background for participant
  Future<void> enableVirtualBackground({
    required String meetingId,
    required String userId,
    required String backgroundType, // 'blur', 'image_url', 'color'
    String? backgroundValue,
  }) async {
    try {
      await _firestore.collection('meetings').doc(meetingId)
          .collection('presence').doc(userId).update({
        'virtualBackground': {
          'type': backgroundType,
          'value': backgroundValue,
          'enabled': true,
        },
      });
      _log.i('✅ Virtual background enabled for: $userId');
    } catch (e) {
      _log.e('enableVirtualBackground failed: $e');
    }
  }

  /// Disable virtual background
  Future<void> disableVirtualBackground(String meetingId, String userId) async {
    try {
      await _firestore.collection('meetings').doc(meetingId)
          .collection('presence').doc(userId).update({
        'virtualBackground': {'enabled': false},
      });
      _log.i('✅ Virtual background disabled for: $userId');
    } catch (e) {
      _log.e('disableVirtualBackground failed: $e');
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // REACTIONS & EMOJIS
  // ═════════════════════════════════════════════════════════════════════════

  /// Send reaction emoji
  Future<void> sendReaction({
    required String meetingId,
    required String userId,
    required String emoji, // '👍', '👏', '❤️', '😂', etc.
  }) async {
    try {
      await _firestore.collection('meetings').doc(meetingId)
          .collection('reactions').add({
        'userId': userId,
        'emoji': emoji,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _log.i('✅ Reaction sent: $emoji');
    } catch (e) {
      _log.e('sendReaction failed: $e');
    }
  }

  /// Stream reactions
  Stream<List<Reaction>> streamReactions(String meetingId) {
    return _firestore.collection('meetings').doc(meetingId)
        .collection('reactions')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) {
              final data = d.data();
              return Reaction(
                userId: data['userId'],
                emoji: data['emoji'],
              );
            })
            .toList());
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// MODELS
// ═════════════════════════════════════════════════════════════════════════════

class WaitingRoomParticipant {
  final String userId;
  final String userName;
  final String? userEmail;
  final String? userPhotoUrl;

  WaitingRoomParticipant({
    required this.userId,
    required this.userName,
    this.userEmail,
    this.userPhotoUrl,
  });
}

class BreakoutRoom {
  final String id;
  final String name;
  final int maxParticipants;
  final int participantCount;
  final String status;

  BreakoutRoom({
    required this.id,
    required this.name,
    required this.maxParticipants,
    required this.participantCount,
    required this.status,
  });

  bool get isFull => participantCount >= maxParticipants;
}

class Reaction {
  final String userId;
  final String emoji;

  Reaction({required this.userId, required this.emoji});
}

enum MeetingLayout {
  gallery,    // Show all participants in grid
  speaker,    // Large speaker + small gallery
  focus,      // Only speaker, no gallery
  presentation, // Fullscreen screen share + speaker
  custom,     // User-defined layout
}
