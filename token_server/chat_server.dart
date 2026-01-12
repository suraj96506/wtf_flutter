import 'dart:convert';
import 'dart:io';

/// Minimal in-memory chat server for local use (no persistence).
///
/// Start: `dart run token_server/chat_server.dart`
/// Emulator base URL: http://10.0.2.2:8081
/// Real device: use your LAN IP, e.g., http://192.168.x.x:8081
Future<void> main(List<String> args) async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 8081);
  // ignore: avoid_print
  print('Chat server running on port ${server.port}');

  final messagesByChat = <String, List<Map<String, dynamic>>>{};
  final typingByChat = <String, String?>{};

  await for (HttpRequest request in server) {
    // Basic CORS
    request.response.headers
      ..set('Access-Control-Allow-Origin', '*')
      ..set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
      ..set('Access-Control-Allow-Headers', 'Content-Type');

    if (request.method == 'OPTIONS') {
      await request.response.close();
      continue;
    }

    try {
      if (request.uri.path == '/messages' && request.method == 'GET') {
        final chatId = request.uri.queryParameters['chatId'];
        final list = messagesByChat[chatId] ?? [];
        _json(request, list);
      } else if (request.uri.path == '/messages' && request.method == 'POST') {
        final body = await utf8.decoder.bind(request).join();
        final data = jsonDecode(body) as Map<String, dynamic>;
        final chatId = data['chatId'] as String;
        final list = messagesByChat.putIfAbsent(chatId, () => []);
        final message = {
          'id': data['id'] ?? 'msg_${DateTime.now().millisecondsSinceEpoch}',
          'chatId': chatId,
          'senderId': data['senderId'],
          'receiverId': data['receiverId'],
          'text': data['text'] ?? '',
          'createdAt': data['createdAt'] ?? DateTime.now().toIso8601String(),
          'status': 'sent',
        };
        list.add(message);
        _json(request, {'ok': true});
      } else if (request.uri.path == '/conversations' && request.method == 'GET') {
        final userId = request.uri.queryParameters['userId'];
        final summaries = <Map<String, dynamic>>[];
        messagesByChat.forEach((chatId, list) {
          final otherUser = _otherUserFromChat(chatId, userId);
          if (otherUser == null) return;
          final last = list.isNotEmpty ? list.last : null;
          final unread = list
              .where((m) => m['receiverId'] == userId && m['status'] != 'read')
              .length;
          summaries.add({
            'chatId': chatId,
            'otherUserId': otherUser,
            'lastMessage': last?['text'],
            'lastTime': last?['createdAt'],
            'unread': unread,
          });
        });

        // Seed a conversation if no messages yet so lists aren't empty.
        if (summaries.isEmpty && userId != null) {
          final other = userId.contains('member') ? 'aarav_trainer_id' : 'dk_member_id';
          summaries.add({
            'chatId': _chatId(userId, other),
            'otherUserId': other,
            'lastMessage': 'Say hi',
            'lastTime': DateTime.now().toIso8601String(),
            'unread': 0,
          });
        }

        _json(request, summaries);
      } else if (request.uri.path == '/typing') {
        if (request.method == 'GET') {
          final chatId = request.uri.queryParameters['chatId'];
          final userId = typingByChat[chatId];
          _json(request, {'isTyping': userId != null, 'userId': userId});
        } else if (request.method == 'POST') {
          final body = await utf8.decoder.bind(request).join();
          final data = jsonDecode(body) as Map<String, dynamic>;
          final chatId = data['chatId'] as String?;
          final isTyping = data['isTyping'] == true;
          final userId = data['userId'] as String?;
          if (chatId != null) {
            typingByChat[chatId] = isTyping ? userId : null;
          }
          _json(request, {'ok': true});
        } else {
          _notFound(request);
        }
      } else if (request.uri.path == '/read' && request.method == 'POST') {
        final body = await utf8.decoder.bind(request).join();
        final data = jsonDecode(body) as Map<String, dynamic>;
        final chatId = data['chatId'] as String?;
        final ids = (data['messageIds'] as List<dynamic>? ?? []).cast<String>();
        if (chatId != null) {
          final list = messagesByChat[chatId];
          if (list != null) {
            for (final m in list) {
              if (ids.contains(m['id'])) {
                m['status'] = 'read';
              }
            }
          }
        }
        _json(request, {'ok': true});
      } else {
        _notFound(request);
      }
    } catch (e) {
      request.response.statusCode = HttpStatus.internalServerError;
      _json(request, {'error': e.toString()});
    }
  }
}

String? _otherUserFromChat(String chatId, String? userId) {
  if (userId == null) return null;
  final parts = chatId.split('_');
  if (parts.length == 2) {
    if (parts.first == userId) return parts.last;
    if (parts.last == userId) return parts.first;
  }
  return null;
}

String _chatId(String a, String b) {
  return (a.compareTo(b) < 0) ? '${a}_$b' : '${b}_$a';
}

void _json(HttpRequest req, Object body) {
  req.response
    ..statusCode = HttpStatus.ok
    ..headers.contentType = ContentType.json
    ..write(jsonEncode(body))
    ..close();
}

void _notFound(HttpRequest req) {
  req.response
    ..statusCode = HttpStatus.notFound
    ..write('Not Found')
    ..close();
}
