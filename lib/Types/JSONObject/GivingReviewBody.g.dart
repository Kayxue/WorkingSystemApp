// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'GivingReviewBody.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GivingReviewBody _$GivingReviewBodyFromJson(Map<String, dynamic> json) =>
    GivingReviewBody(
      ratingValue: (json['ratingValue'] as num).toInt(),
      comment: json['comment'] as String?,
    );

Map<String, dynamic> _$GivingReviewBodyToJson(GivingReviewBody instance) =>
    <String, dynamic>{
      'ratingValue': instance.ratingValue,
      'comment': ?instance.comment,
    };
