import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

/// Minimal 100ms token server.
///
/// Usage:
/// 1) Create token_server/.env with:
///    HMS_ACCESS_KEY=your_app_access_key
///    HMS_SECRET=your_app_secret
///    HMS_ROOM_ID=your_room_id   # or leave empty and pass roomId param
/// 2) Run: `dart run token_server/hms_token_server.dart`
/// 3) Request: GET http://localhost:3000/token?userId=dk_member_id&role=member&roomId=room_main
Future<void> main(List<String> args) async {
  
 final accessKey = "6964b83d6a127e1cf1253b09";
  final appSecret = "R-Ne876hxyDQEPVeDyRTQMaUNKZG2zmQs3dnGFoJrwG2rbNSzlPb8URGyxlYg7hQzFQMkKzSY1Bmjf4PiIbrLakXl3CW1w-dBw4j0JWFo0c4Dt4qc6IHoQwUmUaH3EuPhJGEsgvEtwJlISYPQdiE4wuTYVCVcSYnUYEFmslt3UE=";
  final defaultRoomId = "12122abcabc";

  // if (accessKey == null || appSecret == null) {
  //   stderr.writeln(
  //       'Missing HMS_ACCESS_KEY or HMS_SECRET. Set them in token_server/.env');
  //   exit(1);
  // }

  final server = await HttpServer.bind(InternetAddress.anyIPv4, 3000);
  // ignore: avoid_print
  print('100ms token server running on port ${server.port}');

  await for (HttpRequest request in server) {
    // Basic CORS
    request.response.headers
      ..set('Access-Control-Allow-Origin', '*')
      ..set('Access-Control-Allow-Methods', 'GET, OPTIONS')
      ..set('Access-Control-Allow-Headers', 'Content-Type');

    if (request.method == 'OPTIONS') {
      await request.response.close();
      continue;
    }

    if (request.uri.path == '/token') {
      final userId = request.uri.queryParameters['userId'];
      final role = request.uri.queryParameters['role'];
      final roomId = request.uri.queryParameters['roomId'] ?? defaultRoomId;

      if (userId == null || role == null || roomId == null) {
        request.response
          ..statusCode = HttpStatus.badRequest
          ..write('Missing userId, role, or roomId');
        await request.response.close();
        continue;
      }

      try {
        final token = _generateToken(
          accessKey: accessKey,
          appSecret: appSecret,
          userId: userId,
          role: role,
          roomId: roomId,
          expirySeconds: 3600,
        );
        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'token': token}));
      } catch (e) {
        request.response
          ..statusCode = HttpStatus.internalServerError
          ..write('Error: $e');
      }
      await request.response.close();
    } else {
      request.response
        ..statusCode = HttpStatus.notFound
        ..write('Not Found')
        ..close();
    }
  }
}

String _generateToken({
  required String accessKey,
  required String appSecret,
  required String userId,
  required String role,
  required String roomId,
  required int expirySeconds,
}) {
  final header = {'alg': 'HS256', 'typ': 'JWT'};
  final nowSec = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
  final payload = {
    'access_key': accessKey,
    'type': 'app',
    'version': 2,
    'room_id': roomId,
    'user_id': userId,
    'role': role,
    'iat': nowSec,
    'exp': nowSec + expirySeconds,
  };

  String encode(Object obj) =>
      base64Url.encode(utf8.encode(jsonEncode(obj))).replaceAll('=', '');

  final headerPart = encode(header);
  final payloadPart = encode(payload);
  final signingInput = '$headerPart.$payloadPart';
  final hmac = Hmac(sha256, utf8.encode(appSecret));
  final digest = hmac.convert(utf8.encode(signingInput));
  final signature = base64Url.encode(digest.bytes).replaceAll('=', '');
  return '$signingInput.$signature';
}

Map<String, String> _loadEnv() {
  final file = File('token_server/.env');
  if (!file.existsSync()) return {};
  final lines = file.readAsLinesSync();
  final map = <String, String>{};
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    final idx = trimmed.indexOf('=');
    if (idx == -1) continue;
    final key = trimmed.substring(0, idx).trim();
    final value = trimmed.substring(idx + 1).trim();
    map[key] = value;
  }
  return map;
}
