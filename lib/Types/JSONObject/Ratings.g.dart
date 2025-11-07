// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Ratings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ratings _$RatingsFromJson(Map<String, dynamic> json) => Ratings(
  ratingId: json['ratingId'] as String,
  employer: ReviewEmployer.fromJson(json['employer'] as Map<String, dynamic>),
  gig: RatingGig.fromJson(json['gig'] as Map<String, dynamic>),
  ratingValue: (json['ratingValue'] as num).toDouble(),
  comment: json['comment'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$RatingsToJson(Ratings instance) => <String, dynamic>{
  'ratingId': instance.ratingId,
  'employer': instance.employer.toJson(),
  'gig': instance.gig.toJson(),
  'ratingValue': instance.ratingValue,
  'comment': instance.comment,
  'createdAt': instance.createdAt.toIso8601String(),
};
