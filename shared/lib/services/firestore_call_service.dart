import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared/models/call_request.dart';
import 'package:shared/models/room_meta.dart';
import 'package:shared/services/call_service.dart';

class FirestoreCallService implements CallService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StreamController<RoomMeta?> _roomController = StreamController<RoomMeta?>.broadcast();
  final HMSSDK _hmsSdk = HMSSDK();
  final HMSUpdateListener _hmsListener = _SimpleHMSListener();

  static const _tokenServerBase = String.fromEnvironment(
    'TOKEN_SERVER_BASE',
    defaultValue: 'http://10.0.2.2:3000/token',
  );

  FirestoreCallService() {
    _hmsSdk.addUpdateListener(listener: _hmsListener);
  }

  @override
  Stream<List<CallRequest>> getCallRequests(String userId) {
    return _firestore
        .collection('callRequests')
        .where('memberId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CallRequest.fromJson(doc.data()))
          .toList();
    }).handleError((error) {
      // Basic error handling
      print('Error fetching call requests for member: $error');
      return [];
    });
  }

  Stream<List<CallRequest>> getCallRequestsForTrainer(String trainerId) {
    return _firestore
        .collection('callRequests')
        .where('trainerId', isEqualTo: trainerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CallRequest.fromJson(doc.data()))
          .toList();
    }).handleError((error) {
      // Basic error handling
      print('Error fetching call requests for trainer: $error');
      return [];
    });
  }

  @override
  Future<void> requestCall(CallRequest callRequest) async {
    try {
      await _firestore
          .collection('callRequests')
          .doc(callRequest.id)
          .set(callRequest.toJson());
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> approveCall(CallRequest callRequest) async {
    await _firestore
        .collection('callRequests')
        .doc(callRequest.id)
        .update({'status': CallRequestStatus.approved.name});
  }

  @override
  Future<void> declineCall(CallRequest callRequest) async {
    await _firestore
        .collection('callRequests')
        .doc(callRequest.id)
        .update({'status': CallRequestStatus.declined.name});
  }

  // --- 100ms placeholders ---
  @override
  Future<String> getAuthToken(String userId, String role) async {
    final uri = Uri.parse('$_tokenServerBase?userId=$userId&role=$role');
    late http.Response resp;
    try {
      resp = await http.get(uri);
    } catch (e) {
      throw Exception('Token server unreachable at $uri ($e)');
    }
    if (resp.statusCode != 200) {
      throw Exception('Token fetch failed: ${resp.statusCode} ${resp.body}');
    }
    final body = resp.body;
    // If server returns JSON {token: "..."} handle it, else raw token string
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['token'] is String) {
        return decoded['token'] as String;
      }
    } catch (_) {}
    return body;
  }

  @override
  Future<void> joinRoom(String roomId, String userId, String role) async {
    final token = await getAuthToken(userId, role);
    final config = HMSConfig(authToken: token, userName: userId);
    await _hmsSdk.join(config: config);
    _roomController.add(
      RoomMeta(
        id: roomId,
        callRequestId: roomId,
        hmsRoomId: roomId,
        hmsRoleMember: 'member',
        hmsRoleTrainer: 'trainer',
      ),
    );
  }

  @override
  Future<void> leaveRoom() async {
    await _hmsSdk.leave();
    _roomController.add(null);
  }

  @override
  Stream<RoomMeta?> get currentRoom => _roomController.stream;

  @override
  void dispose() {
    _roomController.close();
    _hmsSdk.removeUpdateListener(listener: _hmsListener);
    _hmsSdk.destroy();
  }
}

class _SimpleHMSListener implements HMSUpdateListener {
  @override
  void onJoin({HMSRoom? room}) {}

  @override
  void onPeerUpdate({HMSPeer? peer, HMSPeerUpdate? update}) {}

  @override
  void onPeerListUpdate(
      {required List<HMSPeer> addedPeers, required List<HMSPeer> removedPeers}) {}

  @override
  void onRoomUpdate({HMSRoom? room, HMSRoomUpdate? update}) {}

  @override
  void onTrackUpdate(
      {HMSTrack? track, HMSTrackUpdate? trackUpdate, HMSPeer? peer}) {}

  @override
  void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {}

  @override
  void onMessage({required HMSMessage message}) {}

  @override
  void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {}

  @override
  void onChangeTrackStateRequest(
      {required HMSTrackChangeRequest hmsTrackChangeRequest}) {}

  @override
  void onRemovedFromRoom(
      {required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer}) {}

  void onException({HMSException? exception}) {
    // ignore: avoid_print
    print('[HMS] exception: $exception');
  }

  @override
  void onAudioDeviceChanged(
      {HMSAudioDevice? currentAudioDevice, List<HMSAudioDevice>? availableAudioDevice}) {}

  void onSessionStoreAvailable({HMSSessionStore? hmsSessionStore}) {}

  @override
  void onReconnecting() {}

  @override
  void onReconnected() {}

  @override
  void onHMSError({required HMSException error}) {
    // ignore: avoid_print
    print('[HMS] error: $error');
  }
}
