// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gig_filters.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GigFilters _$GigFiltersFromJson(Map<String, dynamic> json) => GigFilters(
  city: json['city'] as String?,
  district: json['district'] as String?,
  minRate: (json['minRate'] as num?)?.toInt(),
  maxRate: (json['maxRate'] as num?)?.toInt(),
  dateStart: json['dateStart'] == null
      ? null
      : DateTime.parse(json['dateStart'] as String),
);

Map<String, dynamic> _$GigFiltersToJson(GigFilters instance) =>
    <String, dynamic>{
      'city': instance.city,
      'district': instance.district,
      'minRate': instance.minRate,
      'maxRate': instance.maxRate,
      'dateStart': instance.dateStart?.toIso8601String(),
    };
