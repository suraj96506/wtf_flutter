// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_meta.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomMeta _$RoomMetaFromJson(Map<String, dynamic> json) => RoomMeta(
  id: json['id'] as String,
  callRequestId: json['callRequestId'] as String,
  hmsRoomId: json['hmsRoomId'] as String,
  hmsRoleMember: json['hmsRoleMember'] as String,
  hmsRoleTrainer: json['hmsRoleTrainer'] as String,
);

Map<String, dynamic> _$RoomMetaToJson(RoomMeta instance) => <String, dynamic>{
  'id': instance.id,
  'callRequestId': instance.callRequestId,
  'hmsRoomId': instance.hmsRoomId,
  'hmsRoleMember': instance.hmsRoleMember,
  'hmsRoleTrainer': instance.hmsRoleTrainer,
};
