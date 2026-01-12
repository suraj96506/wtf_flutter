// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CallRequest _$CallRequestFromJson(Map<String, dynamic> json) => CallRequest(
      id: json['id'] as String,
      memberId: json['memberId'] as String,
      trainerId: json['trainerId'] as String,
      trainerName: (json['trainerName'] as String?) ?? '',
      memberName: (json['memberName'] as String?) ?? '',
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      scheduledFor: DateTime.parse(json['scheduledFor'] as String),
      note: json['note'] as String,
      status: $enumDecode(_$CallRequestStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$CallRequestToJson(CallRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'memberId': instance.memberId,
      'trainerId': instance.trainerId,
      'trainerName': instance.trainerName,
      'memberName': instance.memberName,
      'requestedAt': instance.requestedAt.toIso8601String(),
      'scheduledFor': instance.scheduledFor.toIso8601String(),
      'note': instance.note,
      'status': _$CallRequestStatusEnumMap[instance.status]!,
    };

const _$CallRequestStatusEnumMap = {
  CallRequestStatus.pending: 'pending',
  CallRequestStatus.approved: 'approved',
  CallRequestStatus.declined: 'declined',
  CallRequestStatus.cancelled: 'cancelled',
};
