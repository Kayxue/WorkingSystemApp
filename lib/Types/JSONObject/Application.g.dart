// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Application.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Application _$ApplicationFromJson(Map<String, dynamic> json) => Application(
  applicationId: json['applicationId'] as String,
  gigId: json['gigId'] as String,
  gigTitle: json['gigTitle'] as String,
  hourlyRate: (json['hourlyRate'] as num).toInt(),
  employerName: json['employerName'] as String,
  workDate: json['workDate'] as String,
  workTime: json['workTime'] as String,
  status: json['status'] as String,
  appliedAt: json['appliedAt'] as String,
  hasConflict: json['hasConflict'] as bool?,
  hasPendingConflict: json['hasPendingConflict'] as bool?,
);

Map<String, dynamic> _$ApplicationToJson(Application instance) =>
    <String, dynamic>{
      'applicationId': instance.applicationId,
      'gigId': instance.gigId,
      'gigTitle': instance.gigTitle,
      'hourlyRate': instance.hourlyRate,
      'employerName': instance.employerName,
      'workDate': instance.workDate,
      'workTime': instance.workTime,
      'status': instance.status,
      'appliedAt': instance.appliedAt,
      'hasConflict': instance.hasConflict,
      'hasPendingConflict': instance.hasPendingConflict,
    };
