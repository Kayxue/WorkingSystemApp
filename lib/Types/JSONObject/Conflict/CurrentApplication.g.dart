// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CurrentApplication.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrentApplication _$CurrentApplicationFromJson(Map<String, dynamic> json) =>
    CurrentApplication(
      applicationId: json['applicationId'] as String,
      gigId: json['gigId'] as String,
      title: json['title'] as String,
      dateStart: json['dateStart'] as String,
      dateEnd: json['dateEnd'] as String,
      timeStart: json['timeStart'] as String,
      timeEnd: json['timeEnd'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$CurrentApplicationToJson(CurrentApplication instance) =>
    <String, dynamic>{
      'applicationId': instance.applicationId,
      'gigId': instance.gigId,
      'title': instance.title,
      'dateStart': instance.dateStart,
      'dateEnd': instance.dateEnd,
      'timeStart': instance.timeStart,
      'timeEnd': instance.timeEnd,
      'status': instance.status,
    };
