// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'WorkerRatings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkerRatings _$WorkerRatingsFromJson(Map<String, dynamic> json) =>
    WorkerRatings(
      ratingId: json['ratingId'] as String,
      employer: WorkerReviewEmployer.fromJson(
        json['employer'] as Map<String, dynamic>,
      ),
      gig: WorkerRatingGig.fromJson(json['gig'] as Map<String, dynamic>),
      ratingValue: (json['ratingValue'] as num).toDouble(),
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$WorkerRatingsToJson(WorkerRatings instance) =>
    <String, dynamic>{
      'ratingId': instance.ratingId,
      'employer': instance.employer.toJson(),
      'gig': instance.gig.toJson(),
      'ratingValue': instance.ratingValue,
      'comment': instance.comment,
      'createdAt': instance.createdAt.toIso8601String(),
    };
