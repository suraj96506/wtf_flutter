import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// part 'scheduled_meeting.g.dart';

enum MeetingStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('approved')
  approved,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('declined')
  declined,
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
  final String? declineReason;

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
    this.status = MeetingStatus.pending,
    this.declineReason,
  });

  ScheduledMeeting copyWith({
    String? id,
    String? trainerId,
    String? memberId,
    String? trainerName,
    String? memberName,
    DateTime? scheduledFor,
    DateTime? createdAt,
    String? topic,
    String? description,
    int? durationMinutes,
    MeetingStatus? status,
    String? declineReason,
  }) {
    return ScheduledMeeting(
      id: id ?? this.id,
      trainerId: trainerId ?? this.trainerId,
      memberId: memberId ?? this.memberId,
      trainerName: trainerName ?? this.trainerName,
      memberName: memberName ?? this.memberName,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      createdAt: createdAt ?? this.createdAt,
      topic: topic ?? this.topic,
      description: description ?? this.description,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      declineReason: declineReason ?? this.declineReason,
    );
  }

  factory ScheduledMeeting.fromJson(Map<String, dynamic> json) {
    return ScheduledMeeting(
      id: json['id'] as String,
      trainerId: json['trainerId'] as String,
      memberId: json['memberId'] as String,
      trainerName: json['trainerName'] as String,
      memberName: json['memberName'] as String,
      scheduledFor: _toDateTime(json['scheduledFor']),
      createdAt: _toDateTime(json['createdAt']),
      topic: json['topic'] as String,
      description: json['description'] as String?,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 60,
      status: statusFromString(json['status'] as String?),
      declineReason: json['declineReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'trainerId': trainerId,
        'memberId': memberId,
        'trainerName': trainerName,
        'memberName': memberName,
        'scheduledFor': scheduledFor.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'topic': topic,
        'description': description,
        'durationMinutes': durationMinutes,
        'status': statusToString(status),
        'declineReason': declineReason,
      };

  static MeetingStatus statusFromString(String? value) {
    switch (value) {
      case 'approved':
        return MeetingStatus.approved;
      case 'completed':
        return MeetingStatus.completed;
      case 'cancelled':
        return MeetingStatus.cancelled;
      case 'declined':
        return MeetingStatus.declined;
      case 'pending':
      default:
        return MeetingStatus.pending;
    }
  }

  static String statusToString(MeetingStatus status) {
    switch (status) {
      case MeetingStatus.pending:
        return 'pending';
      case MeetingStatus.approved:
        return 'approved';
      case MeetingStatus.completed:
        return 'completed';
      case MeetingStatus.cancelled:
        return 'cancelled';
      case MeetingStatus.declined:
        return 'declined';
    }
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    throw ArgumentError('Unsupported date type: $value');
  }
}

