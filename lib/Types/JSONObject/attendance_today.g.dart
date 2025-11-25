// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_today.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceToday _$AttendanceTodayFromJson(Map<String, dynamic> json) =>
    AttendanceToday(
      date: json['date'] as String,
      jobs: (json['jobs'] as List<dynamic>)
          .map((e) => AttendanceGigInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$AttendanceTodayToJson(AttendanceToday instance) =>
    <String, dynamic>{
      'date': instance.date,
      'jobs': instance.jobs.map((e) => e.toJson()).toList(),
      'total': instance.total,
    };
