// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'WorkerGivenReviewReturn.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkerGivenReviewReturn _$WorkerGivenReviewReturnFromJson(
  Map<String, dynamic> json,
) => WorkerGivenReviewReturn(
  myRatings: (json['myRatings'] as List<dynamic>)
      .map((e) => WorkerRatings.fromJson(e as Map<String, dynamic>))
      .toList(),
  pagination: Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
);

Map<String, dynamic> _$WorkerGivenReviewReturnToJson(
  WorkerGivenReviewReturn instance,
) => <String, dynamic>{
  'myRatings': instance.myRatings.map((e) => e.toJson()).toList(),
  'pagination': instance.pagination.toJson(),
};
