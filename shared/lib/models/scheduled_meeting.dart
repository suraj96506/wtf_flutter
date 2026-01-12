import 'package:json_annotation/json_annotation.dart';

part 'scheduled_meeting.g.dart';

enum MeetingStatus {
  @JsonValue('scheduled')
  scheduled,
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}

@JsonSerializable()
class ScheduledMeeting {
  final String id;
  final String trainerId;
  final String memberId;
  final String trainerName;
  final String memberName;
  final DateTime scheduledFor;
  final DateTime createdAt;
  final String topic;
  final String? description;
  final int durationMinutes; // Default 60 minutes
  final MeetingStatus status;

  ScheduledMeeting({
    required this.id,
    required this.trainerId,
    required this.memberId,
    required this.trainerName,
    required this.memberName,
    required this.scheduledFor,
    required this.createdAt,
    required this.topic,
    this.description,
    this.durationMinutes = 60,
    this.status = MeetingStatus.scheduled,
  });

  factory ScheduledMeeting.fromJson(Map<String, dynamic> json) => _$ScheduledMeetingFromJson(json);
  Map<String, dynamic> toJson() => _$ScheduledMeetingToJson(this);
}
