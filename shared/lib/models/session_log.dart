import 'package:json_annotation/json_annotation.dart';

part 'session_log.g.dart';

@JsonSerializable()
class SessionLog {
  final String id;
  final String memberId;
  final String trainerId;
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationSec;
  final int? rating; // 1-5
  final String? trainerNotes;
  final String? memberNotes;

  SessionLog({
    required this.id,
    required this.memberId,
    required this.trainerId,
    required this.startedAt,
    required this.endedAt,
    required this.durationSec,
    this.rating,
    this.trainerNotes,
    this.memberNotes,
  });

  factory SessionLog.fromJson(Map<String, dynamic> json) => _$SessionLogFromJson(json);
  Map<String, dynamic> toJson() => _$SessionLogToJson(this);
}
