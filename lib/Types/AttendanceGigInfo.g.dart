// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AttendanceGigInfo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceGigInfo _$AttendanceGigInfoFromJson(Map<String, dynamic> json) =>
    AttendanceGigInfo(
      gigId: json['gigId'] as String,
      title: json['title'] as String,
      timeStart: json['timeStart'] as String,
      timeEnd: json['timeEnd'] as String,
      city: json['city'] as String,
      district: json['district'] as String,
      address: json['address'] as String,
      checkedIn: json['checkedIn'] as bool,
      checkedOut: json['checkedOut'] as bool,
    );

Map<String, dynamic> _$AttendanceGigInfoToJson(AttendanceGigInfo instance) =>
    <String, dynamic>{
      'gigId': instance.gigId,
      'title': instance.title,
      'timeStart': instance.timeStart,
      'timeEnd': instance.timeEnd,
      'city': instance.city,
      'district': instance.district,
      'address': instance.address,
      'checkedIn': instance.checkedIn,
      'checkedOut': instance.checkedOut,
    };
