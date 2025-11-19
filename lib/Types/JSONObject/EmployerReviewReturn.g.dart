// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'EmployerReviewReturn.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmployerReviewReturn _$EmployerReviewReturnFromJson(
  Map<String, dynamic> json,
) => EmployerReviewReturn(
  ratings: (json['ratings'] as List<dynamic>)
      .map((e) => EmployerRating.fromJson(e as Map<String, dynamic>))
      .toList(),
  pagination: Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
);

Map<String, dynamic> _$EmployerReviewReturnToJson(
  EmployerReviewReturn instance,
) => <String, dynamic>{
  'ratings': instance.ratings.map((e) => e.toJson()).toList(),
  'pagination': instance.pagination.toJson(),
};
