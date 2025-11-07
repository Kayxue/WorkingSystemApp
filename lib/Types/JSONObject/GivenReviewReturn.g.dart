// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'GivenReviewReturn.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GivenReviewReturn _$GivenReviewReturnFromJson(Map<String, dynamic> json) =>
    GivenReviewReturn(
      ratings: (json['ratings'] as List<dynamic>)
          .map((e) => Ratings.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: Pagination.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$GivenReviewReturnToJson(GivenReviewReturn instance) =>
    <String, dynamic>{
      'ratings': instance.ratings.map((e) => e.toJson()).toList(),
      'pagination': instance.pagination.toJson(),
    };
