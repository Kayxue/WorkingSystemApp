// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'WorkerRatingGig.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkerRatingGig _$WorkerRatingGigFromJson(Map<String, dynamic> json) =>
    WorkerRatingGig(
      gigId: json['gigId'] as String,
      title: json['title'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
    );

Map<String, dynamic> _$WorkerRatingGigToJson(WorkerRatingGig instance) =>
    <String, dynamic>{
      'gigId': instance.gigId,
      'title': instance.title,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
    };
