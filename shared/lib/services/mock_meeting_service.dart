import 'dart:async';

import 'package:shared/models/scheduled_meeting.dart';
import 'package:shared/services/meeting_service.dart';

class MockMeetingService implements MeetingService {
  final List<ScheduledMeeting> _meetings = [];
  final List<ScheduledMeeting> _meetingRequests = []; // pending requests
  late StreamController<List<ScheduledMeeting>> _trainerMeetingsController;
  late StreamController<List<ScheduledMeeting>> _memberMeetingsController;
  late StreamController<List<ScheduledMeeting>> _trainerRequestsController;

  MockMeetingService() {
    _trainerMeetingsController = StreamController<List<ScheduledMeeting>>.broadcast();
    _memberMeetingsController = StreamController<List<ScheduledMeeting>>.broadcast();
    _trainerRequestsController = StreamController<List<ScheduledMeeting>>.broadcast();
  }

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
      status: MeetingStatus.pending, // Request pending trainer approval
    );

    _meetingRequests.add(meeting);
    _notifyListeners();

    return meeting;
  }

  @override
  Stream<List<ScheduledMeeting>> getTrainerMeetings(String trainerId) {
    final trainerMeetings = _meetings.where((m) => m.trainerId == trainerId).toList();
    _trainerMeetingsController.add(trainerMeetings);
    return _trainerMeetingsController.stream;
  }

  @override
  Stream<List<ScheduledMeeting>> getMemberMeetings(String memberId) {
    final memberMeetings = _meetings.where((m) => m.memberId == memberId).toList();
    _memberMeetingsController.add(memberMeetings);
    return _memberMeetingsController.stream;
  }

  /// Get pending meeting requests for a trainer
  @override
  Stream<List<ScheduledMeeting>> getTrainerMeetingRequests(String trainerId) {
    final requests = _meetingRequests.where((m) => m.trainerId == trainerId).toList();
    _trainerRequestsController.add(requests);
    return _trainerRequestsController.stream;
  }

  @override
  Future<void> updateMeetingStatus(
    String meetingId,
    MeetingStatus status, {
    String? declineReason,
  }) async {
    // Find and update the meeting
    final meetingIndex = _meetings.indexWhere((m) => m.id == meetingId);
    if (meetingIndex != -1) {
      final oldMeeting = _meetings[meetingIndex];
      _meetings[meetingIndex] = ScheduledMeeting(
        id: oldMeeting.id,
        trainerId: oldMeeting.trainerId,
        memberId: oldMeeting.memberId,
        trainerName: oldMeeting.trainerName,
        memberName: oldMeeting.memberName,
        scheduledFor: oldMeeting.scheduledFor,
        createdAt: oldMeeting.createdAt,
        topic: oldMeeting.topic,
        description: oldMeeting.description,
        durationMinutes: oldMeeting.durationMinutes,
        status: status,
        declineReason: declineReason ?? oldMeeting.declineReason,
      );
      _notifyListeners();
    }
  }

  /// Approve a meeting request (trainer action)
  @override
  Future<void> approveMeetingRequest(String meetingId) async {
    final requestIndex = _meetingRequests.indexWhere((m) => m.id == meetingId);
    if (requestIndex != -1) {
      final request = _meetingRequests[requestIndex];
      _meetingRequests.removeAt(requestIndex);

      // Move to confirmed meetings
      _meetings.add(
        ScheduledMeeting(
          id: request.id,
          trainerId: request.trainerId,
          memberId: request.memberId,
          trainerName: request.trainerName,
          memberName: request.memberName,
          scheduledFor: request.scheduledFor,
          createdAt: request.createdAt,
          topic: request.topic,
          description: request.description,
          durationMinutes: request.durationMinutes,
          status: MeetingStatus.approved,
        ),
      );
      _notifyListeners();
    }
  }

  /// Decline a meeting request (trainer action)
  @override
  Future<void> declineMeetingRequest(String meetingId, {String? reason}) async {
    final requestIndex = _meetingRequests.indexWhere((m) => m.id == meetingId);
    if (requestIndex != -1) {
      final request = _meetingRequests.removeAt(requestIndex);
      // Keep declined record in history
      _meetings.add(request.copyWith(status: MeetingStatus.declined, declineReason: reason));
      _notifyListeners();
    }
  }

  @override
  Future<void> cancelMeeting(String meetingId) async {
    await updateMeetingStatus(meetingId, MeetingStatus.cancelled);
  }

  @override
  Future<ScheduledMeeting?> getMeetingById(String meetingId) async {
    try {
      return _meetings.firstWhere((m) => m.id == meetingId);
    } catch (e) {
      return null;
    }
  }

  void _notifyListeners() {
    _trainerMeetingsController.add(_meetings);
    _memberMeetingsController.add(_meetings);
    _trainerRequestsController.add(_meetingRequests);
  }

  @override
  void dispose() {
    _trainerMeetingsController.close();
    _memberMeetingsController.close();
    _trainerRequestsController.close();
  }
}
