import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

/// Service pour gérer le chat en réunion
/// Stocke les messages dans Firestore: meetings/{meetingId}/chat/{messageId}
class ChatService {
  static final ChatService _instance = ChatService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _log = Logger();

  factory ChatService() => _instance;
  ChatService._internal();

  /// Envoyer un message de chat
  Future<void> sendMessage({
    required String meetingId,
    required String userId,
    required String userName,
    required String message,
    String? userAvatar,
  }) async {
    try {
      await _firestore.collection('meetings').doc(meetingId)
          .collection('chat').add({
        'userId': userId,
        'userName': userName,
        'userAvatar': userAvatar,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'isDeleted': false,
      });
      _log.i('✅ Message envoyé: $message');
    } catch (e) {
      _log.e('sendMessage failed: $e');
      throw Exception('chat_send_failed');
    }
  }

  /// Stream des messages en temps réel (lecture seule après 5 min)
  Stream<List<Map<String, dynamic>>> streamChatMessages(String meetingId) {
    return _firestore.collection('meetings').doc(meetingId)
        .collection('chat')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => {...d.data(), 'id': d.id})
            .toList());
  }

  /// Supprimer un message (soft delete)
  Future<void> deleteMessage(String meetingId, String messageId, String userId) async {
    try {
      final msg = await _firestore.collection('meetings').doc(meetingId)
          .collection('chat').doc(messageId).get();
      
      // Vérifier que c'est l'auteur
      if (msg.data()?['userId'] != userId) {
        throw Exception('unauthorized');
      }

      await msg.reference.update({'isDeleted': true, 'message': '[Message supprimé]'});
      _log.i('✅ Message supprimé: $messageId');
    } catch (e) {
      _log.e('deleteMessage failed: $e');
    }
  }

  /// Rechercher messages par keyword
  Future<List<Map<String, dynamic>>> searchMessages(String meetingId, String keyword) async {
    try {
      final snap = await _firestore.collection('meetings').doc(meetingId)
          .collection('chat')
          .get();
      
      return snap.docs
          .where((d) => d['message'].toString().toLowerCase().contains(keyword.toLowerCase()))
          .map((d) => {...d.data(), 'id': d.id})
          .toList();
    } catch (e) {
      _log.e('searchMessages failed: $e');
      return [];
    }
  }
}
