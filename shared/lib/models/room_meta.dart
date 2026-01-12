import 'package:json_annotation/json_annotation.dart';

part 'room_meta.g.dart';

@JsonSerializable()
class RoomMeta {
  final String id;
  final String callRequestId;
  final String hmsRoomId;
  final String hmsRoleMember; // e.g., "member" role in 100ms
  final String hmsRoleTrainer; // e.g., "trainer" role in 100ms

  RoomMeta({
    required this.id,
    required this.callRequestId,
    required this.hmsRoomId,
    required this.hmsRoleMember,
    required this.hmsRoleTrainer,
  });

  factory RoomMeta.fromJson(Map<String, dynamic> json) => _$RoomMetaFromJson(json);
  Map<String, dynamic> toJson() => _$RoomMetaToJson(this);
}
