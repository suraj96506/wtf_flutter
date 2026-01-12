import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shared/models/message.dart';
import 'package:shared/models/user.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/services/chat_service.dart';

class MockChatService implements ChatService {
  final AuthService _authService;
  final Map<String, StreamController<List<Message>>> _messageControllers = {};
  final Map<String, StreamController<bool>> _typingControllers = {};
  static Directory? _tempDir;

  MockChatService(this._authService);

  void _ensureStorageDir() {
    if (_tempDir != null) return;
    final dir = Directory('${Directory.systemTemp.path}/wtf_mock_chat');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    _tempDir = dir;
  }

  File _getChatFile(String chatId) {
    _ensureStorageDir();
    return File('${_tempDir!.path}/$chatId.json');
  }

  @override
  Stream<List<Message>> getMessages(String chatId) {
    _ensureStorageDir();
    if (!_messageControllers.containsKey(chatId)) {
      _messageControllers[chatId] = StreamController<List<Message>>.broadcast();

      final chatFile = _getChatFile(chatId);
      if (!chatFile.existsSync()) {
        chatFile.createSync();
        chatFile.writeAsStringSync('[]');
      }

      chatFile.watch().listen((event) {
        final messages = _readMessagesFromFile(chatFile);
        _messageControllers[chatId]!.add(messages);
      });

      // Initial read
      final messages = _readMessagesFromFile(chatFile);
      _messageControllers[chatId]!.add(messages);
    }
    return _messageControllers[chatId]!.stream;
  }

  List<Message> _readMessagesFromFile(File chatFile) {
    final content = chatFile.readAsStringSync();
    if (content.isEmpty) return [];
    final List<dynamic> jsonList = jsonDecode(content);
    return jsonList.map((json) => Message.fromJson(json)).toList();
  }

  @override
  Future<void> sendMessage(Message message) async {
    _ensureStorageDir();
    final chatFile = _getChatFile(message.chatId);
    final messages = _readMessagesFromFile(chatFile);
    messages.add(message);
    _writeMessagesToFile(chatFile, messages);
  }

  void _writeMessagesToFile(File chatFile, List<Message> messages) {
    final jsonList = messages.map((m) => m.toJson()).toList();
    chatFile.writeAsStringSync(jsonEncode(jsonList));
  }

  @override
  Stream<List<User>> getConversations(String currentUserId) {
    // Immediate, single-emission stream so UI never stays on a spinner.
    final user = (_authService as dynamic).currentUserSync as User?;
    final List<User> conversations = [];
    if (user != null) {
      if (user.role == 'member') {
        conversations.add(User(
          id: 'aarav_trainer_id',
          role: 'trainer',
          name: 'Aarav (Lead Trainer)',
          email: 'aarav@example.com',
        ));
      } else if (user.role == 'trainer') {
        conversations.add(User(
          id: 'dk_member_id',
          role: 'member',
          name: 'DK',
          email: 'dk@example.com',
        ));
      }
    }
    return Stream<List<User>>.value(conversations);
  }

  // Typing status will not work across devices with this file-based approach without more complexity.
  // We'll leave the local implementation.
  @override
  Stream<bool> getTypingStatus(String chatId) {
    if (!_typingControllers.containsKey(chatId)) {
      _typingControllers[chatId] = StreamController<bool>.broadcast()..add(false);
    }
    return _typingControllers[chatId]!.stream;
  }

  @override
  Future<void> simulateTyping(String chatId, bool isTyping, {String? userId}) async {
    _typingControllers[chatId]?.add(isTyping);
  }
  
  @override
  Future<void> markMessagesAsRead(String chatId, List<String> messageIds) async {
    // This would also require more complex file handling to ensure atomicity
    // Leaving as a no-op for now.
  }

  @override
  void dispose() {
    for (var controller in _messageControllers.values) {
      controller.close();
    }
    for (var controller in _typingControllers.values) {
      controller.close();
    }
  }
}
