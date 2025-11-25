// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application_gig.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApplicationGig _$ApplicationGigFromJson(Map<String, dynamic> json) =>
    ApplicationGig(
      gigId: json['gigId'] as String,
      title: json['title'] as String,
      dateStart: DateTime.parse(json['dateStart'] as String),
      dateEnd: DateTime.parse(json['dateEnd'] as String),
      timeStart: json['timeStart'] as String,
      timeEnd: json['timeEnd'] as String,
      employer: json['employer'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$ApplicationGigToJson(ApplicationGig instance) =>
    <String, dynamic>{
      'gigId': instance.gigId,
      'title': instance.title,
      'dateStart': instance.dateStart.toIso8601String(),
      'dateEnd': instance.dateEnd.toIso8601String(),
      'timeStart': instance.timeStart,
      'timeEnd': instance.timeEnd,
      'employer': instance.employer,
    };
