// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  role: json['role'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  assignedTrainerId: json['assignedTrainerId'] as String?,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'role': instance.role,
  'name': instance.name,
  'email': instance.email,
  'avatarUrl': instance.avatarUrl,
  'assignedTrainerId': instance.assignedTrainerId,
};
