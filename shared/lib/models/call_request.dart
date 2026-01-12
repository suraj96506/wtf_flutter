import 'package:json_annotation/json_annotation.dart';

part 'call_request.g.dart';

enum CallRequestStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('approved')
  approved,
  @JsonValue('declined')
  declined,
  @JsonValue('cancelled')
  cancelled,
}

@JsonSerializable()
class CallRequest {
  final String id;
  final String memberId;
  final String trainerId;
  final String trainerName;
  final String memberName;
  final DateTime requestedAt;
  final DateTime scheduledFor;
  final String note;
  final CallRequestStatus status;

  CallRequest({
    required this.id,
    required this.memberId,
    required this.trainerId,
    required this.trainerName,
    required this.memberName,
    required this.requestedAt,
    required this.scheduledFor,
    required this.note,
    required this.status,
  });

  factory CallRequest.fromJson(Map<String, dynamic> json) => _$CallRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CallRequestToJson(this);
}
