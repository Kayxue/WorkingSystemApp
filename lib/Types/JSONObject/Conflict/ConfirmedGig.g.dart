// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ConfirmedGig.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConfirmedGig _$ConfirmedGigFromJson(Map<String, dynamic> json) => ConfirmedGig(
  gigId: json['gigId'] as String,
  title: json['title'] as String,
  dateStart: json['dateStart'] as String,
  dateEnd: json['dateEnd'] as String,
  timeStart: json['timeStart'] as String,
  timeEnd: json['timeEnd'] as String,
  hourlyRate: (json['hourlyRate'] as num).toInt(),
  employerName: json['employerName'] as String,
  city: json['city'] as String,
  district: json['district'] as String,
  address: json['address'] as String,
);

Map<String, dynamic> _$ConfirmedGigToJson(ConfirmedGig instance) =>
    <String, dynamic>{
      'gigId': instance.gigId,
      'title': instance.title,
      'dateStart': instance.dateStart,
      'dateEnd': instance.dateEnd,
      'timeStart': instance.timeStart,
      'timeEnd': instance.timeEnd,
      'hourlyRate': instance.hourlyRate,
      'employerName': instance.employerName,
      'city': instance.city,
      'district': instance.district,
      'address': instance.address,
    };
