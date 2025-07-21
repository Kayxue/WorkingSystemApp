// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Gigs.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Gigs _$GigsFromJson(Map<String, dynamic> json) => Gigs(
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  gigId: json['gigId'] as String,
  title: json['title'] as String,
  hourlyRate: json['hourlyRate'] as String,
  city: json['city'] as String,
  district: json['district'] as String,
);

Map<String, dynamic> _$GigsToJson(Gigs instance) => <String, dynamic>{
  'updatedAt': instance.updatedAt.toIso8601String(),
  'gigId': instance.gigId,
  'title': instance.title,
  'hourlyRate': instance.hourlyRate,
  'city': instance.city,
  'district': instance.district,
};
