// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionLog _$SessionLogFromJson(Map<String, dynamic> json) => SessionLog(
  id: json['id'] as String,
  memberId: json['memberId'] as String,
  trainerId: json['trainerId'] as String,
  startedAt: DateTime.parse(json['startedAt'] as String),
  endedAt: DateTime.parse(json['endedAt'] as String),
  durationSec: (json['durationSec'] as num).toInt(),
  rating: (json['rating'] as num?)?.toInt(),
  trainerNotes: json['trainerNotes'] as String?,
  memberNotes: json['memberNotes'] as String?,
);

Map<String, dynamic> _$SessionLogToJson(SessionLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'memberId': instance.memberId,
      'trainerId': instance.trainerId,
      'startedAt': instance.startedAt.toIso8601String(),
      'endedAt': instance.endedAt.toIso8601String(),
      'durationSec': instance.durationSec,
      'rating': instance.rating,
      'trainerNotes': instance.trainerNotes,
      'memberNotes': instance.memberNotes,
    };
