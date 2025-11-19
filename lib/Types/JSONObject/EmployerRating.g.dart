// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'EmployerRating.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmployerRating _$EmployerRatingFromJson(Map<String, dynamic> json) =>
    EmployerRating(
      ratingId: json['ratingId'] as String,
      name: json['name'] as String,
      ratingValue: (json['ratingValue'] as num).toDouble(),
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$EmployerRatingToJson(EmployerRating instance) =>
    <String, dynamic>{
      'ratingId': instance.ratingId,
      'name': instance.name,
      'ratingValue': instance.ratingValue,
      'comment': instance.comment,
      'createdAt': instance.createdAt.toIso8601String(),
    };
