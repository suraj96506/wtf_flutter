import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/models/user.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/services/call_service.dart';
import 'package:shared/services/chat_service.dart';
import 'package:shared/services/firestore_call_service.dart';
import 'package:shared/services/hms_call_service.dart'; // Renamed import
import 'package:shared/services/http_chat_service.dart';
import 'package:shared/services/meeting_service.dart';
import 'package:shared/services/mock_auth_service.dart';
import 'package:shared/services/mock_meeting_service.dart';
import 'package:shared/services/firestore_meeting_service.dart';

const _chatBaseUrl = String.fromEnvironment(
  'CHAT_BASE_URL',
  defaultValue: 'http://10.0.2.2:8081',
);

// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  final service = MockAuthService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

final chatServiceProvider = Provider<ChatService>((ref) {
  final httpChatService = HttpChatService(baseUrl: _chatBaseUrl);
  ref.onDispose(() {
    httpChatService.dispose();
  });
  return httpChatService;
});

// Provider for CallService
final callServiceProvider = Provider<CallService>((ref) {
  final callService = FirestoreCallService();
  ref.onDispose(() {
    callService.dispose();
  });
  return callService;
});

// Provider for MeetingService
final meetingServiceProvider = Provider<MeetingService>((ref) {
  final service = FirestoreMeetingService();
  ref.onDispose(() => service.dispose());
  return service;
});

// Provider for the current user stream
final currentUserStreamProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.currentUser;
});
