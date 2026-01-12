import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared/models/scheduled_meeting.dart';
import 'package:shared/services/meeting_service.dart';

/// Firestore-backed meeting service shared by both apps.
class FirestoreMeetingService implements MeetingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection('callRequests');

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
    await _collection.doc(meeting.id).set(meeting.toJson());
    return meeting;
  }

  @override
  Stream<List<ScheduledMeeting>> getTrainerMeetingRequests(String trainerId) {
    return _collection
        .where('trainerId', isEqualTo: trainerId)
        .where('status', isEqualTo: ScheduledMeeting.statusToString(MeetingStatus.pending))
        .snapshots()
        .map(_mapSnapshot);
  }

  @override
  Stream<List<ScheduledMeeting>> getTrainerMeetings(String trainerId) {
    return _collection
        .where('trainerId', isEqualTo: trainerId)
        .snapshots()
        .map(_mapSnapshot);
  }

  @override
  Stream<List<ScheduledMeeting>> getMemberMeetings(String memberId) {
    return _collection
        .where('memberId', isEqualTo: memberId)
        .snapshots()
        .map(_mapSnapshot);
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
    await _collection.doc(meetingId).update({
      'status': ScheduledMeeting.statusToString(status),
      if (declineReason != null) 'declineReason': declineReason,
    });
  }

  @override
  Future<void> cancelMeeting(String meetingId) async {
    await updateMeetingStatus(meetingId, MeetingStatus.cancelled);
  }

  @override
  Future<ScheduledMeeting?> getMeetingById(String meetingId) async {
    final snap = await _collection.doc(meetingId).get();
    if (!snap.exists) return null;
    return ScheduledMeeting.fromJson({
      ...snap.data()!,
      'id': snap.id,
    });
  }

  List<ScheduledMeeting> _mapSnapshot(QuerySnapshot<Map<String, dynamic>> snap) {
    final items = snap.docs
        .map((d) => ScheduledMeeting.fromJson({
              ...d.data(),
              'id': d.id,
            }))
        .toList();
    items.sort((a, b) => b.scheduledFor.compareTo(a.scheduledFor));
    return items;
  }

  @override
  void dispose() {}
}
