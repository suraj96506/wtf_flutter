import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared/models/scheduled_meeting.dart';
import 'package:shared/services/meeting_service.dart';

/// Lightweight RTDB-backed meeting service using REST (works across both apps).
class FirebaseMeetingService implements MeetingService {
  FirebaseMeetingService({required String databaseUrl})
      : _baseUrl = databaseUrl.endsWith('/')
            ? databaseUrl.substring(0, databaseUrl.length - 1)
            : databaseUrl;

  final String _baseUrl;
  final _client = http.Client();
  final Map<String, StreamController<List<ScheduledMeeting>>> _memberControllers = {};
  final Map<String, StreamController<List<ScheduledMeeting>>> _trainerControllers = {};
  final Map<String, Timer> _pollers = {};

  @override
  Future<ScheduledMeeting> scheduleMeeting({
    required String trainerId,
    required String memberId,
    required String trainerName,
    required String memberName,
    required DateTime scheduledFor,
    required String topic,
    String? description,
    int durationMinutes = 60,
  }) async {
    final meeting = ScheduledMeeting(
      id: 'meeting_${DateTime.now().millisecondsSinceEpoch}',
      trainerId: trainerId,
      memberId: memberId,
      trainerName: trainerName,
      memberName: memberName,
      scheduledFor: scheduledFor,
      createdAt: DateTime.now(),
      topic: topic,
      description: description,
      durationMinutes: durationMinutes,
      status: MeetingStatus.pending,
    );
    final uri = Uri.parse('$_baseUrl/callRequests/${meeting.id}.json');
    final resp = await _client.put(uri, body: jsonEncode(meeting.toJson()));
    if (resp.statusCode >= 400) {
      _log('scheduleMeeting', 'PUT $uri failed ${resp.statusCode}: ${resp.body}');
      throw Exception('Failed to schedule meeting (${resp.statusCode})');
    } else {
      _log('scheduleMeeting', 'PUT $uri ok ${resp.statusCode}');
    }
    _refreshForMember(memberId);
    _refreshForTrainer(trainerId);
    return meeting;
  }

  @override
  Stream<List<ScheduledMeeting>> getTrainerMeetings(String trainerId) {
    _trainerControllers.putIfAbsent(trainerId, () => StreamController.broadcast());
    _startPolling();
    _refreshForTrainer(trainerId);
    return _trainerControllers[trainerId]!.stream.map(
      (list) => list.where((m) => m.trainerId == trainerId && m.status != MeetingStatus.pending).toList(),
    );
  }

  @override
  Stream<List<ScheduledMeeting>> getMemberMeetings(String memberId) {
    _memberControllers.putIfAbsent(memberId, () => StreamController.broadcast());
    _startPolling();
    _refreshForMember(memberId);
    return _memberControllers[memberId]!.stream.map(
      (list) => list.where((m) => m.memberId == memberId).toList(),
    );
  }

  @override
  Stream<List<ScheduledMeeting>> getTrainerMeetingRequests(String trainerId) {
    _trainerControllers.putIfAbsent(trainerId, () => StreamController.broadcast());
    _startPolling();
    _refreshForTrainer(trainerId);
    return _trainerControllers[trainerId]!.stream.map(
      (list) => list.where((m) => m.trainerId == trainerId && m.status == MeetingStatus.pending).toList(),
    );
  }

  @override
  Future<void> approveMeetingRequest(String meetingId) async {
    await updateMeetingStatus(meetingId, MeetingStatus.approved);
  }

  @override
  Future<void> declineMeetingRequest(String meetingId, {String? reason}) async {
    await updateMeetingStatus(meetingId, MeetingStatus.declined, declineReason: reason);
  }

  @override
  Future<void> updateMeetingStatus(String meetingId, MeetingStatus status, {String? declineReason}) async {
    final meeting = await getMeetingById(meetingId);
    if (meeting == null) return;
    final updated = meeting.copyWith(status: status, declineReason: declineReason);
    final uri = Uri.parse('$_baseUrl/callRequests/$meetingId.json');
    final resp = await _client.put(uri, body: jsonEncode(updated.toJson()));
    if (resp.statusCode >= 400) {
      _log('updateStatus', 'PUT $uri failed ${resp.statusCode}: ${resp.body}');
      throw Exception('Failed to update meeting (${resp.statusCode})');
    } else {
      _log('updateStatus', 'PUT $uri ok ${resp.statusCode}');
    }
    _refreshForMember(updated.memberId);
    _refreshForTrainer(updated.trainerId);
  }

  @override
  Future<void> cancelMeeting(String meetingId) async {
    await updateMeetingStatus(meetingId, MeetingStatus.cancelled);
  }

  @override
  Future<ScheduledMeeting?> getMeetingById(String meetingId) async {
    final uri = Uri.parse('$_baseUrl/callRequests/$meetingId.json');
    final resp = await _client.get(uri);
    if (resp.statusCode != 200 || resp.body == 'null') {
      _log('getById', 'GET $uri status ${resp.statusCode} body ${resp.body}');
      return null;
    }
    final map = jsonDecode(resp.body) as Map<String, dynamic>;
    return ScheduledMeeting.fromJson(map);
  }

  void _startPolling() {
    _pollers.putIfAbsent(
      'poll',
      () => Timer.periodic(const Duration(seconds: 2), (_) async {
        final uri = Uri.parse('$_baseUrl/callRequests.json');
        final resp = await _client.get(uri);
        if (resp.statusCode != 200) {
          _log('poll', 'GET $uri failed ${resp.statusCode}: ${resp.body}');
          return;
        }
        if (resp.body == 'null') {
          _broadcastAll([]);
          return;
        }
        final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
        final items = decoded.values
            .whereType<Map<String, dynamic>>()
            .map((m) => ScheduledMeeting.fromJson(m))
            .toList()
          ..sort((a, b) => b.scheduledFor.compareTo(a.scheduledFor));
        _broadcastAll(items);
      }),
    );
  }

  void _broadcastAll(List<ScheduledMeeting> all) {
    for (final entry in _memberControllers.entries) {
      entry.value.add(all.where((m) => m.memberId == entry.key).toList());
    }
    for (final entry in _trainerControllers.entries) {
      entry.value.add(all.where((m) => m.trainerId == entry.key).toList());
    }
  }

  void _refreshForMember(String memberId) {
    _startPolling();
  }

  void _refreshForTrainer(String trainerId) {
    _startPolling();
  }

  @override
  void dispose() {
    for (final timer in _pollers.values) {
      timer.cancel();
    }
    for (final c in _memberControllers.values) {
      c.close();
    }
    for (final c in _trainerControllers.values) {
      c.close();
    }
    _client.close();
  }

  void _log(String tag, String message) {
    // ignore: avoid_print
    print('[MEETING][$tag] $message');
  }
}
