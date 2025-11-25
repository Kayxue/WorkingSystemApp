// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gig_return_for_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GigReturnForMessage _$GigReturnForMessageFromJson(Map<String, dynamic> json) =>
    GigReturnForMessage(
      gigId: json['gigId'] as String,
      employerId: json['employerId'] as String,
      title: json['title'] as String,
      dateStart: DateTime.parse(json['dateStart'] as String),
      dateEnd: DateTime.parse(json['dateEnd'] as String),
      timeStart: json['timeStart'] as String,
      timeEnd: json['timeEnd'] as String,
      city: json['city'] as String,
      district: json['district'] as String,
      address: json['address'] as String,
    );

Map<String, dynamic> _$GigReturnForMessageToJson(
  GigReturnForMessage instance,
) => <String, dynamic>{
  'gigId': instance.gigId,
  'employerId': instance.employerId,
  'title': instance.title,
  'dateStart': instance.dateStart.toIso8601String(),
  'dateEnd': instance.dateEnd.toIso8601String(),
  'timeStart': instance.timeStart,
  'timeEnd': instance.timeEnd,
  'city': instance.city,
  'district': instance.district,
  'address': instance.address,
};
