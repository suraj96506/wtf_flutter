import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

// Configure routes.
final _router = Router()
  ..get('/token', _tokenHandler);

Future<Response> _tokenHandler(Request req) async {
  final userId = req.url.queryParameters['userId'];
  final role = req.url.queryParameters['role'];

  if (userId == null || role == null) {
    return Response.badRequest(body: 'userId and role are required');
  }

  // In a real app, you would generate a real 100ms token here.
  // For this assessment, we'll return a dummy token.
  final dummyToken = 'dummy_token_for_${userId}_as_$role';

  return Response.ok(dummyToken);
}

void main(List<String> args) async {
  // Use any available host or container IP (usually Platform.localHostname).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(_router.call); // explicit tear-off

  // For running in containers, we use the provided PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  // ignore: avoid_print
  print('Server listening on port ${server.port}');
}
