import 'package:shared/models/scheduled_meeting.dart';

abstract class MeetingService {
  /// Schedule a new meeting with a trainer
  Future<ScheduledMeeting> scheduleMeeting({
    required String trainerId,
    required String memberId,
    required String trainerName,
    required String memberName,
    required DateTime scheduledFor,
    required String topic,
    String? description,
    int durationMinutes = 60,
  });

  /// Get all scheduled meetings for a trainer
  Stream<List<ScheduledMeeting>> getTrainerMeetings(String trainerId);

  /// Get all scheduled meetings for a member
  Stream<List<ScheduledMeeting>> getMemberMeetings(String memberId);

  /// Pending requests for trainers
  Stream<List<ScheduledMeeting>> getTrainerMeetingRequests(String trainerId);

  /// Approve a pending request
  Future<void> approveMeetingRequest(String meetingId);

  /// Decline a pending request with optional reason
  Future<void> declineMeetingRequest(String meetingId, {String? reason});

  /// Update meeting status
  Future<void> updateMeetingStatus(String meetingId, MeetingStatus status, {String? declineReason});

  /// Cancel a meeting
  Future<void> cancelMeeting(String meetingId);

  /// Get a specific meeting by ID
  Future<ScheduledMeeting?> getMeetingById(String meetingId);

  void dispose();
}
