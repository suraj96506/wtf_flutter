import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared/models/message.dart';
import 'package:shared/models/user.dart';
import 'package:shared/models/conversation_summary.dart';
import 'package:shared/services/chat_service.dart';

/// Firestore-backed chat service with local persistence (Firestore offline).
class FirebaseChatService implements ChatService {
  FirebaseChatService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _conv =>
      _firestore.collection('conversations');

  @override
  Future<void> sendMessage(Message message) async {
    final convoRef = _conv.doc(message.chatId);
    final msgRef = convoRef.collection('messages').doc(message.id);
    final now = message.createdAt;

    await _firestore.runTransaction((txn) async {
      txn.set(msgRef, {
        'id': message.id,
        'chatId': message.chatId,
        'senderId': message.senderId,
        'receiverId': message.receiverId,
        'text': message.text,
        'createdAt': now.toIso8601String(),
        'status': 'sent',
      });
      txn.set(convoRef, {
        'lastMessage': message.text,
        'lastTime': now.toIso8601String(),
        'participants': [message.senderId, message.receiverId],
      }, SetOptions(merge: true));
      txn.update(convoRef, {
        'unread.${message.receiverId}': FieldValue.increment(1),
      });
    });
  }

  @override
  Stream<List<Message>> getMessages(String chatId) {
    return _conv
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data();
        return Message(
          id: data['id'] as String,
          chatId: data['chatId'] as String,
          senderId: data['senderId'] as String,
          receiverId: data['receiverId'] as String,
          text: data['text'] as String? ?? '',
          createdAt: DateTime.parse(data['createdAt'] as String),
          status: _statusFromString(data['status'] as String? ?? 'sent'),
        );
      }).toList();
    });
  }

  @override
  Stream<bool> getTypingStatus(String chatId) {
    return _conv
        .doc(chatId)
        .snapshots()
        .map((doc) => (doc.data()?['typing'] as bool?) ?? false);
  }

  @override
  Future<void> simulateTyping(String chatId, bool isTyping, {String? userId}) async {
    await _conv.doc(chatId).set({'typing': isTyping}, SetOptions(merge: true));
  }

  @override
  Future<void> markMessagesAsRead(String chatId, List<String> messageIds) async {
    final convoRef = _conv.doc(chatId);
    final batch = _firestore.batch();
    for (final id in messageIds) {
      final msgRef = convoRef.collection('messages').doc(id);
      batch.update(msgRef, {'status': 'read'});
    }
    batch.update(convoRef, {'unread': FieldValue.delete()});
    await batch.commit();
  }

  @override
  Stream<List<User>> getConversations(String currentUserId) {
    return getConversationSummaries(currentUserId)
        .map((list) => list.map((s) => s.otherUser).toList());
  }

  /// Rich summaries for UI: last message, time, unread.
  Stream<List<ConversationSummary>> getConversationSummaries(String currentUserId) {
    return _conv
        .where('participants', arrayContains: currentUserId)
        .snapshots()
        .map((snap) {
      return snap.docs.map<ConversationSummary>((doc) {
        final data = doc.data();
        final otherId =
            (data['participants'] as List<dynamic>).cast<String>().firstWhere((id) => id != currentUserId, orElse: () => '');
        return ConversationSummary(
          chatId: doc.id,
          otherUser: User(
            id: otherId.isEmpty ? 'unknown' : otherId,
            role: otherId == 'aarav_trainer_id' ? 'trainer' : 'member',
            name: otherId == 'aarav_trainer_id'
                ? 'Aarav (Lead Trainer)'
                : (otherId.isEmpty ? 'Unknown' : 'DK'),
            email: otherId == 'aarav_trainer_id'
                ? 'aarav@example.com'
                : (otherId.isEmpty ? '' : 'dk@example.com'),
          ),
          lastMessage: data['lastMessage'] as String? ?? '',
          lastTime: data['lastTime'] != null
              ? DateTime.tryParse(data['lastTime'] as String) ?? DateTime.now()
              : DateTime.now(),
          unread: (data['unread'] as Map<String, dynamic>?)?[currentUserId] as int? ?? 0,
        );
      }).toList();
    });
  }

  MessageStatus _statusFromString(String status) {
    switch (status) {
      case 'read':
        return MessageStatus.read;
      case 'sent':
        return MessageStatus.sent;
      default:
        return MessageStatus.sending;
    }
  }

  @override
  void dispose() {}
}
