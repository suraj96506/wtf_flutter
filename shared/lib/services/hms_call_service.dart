import 'dart:async';

import 'package:shared/models/call_request.dart';
import 'package:shared/models/room_meta.dart';
import 'package:shared/services/call_service.dart';

/// HMSCallService placeholder that satisfies the CallService contract.
/// Keeps UI flows unblocked while 100ms wiring is pending.
class HMSCallService implements CallService {
  final List<CallRequest> _requests = [];
  final StreamController<List<CallRequest>> _requestsController =
      StreamController<List<CallRequest>>.broadcast();
  final StreamController<RoomMeta?> _roomController =
      StreamController<RoomMeta?>.broadcast();

  @override
  Stream<List<CallRequest>> getCallRequests(String userId) {
    _requestsController.add(_requests
        .where((req) => req.memberId == userId || req.trainerId == userId)
        .toList());
    return _requestsController.stream.map((list) => list
        .where((req) => req.memberId == userId || req.trainerId == userId)
        .toList());
  }

  @override
  Future<void> requestCall(CallRequest callRequest) async {
    _requests.add(callRequest);
    _requestsController.add(List.unmodifiable(_requests));
  }

  @override
  Future<void> approveCall(CallRequest callRequest) async {
    _updateRequest(callRequest.id, CallRequestStatus.approved);
  }

  @override
  Future<void> declineCall(CallRequest callRequest) async {
    _updateRequest(callRequest.id, CallRequestStatus.declined);
  }

  void _updateRequest(String id, CallRequestStatus status) {
    final index = _requests.indexWhere((r) => r.id == id);
    if (index == -1) return;
    final existing = _requests[index];
    _requests[index] = CallRequest(
      id: existing.id,
      memberId: existing.memberId,
      trainerId: existing.trainerId,
      requestedAt: existing.requestedAt,
      scheduledFor: existing.scheduledFor,
      note: existing.note,
      status: status,
    );
    _requestsController.add(List.unmodifiable(_requests));
  }

  // --- 100ms placeholders ---
  @override
  Future<String> getAuthToken(String userId, String role) async {
    // Return a dummy token for UI flows until real token service is connected.
    return 'mock-token-for-$userId-$role';
  }

  @override
  Future<void> joinRoom(String roomId, String userId, String role) async {
    _roomController.add(RoomMeta(
      id: roomId,
      callRequestId: roomId,
      hmsRoomId: 'mock_hms_room',
      hmsRoleMember: 'member',
      hmsRoleTrainer: 'trainer',
    ));
  }

  @override
  Future<void> leaveRoom() async {
    _roomController.add(null);
  }

  @override
  Stream<RoomMeta?> get currentRoom => _roomController.stream;

  @override
  void dispose() {
    _requestsController.close();
    _roomController.close();
  }
}
