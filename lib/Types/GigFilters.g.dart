// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'GigFilters.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Gigfilters _$GigfiltersFromJson(Map<String, dynamic> json) => Gigfilters(
  city: json['city'] as String?,
  district: json['district'] as String?,
  minRate: (json['minRate'] as num?)?.toInt(),
  maxRate: (json['maxRate'] as num?)?.toInt(),
  dateStart: json['dateStart'] == null
      ? null
      : DateTime.parse(json['dateStart'] as String),
);

Map<String, dynamic> _$GigfiltersToJson(Gigfilters instance) =>
    <String, dynamic>{
      'city': instance.city,
      'district': instance.district,
      'minRate': instance.minRate,
      'maxRate': instance.maxRate,
      'dateStart': instance.dateStart?.toIso8601String(),
    };
