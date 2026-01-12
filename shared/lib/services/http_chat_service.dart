import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared/models/message.dart';
import 'package:shared/models/user.dart';
import 'package:shared/services/chat_service.dart';

/// Simple HTTP-based chat service for local LAN / emulator.
/// Expects the chat server to be running in `token_server/chat_server.dart`.
class HttpChatService implements ChatService {
  HttpChatService({String? baseUrl})
      : _baseUrl = baseUrl ??
            (Platform.isAndroid ? 'http://10.0.2.2:8081' : 'http://localhost:8081');

  final String _baseUrl;
  final http.Client _client = http.Client();

  final Map<String, StreamController<List<Message>>> _messageControllers = {};
  final Map<String, Timer> _messageTimers = {};

  final Map<String, StreamController<bool>> _typingControllers = {};
  final Map<String, Timer> _typingTimers = {};
  final Map<String, String?> _typingUsers = {};

  StreamController<List<User>>? _conversationController;
  Timer? _conversationTimer;

  // Static user directory to enrich conversation list.
  static final Map<String, User> _knownUsers = {
    'dk_member_id': User(
      id: 'dk_member_id',
      role: 'member',
      name: 'DK',
      email: 'dk@example.com',
      avatarUrl: 'https://i.pravatar.cc/150?img=1',
      assignedTrainerId: 'aarav_trainer_id',
    ),
    'aarav_trainer_id': User(
      id: 'aarav_trainer_id',
      role: 'trainer',
      name: 'Aarav (Lead Trainer)',
      email: 'aarav@example.com',
      avatarUrl: 'https://i.pravatar.cc/150?img=2',
    ),
  };

  // --- ChatService API ---

  @override
  Stream<List<Message>> getMessages(String chatId) {
    _messageControllers.putIfAbsent(
        chatId, () => StreamController<List<Message>>.broadcast());

    // Emit immediately so UI doesn't hang on a spinner if the server is slow.
    _messageControllers[chatId]!.add(const []);

    _fetchMessages(chatId); // initial fetch
    _messageTimers[chatId]?.cancel();
    _messageTimers[chatId] = Timer.periodic(const Duration(milliseconds: 900), (_) {
      _fetchMessages(chatId);
    });

    return _messageControllers[chatId]!.stream;
  }

  @override
  Future<void> sendMessage(Message message) async {
    final uri = Uri.parse('$_baseUrl/messages');
    await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': message.id,
        'chatId': message.chatId,
        'senderId': message.senderId,
        'receiverId': message.receiverId,
        'text': message.text,
        'createdAt': message.createdAt.toIso8601String(),
      }),
    );
  }

  @override
  Stream<bool> getTypingStatus(String chatId) {
    _typingControllers.putIfAbsent(chatId, () => StreamController<bool>.broadcast());
    _fetchTyping(chatId); // initial

    _typingTimers[chatId]?.cancel();
    _typingTimers[chatId] =
        Timer.periodic(const Duration(milliseconds: 750), (_) => _fetchTyping(chatId));

    return _typingControllers[chatId]!.stream;
  }

  /// Typing stream that filters out the current user.
  Stream<bool> getTypingStatusFor(String chatId, String currentUserId) {
    _typingControllers.putIfAbsent(chatId, () => StreamController<bool>.broadcast());
    _fetchTyping(chatId); // initial

    _typingTimers[chatId]?.cancel();
    _typingTimers[chatId] =
        Timer.periodic(const Duration(milliseconds: 750), (_) => _fetchTyping(chatId));

    return _typingControllers[chatId]!.stream.map((isTyping) {
      // The controller emits true only when other user is typing.
      return _typingUsers[chatId] != null && _typingUsers[chatId] != currentUserId;
    });
  }

  @override
  Future<void> simulateTyping(String chatId, bool isTyping, {String? userId}) async {
    final uri = Uri.parse('$_baseUrl/typing');
    await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'chatId': chatId, 'isTyping': isTyping, 'userId': userId}),
    );
  }

  @override
  Future<void> markMessagesAsRead(String chatId, List<String> messageIds) async {
    final uri = Uri.parse('$_baseUrl/read');
    await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'chatId': chatId, 'messageIds': messageIds}),
    );
  }

  @override
  Stream<List<User>> getConversations(String currentUserId) {
    _conversationController ??= StreamController<List<User>>.broadcast();
    // Emit a seed conversation immediately so UI isn't empty if server is down.
    _conversationController!.add(_seedConversationsForUser(currentUserId));
    _fetchConversations(currentUserId);
    _conversationTimer?.cancel();
    _conversationTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => _fetchConversations(currentUserId));
    return _conversationController!.stream;
  }

  // --- Internals ---

  Future<void> _fetchMessages(String chatId) async {
    try {
      final uri = Uri.parse('$_baseUrl/messages?chatId=$chatId');
      final resp = await _client.get(uri);
      if (resp.statusCode == 200) {
        final List<dynamic> data = jsonDecode(resp.body) as List<dynamic>;
        final messages = data
            .map((e) => Message(
                  id: e['id'] as String,
                  chatId: e['chatId'] as String,
                  senderId: e['senderId'] as String,
                  receiverId: e['receiverId'] as String,
                  text: e['text'] as String,
                  createdAt: DateTime.parse(e['createdAt'] as String),
                  status: _statusFromString(e['status'] as String? ?? 'sent'),
                ))
            .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
        _messageControllers[chatId]?.add(messages);
      }
    } catch (_) {
      // swallow errors to avoid breaking stream; could log.
    }
  }

  Future<void> _fetchTyping(String chatId) async {
    try {
      final uri = Uri.parse('$_baseUrl/typing?chatId=$chatId');
      final resp = await _client.get(uri);
      if (resp.statusCode == 200) {
        final map = jsonDecode(resp.body) as Map<String, dynamic>;
        final isTyping = map['isTyping'] == true;
        final userId = map['userId'] as String?;
        _typingUsers[chatId] = userId;
        _typingControllers[chatId]?.add(isTyping);
      }
    } catch (_) {}
  }

  Future<void> _fetchConversations(String userId) async {
    try {
      final uri = Uri.parse('$_baseUrl/conversations?userId=$userId');
      final resp = await _client.get(uri);
      if (resp.statusCode == 200) {
        final List<dynamic> data = jsonDecode(resp.body) as List<dynamic>;
        final users = <User>[];
        for (final item in data) {
          final otherId = item['otherUserId'] as String;
          users.add(_knownUsers[otherId] ??
              User(
                id: otherId,
                role: item['role'] as String? ?? 'trainer',
                name: item['name'] as String? ?? otherId,
                email: item['email'] as String? ?? '',
              ));
        }
        if (users.isEmpty) {
          _conversationController?.add(_seedConversationsForUser(userId));
        } else {
          _conversationController?.add(users);
        }
      }
    } catch (_) {}
  }

  List<User> _seedConversationsForUser(String userId) {
    if (userId == 'dk_member_id') {
      return [_knownUsers['aarav_trainer_id']!];
    }
    if (userId == 'aarav_trainer_id') {
      return [_knownUsers['dk_member_id']!];
    }
    return [];
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
  void dispose() {
    for (final timer in _messageTimers.values) {
      timer.cancel();
    }
    for (final timer in _typingTimers.values) {
      timer.cancel();
    }
    _conversationTimer?.cancel();
    for (final controller in _messageControllers.values) {
      controller.close();
    }
    for (final controller in _typingControllers.values) {
      controller.close();
    }
    _conversationController?.close();
    _client.close();
  }
}
