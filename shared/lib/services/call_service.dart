import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:shared/models/call_request.dart';
import 'package:shared/models/room_meta.dart';

abstract class CallService {
  // Call Request management
  Stream<List<CallRequest>> getCallRequests(String userId);
  Future<void> requestCall(CallRequest callRequest);
  Future<void> approveCall(CallRequest callRequest);
  Future<void> declineCall(CallRequest callRequest);

  // 100ms Integration
  Future<String> getAuthToken(String userId, String role);
  Future<void> joinRoom(String roomId, String userId, String role);
  Future<void> leaveRoom();
  Stream<RoomMeta?> get currentRoom; // Stream to get current room info
  Stream<List<HMSVideoTrack>> get videoTracks;
  Future<void> toggleMicMuteState();
  Future<void> toggleCameraMuteState();

  void dispose();
}
