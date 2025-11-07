// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'WorkerReview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkerReview _$WorkerReviewFromJson(Map<String, dynamic> json) => WorkerReview(
  gigId: json['gigId'] as String,
  title: json['title'] as String,
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  employer: ReviewEmployer.fromJson(json['employer'] as Map<String, dynamic>),
);

Map<String, dynamic> _$WorkerReviewToJson(WorkerReview instance) =>
    <String, dynamic>{
      'gigId': instance.gigId,
      'title': instance.title,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'employer': instance.employer.toJson(),
    };
