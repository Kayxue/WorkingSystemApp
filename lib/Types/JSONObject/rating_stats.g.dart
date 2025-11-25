// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rating_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RatingStats _$RatingStatsFromJson(Map<String, dynamic> json) => RatingStats(
  averageRating: (json['averageRating'] as num).toDouble(),
  totalRatings: (json['totalRatings'] as num).toInt(),
);

Map<String, dynamic> _$RatingStatsToJson(RatingStats instance) =>
    <String, dynamic>{
      'averageRating': instance.averageRating,
      'totalRatings': instance.totalRatings,
    };
